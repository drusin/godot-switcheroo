extends GdUnitTestSuite

var mockHTTPRequest: DownloadRequest._HTTPRequestInternal


func before_test() -> void:
	mockHTTPRequest = mock(DownloadRequest._HTTPRequestInternal)


func test_updates() -> void:
	var dl_req := DownloadRequest.new(get_tree().get_root())
	dl_req._request("test", func (): return mockHTTPRequest)

	var update = await dl_req.update
	assert_int(update).is_equal(0)

	do_return(20).on(mockHTTPRequest).get_downloaded_bytes()
	update = await dl_req.update
	assert_int(update).is_equal(20)

	# emit completed signal, so stuff will be cleaned up/freed
	mockHTTPRequest.request_completed.emit(0, 0, PackedStringArray(), PackedByteArray())
