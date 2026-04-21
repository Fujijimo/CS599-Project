class_name Accessory
extends Node3D

const DEFAULT_DATA: Resource = preload("res://golf/assets/accessories/accessory.tres")

@export var data = DEFAULT_DATA.duplicate()
