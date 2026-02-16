extends Node

var items: Array[ItemData] = []

func add_item(item: ItemData):
	items.append(item)
	
func remove_item(item: ItemData):
	if items.has(item):
		items.erase(item)
