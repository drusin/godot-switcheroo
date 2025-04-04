extends GdUnitTestSuite


func before_test() -> void:
	Globals.root = get_tree().get_root()


func test_percentage_calc() -> void:
	var downloader: GodotDownloader = monitor_signals(GodotDownloader.new())
	var update_listener_1 := downloader._create_update_listener("test", 50)
	var update_listener_2 := downloader._create_update_listener("test2", 50)
	update_listener_1.call(10)
	update_listener_2.call(20)
	await assert_signal(downloader).is_emitted("update", [2, 30])
