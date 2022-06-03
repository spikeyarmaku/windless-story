extends RigidBody2D

signal eat(object)

const Food_icon = preload("res://Scenes/Food_icon.tscn")

export var _start_energy : int = 10
var _max_energy : int = 60
#export var _drain_in_air : int = 5 # Amount of energy consumed every second
#export var _drain_on_ground : int = 1

var _current_time : float = 0
var _current_energy : int
enum State {Walking, Running, Flying, Eating, Dead}
var _current_state = State.Walking
var _eat_start : float = -10

var _flaps_needed : int = 3
var _wing_flaps : int
var _current_wing_state : int = 0

var _energy_loss : float = 0 # 1 energy per N steps
var _energy_lost_at : float = 0

var _prev_energy : int
var _last_run : bool = false

func _set_current_energy(energy : int) -> void:
    _current_energy = energy
    _update_energy_meter()

func _update_energy_meter():
    var current_energy = max(_current_energy, 0)
    var blink : int
    if _prev_energy < current_energy:
        blink = 1
    elif _prev_energy > current_energy:
        blink = -1
    else:
        blink = 0
    var energy_left : int = min(current_energy, _max_energy)
    var icon_count : int = 0
    while energy_left != 0:
        var icon_level = min(3, energy_left)
        $FoodMeter.get_child(icon_count).set_level(icon_level)
        energy_left -= icon_level
        icon_count += 1
    for i in range(icon_count, _max_energy / 3):
        $FoodMeter.get_child(i).set_level(0)
    if blink == 1:
        $FoodMeter.get_child(icon_count).positive_blink()
    elif blink == -1:
        $FoodMeter.get_child(icon_count).negative_blink()
    _prev_energy = _current_energy

# Called when the node enters the scene tree for the first time.
func _ready():
    for i in range(20):
        var icon = Food_icon.instance()
        icon.position.x = i * 7
        icon.set_level(0)
        $FoodMeter.add_child(icon)
    _set_current_energy(_start_energy)

func on_step():
    if _energy_loss != 0:
        if _current_time - _energy_lost_at >= _energy_loss:
            _current_energy -= 1
            _energy_lost_at = _current_time
    _update_energy_meter()
#    if _is_on_ground:
#        _current_energy -= _drain_on_ground
#    else:
#        _current_energy -= _drain_in_air

func eat(plus : int):
    _set_current_energy(_current_energy + plus)
#    $Sprite/Blink.play("Blink")

func _bend_down():
    _current_state = State.Eating
    _eat_start = _current_time
    $Sprite/Move.play("Eat")

func _straighten_up():
    _current_state = State.Walking

func _input(event):
    if event.is_pressed() and not event.is_echo():
        if _current_state == State.Walking and _current_time > _eat_start + 1:
            _bend_down()
        elif _current_state == State.Flying:
            _flap_wings()
    if _current_state == State.Eating:
        for b in $Beak.get_overlapping_areas():
            if b.get_parent() != self:
                emit_signal("eat", b.get_parent())
                eat(1)

func _init_wings():
    $WingMeter/AnimationPlayer.play("Up")
    _wing_flaps = _flaps_needed
    _current_wing_state = 0
    $WingMeter/WingMeterDisplay.modulate.a = 0
    $WingMeter/Blink.play("Blink")
    _set_height(1)

func _flap_wings():
    _wing_flaps -= 1
    if _wing_flaps == 0:
        _wing_flaps = _flaps_needed
        _current_wing_state = 1 - _current_wing_state
        _set_height(1)
        match _current_wing_state:
            0:
                $Sprite/Move.play("Fly1") # Wings down
                $WingMeter/AnimationPlayer.play("Up")
            1:
                $Sprite/Move.play("Fly2") # Wings up
                $WingMeter/AnimationPlayer.play("Down")
    $WingMeter/WingMeterDisplay.modulate.a = \
        float(_flaps_needed - _wing_flaps) * \
            (1.0 / (float(_flaps_needed) - 1.0))

