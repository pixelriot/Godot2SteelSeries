extends Control
"""
UI to test Steel Series Integration
"""

onready var steelseries = $SteelSeriesController

func _ready() -> void:
	steelseries.init_steelseries()
	if steelseries.is_active:
		$CheckBox.pressed = true


func _on_Bitmap_Upgrade_pressed() -> void:
	steelseries.trigger_bitmap_event("UPGRADE", 50)


func _on_Bitmap_Reset_pressed() -> void:
	steelseries.trigger_bitmap_event("RESET", 50)
	
	
func _on_HealthSlider_value_changed(value: float) -> void:
	steelseries.trigger_event("HEALTH", value)
	
	
func _on_DeathCount_value_changed(value: float) -> void:
	steelseries.trigger_event("DEATH", value)
	
	
func _on_KillCount_value_changed(value: float) -> void:
	steelseries.trigger_event("KILL", value)


func _on_FlashColor_value_changed(value: float) -> void:
	steelseries.trigger_event("FLASH", value)


