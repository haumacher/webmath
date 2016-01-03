shared interface DisplayMode of editing | disabled | displaying | hidden {}

object editing satisfies DisplayMode {}
object disabled satisfies DisplayMode {}
object displaying satisfies DisplayMode {}
object hidden satisfies DisplayMode {}
