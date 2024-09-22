extends Area3D

@export var knockback_force: float

func _on_body_entered(body):
	if body.has_method("knockback"):
		print(body.name,  " has knockback")
		var k = Knockback.new()
		k.knockback_origin = global_transform.origin
		k.knockback_force = knockback_force
		body.knockback(k);
	else:
		print(body.name,  " doesn't have knockback")
