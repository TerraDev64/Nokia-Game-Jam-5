extends Node


onready var idle_screen_ui = $UI/IdleScreen
onready var menu_ui = $UI/Menu
onready var stats_ui = $UI/StatsMenu
onready var player = $Player
onready var idle_timer = $IdleTimer
onready var money = $UI/Menu/Money
onready var delete_screen = $UI/DeleteScreen


var _save := SaveGame.new()

var food_costs: int = 50


enum {
	MENU,
	STATS,
	IDLE,
	DELETE
}

var ui_state = MENU


# Called when the node enters the scene tree for the first time.
func _ready():
	ui_state = MENU
	$UI/Menu/VBoxContainer/StatsButton.grab_focus()
	

func _process(delta):
	
	match ui_state:
		IDLE:
			menu_ui.hide()
			stats_ui.hide()
			idle_screen_ui.show()
			player.show()
		MENU:
			idle_screen_ui.hide()
			stats_ui.hide()
			delete_screen.hide()
			menu_ui.show()
			player.show()
			$UI/Menu/Money.text = "$" + String(Global.money)
		STATS:
			idle_screen_ui.hide()
			menu_ui.hide()
			player.hide()
			stats_ui.show()
		DELETE:
			idle_screen_ui.hide()
			menu_ui.hide()
			player.hide()
			delete_screen.show()
			
			
func _input(event):
	if Input.is_action_pressed("delete_save"):
		ui_state = DELETE
		if $DeleteTimer.time_left <= 0:
			$DeleteTimer.start()
		$UI/DeleteScreen/DeleteLabel.text = "Delete Save \nin: " + String("%01d" % $DeleteTimer.time_left)
	elif Input.is_action_just_released("delete_save"):
		$DeleteTimer.stop()
		_on_back_to_menu()

func _on_RunButton_pressed():
	
	if Global.age >= 1:
		$ClickAudio.play()
		get_tree().change_scene("res://scenes/RunGame.tscn")
	else:
		$DenyAudio.play()
	

func _on_IdleTimer_timeout():
	ui_state = IDLE


func _on_StatsButton_pressed():
	ui_state = STATS
	$ClickAudio.play()
	idle_timer.start()
	


func _on_FoodButton_pressed():
	if Global.money >= food_costs:
		$ClickAudio.play()
		$HungerTimer.start()
		Global.hunger += 10
		if Global.hunger > 99:
			Global.hunger = 99
		Global.money -= food_costs
	else:
		$DenyAudio.play()


func _on_SaveButton_pressed():
	_save.write_savegame()
	$SaveAudio.play()



func _on_back_to_menu():
	ui_state = MENU
	$ClickAudio.play()
	# This makes the button focused after a frame, bc it wouldn't work else (tried to grab focus when not even visible)
	# Thank you so much Alice <3
	yield(get_tree(), "idle_frame")
	$UI/Menu/VBoxContainer/StatsButton.grab_focus()
	idle_timer.start()


func _on_DeleteTimer_timeout():
	_save.delete_savegame()
	get_tree().change_scene("res://scenes/Intro.tscn")
