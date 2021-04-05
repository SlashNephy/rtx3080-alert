package blue.starry.rtxalert

import io.ktor.client.*
import io.ktor.client.features.*
import io.ktor.client.features.json.*
import io.ktor.client.features.json.serializer.*
import io.ktor.http.*

val RTXAlertHttpClient = HttpClient {
    install(JsonFeature) {
        serializer = KotlinxSerializer()
    }

    defaultRequest {
        userAgent("rtxalert (+https://github.com/SlashNephy/rtx3080-alert)")
    }
}
