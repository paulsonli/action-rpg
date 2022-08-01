extends Control

var hearts = null setget set_hearts
var max_hearts = null setget set_max_hearts

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty


func set_hearts(value):
#	hearts = clamp (value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = PlayerStats.health * 15
	
	
func set_max_hearts(value):
#	max_hearts = max(value, 1)
#	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = PlayerStats.max_health * 15
		
	
func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
	PlayerStats.connect("health_changed", self, "set_hearts")

	
	

	