# Calculates height based on the remaining time of the current flying sequence
# (139 for the first one and ... for the second one)
func _set_height(lift : int):
    var end : int
    if _current_time < 128:
        end = 127
    elif _current_time < 140:
        end = 139
    elif _current_time < 265:
        end = 264
    elif _current_time < 278 :
        end = 277
    elif _current_time < 290:
        end = 289
    elif _current_time < 309:
        end = 308
    var remaining_time = end - _current_time
    var max_height = 3 * remaining_time
    $Sprite.position.y = -min(max_height, -$Sprite.position.y + lift)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    _current_time += delta
    if _current_time > _eat_start + 0.3 and _current_state == State.Eating:
        _straighten_up()
    if _current_state != State.Eating:
        # First flying sequence
        if 92 <= _current_time and _current_time < 105:
            $Sprite/Move.play("WonderWalk")
        elif 105 <= _current_time and _current_time < 114:
            $Sprite/Move.play("ChirpWalk")
        elif 114 <= _current_time and _current_time < 117:
            $Sprite/Move.play("Run")
            _current_state = State.Running
        elif 117 <= _current_time and _current_time < 127:
#            FLY!!!
            if _current_state != State.Flying:
                _init_wings()
                _current_state = State.Flying
        elif 127 <= _current_time and _current_time < 130:
            $Sprite/Move.play("Run")
            _current_state = State.Running
        elif 130 <= _current_time and _current_time < 139:
#            FLY!!!
            if _current_state != State.Flying:
                _init_wings()
                _current_state = State.Flying
        elif 139 <= _current_time and _current_time < 142:
            $Sprite/Move.play("Run")
            _current_state = State.Running
        elif 142 <= _current_time and _current_time < 162:
            $Sprite/Move.play("TiredWalk")
            _current_state = State.Walking
            
        ## Second flying sequence
        elif 230 <= _current_time and _current_time < 243:
            $Sprite/Move.play("WonderWalk")
        elif 243 <= _current_time and _current_time < 252:
            $Sprite/Move.play("ChirpWalk")
        elif 252 <= _current_time and _current_time < 255:
            $Sprite/Move.play("Run")
            _current_state = State.Running
        elif 255 <= _current_time and _current_time < 264:
            #            FLY!!!
            if _current_state != State.Flying:
                _init_wings()
                _current_state = State.Flying
        elif 264 <= _current_time and _current_time < 267:
            $Sprite/Move.play("Run")
            _current_state = State.Running
        elif 267 <= _current_time and _current_time < 277:
            #            FLY!!!
            if _current_state != State.Flying:
                _init_wings()
                _current_state = State.Flying
        elif 277 <= _current_time and _current_time < 280:
            $Sprite/Move.play("Run")
            _current_state = State.Running
        elif 280 <= _current_time and _current_time < 289:
            #            FLY!!!
            if _current_state != State.Flying:
                _init_wings()
                _current_state = State.Flying
        elif 289 <= _current_time and _current_time < 292:
            $Sprite/Move.play("Run")
            _current_state = State.Running
        elif 292 <= _current_time and _current_time < 308:
            #            FLY!!!
            if _current_state != State.Flying:
                _init_wings()
                _current_state = State.Flying
        elif 308 <= _current_time and _current_time < 343:
            $Sprite/Move.play("TiredWalk")
            _current_state = State.Walking
        elif 343 <= _current_time:
            _current_state = State.Dead
            $Sprite/Move.play("Die")
        else:
            var look = $LookArea.get_overlapping_areas()
            if look.size() > 1 and _current_time < 92:
                $Sprite/Move.play("LookDown")
            else:
                $Sprite/Move.play("Walk")
    
    if int(_current_time) == 308 and not _last_run:
        _last_run = true
        _energy_loss = 35.0 / float(_current_energy)
        _energy_lost_at = _current_time
        
    if _current_state == State.Flying:
        $WingMeter.visible = true
        _set_height(0)
        if _current_energy > 20:
            _energy_loss = 1
        else:
            _energy_loss = 5
    else:
        if int(_current_time) < 308:
            _energy_loss = 0
        else:
            if _energy_lost_at + _energy_loss <= _current_time:
                _current_energy -= 1
                _energy_lost_at = _current_time
        $WingMeter.visible = false
        $WingMeter/WingMeterDisplay.modulate.a = 1
