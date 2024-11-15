extends GdUnitTestSuite

const TEST_FILE_NAME := "Godot_v4.3-stable_win64.exe"

func before() -> void:
    DirAccess.remove_absolute("./target/" + TEST_FILE_NAME)


@warning_ignore('unused_parameter')
func test_download(do_skip = true, skip_reason = "Takes too long") -> void:
    var downloader := GodotDownloader.new(get_tree())

    var metadata := GodotDownloadMetadata.new()
    metadata.name = TEST_FILE_NAME + ".zip"
    metadata.size = 57381972
    metadata.browser_download_url = "https://github.com/godotengine/godot-builds/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip"

    downloader.download("4.3", metadata, "target")
    await downloader.downloaded

    assert_file("target/" + TEST_FILE_NAME).exists()
