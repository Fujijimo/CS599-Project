extends Node

var items: Array[Item] = []

func add_item(item: ItemData):
	items.append(item)
	
func remove_item(item: ItemData):
	if items.has(item):
		items.erase(item)
