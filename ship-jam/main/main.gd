extends Node2D

@export var resourceManager : ResourceManager

@onready var wave_manager = $GameLayer/WaveScheduler
@onready var rounds_cleared_ui = $GameOverLayer/CenterContainer/VBoxContainer/Rounds

enum screens { GameStart, Game, GameOver }

func _ready() -> void:
	set_screen(screens.GameStart)

func _hide_all():
	$BackgroundLayer.hide()
	$GameLayer.hide()
	$UI.hide()
	$GameStartLayer.hide()
	$GameOverLayer.hide()
	$GameLayer.process_mode = Node.PROCESS_MODE_DISABLED

func _show_game_screen():
	$BackgroundLayer.show()
	$GameLayer.show()
	$UI.show()
	$GameLayer.process_mode = Node.PROCESS_MODE_INHERIT


func set_screen(screen : screens):
	_hide_all()
	$BackgroundLayer.show()
	if screen == screens.GameStart:
		$GameStartLayer.show()
		
	elif screen == screens.Game:
		_show_game_screen()
		
	elif screen == screens.GameOver:
		$GameOverLayer.show()

func game_over():
	rounds_cleared_ui.text = "Waves Cleared: " + str(wave_manager.rounds_cleared)
	set_screen(screens.GameOver)


func _on_start_game_button_pressed() -> void:
	resourceManager.restart()
	set_screen(screens.Game)
	$GameLayer/world.start()


func _on_go_to_menu_button_pressed() -> void:
	set_screen(screens.GameStart)
