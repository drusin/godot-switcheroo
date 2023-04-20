extends ScrollContainer
class_name SelectablesList

signal selection_changed(selection: Array)

@export var _dummy_items_count := 0

@onready var Selectables: VBoxContainer = $Selectables
@onready var ListItemScene := preload("res://src/general/list_item.tscn")

var last_selected_index := -1


func _ready() -> void:
	var dummy_items = []
	for i in range(0, _dummy_items_count):
		dummy_items.append(ListItemScene.instantiate())
	set_content(dummy_items)


func set_content(items: Array) -> void:
	last_selected_index = -1
	for child in Selectables.get_children():
		child.queue_free()
	for item in items:
		var list_item := item as ListItem
		list_item.selected_changed.connect(_item_selected_behaviour(list_item))
		Selectables.add_child(list_item)


func get_items() -> Array:
	return Selectables.get_children()


func get_selected_items() -> Array:
	return Selectables.get_children().filter(func (item: ListItem): return item.is_selected)


func _update_last_selected(item: ListItem) -> void:
	last_selected_index = Selectables.get_children().find(item)


func _send_selection_signal() -> void:
	emit_signal("selection_changed", get_selected_items())


func _item_selected_behaviour(item: ListItem) -> Callable:
	return func (selected: bool) -> void:
		if Input.is_key_pressed(KEY_CTRL):
			_update_last_selected(item)
		elif Input.is_key_pressed(KEY_SHIFT):
			_select_projects_between(item, selected)
		else:
			_select_single_line(item, selected)
			_update_last_selected(item)
		_send_selection_signal()


func _select_projects_between(item: ListItem, selected: bool) -> void:
	if not selected:
		item.is_selected = true
		return
	var items := Selectables.get_children()
	var item_index := items.find(item)
	var first := item_index
	var last := item_index
	if last_selected_index < 0:
		first = 0
		if first == last:
			_update_last_selected(item)
			return
	else:
		if item_index < last_selected_index:
			last = last_selected_index
		else:
			first = last_selected_index

	for i in range(0, items.size()):
		items[i].is_selected = i >= first && i <= last


func _select_single_line(item: ListItem, selected: bool) -> void:
	if get_selected_items().size() > 1 and not selected:
		item.is_selected = true
	for child in Selectables.get_children():
		if child != item:
			child.is_selected = false
