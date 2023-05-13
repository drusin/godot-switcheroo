extends Node

const URL := "https://downloads.tuxfamily.org/godotengine/"
var request := HTTPRequest.new()


func _ready() -> void:
	get_tree().get_root().add_child.call_deferred(request)
	request.tree_entered.connect(_test_await)
#	request.tree_entered.connect(func(): request.request(URL))
#	request.request_completed.connect(_on_request_completed)


func _test_await() -> void:
	request.request(URL)
	var result := ((await request.request_completed)[-1] as PackedByteArray).get_string_from_utf8()
	print(result)


func _on_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print(body.get_string_from_utf8())
