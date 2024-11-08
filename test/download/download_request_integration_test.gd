extends GdUnitTestSuite

const TEST_FILE_ADDRESS := "http://127.0.0.1:9615/testfile.txt"
const NODE_PROJECT_PATH := "res://test/download/webserver/"

var pid: int

func before() -> void:
	pid = OS.create_process("powershell.exe", ["-Command", "npm", "start", "--prefix", ProjectSettings.globalize_path(NODE_PROJECT_PATH)])


func test_download_return() -> void:
	var req := DownloadRequest.new(get_tree())
	var result := await req.request(TEST_FILE_ADDRESS)
	assert_str(result.body.get_string_from_utf8()).is_equal("This is a download test file.")
	assert_int(result.status_code).is_equal(200)


func test_downloaded_signal() -> void:
	var req := DownloadRequest.new(get_tree())
	req.request(TEST_FILE_ADDRESS)
	var result: DownloadRequest.ReqResult = await req.downloaded
	assert_str(result.body.get_string_from_utf8()).is_equal("This is a download test file.")
	assert_int(result.status_code).is_equal(200)


func after() -> void:
	OS.kill(pid)
