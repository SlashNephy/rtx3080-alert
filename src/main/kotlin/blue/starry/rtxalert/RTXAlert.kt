package blue.starry.rtxalert

import io.ktor.client.request.*
import io.ktor.http.*
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.joinAll
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import org.jsoup.Jsoup
import org.jsoup.nodes.Element

object RTXAlert {
    // 価格ページの URL をキーとする価格情報のキャッシュ
    private val cache = mutableMapOf<String, PriceData>()
    private val mutex = Mutex()

    suspend fun check() = coroutineScope {
        val html = RTXAlertHttpClient.get<String>(Env.PRICE_LIST_URL)
        val soup = Jsoup.parse(html)

        // キャッシュが空の場合, 初回起動として扱う (通知しない)
        val isFirstRun = mutex.withLock { cache.isEmpty() }

        soup.select("div#popupPos .itemCatWrap").map {
            launch {
                checkItem(it, isFirstRun)
            }
        }.joinAll()
    }

    private suspend fun checkItem(element: Element, isFirstRun: Boolean) {
        val data = PriceData(
            name = element.selectFirst(".itemCatName .name2line").text(),
            url = element.selectFirst(".itemphotoArea a").attr("href"),
            imgUrl = element.selectFirst(".itemphotoArea a img").attr("src"),
            maker = element.selectFirst(".itemCatName .maker").text(),
            price = element.selectFirst(".itemCatPrice .price").text()
                .removePrefix("¥")
                .replace(",", "")
                .toIntOrNull()
        )

        mutex.withLock {
            // 前回のデータ
            val previousData = cache[data.url]

            when {
                // 初回起動のとき
                isFirstRun -> {
                }
                // 前回のデータが存在しないとき
                previousData == null -> {
                    val embed = DiscordEmbed(
                        title = "✨ 新製品が登録されました！",
                        url = data.url,
                        description = data.name,
                        fields = listOf(
                            DiscordEmbed.Field(
                                name = "メーカー",
                                value = data.maker
                            ),
                            DiscordEmbed.Field(
                                name = "価格",
                                value = if (data.price != null) "¥${"%,d".format(data.price)}" else "未登録"
                            )
                        ),
                        image = DiscordEmbed.Image(
                            url = data.imgUrl
                        ),
                        footer = DiscordEmbed.Footer(
                            text = "価格.com",
                            iconUrl = "https://img1.kakaku.k-img.com/images/favicon/apple-touch-icon.png"
                        )
                    )

                    sendToDiscord(embed)
                }
                // 前回の価格と今回の価格が変動したとき
                previousData.price != null && data.price != null && previousData.price != data.price -> {
                    val embed = DiscordEmbed(
                        title = if (previousData.price < data.price) "😅 値上がりしました…" else "😎 値下がりしました！",
                        url = data.url,
                        description = data.name,
                        fields = listOf(
                            DiscordEmbed.Field(
                                name = "メーカー",
                                value = data.maker
                            ),
                            DiscordEmbed.Field(
                                name = "価格",
                                value = "¥${"%,d".format(data.price)} (${"%+".format(data.price - previousData.price)} 円)"
                            )
                        ),
                        image = DiscordEmbed.Image(
                            url = data.imgUrl
                        ),
                        footer = DiscordEmbed.Footer(
                            text = "価格.com",
                            iconUrl = "https://img1.kakaku.k-img.com/images/favicon/apple-touch-icon.png"
                        )
                    )

                    sendToDiscord(embed)
                }
                // 価格情報が消えたとき
                previousData.price != null && data.price == null -> {
                    val embed = DiscordEmbed(
                        title = "😱 在庫がなくなりました...",
                        url = data.url,
                        description = data.name,
                        fields = listOf(
                            DiscordEmbed.Field(
                                name = "メーカー",
                                value = data.maker
                            ),
                            DiscordEmbed.Field(
                                name = "最終価格",
                                value = "¥${"%,d".format(previousData.price)}"
                            )
                        ),
                        image = DiscordEmbed.Image(
                            url = data.imgUrl
                        ),
                        footer = DiscordEmbed.Footer(
                            text = "価格.com",
                            iconUrl = "https://img1.kakaku.k-img.com/images/favicon/apple-touch-icon.png"
                        )
                    )

                    sendToDiscord(embed)
                }
                // 価格情報が登録されたとき
                previousData.price == null && data.price != null -> {
                    val embed = DiscordEmbed(
                        title = "🤩 在庫が復活しました！",
                        url = data.url,
                        description = data.name,
                        fields = listOf(
                            DiscordEmbed.Field(
                                name = "メーカー",
                                value = data.maker
                            ),
                            DiscordEmbed.Field(
                                name = "価格",
                                value = "¥${"%,d".format(data.price)}"
                            )
                        ),
                        image = DiscordEmbed.Image(
                            url = data.imgUrl
                        ),
                        footer = DiscordEmbed.Footer(
                            text = "価格.com",
                            iconUrl = "https://img1.kakaku.k-img.com/images/favicon/apple-touch-icon.png"
                        )
                    )

                    sendToDiscord(embed)
                }
            }

            // キャッシュ更新
            cache[data.url] = data
        }
    }

    private suspend fun sendToDiscord(embed: DiscordEmbed) {
        logger.trace { embed }

        if (Env.DRYRUN) {
            return
        }

        RTXAlertHttpClient.post<Unit>(Env.DISCORD_WEBHOOK_URL) {
            contentType(ContentType.Application.Json)

            body = DiscordWebhookMessage(
                embeds = listOf(embed)
            )
        }
    }
}
