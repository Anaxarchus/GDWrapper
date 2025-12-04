@tool
extends ConfirmationDialog

func clear() -> void:
    %CodeEdit.text = ""
    %ErrorMessage.text = ""
    %ErrorMessage.hide()

func set_error_message(message: String) -> void:
    %ErrorMessage.text = "[color=red]" + message + "[/color]"
    %ErrorMessage.show()

func set_boilerplate_code(code: String) -> void:
    %CodeEdit.text = code

func _ready() -> void:
    confirmed.connect(_on_copy_button_pressed)
    canceled.connect(_on_cancel_button_pressed)

func _on_cancel_button_pressed() -> void:
    clear()
    self.hide()

func _on_copy_button_pressed() -> void:
    DisplayServer.clipboard_set(%CodeEdit.text)
    clear()
    self.hide()
