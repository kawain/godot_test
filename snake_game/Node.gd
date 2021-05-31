extends Node


var cell_size
var window_size
var shape_x
var shape_y

const FOOD = 0
const HEAD = 1
const TAIL = 2

var food_pos
var snake_body = [Vector2(5, 10), Vector2(4, 10), Vector2(3, 10)]
var snake_direction = Vector2(1, 0)
var add_food = false
var score = 0
var game_over = false
var rng = RandomNumberGenerator.new()

onready var map = $TileMap
onready var timer = $Timer
onready var label = $Label


func _ready():
	rng.randomize()
	cell_size = map.cell_size.x
	# 画面幅 / セルサイズ の正方形
	window_size = OS.get_window_size()
	shape_x = window_size.x / cell_size
	shape_y = window_size.y / cell_size
	food_pos = place_food()


func place_food():
	# randi_range ( int from, int to )
	# from と to の間 (両端を含む)
	var x = rng.randi_range(0, shape_x - 1)
	var y = rng.randi_range(0, shape_y - 1)
	return Vector2(x, y)


func draw_food():
	map.set_cellv(food_pos, FOOD)


func draw_snake():
	for i in snake_body.size():
		if i == 0:
			map.set_cellv(snake_body[i], HEAD)
		else:
			map.set_cellv(snake_body[i], TAIL)


func move_snake():
	delete_tile()
	var body_copy
	if add_food:
		body_copy = snake_body
		add_food = false
	else:
		# 配列の最後を除いてコピー
		body_copy = snake_body.slice(0, -2)
	# 新しい頭を作成
	var new_head = body_copy[0] + snake_direction
	# 配列の先頭に追加
	body_copy.insert(0, new_head)
	# snake_bodyを更新
	snake_body = body_copy


func delete_tile(all=false):
	var head_cell = map.get_used_cells_by_id(HEAD)
	for v in head_cell:
		map.set_cell(v.x, v.y, -1)

	var tail_cell = map.get_used_cells_by_id(TAIL)
	for v in tail_cell:
		map.set_cell(v.x, v.y, -1)

	if all:
		var food_cell = map.get_used_cells_by_id(FOOD)
		for v in food_cell:
			map.set_cell(v.x, v.y, -1)


# 標準の Node._input() 関数
func _input(event):
	var up = Vector2(0, -1)
	var down = Vector2(0, 1)
	var left = Vector2(-1, 0)
	var right = Vector2(1, 0)
	
	if snake_direction != down and Input.is_action_just_pressed("ui_up"):
		snake_direction = up
	elif snake_direction != up and Input.is_action_just_pressed("ui_down"):
		snake_direction = down
	elif snake_direction != right and Input.is_action_just_pressed("ui_left"):
		snake_direction = left
	elif snake_direction != left and Input.is_action_just_pressed("ui_right"):
		snake_direction = right

	if event.is_action_pressed("click"):
		reset()


func check_food_eaten():
	if food_pos == snake_body[0]:
		food_pos = place_food()
		add_food = true
		score += 1


func check_game_over():
	var head = snake_body[0]
	# 外にぶつかる
	if head.x < 0 or head.y < 0 or head.x >= shape_x or head.y >= shape_y:
		game_over()
	# 自分にぶつかる
	for i in snake_body.size():
		if i == 0:
			continue
		if head == snake_body[i]:
			game_over()
			break


func game_over():
	game_over = true
	timer.stop()
	

func reset():
	game_over = false
	score = 0
	label.text = ""
	delete_tile(true)
	snake_body = [Vector2(5, 10), Vector2(4, 10), Vector2(3, 10)]
	snake_direction = Vector2(1, 0)
	food_pos = place_food()
	timer.start()


func _on_Timer_timeout():
	move_snake()
	draw_food()
	draw_snake()
	check_food_eaten()
	check_game_over()
	if game_over:
		label.text = "score: " + str(score) + " Game over Click to resume"
	else:
		label.text = "score: " + str(score)

