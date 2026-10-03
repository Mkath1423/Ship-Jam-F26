extends Node2D

@export var resourceManager : Resource

enum screens { GameStart, Game, GameOver }

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (resourceManager.playerHealth <= 0):
		game_over()

func set_screen(screen : screens):
	if screen == screens.GameStart:
		$BackgroundLayer.hide()
		$GameLayer.hide()
		$GameStartLayer.show()
		$GameOverLayer.hide()
	elif screen == screens.Game:
		$BackgroundLayer.show()
		$GameLayer.show()
		$GameStartLayer.hide()
		$GameOverLayer.hide()
	elif screen == screens.GameOver:
		$BackgroundLayer.hide()
		$GameLayer.hide()
		$GameStartLayer.hide()
		$GameOverLayer.show()

func game_over():
	set_screen(screens.GameOver)


func _on_start_game_button_pressed() -> void:
	set_screen(screens.Game)


func _on_go_to_menu_button_pressed() -> void:
	set_screen(screens.GameStart)
