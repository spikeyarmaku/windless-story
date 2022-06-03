extends Sprite

var _fly_speed : float # Change stances every 3 seconds
var _lift_speed : float
var _fly_time : float = 0
var _lift_time : float = 0
var _lift = 1

# Called when the node enters the scene tree for the first time.
func _ready():
    _fly_speed = rand_range(0.4, 0.6)
    _lift_speed = rand_range(0.8, 1.2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    _fly_time += delta
    _lift_time += delta
    if _fly_time > _fly_speed:
        _fly_time -= _fly_speed
        flip_v = not flip_v
    if _lift_time > _lift_speed:
        _lift_time -= _lift_speed
        _lift = -_lift
        position.y += _lift
