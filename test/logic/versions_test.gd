extends GdUnitTestSuite

var versions: Versions
var mock_api_gateway: ApiGateway


func before_test() -> void:
    versions = Versions.new()
    mock_api_gateway = mock(ApiGateway)
    versions._api_gateway = mock_api_gateway


func test_get_available_versions_combines_local_and_remote() -> void:
    var local_version_name := "local_version"
    var local_version := GodotVersion.simple(local_version_name)
    versions._versions[local_version_name] = local_version

    var remote_version_name := "remote_version_name"
    var remote_version := GodotVersion.simple(remote_version_name)
    do_return({ remote_version_name = "remote address" }).on(mock_api_gateway).get_available_versions()

    var result := await versions.get_available_versions()
    assert_array(result).contains_exactly_in_any_order([local_version, remote_version])
