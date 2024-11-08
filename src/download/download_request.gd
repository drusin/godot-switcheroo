class_name DownloadRequest
extends RefCounted

signal update(bytes_downloaded: int)
signal downloaded(result: ReqResult)

var _tree: SceneTree


func _init(tree: SceneTree) -> void:
	_tree = tree


func request(url: String) -> ReqResult:
	var timer = Timer.new()
	_tree.get_root().add_child.call_deferred(timer)
	await timer.tree_entered
	var req = HTTPRequest.new()
	_tree.get_root().add_child.call_deferred(req)
	await req.tree_entered
	req.request(url)
	timer.timeout.connect(func (): update.emit(req.get_downloaded_bytes()))
	timer.start()
	var results: Array = await req.request_completed
	timer.stop()
	timer.queue_free()
	req.queue_free()
	var reqResult: = ReqResult.new(results)
	downloaded.emit(reqResult)
	return reqResult


class ReqResult extends RefCounted:
	var result: int
	var status_code: int
	var headers: PackedStringArray
	var body: PackedByteArray

	func _init(from: Array) -> void:
		result = from[0]
		status_code = from[1]
		headers = from[2]
		body = from[3]
