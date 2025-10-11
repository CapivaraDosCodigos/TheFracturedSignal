extends Resource
class_name TimeGame

static func get_time() -> String:
	var data := Time.get_date_string_from_system()
	var hora := Time.get_time_string_from_system().substr(0, 5)
	var data_hora := "%s %sh%s" % [data.replace("-", "/"), hora.substr(0, 2), hora.substr(3, 2)]
	return data_hora
