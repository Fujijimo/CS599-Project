extends Resource
class_name ItemData

@export var name: String = ""
@export_multiline var basic_description: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var texture: Texture2D
@export var mesh: Mesh
@export var collision: Shape3D
@export var marker_height: float = 1.0
