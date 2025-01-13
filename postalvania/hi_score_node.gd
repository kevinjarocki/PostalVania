extends Node2D

#entry.452946419 - Name
#entry.163581294 - Time

var client = HTTPClient.new()

const url_submit = "https://docs.google.com/forms/u/0/d/e/1FAIpQLSeqPVDLyp7k14UYqlEJRcyX5n_U0--vPMN5e8npFS6oO3FQug/formResponse"
const headers = ["Content-Type: application/x-www-form-urlencoded"]

func http_submit(_result, _response_code, _headers, _body, _http):
	pass

func _on_submit_pressed():
	print("here")
	var http = HTTPRequest.new()
	#http.connect("request_completed", http_submit(), [http])
	add_child(http)
	var user_data = client.query_string_from_dict({
		"entry.452946419" : $NinePatchRect/TextEdit.text,
		"entry.163581294" : $"..".time[0]
	})
	var err = http.request(url_submit,headers,HTTPClient.METHOD_POST,user_data)
