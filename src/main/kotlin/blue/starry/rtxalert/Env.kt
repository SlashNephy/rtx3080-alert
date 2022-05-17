package blue.starry.rtxalert

import kotlin.properties.ReadOnlyProperty

object Env {
    val PRICE_LIST_URL by string { "https://kakaku.com/pc/videocard/itemlist.aspx?pdf_Spec103=480&pdf_Spec104=12&pdf_ob=0&pdf_vi=c" }
    val INTERVAL_SECONDS by long { 180 }
    val DISCORD_WEBHOOK_URL by string

    val DRYRUN by boolean
}

private val string: ReadOnlyProperty<Env, String>
    get() = ReadOnlyProperty { _, property ->
        System.getenv(property.name) ?: error("Env: ${property.name} is not present.")
    }

private fun string(default: () -> String) = ReadOnlyProperty<Env, String> { _, property ->
    System.getenv(property.name) ?: default()
}

private fun long(default: () -> Long) = ReadOnlyProperty<Env, Long> { _, property ->
    System.getenv(property.name)?.toLongOrNull() ?: default()
}

private fun String?.toBooleanFazzy(): Boolean {
    return when (this) {
        null -> false
        "1", "yes" -> true
        else -> lowercase().toBoolean()
    }
}

private val boolean: ReadOnlyProperty<Env, Boolean>
    get() = ReadOnlyProperty { _, property ->
        System.getenv(property.name).toBooleanFazzy()
    }
