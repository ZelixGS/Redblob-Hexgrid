class_name DebugConsole extends PanelContainer

@onready var container: VBoxContainer = $MarginContainer/VBoxContainer

func _ready() -> void:
	visible = false
	Global.debug = self

func _process(_delta: float) -> void:
	add_property("FPS", str(Engine.get_frames_per_second()))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		visible = !visible

func add_property(title: String, value: String, order: int = 0) -> void:
	var target: Label = container.find_child(title, true, false)
	if not target:
		target = Label.new()
		container.add_child(target)
		target.name = title
		target.text = target.name + value
	elif visible:
		target.text = "%s: %s" % [title, value]
		container.move_child(target, order)
