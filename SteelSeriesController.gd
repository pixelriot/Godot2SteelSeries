extends Node
"""
Steel Series Integration
"""
var is_active = false
var request_buffer = []
var ip_address := ""

onready var app_name = ProjectSettings.get("application/config/name")
const DEVELOPER := "YOUR COMPANY"
const HEADERS = ["Content-Type: application/json"]
const USE_SSL = false
const HEARTBEAT = 30000 #in ms


func init_steelseries() -> void:
	#get ip address
	var file = File.new()
	var filepath
	if OS.get_name() == "OSX":
		filepath = "/Library/Application Support/SteelSeries Engine 3/coreProps.json"
	elif OS.get_name() == "Windows":
		filepath = "C:/ProgramData/SteelSeries/SteelSeries Engine 3/coreProps.json"
	else:
		return
		
	#read Steel Series address
	if file.open(filepath, File.READ) == OK:
		var content = file.get_as_text()
		file.close()
		var coreProps = parse_json(content)
		if coreProps.has("address"):
			ip_address = "http://" + coreProps["address"]
			is_active = true
			print("Steel Series initialized at: " + coreProps["address"])
		
	#initiate Steel Series events
	if is_active:
		register_events()
		register_game()
		$Heartbeat.start(HEARTBEAT)


func trigger_event(event:String, new_value:float=50) -> void:
	if is_active:
		var payload : Dictionary = {
										"game": app_name.to_upper(),
										"event": event.to_upper(),
										"data": {
											"value": int(new_value)
										}
									}
		send_event("/game_event", payload)


func trigger_bitmap_event(event:String, cycles:int=50) -> void:
	if is_active:
		var bitmap = []
		for c in cycles:
			bitmap = get_bitmap(event, c)
			var payload : Dictionary = {
											"game": app_name.to_upper(),
											"event": "BITMAP",
											"data": {
												"frame": {
													"bitmap": bitmap,
													"excluded-events": ["HEALTH"]
												}
											}
										}
			send_event("/game_event", payload)
			$BitmapTimer.start(0.1)
			yield($BitmapTimer, "timeout")


static func get_bitmap(pattern:String, cycle:int) -> Array:
	var bitmap := []
	match pattern:
		"UPGRADE":
			for b in 132:
				bitmap.append([	wrapi(4*b*cycle, 0, 256),
								wrapi(0, 0, 255),
								wrapi(b*cycle, 0, 256)
							])
		"RESET":
			for b in 132:
				bitmap.append([	wrapi(4*b*cycle, 0, 256),
								wrapi(4*b*cycle, 0, 256),
								wrapi(255, 0, 256)
							])
	return bitmap


