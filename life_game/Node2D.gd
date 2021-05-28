extends Node2D

var width = 1000
var height = 600
var cell = 10
var col = width / cell
var row = height / cell
var arr = []
var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	arr = make_arr(true)


func _draw():
	var x
	var y
	var color
	for r in range(row):
		for c in range(col):
			x = c * cell
			y = r * cell
			if arr[r][c] == 0:
				color = "#000000"
			else:
				color = "#ff0000"

			draw_rect(
				Rect2(Vector2(x, y), Vector2(cell, cell)),
				Color(color),
				true
			)


func _process(_delta):
	generation()
	update()


func _input(event):
	if event.is_action_pressed("click"):
		arr = make_arr(true)

	
func generation():
	var arr_tmp = make_arr(false)
	var count
	for r in range(row):
		for c in range(col):
			# 8方向のうち、生きているセルをカウント
			count = 0

			if r - 1 >= 0:
				# 上
				count += arr[r - 1][c]
			if r - 1 >= 0 and c + 1 < col:
				# 右上
				count += arr[r - 1][c + 1]
			if c + 1 < col:
				# 右
				count += arr[r][c + 1]
			if r + 1 < row and c + 1 < col:
				# 右下
				count += arr[r + 1][c + 1]
			if r + 1 < row:
				# 下
				count += arr[r + 1][c]
			if r + 1 < row and c - 1 >= 0:
				# 左下
				count += arr[r + 1][c - 1]
			if c - 1 >= 0:
				# 左
				count += arr[r][c - 1]
			if r - 1 >= 0 and c - 1 >= 0:
				# 左上
				count += arr[r - 1][c - 1]

			# 誕生
			# 死んでいるセルに隣接する生きたセルがちょうど3つあれば、次の世代が誕生する。
			if arr[r][c] == 0 and count == 3:
				arr_tmp[r][c] = 1

			# 生存
			# 生きているセルに隣接する生きたセルが2つか3つならば、次の世代でも生存する。
			elif arr[r][c] == 1 and (count == 2 or count == 3):
				arr_tmp[r][c] = 1

			# 過疎
			# 生きているセルに隣接する生きたセルが1つ以下ならば、過疎により死滅する。
			elif arr[r][c] == 1 and count <= 1:
				arr_tmp[r][c] = 0

			# 過密
			# 生きているセルに隣接する生きたセルが4つ以上ならば、過密により死滅する。
			elif arr[r][c] == 1 and count >= 4:
				arr_tmp[r][c] = 0

	arr = arr_tmp


func make_arr(rand):
	var arr_tmp = []
	var tmp
	for _r in range(row):
		tmp = []
		for _c in range(col):
			if rand:
				var my_random_number = rng.randi_range(0, 1)
				tmp.append(my_random_number)
			else:
				tmp.append(0)
		arr_tmp.append(tmp)
	return arr_tmp
