extends Node3D

func _physics_process(_delta: float) -> void:
	$FloatingCubes/StaticBody3D2.rotate_y(0.01)
	$FloatingCubes/StaticBody3D3.rotate_y(-0.01)
	$FloatingCubes/StaticBody3D4.rotate_y(0.01)
