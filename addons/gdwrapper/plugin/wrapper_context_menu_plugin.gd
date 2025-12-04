@tool
extends EditorContextMenuPlugin

signal pressed(paths: PackedStringArray)

func _popup_menu(paths: PackedStringArray) -> void:
    if paths.is_empty(): return
    var valid_paths: PackedStringArray
    for path in paths:
        if path.get_file().ends_with(".gd"):
            valid_paths.append(path)
    if !valid_paths.is_empty():
        add_context_menu_item("Wrap", pressed.emit)
