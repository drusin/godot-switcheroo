class_name SelectablesList
extends ScrollContainer

@export var _dummy_items_count := 0

@onready var Selectables: VBoxContainer = $Selectables

var last_selected_index := -1


func _ready() -> void:
	if _dummy_items_count == 0:
		_on_visibility_changed.call_deferred()
		return
	var ListItemScene = load("res://src/general/list_item.tscn")
	var dummy_items = []
	for i in range(0, _dummy_items_count):
		dummy_items.append(ListItemScene.instantiate())
	set_content(dummy_items)


func set_content(items: Array) -> void:
	last_selected_index = -1
	for child in Selectables.get_children():
		child.is_selected = false
		Selectables.remove_child(child)
		child.queue_free()
	for item in items:
		var list_item := item as ListItem
		list_item.selected_changed.connect(_item_selected_behaviour(list_item))
		Selectables.add_child(list_item)
	
	if visible:
		SIGNALS.list_amount_changed.emit(items.size())


func get_items() -> Array:
	return Selectables.get_children() if Selectables else []


func get_selected_items() -> Array:
	return get_items() \
			.filter(func (item: ListItem): return item.visible) \
			.filter(func (item: ListItem): return item.is_selected)


func sort_items(comparator: Callable) -> void:
	var sorted := Selectables.get_children()
	Arrays.sort(sorted, comparator)
	for child in Selectables.get_children():
		Selectables.remove_child(child)
	for child in sorted:
		Selectables.add_child(child)


func _update_last_selected(item: ListItem) -> void:
	last_selected_index = Selectables.get_children().find(item)


func _send_selection_signal() -> void:
	SIGNALS.selected_amount_changed.emit(get_selected_items().size())


func _item_selected_behaviour(item: ListItem) -> Callable:
	return func (selected: bool) -> void:
		if Input.is_key_pressed(KEY_CTRL):
			_update_last_selected(item)
		elif Input.is_key_pressed(KEY_SHIFT):
			_select_projects_between(item, selected)
		else:
			_select_single_line(item, selected)
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
	else:
		if item_index < last_selected_index:
			last = last_selected_index
		else:
			first = last_selected_index

	for i in range(0, items.size()):
		items[i].is_selected = i >= first && i <= last


func _select_single_line(item: ListItem, selected: bool) -> void:
	_update_last_selected(item)
	if not selected:
		if get_selected_items().size() > 0:
			item.is_selected = true
		else:
			last_selected_index = -1
	for child in Selectables.get_children():
		if child != item:
			child.is_selected = false


func _on_visibility_changed():
	if is_visible_in_tree():
		SIGNALS.list_amount_changed.emit(get_items().size())
		SIGNALS.selected_amount_changed.emit(get_selected_items().size())
