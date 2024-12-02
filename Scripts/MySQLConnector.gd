extends Node
var querys := {}
var querys_id: Array[int] = []
signal query_finished(query_id: int, result)

func query(query_string: String, bindings: Array = []) -> int:
	var query_id = generate_unique_id()
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(
		func(result, response_code, headers, body):
			_on_request_completed(query_id, http_request, result, response_code, headers, body)
			)
	var data = {"sql": query_string, "values": bindings}
	var json_data = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	var err = http_request.request("http://localhost:3000/query", headers, HTTPClient.METHOD_POST, json_data)
	if err != OK:
		print("Error al enviar la consulta")
		push_error("Error al enviar la consulta")
		http_request.queue_free()
		return -1
	return query_id

func _on_request_completed(query_id: int, http_request: HTTPRequest, result, response_code, headers, body):
	var success = (response_code == 200)
	var parsed_result
	if success:
		parsed_result = JSON.parse_string(body.get_string_from_utf8())
	else:
		print("Error en la consulta, código:", response_code)
	querys[query_id] = parsed_result
	querys_id.erase(query_id)
	http_request.queue_free()
	query_finished.emit(query_id, querys[query_id])

func await_query(query_id: int):
	while not MySQLConnector.querys.has(query_id):
		await MySQLConnector.query_finished
	return MySQLConnector.querys[query_id]

func generate_unique_id() -> int:
	var id = Time.get_ticks_msec()
	while querys_id.has(id):
		id -= 1
	querys_id.append(id)
	return id

func cleanup_query(query_id: int) -> void:
	querys.erase(query_id)
