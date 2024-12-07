extends Label

var selected := 0:
	set(new_val):
		selected = new_val
		update_text()

var amount := 0:
	set(new_val):
		amount = new_val
		update_text()


func _ready() -> void:
	SIGNALS.selected_amount_changed.connect(func (val): selected = val)
	SIGNALS.list_amount_changed.connect(func (val): amount = val)


func update_text() -> void:
	text = "Selected: " + str(selected) + "/" + str(amount)
