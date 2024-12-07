extends GdUnitTestSuite


func before_test() -> void:
    Globals.root = get_tree().get_root()


func test_percentage_calc() -> void:
    var downloader: GodotDownloader = monitor_signals(GodotDownloader.new())
    var update_listener := downloader._create_update_listener("test", 50)
    update_listener.call(10)
    await assert_signal(downloader).is_emitted("update", ["test", 20])
