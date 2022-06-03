extends Node2D

export var _speed : float = 2.0 # how many pixels does the game advance in a second

var _time : float = 0
var _tick : int = 0
var _elapsed_time : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    $Tuuleton.connect("eat", self, "_on_tuuleton_eat")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    _time += delta
    _elapsed_time += delta
    if _time > 1.0/(_speed * 16.0):
        $Level.advance()
        _time -= 1.0/(_speed * 16.0)
        _tick += 1
    if _tick == 16:
        _tick = 0
        $Tuuleton.on_step()
        $Level.on_step(1.0 / _speed)
        
    if _elapsed_time > 344:
        $FadeOut/AnimationPlayer.play("FadeOut")
    if _elapsed_time > 346:
        get_tree().change_scene("res://Scenes/Menu.tscn")

func _on_tuuleton_eat(food):
    $Level.remove_food(food)
