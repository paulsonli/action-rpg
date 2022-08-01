extends KinematicBody2D

const PlayerHurtSound = preload("res://Music and Sounds/PlayerHurtSound.tscn")

export var ACCELERATION = 1000
export var MAX_SPEED = 100
export var FRICTION = 1000
export var ROLL_SPEED =  120
export var IFRAME_TIME = .8#seconds
export var ROLL_IFRAME_TIME = .3 # roll frame is .5 sec

enum {
	MOVE,
	ROLL ,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var invulnerable_is_on = false


onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	$HitboxPivot/SwordHitbox/CollisionShape2D.set_deferred('disabled', true)
	#swordHitbox.knockback_vector = roll_vector
	
func set_spawn(location, direction):
	animationTree.set("parameters/Idle/blend_position", direction)
	position = location

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
			
		ROLL:
			roll_state()
			
		ATTACK:
			attack_state()


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector) #do animation in the facing position
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector) 
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) #friction, player stops when no key input
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("invulnerable"):
		if invulnerable_is_on == false:
			invulnerable()
			invulnerable_is_on = true
			print("invulnerable on")
		else:
			not_invulnerable()
			invulnerable_is_on = false
			print("invulnerable off")
		
	
		
func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func move():
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	velocity = velocity / 2
	state = MOVE

func roll_animation_start():
	hurtbox.start_invincibility(ROLL_IFRAME_TIME)

func attack_animation_finished():
	state = MOVE

func _on_Hurtbox_area_entered(area):
	if hurtbox.invincible == false:
		stats.health -= area.damage
		hurtbox.start_invincibility(IFRAME_TIME)
		hurtbox.create_hit_effect()	
		
		var playerHurtSound = PlayerHurtSound.instance()
		get_tree().current_scene.add_child(playerHurtSound)

func invulnerable():
	hurtbox.set_collision_layer_bit(6, true)
	hurtbox.set_collision_layer_bit(2, false)
	
func not_invulnerable():
	hurtbox.set_collision_layer_bit(6, false)
	hurtbox.set_collision_layer_bit(2, true)

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
