extends Node

var rooms = {
	"the_office_inner": {
		"texture": preload("res://assets/rooms/the_office_inner.jpg"),
		"transitions": {
			"Outer": "the_office",
		},
		"subscenes": {
			"Monitor": {
				"scene": preload("res://scenes/monitors/CameraTest.tscn"),
			},
		},
	},
	
	"the_office": {
		"texture": preload("res://assets/rooms/the_office.jpg"),
		"transitions": {
			"Inner": "the_office_inner",
			"Door": "hallway_the_office",
		},
	},
	
	"hallway_the_office": {
		"texture": preload("res://assets/rooms/hallway_the_office.jpg"),
		"transitions": {
			"DoorTheOffice": "the_office",
			"HallwayMaintenanceRoom": "hallway_maintenance_room",
		},
	},
	
	"hallway_maintenance_room": {
		"texture": preload("res://assets/rooms/hallway_maintenance_room.jpg"),
		"transitions": {
			"DoorMaintenanceRoom": "maintenance_room",
			"BackHallwayTheOffice": "hallway_the_office",
		},
	},
	
	"maintenance_room": {
		"texture": preload("res://assets/rooms/maintenance_room.jpg"),
		"transitions": {
			"Door": "hallway_maintenance_room",
			"Inner": "maintenance_room_inner",
		},
	},
	
	"maintenance_room_inner": {
		"texture": preload("res://assets/rooms/maintenance_room_inner.jpg"),
		"transitions": {
			"Outer": "maintenance_room",
		},
		"subscenes": {
			"PowerMonitor": {
				"scene": preload("res://scenes/monitors/PowerMonitorTest.tscn"),
			},
		},
	},
}

var current_room

func _init():
	for room_name in rooms:
		rooms[room_name]["name"] = room_name
