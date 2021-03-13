tool
extends TextureRect

class_name ProceduralWorld2D

export (int, 0, 100) var density     : int = 50 setget set_density
export (int, 0, 50)  var interations : int = 0 setget set_iterations
export (int, 0, 50)  var smooth      : int = 0 setget set_smooth

export (Image) var noise_image : Image = Image.new()
export (ImageTexture) var noise_texture : ImageTexture = ImageTexture.new()

export (Array) var Noise : Array = []
var Noise_seed : int

func set_density(value:int) -> void:
	density = clamp(value,0,100)
	update_noise()

func set_iterations(value:int) -> void:
	interations = clamp(value,0,50)

func set_smooth(value:int) -> void:
	smooth = clamp(value,0,50)

func generate_random_noise(size:Vector2, density_:int = 50) -> Array:
	var noise : Array
	for i in size.x:
		var sub_array : Array = []
		for j in size.y:
			sub_array.append(6*int(((randi()%100)+1) < density_))
		noise.append(sub_array)
	return noise

func generate_noise_by_seed(size:Vector2, seed_:int) -> Array:
	seed(seed_)
	var noise : Array
	for i in size.x:
		var sub_array : Array = []
		for j in size.y:
			sub_array.append(6*(randi()%2))
		noise.append(sub_array)
	return noise

func generate_noise_image(noise:Array) -> Image:
	var width  : int = noise   .size()
	var height : int = noise[0].size()
	var img := Image.new()
	img.create(width, height, false, Image.FORMAT_RGBA8)
	img.lock()
	
	var colors : PoolColorArray = [
		Color("#004289"), # mar
		Color("#0057b5"), # praia
		Color("#f5ce6c"), # areia
		Color("#5fc62c"), # grama
		Color("#4d8f28"), # floresta
		Color("#73665b"), # montanhas
		Color("#ffe2ca"), # neve
	]
	
	for i in width:
		for j in height:
			img.set_pixel(i, j, colors[round(noise[i][j])])
	img.unlock()
	return img


func _ready():
	connect("resized",self,"update_noise")

func update_noise():
	Noise = generate_random_noise(rect_size,density)
	for i in interations:
		Noise = interate(Noise)
	for i in smooth:
		Noise = smooth_terrain(Noise)
	noise_image = generate_noise_image(Noise)
	noise_texture.image = noise_image
	noise_texture.flags = 0
	texture = noise_texture

func interate(noise:Array):
	var temp_noise : Array
	var width  : int = noise   .size()
	var height : int = noise[0].size()
	
	# noise copy
	for i in width:
		var temp_array : Array
		for j in height:
			temp_array.append(noise[i][j])
		temp_noise.append(temp_array)
	
	
	for i in width:
		for j in height:
			var neighbors : int = 0
			for u in 3:
				for o in 3:
					if u == 1 && o == 1: continue
					var x = i+u-1
					var y = j+o-1
					if x < 0 || x == width || y < 0 || y == height: continue
					neighbors += temp_noise[x][y]
			noise[i][j] = 6*int(neighbors>(6*3))
	
	return noise

func smooth_terrain(noise:Array):
	var temp_noise : Array
	var width  : int = noise   .size()
	var height : int = noise[0].size()
	
	# noise copy
	for i in width:
		var temp_array : Array
		for j in height:
			temp_array.append(noise[i][j])
		temp_noise.append(temp_array)
	
	for i in width:
		for j in height:
			var neighbors : int = 0
			for u in 3:
				for o in 3:
					if u == 1 && o == 1: continue
					var x = i+u-1
					var y = j+o-1
					if x < 0 || x == width || y < 0 || y == height: continue
					neighbors += temp_noise[x][y]
			noise[i][j] = float(neighbors)/8
	
	return noise
