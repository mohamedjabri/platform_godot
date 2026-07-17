extends CharacterBody2D


const JUMP_VELOCITY = -300.0
const max_health = 100
var jump_counter = 0
var current_health: int = 100
var is_hurt: bool = false
var coyote_timer_activated = false
var has_key = false
var shot_fired: bool = false
var can_control: bool = true

@export var current_speed: int = 130
@export var jump_damage: int = 50
@export var laser_scene: PackedScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var health_bar: ProgressBar = %HealthBar
@onready var healing_amount: AnimationPlayer = $HealingAmountAnimation
@onready var healing_label: Label = $HealingLabel
@onready var camera_2d: Camera2D = $Camera2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var shoot_timer: Timer = $shootTimer
@onready var death_animation: AnimationPlayer = %DeathAnimation

func _ready():
	update_health_bar_color()
	has_key = SaveManager.is_key_collected()
	
func play_intro(from_position: Vector2, walk_distance: float, duration: float = 1.2) -> void:
	can_control = false
	global_position = from_position
	animated_sprite.play("run")
	var target := from_position + Vector2(walk_distance, 0)
	var tween := create_tween()
	tween.tween_property(self, "global_position", target, duration)
	await tween.finished
	animated_sprite.play("idle")
	can_control = true

func update_health_bar_color() -> void:
	var new_style = StyleBoxFlat.new()
	var health_ratio = float(current_health) / float(max_health)
	new_style.bg_color = Color.RED.lerp(Color(0.0, 0.568, 0.04, 1.0), health_ratio)
	new_style.set_corner_radius_all(12)
	health_bar.add_theme_stylebox_override("fill", new_style)
	
func take_damage(amount: int, run_damage_animation: bool = false) -> void:
	current_health = max(current_health - amount, 0)
	health_bar.value = current_health
	update_health_bar_color()
	if run_damage_animation:
		hurt_sound.play()
		is_hurt = true
		animated_sprite.play("damage")
		camera_2d.apply_shake(round((amount/10)))
		await get_tree().create_timer(0.3).timeout
		is_hurt = false
		
	if current_health <= 0:
		Music.stop()
		DeathMusic.play()
		death_animation.play("youdied")
		get_node("CollisionShape2D").queue_free()
		await death_animation.animation_finished
		SaveManager.respawn()
		
		
func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_bar.value = current_health
	update_health_bar_color()
	healing_amount.play("healing_amount")
	healing_label.text = "+ " + str(amount) + " hp"

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor():
		coyote_timer.start()
		jump_counter = 0

	var can_first_jump = is_on_floor() or (jump_counter == 0 and coyote_timer.time_left > 0)
	var can_double_jump = jump_counter == 1

	if Input.is_action_just_pressed("jump") and (can_first_jump or can_double_jump) and can_control:
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
		jump_counter += 1

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction == -1:
		animated_sprite.flip_h = true
	if direction == 1:
		animated_sprite.flip_h = false
		
	if is_hurt == false:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		elif jump_counter==1:
			animated_sprite.play("jump")
		elif jump_counter==2:
			animated_sprite.play("double_jump")
		else:
			animated_sprite.play("idle")
			
	if can_control:
		if direction:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()
	if Input.is_action_just_pressed("shoot") and can_control:
		if shot_fired == false:
			shot_fired = true
			shoot_timer.start()
			var laser = laser_scene.instantiate()
			laser.direction = -1 if animated_sprite.flip_h else 1
			laser.global_position = global_position + Vector2(10 * laser.direction, -7) 
			laser.scale = Vector2(0.3, 0.3)
			laser.z_index = 1
			get_tree().current_scene.add_child(laser)
	
func apply_save_data(data: Dictionary) -> void:
	var pos = data.get("position")
	if pos != null:
		global_position = Vector2(pos[0], pos[1])

	var health = data.get("health")
	if health != null:
		current_health = health
		health_bar.value = current_health
		update_health_bar_color()


func _on_shoot_timer_timeout() -> void:
	shot_fired = false
