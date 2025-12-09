extends ColorRect

@export var virtual_res_y: float
@onready var shader_material := material as ShaderMaterial

func _process(_delta: float) -> void:
	var viewport_res := get_viewport().get_visible_rect().size
	var new_virtual_res := Vector2((viewport_res.x / viewport_res.y) * virtual_res_y, virtual_res_y)
	shader_material.set_shader_parameter("viewport_res", viewport_res)
	shader_material.set_shader_parameter("virtual_res", new_virtual_res)
