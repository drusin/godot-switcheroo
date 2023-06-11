class_name Comparators
extends RefCounted

enum {
	NUMBER,
	STR_CASE,
	STR_NO_CASE,
	STR_NATURAL_NO_CASE,
}

var _comparators := [
	func (left, right) -> int:
		return left - right,
	
	func (left: String, right: String) -> int:
		return left.casecmp_to(right),
	
	func (left: String, right: String) -> int:
		return left.nocasecmp_to(right),
	
	func (left: String, right: String) -> int:
		return left.naturalnocasecmp_to(right)
]

static func which(which: int) -> Callable:
	var comparators = Comparators.new()
	return comparators._comparators[which]

