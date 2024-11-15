class_name Preferences
extends Object

static var test: int:
    get:
        return _values.get("test", 1)

static var _values := {}


class DeeperPrefs extends Object:
    static var deeper_test: int:
        get:
            return Preferences._values.get("deeper.test", 1)
