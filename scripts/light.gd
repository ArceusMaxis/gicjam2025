extends Area3D

var first : bool = true

func _on_body_entered(body: Node3D) -> void:
	if first:
		if body.is_in_group("player"):
			first = false
			body.new_match()
			Global.extra_matches += 1
			print(Global.extra_matches)
			$matchbox.visible = false

func _ready() -> void:
	$matchbox.rotation_degrees.y = randi_range(0,360)
