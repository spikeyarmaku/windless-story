extends Node2D

var _slide : float = 0
var _leftmost_index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func slide(reuse : bool):
    for c in get_children():
        if "position" in c:
            c.position.x -= 1
    _slide += 1
    if _slide > 16:
        _slide -= 16
        for c in get_children():
            if "position" in c:
                if c.position.x < -32:
                    if reuse:
                        c.position.x += 12 * 16
                        c.modulate.a = 1
                    else:
                        remove_child(c)
                        c.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
