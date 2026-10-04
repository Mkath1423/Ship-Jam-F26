extends Node2D

@export var resourceManager : ResourceManager

enum screens { GameStart, Game, GameOver }


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
	set_screen(screens.GameOver)


func _on_start_game_button_pressed() -> void:
	resourceManager.restart()
	set_screen(screens.Game)
	$GameLayer/world.start()


func _on_go_to_menu_button_pressed() -> void:
	set_screen(screens.GameStart)
