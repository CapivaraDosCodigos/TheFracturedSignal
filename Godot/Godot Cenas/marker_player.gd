extends Node2D
class_name MarkerPlayer

var markers: Array[Marker2D] = []

func _ready() -> void:
	for child in get_children():
		if child is Marker2D:
			markers.append(child)
			
	
	if Starts.Pdir != null:
		var dir = Starts.Pdir.duplicate()  # cópia
		dir.erase(Starts.Current_player.N) # remove só da cópia
			for ip in dir.values():
					
