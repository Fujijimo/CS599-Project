extends Node

signal item_pick_up
var items: Array[Item] = []

func add_item(item: Item):
	items.append(item)
	
func remove_item(item: Item):
	if items.has(item):
		items.erase(item)
