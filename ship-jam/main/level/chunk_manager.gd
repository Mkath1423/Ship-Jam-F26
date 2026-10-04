extends Node2D

@export var player : Node2D 
@export var test_check : PackedScene

@export var chunk_1 : PackedScene

@export var chunk_dims : Vector2 = Vector2(100, 100)
@export var chunk_load_distance : Vector2i = Vector2i(5, 5)
@export var world_dimentions : Vector2i = Vector2i(6, 6)

class ChunkInfo:
	var node : Node2D
	var stale : bool 
	var chunk_offset : Vector2i

var chunks : Dictionary[Vector2i, ChunkInfo] = {}
var last_player_pos : Vector2i = Vector2i(100000, 100000)


func _process(_delta: float) -> void:
	_mark_all_stale()
	load_nearby_chunks()

func _mark_all_stale():
	for k in chunks.keys():
		chunks[k].stale = true
		
func _cleanup_stale_chunks():
	for k in chunks.keys():
		if chunks[k].stale:
			#print("freeing", k)
			chunks[k].node.queue_free()
			chunks.erase(k)

func _spawn_chunk(pos : Vector2i):
	var mod_pos = Vector2i(
		posmod(pos.x, world_dimentions.x), 
		posmod(pos.y, world_dimentions.y))
	if mod_pos in chunks:
		var chunk = chunks[mod_pos]
		chunk.stale = false
		
		if chunk.chunk_offset != pos:
			chunk.chunk_offset = pos
			chunk.node.global_position = chunk_dims * Vector2(pos)
			chunk.node.move_to(chunk_dims * Vector2(pos), pos)
		
	else:
		var chunk = ChunkInfo.new()
		chunk.node = chunk_1.instantiate() as Node2D
		chunk.node.global_position = chunk_dims * Vector2(pos)
		chunk.chunk_offset = pos
		add_child(chunk.node)
		chunk.stale = false
		chunk.node.initialize_at(chunk_dims * Vector2(pos), pos)
		chunks[mod_pos] = chunk

func load_nearby_chunks():
	var player_chunk_pos = Vector2i(floor(player.global_position / chunk_dims))
	
	
	if last_player_pos == player_chunk_pos:
		return
	
	last_player_pos = player_chunk_pos
	
	for x in range(-chunk_load_distance.x, chunk_load_distance.x + 1):
		for y in range(-chunk_load_distance.y, chunk_load_distance.y + 1):
			_spawn_chunk(player_chunk_pos + Vector2i(x, y))
			
			
	_cleanup_stale_chunks()

	
	
	
	
