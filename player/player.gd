extends KinematicBody

var camera_angle = 0
const fwd_move_speed = 8
const side_move_speed = 8
const rot_speed = 1

#camera horizontal rotation limit about y azix
const h_camera_limit_left = 200 #degree
const h_camera_limit_right = -200 #degree

#camera vertical rotation limit about x axis
const v_camera_limit_up = 90 #degree
const v_camera_limit_down = -20 #degree

var f = Vector3.FORWARD
var left
var right
var up
var down
var v = Vector3()
var move_dir = Vector3.FORWARD

var jump_time = .6
var jump_speed
var jump_height = 5
var g 

var on_ground = false
# Called when the node enters the scene tree for the first time.
var mouse_sensitivity = .3
var camera_anglev=0

var last_event_pos_x
var camera_change = Vector2()
func _ready():
	g = 2*jump_height/pow(jump_time,2)
	jump_speed = g*jump_time
	$Camera.current = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
#mouse input for camera rotation
func _input(event): 
	
	if event is InputEventMouseMotion:
		camera_change = event.relative
		#last_event_pos_x = event.position.x		
		
		#var angles = cam_angles(h_camera_limit_left,h_camera_limit_right,v_camera_limit_up,v_camera_limit_down,event.position)
		
		
		#self.rotate_y(deg2rad(-event.relative.x*mouse_sens))
		#self.rotation_degrees.y = angles.y
		
		
		#$Camera.rotation_degrees.x = angles.x
		
		#var changev=-event.relative.y*mouse_sens
		#if camera_anglev+changev>-50 and camera_anglev+changev<50:
			#camera_anglev+=changev
			#$Camera.rotate_x(deg2rad(changev))
		#$Camera.rotate_x(deg2rad(-event.relative.y*.15))
		
		#print(angles)
func _physics_process(delta):
	#when within the limits
	if camera_change.length() > 0:
		self.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))
		move_dir = Vector3.FORWARD.rotated(Vector3.UP,self.rotation.y)
		var change = -camera_change.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Camera.rotate_x(deg2rad(change))
			camera_angle += change
		camera_change = Vector2()
		
	on_ground = $RayCast.is_colliding()
	left = Input.is_action_pressed("ui_left")
	right = Input.is_action_pressed("ui_right")
	up = Input.is_action_pressed("ui_up")
	down = Input.is_action_pressed("ui_down")
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	#ROTATION OUT SIDE LIMIT
	#when left of left_limit
	#if last_event_pos_x < get_viewport().size.x*.1:
		#self.rotate_y(deg2rad(3))
	#when right of right_limit
	#elif last_event_pos_x > get_viewport().size.x*.9:
		#self.rotate_y(deg2rad(-3))
	
	if left:
		v.x= side_move_speed*(move_dir.rotated(Vector3.UP,deg2rad(90))).x
		v.z= side_move_speed*(move_dir.rotated(Vector3.UP,deg2rad(90))).z
		
		#self.rotate(Vector3(0,1,0),deg2rad(rot_speed))
		#move_dir = Vector3.FORWARD.rotated(Vector3.UP,self.rotation.y)#move_dir.rotated(Vector3(0,1,0),deg2rad(rot_speed))
		#move_dir = move_dir.rotated(Vector3.UP,deg2rad(rot_speed))
	
	elif right:
		v.x= side_move_speed*(move_dir.rotated(Vector3.UP,deg2rad(-90))).x
		v.z= side_move_speed*(move_dir.rotated(Vector3.UP,deg2rad(-90))).z
		
		#self.rotate(Vector3(0,1,0),deg2rad(-rot_speed))
		#move_dir = Vector3.FORWARD.rotated(Vector3.UP,self.rotation.y)#move_dir.rotated(Vector3(0,1,0),deg2rad(rot_speed))
		#move_dir = move_dir.rotated(Vector3.UP,deg2rad(-rot_speed))
		
	
	elif up:
		v.x= fwd_move_speed*move_dir.x
		v.z= fwd_move_speed*move_dir.z
		
	elif down:
		v.x= -fwd_move_speed*move_dir.x
		v.z= -fwd_move_speed*move_dir.z
		
	else:
		if on_ground:
			v = Vector3()
		
	if on_ground and Input.is_action_just_pressed("ui_accept"):
		v.y = jump_speed
		
	v.y -=g*delta
	v=move_and_slide(v,Vector3.UP)
	
#calculate camera x and y rotation based on it rotation limit and mouse position
func cam_angles(h_limit_l,h_limit_r,v_limit_up,v_limit_down,mouse_pos):
	var H = get_viewport().size.x
	var V = get_viewport().size.y
	
	var h_angle_per_unit_length = (h_limit_r - h_limit_l)/H
	var v_angle_per_unit_length = (v_limit_up - v_limit_down)/V
	
	var x_rot = -mouse_pos.y*v_angle_per_unit_length + v_limit_up 
	var y_rot = mouse_pos.x*h_angle_per_unit_length + h_limit_l
	
	return {x=x_rot,y=y_rot}
