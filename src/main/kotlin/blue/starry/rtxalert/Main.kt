package blue.starry.rtxalert

import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import mu.KotlinLogging
import kotlin.time.Duration.Companion.seconds
import kotlin.time.ExperimentalTime
import kotlin.time.measureTime

val logger = KotlinLogging.logger("rtxalert")

@OptIn(ExperimentalTime::class)
suspend fun main(): Unit = coroutineScope {
    while (true) {
        val taken = measureTime {
            try {
                RTXAlert.check()
            } catch (t: Throwable) {
                logger.error(t) { "Error occurred while checking." }
            }
        }
        logger.trace { "Checking finished in $taken." }

        delay(Env.INTERVAL_SECONDS.seconds)
    }
}
