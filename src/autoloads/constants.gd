extends Node

const DOWNLOADING := "DOWNLOADING"
const DOWNLOAD_TIMER_UPDATE := 1
# ballpark Godot download sizes for percentage calculation 
const DOWNLOADS_SIZES := {
	"1": 10_000_000,
	"2": 20_000_000,
	"3": 70_000_000,
	"4": 60_000_000,
}
const PROJECT_FILE_NAME := "project.godot"
