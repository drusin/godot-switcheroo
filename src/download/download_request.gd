class_name DownloadRequest
extends RefCounted

signal update(bytes_downloaded: int)
signal downloaded(result: ReqResult)

var _url: String


func _init(url: String) -> void:
	_url = url


func request() -> ReqResult:
	return await _request(func (): return _HTTPRequestInternal.new())


func _request(httpRequestCreator: Callable) -> ReqResult:
	var timer = Timer.new()
	Globals.root.add_child.call_deferred(timer)
	await timer.tree_entered
	var req: _HTTPRequestInternal = httpRequestCreator.call()
	Globals.root.add_child.call_deferred(req)
	await req.tree_entered

	req.request(_url)
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


class _HTTPRequestInternal extends Node:
## Facade over [HTTPRequest] for testability/mocking

	signal request_completed(result: int, status_code: int, headers: PackedStringArray, body: PackedByteArray)

	var _httpRequest: HTTPRequest

	func _enter_tree() -> void:
		_httpRequest = HTTPRequest.new()
		get_tree().get_root().add_child(_httpRequest)


	func _exit_tree() -> void:
		_httpRequest.queue_free()


	func get_downloaded_bytes() -> int:
		return _httpRequest.get_downloaded_bytes()


	func _emit_req_completed(result: int, status_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
		request_completed.emit(result, status_code, headers, body)


	func request(url: String) -> int:
		_httpRequest.request_completed.connect(_emit_req_completed)
		return _httpRequest.request(url)
