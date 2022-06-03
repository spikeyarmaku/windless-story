extends Node2D

const GroundSummer = preload("res://Scenes/Grounds/SummerGround.tscn")
const GroundFall = preload("res://Scenes/Grounds/FallGround.tscn")
const GroundWinter = preload("res://Scenes/Grounds/WinterGround.tscn")

const CloudsSummer = preload("res://Scenes/Clouds/CloudsSummer.tscn")

const Grasshopper = preload("res://Scenes/Food/Grasshopper.tscn")
const Snail = preload("res://Scenes/Food/Snail.tscn")

const Oak = preload("res://Scenes/Trees/Oak.tscn")
const Pine = preload("res://Scenes/Trees/Pine.tscn")

export var _food_summer : int = 10 # On average, one food every N tiles
export var _food_fall :   int = 20
export var _variance :    int = 2
var _next_food_in : int = 0

var _next_tree_in : int = 0

var _prev_step : int = 0
var _current_step : int = 0
var _accumulator : float = 0
var _fall_start : int = 34
var _fall_end : int = 48
var _winter_start : int = 220
var _winter_end : int = 254

enum Season {Summer, Fall, Winter}
var _current_season = Season.Summer
var _season_trans_num : int = 10 # The number of tiles it takes to transition
                                 # from one season to the next
var _season_trans_state : int = 0 # Last tile's transition number

var _slide_frame : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    for i in range(0, 12):
        var ground = GroundSummer.instance()
        ground.position.x = i * 16
        $GroundSummer.add_child(ground)
        
        var rnd = rand_range(0, 2)
        var clouds
        if rnd < 1:
            clouds = CloudsSummer.instance()
            clouds.position.y += rand_range(-12, 8)
        else:
            clouds = Node2D.new()
        clouds.position.x = i * 16
        $Clouds.add_child(clouds)

func _change_tiles():
    pass

func on_step(add):
    if _next_food_in <= 0:
        _next_food_in = _food_when()
        _put_food()
    else:
        _next_food_in -= 1
        
    if _next_tree_in <= 0:
        _next_tree_in = rand_range(0, 3)
        _put_tree()
    else:
        _next_tree_in -= 1
        
    _prev_step = _current_step
    _accumulator += add
    if _accumulator >= 1.0:
        _accumulator -= 1.0
        _current_step += 1
    if _current_step == _fall_end:
        _current_season = Season.Fall
    if _current_step == _winter_end:
        _current_season = Season.Winter
    if _current_step == _fall_start and _prev_step != _current_step:
        $Sky/Transition.play("Fall")
        $Clouds/Transition.play("Fall")
    if _current_step == _winter_start and _prev_step != _current_step:
        $Sky/Transition.play("Winter")
        $Clouds/Transition.play("Winter")
    if _current_step >= _fall_start and _current_step <= _fall_end:
        var diff = _current_step - _fall_start
        var total = _fall_end - _fall_start
        var change_level = float(diff) / float(total)
        var ground = GroundFall.instance()
        ground.position.x = 12 * 16 - 0.1 # that .1 is an ugly hack
        # so that there won't be a flickering line between ground tiles
        ground.modulate.a = change_level
        $GroundFall.add_child(ground)
    if _current_step >= _winter_start and _current_step <= _winter_end:
        var diff = _current_step - _winter_start
        var total = _winter_end - _winter_start
        var change_level = float(diff) / float(total)
        var ground = GroundWinter.instance()
        ground.position.x = 12 * 16 - 0.1 # that .1 is an ugly hack
        # so that there won't be a flickering line between ground tiles
        ground.modulate.a = change_level
        $GroundWinter.add_child(ground)

func advance():
    if _current_step < 342:
        _slide_frame += 1
        $GroundSummer.slide(true)
        $GroundFall.slide(_current_step > _fall_end)
        $GroundWinter.slide(_current_step > _winter_end)
        if _slide_frame % 16 == 0:
            $Clouds.slide(true)
        $Food.slide(false)
        $Trees.slide(false)
        if _slide_frame % 8 == 0:
            if _current_step > 85:
                $Thrustles1.position.x += 1
            if _current_step > 224:
                $Thrustles2.position.x += 1
                $Thrustles3.position.x += 1

func _food_when() -> int:
    var food_interval : int
    match _current_season:
        Season.Summer: food_interval = _food_summer
        Season.Fall:   food_interval = _food_fall
        Season.Winter: return 10000
    return int(rand_range(food_interval - _variance, food_interval + _variance))

func _put_food():
    var food
    var i = rand_range(0, 1)
    if i < 0.5:
        food = Grasshopper.instance()
    else:
        food = Snail.instance()
    food.position.x = 160
    $Food.add_child(food)

func _put_tree():
    var tree
    var i = rand_range(0, 1)
    if i < 0.5:
        tree = Oak.instance()
        match _current_season:
            Season.Summer: tree.frame = 0
            Season.Fall:   tree.frame = 1
            Season.Winter: tree.frame = 2
    else:
        tree = Pine.instance()
        match _current_season:
            Season.Summer: tree.frame = 0
            Season.Fall:   tree.frame = 0
            Season.Winter: tree.frame = 1
    tree.position.x = 160
    tree.position.y += rand_range(0, 4)
    $Trees.add_child(tree)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func remove_food(food):
    $Food.remove_child(food)
    food.queue_free()