func register_events() -> void:
	var events_dictionary : Dictionary = {
		"HEALTH":{
			"icon_id":"1",
			"value_optional": true,
			"handlers": [
				#function keys show percentage
				{
					"device-type": "keyboard",
					"zone": "function-keys",
					"color": {"gradient": {"zero": {"red": 255, "green": 0, "blue": 0},
					"hundred": {"red": 0, "green": 255, "blue": 0}}},
					"mode": "percent"
				},
				#screen shows health amount
				{
					"device-type": "screened",
					"zone": "one",
					"datas": [{
						"has-text": true,
						"suffix": " health",
						"icon-id": 1
					}],
					"mode": "screen"
				}
			]
		},
		"DEATH":{
			"icon_id":"1",
			"value_optional": true,
			"handlers": [
				#screen shows death count
				{
					"device-type": "screened",
					"zone": "one",
					"datas": [{
						"has-text": true,
						"suffix": " death",
						"icon-id": 7
					}],
					"mode": "screen"
				},
				#flash main keyboard keys red
				{
					"device-type": "keyboard",
					"zone": "main-keyboard",
					"color": {"red": 255, "green": 0, "blue": 0},
					"mode": "color",
					"rate": {
						"frequency": 10,
						"repeat_limit": 3
					}
				}
			]
		},
		"KILL":{
			"icon_id":"1",
			"value_optional": true,
			"handlers": [
				#screen shows kill count
				{
					"device-type": "screened",
					"zone": "one",
					"datas": [{
						"has-text": true,
						"suffix": " kills",
						"icon-id": 6
					}],
					"mode": "screen"
				},
				#flash main keyboard keys white
				{
					"device-type": "keyboard",
					"zone": "main-keyboard",
					"color": {"red": 255, "green": 255, "blue": 255},
					"mode": "color",
					"rate": {
						"frequency": 10,
						"repeat_limit": 3
					}
				}
			]
		},
		"FLASH": {
			"icon_id":"1",
			"value_optional": true,
			"handlers": [
				#mouse color range
				{
					"device-type": "mouse",
					"zone": "wheel",
					"color": [
						{"low": 0,"high": 1,"color": {"red": 237,"green": 0,"blue": 112}},
						{"low": 2,"high": 3,"color": {"red": 118,"green": 18,"blue": 159}},
						{"low": 4,"high": 5,"color": {"red": 0,"green": 237,"blue": 112}},
						{"low": 6,"high": 7,"color": {"red": 31,"green": 198,"blue": 229}},
						{"low": 8,"high": 9,"color": {"red": 253,"green": 208,"blue": 71}},
						{"low": 10,"high": 11,"color": {"red": 205,"green": 172,"blue": 81}},
						{"low": 12,"high": 13,"color": {"red": 138,"green": 37,"blue": 100}},
						{"low": 14,"high": 15,"color": {"red": 205,"green": 172,"blue": 81}},
						{"low": 16,"high": 17,"color": {"red": 129,"green": 232,"blue": 252}},
					],
					"mode": "color",
					"rate": {
						"frequency": 10,
						"repeat_limit": 3
					}
				},
				#keyboard color range
				{
					"device-type": "keyboard",
					"zone": "main-keyboard", #keypad, number-keys
					"color": [
						{"low": 0,"high": 1,"color": {"red": 237,"green": 0,"blue": 112}},
						{"low": 2,"high": 3,"color": {"red": 118,"green": 18,"blue": 159}},
						{"low": 4,"high": 5,"color": {"red": 0,"green": 237,"blue": 112}},
						{"low": 6,"high": 7,"color": {"red": 31,"green": 198,"blue": 229}},
						{"low": 8,"high": 9,"color": {"red": 253,"green": 208,"blue": 71}},
						{"low": 10,"high": 11,"color": {"red": 205,"green": 172,"blue": 81}},
						{"low": 12,"high": 13,"color": {"red": 138,"green": 37,"blue": 100}},
						{"low": 14,"high": 14,"color": {"red": 205,"green": 172,"blue": 81}},
						{"low": 16,"high": 15,"color": {"red": 129,"green": 232,"blue": 252}},
					],
					"mode": "color",
					"rate": {
						"frequency": 10,
						"repeat_limit": 3
					}
				},
				#headphone color range
				{
					"device-type": "headset",
					"zone": "earcups",
					"color": [
						{"low": 0,"high": 1,"color": {"red": 237,"green": 0,"blue": 112}},
						{"low": 2,"high": 3,"color": {"red": 118,"green": 18,"blue": 159}},
						{"low": 4,"high": 5,"color": {"red": 0,"green": 237,"blue": 112}},
						{"low": 6,"high": 7,"color": {"red": 31,"green": 198,"blue": 229}},
						{"low": 8,"high": 9,"color": {"red": 253,"green": 208,"blue": 71}},
						{"low": 10,"high": 11,"color": {"red": 205,"green": 172,"blue": 81}},
						{"low": 12,"high": 13,"color": {"red": 138,"green": 37,"blue": 100}},
						{"low": 14,"high": 14,"color": {"red": 205,"green": 172,"blue": 81}},
						{"low": 16,"high": 15,"color": {"red": 129,"green": 232,"blue": 252}},
					],
					"mode": "color",
					"rate": {
						"frequency": 10,
						"repeat_limit": 3
					}
				}
			]
		},
		"BITMAP":{
			"icon_id":"17",
			"value_optional": true,
			"handlers": [
				{
					"device-type": "rgb-per-key-zones",
					"mode": "partial-bitmap",
					"excluded-events": ["HEALTH"]
				}
			]
		}
	}

	for e in events_dictionary:
		events_dictionary[e]["game"] = app_name.to_upper()
		events_dictionary[e]["event"] = e.to_upper()
		send_event("/bind_game_event", events_dictionary[e])


func register_game() -> void:
	var payload : Dictionary = {	"game": app_name.to_upper(),
									"game_display_name":app_name,
									"developer": DEVELOPER,
									"deinitialize_timer_length_ms": HEARTBEAT
								}
	send_event("/game_metadata", payload)


func _on_Heartbeat_timeout() -> void:
	var payload : Dictionary = {"game": app_name.to_upper()}
	send_event("/game_heartbeat", payload)


func send_event(endpoint:String, payload:Dictionary) -> void:
	if $HTTPRequest.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		print("Steel Series: sending event.")
		var error = $HTTPRequest.request(	ip_address + endpoint,
											HEADERS,
											USE_SSL,
											HTTPClient.METHOD_POST,
											JSON.print(payload)
										)
		if error != OK:
			print("Steel Series: error in http request: " + error)
			$Heartbeat.stop()
	else:
		request_buffer.append([endpoint, payload])


func _on_HTTPRequest_request_completed(	result: int, 
										response_code: int, 
										headers: PoolStringArray, 
										body: PoolByteArray) -> void:
	var message = body.get_string_from_utf8()
	if message.begins_with("{\"error"):
		print("Steel Series: http error: " + message)

	if not request_buffer.empty():
		send_event(request_buffer[0][0], request_buffer[0][1])
		request_buffer.pop_front()


