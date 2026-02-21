extends CanvasLayer

@onready var WhiteBar = %WhiteBar
@onready var BarChaser = %BarChaser
var style 

func _ready():
	style = BarChaser.get_theme_stylebox("fill") as StyleBoxFlat
	# Listen for the signal and connect it to a local function
	Events.brake_gauge_updated.connect(_on_brake_gauge_updated)

# This runs automatically whenever the Player emits the signal
func _on_brake_gauge_updated(current_heat: float, max_heat: float):
	WhiteBar.max_value = max_heat
	WhiteBar.value = current_heat
	
	style.bg_color = Color.GREEN.lerp(Color.RED, current_heat / max_heat)
	var tween = create_tween()
	tween.tween_property(BarChaser, "value", WhiteBar.value, 0.5).set_trans(Tween.TRANS_SINE)
	
	if BarChaser.value < 3:
		BarChaser.value = 0
	
	if WhiteBar.value < 25:
		var tween2 = create_tween()
		tween2.tween_property($BarContainer, "modulate:a", 0.5, 0.5)
	else:
		var tween3 = create_tween()
		tween3.tween_property($BarContainer, "modulate:a", 1, 0.5)
#TODO
#TEST THE BREAK SYSTEM, SEE IF IT ALSO REFLECTS IN PLAYER HUD, 
#MAKE IT SO WHITEBAR IS UPDATED WHEN THE SIGNAL IS UPDATED
#WHICH BARCHASER WILL TWEEN INTO THE WHITEBAR'S VALUE
#CHANGE TEH VALUES FOR BREAK AS WELL
