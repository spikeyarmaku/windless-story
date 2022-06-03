extends Sprite

const State1 = preload("res://Assets/FoodIcon/food_icon.png")
const State2 = preload("res://Assets/FoodIcon/food_icon_half.png")
const State3 = preload("res://Assets/FoodIcon/food_icon_full.png")

# Called when the node enters the scene tree for the first time.
func _ready():
    texture = State1

func set_level(level : int) -> void:
    if level == 0:
        visible = false
    else:
        visible = true
        match level:
            1: texture = State1
            2: texture = State2
            3: texture = State3

func positive_blink():
    $AnimationPlayer.play("PositiveBlink")

func negative_blink():
    $AnimationPlayer.play("NegativeBlink")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
