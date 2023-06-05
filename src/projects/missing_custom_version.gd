class_name MissingCustomVersion
extends Window

signal select_new_version()
signal locate_custom_version()


func _on_select_pressed():
	emit_signal("select_new_version")
	hide()


func _on_locate_pressed():
	emit_signal("locate_custom_version")
	hide()


func _on_cancel_pressed():
	hide()
