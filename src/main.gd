extends Control

@onready var Bottom := $Content/Bottom


func _ready() -> void:
	OS.low_processor_usage_mode = true


func _on_tabs_tab_changed(tab: int) -> void:
	for child in Bottom.get_children():
		if not "index" in child:
			continue
		child.visible = tab == child.index
