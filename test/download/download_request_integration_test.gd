extends GdUnitTestSuite

const TEST_FILE_ADDRESS := "http://127.0.0.1:9615/testfile.txt"
const NODE_PROJECT_PATH := "res://test/download/webserver/"

var pid: int

func before() -> void:
	var exec: String
	var param: String
	if (OS.get_name() == "Windows"):
		exec = "powershell.exe"
		param = "-Command"
	else:
		exec = "sh"
		param = "-c"
	pid = OS.create_process(exec, [param, "npm", "start", "--prefix", ProjectSettings.globalize_path(NODE_PROJECT_PATH)])


func before_test() -> void:
	Globals.root = get_tree().get_root()


func test_download_return() -> void:
	var req := DownloadRequest.new(TEST_FILE_ADDRESS)
	var result := await req.request()
	assert_str(result.body.get_string_from_utf8()).is_equal("This is a download test file.")
	assert_int(result.status_code).is_equal(200)


func test_downloaded_signal() -> void:
	var req := DownloadRequest.new(TEST_FILE_ADDRESS)
	req.request()
	var result: DownloadRequest.ReqResult = await req.downloaded
	assert_str(result.body.get_string_from_utf8()).is_equal("This is a download test file.")
	assert_int(result.status_code).is_equal(200)


func after() -> void:
	OS.kill(pid)
