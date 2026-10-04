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
		$GameStartLayer.show()
		$BackgroundLayer.hide()
		$GameLayer.hide()
		$UI.hide()
		$GameOverLayer.hide()
	elif screen == screens.Game:
		$GameStartLayer.hide()
		$BackgroundLayer.show()
		$GameLayer.show()
		$UI.show()
		$GameOverLayer.hide()
	elif screen == screens.GameOver:
		$GameStartLayer.hide()
		$BackgroundLayer.hide()
		$GameLayer.hide()
		$UI.hide()
		$GameOverLayer.show()

func game_over():
	$GameLayer/world.end.emit()
	set_screen(screens.GameOver)


func _on_start_game_button_pressed() -> void:
	set_screen(screens.Game)
	$GameLayer/world.restart.emit()


func _on_go_to_menu_button_pressed() -> void:
	set_screen(screens.GameStart)
