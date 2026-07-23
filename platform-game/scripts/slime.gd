extends CharacterBody2D

var direction = 1

@export var speed: float = 30
@export  var slime_health: int = 20
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var killzone_shape: CollisionShape2D = $Killzone/killzoneShape
@onready var damage_zone_shape: CollisionShape2D = $DamageZone/DamageZoneShape
@onready var laser_hit_box: CollisionShape2D = $LaserHitBox/laserHitBox
var is_dormant: bool = false

func _ready() -> void:
	pass

func set_dormant(dormant: bool) -> void:
	is_dormant = dormant
	collision_shape_2d.disabled = dormant
	killzone_shape.disabled = dormant
	damage_zone_shape.disabled = dormant
	laser_hit_box.disabled = dormant
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_dormant:
		return
		
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	velocity.x = direction * speed
		
	move_and_slide()

func take_damage(amount: int) -> void:
	slime_health = max(slime_health - amount, 0)
	if slime_health <= 0:
		animated_sprite.play("slime_death")
		get_node("Killzone").queue_free()
		get_node("DamageZone").queue_free()
		get_node("LaserHitBox").queue_free()
		timer.wait_time = 0.5
		timer.start()


func _on_timer_timeout() -> void:
	queue_free()
