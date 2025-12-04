@tool
extends EditorPlugin

const WrapperScript = preload("script_wrapper.gd")
const WrapperDialog = preload("wrapper_dialog.tscn")
const PackageContextMenuPlugin = preload("wrapper_context_menu_plugin.gd")

var dialog: ConfirmationDialog
var ctx: EditorContextMenuPlugin

func _enter_tree():
    dialog = WrapperDialog.instantiate()
    ctx = PackageContextMenuPlugin.new()
    ctx.pressed.connect(_on_wrap_pressed)
    add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, ctx)

func _exit_tree() -> void:
    remove_context_menu_plugin(ctx)

func _on_wrap_pressed(paths: PackedStringArray) -> void:
    var parent = dialog.get_parent()
    if parent:
        parent.remove_child(dialog)
    EditorInterface.popup_dialog_centered(dialog,Vector2i(500, 300))
    dialog.set_boilerplate_code(_generate_boilerplate(paths))

func _generate_boilerplate(paths: PackedStringArray) -> String:
    return WrapperScript.wrap_scripts(paths)
