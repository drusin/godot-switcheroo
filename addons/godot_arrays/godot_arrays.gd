class_name Arrays
extends Object

enum {
	ASC = 1,
	DESC = -1
}


func _init():
	push_error("This class is not meant for instanncing, use the static functions instead")


static func sort(input: Array, comparator: Callable, direction := ASC) -> void:
	_insertion_sort(input, comparator, direction)


static func _insertion_sort(input: Array, comparator: Callable, direction: int) -> void:
	if input.size() < 2:
		return
	for i in range(1, input.size()):
		var value = input[i]
		var j := i
		while (j > 0 and comparator.call(value, input[j -1]) * direction < 0):
			j -= 1
		input.insert(j, input.pop_at(i))
