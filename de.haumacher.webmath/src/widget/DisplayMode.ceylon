shared interface DisplayMode of enabled | disabled | displaying | hidden {}

object enabled satisfies DisplayMode {}
object disabled satisfies DisplayMode {}
object displaying satisfies DisplayMode {}
object hidden satisfies DisplayMode {}
