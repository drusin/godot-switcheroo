extends ConfirmationDialog

@export var path := "":
	set(new_val):
		path = new_val
		if PathEdit:
			PathEdit.text = new_val

@export var version := "":
	set(new_val):
		version = new_val
		if NameEdit:
			NameEdit.text = new_val

@export var custom_name := "":
	set(new_val):
		custom_name = new_val
		if NameEdit:
			NameEdit.text = new_val

@onready var PathEdit: LineEdit = $Content/Path/PathEdit
@onready var VersionEdit: LineEdit = $Content/Version/VersionEdit
@onready var NameEdit: LineEdit = $Content/CustomName/NameEdit
