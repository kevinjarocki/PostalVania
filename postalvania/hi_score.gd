extends MarginContainer

#entry.452946419 - Name
#entry.163581294 - Time

var client = HTTPClient.new()
var user_panel = preload("res://panel.tscn")

const url_submit = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSeqPVDLyp7k14UYqlEJRcyX5n_U0--vPMN5e8npFS6oO3FQug/formResponse"
const headers = ["Content-Type: application/x-www-form-urlencoded"]
const url_data = "https://opensheet.elk.sh/1ZZUQk2zmmpON93tmDhA1aX9c222ltbPysiMaky1i798/data"

func start():
	$".".visible = true
	$VBoxContainer/HBoxContainer/Panel/Label.text = $"..".totalTime
	update_data()

func update_data():
	var http = HTTPRequest.new()
	http.connect("request_completed", http_done.bind(http))
	add_child(http)
	
	http.request(url_data,headers,HTTPClient.METHOD_GET)

func http_done(_result, _response_code, _headers, _body, http):
	http.queue_free()
	
	#With the results
	if !_result:
		var data = JSON.parse_string(_body.get_string_from_utf8())
		
		for x in data:
			if x["Name"]:
				var user = user_panel.instantiate()
				user._name = x["Name"]
				var temp = float(x["Time"])
				user._time = "%.1f" %temp + " sec"
				$VBoxContainer/ScrollContainer/VBoxContainer.add_child(user)

func http_submit(_result, _response_code, _headers, _body, http):
	http.queue_free()
	await get_tree().create_timer(3).timeout
	update_data()
	pass

func _on_button_pressed() -> void:
	for x in $VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		x.queue_free()
	
	var http = HTTPRequest.new()
	http.connect("request_completed", http_submit.bind(http))
	add_child(http)
	var user_data = client.query_string_from_dict({
		"entry.452946419" : $VBoxContainer/HBoxContainer/Panel2/LineEdit.text,
		"entry.163581294" : $"..".totalTime
	})
	var err = http.request(url_submit,headers,HTTPClient.METHOD_POST,user_data)
	
	if err:
		http.queue_free()
	else:
		$VBoxContainer/HBoxContainer/Button.disabled = true
		pass
