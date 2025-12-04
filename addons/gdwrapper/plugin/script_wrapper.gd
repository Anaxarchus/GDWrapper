extends Object

## This script handles automatically generating boilerplate wrappers for a given script.
## Scripts will attempt to be referenced by their global class name. If one does not exist,
## references will fall back to statically loading them.

static func get_type_string(type: Variant.Type, usage_flags: int) -> String:
    match type:
        TYPE_BOOL: return "bool"
        TYPE_INT: return "int"
        TYPE_FLOAT: return "float"
        TYPE_STRING: return "String"
        TYPE_VECTOR2: return "Vector2"
        TYPE_VECTOR2I: return "Vector2i"
        TYPE_RECT2: return "Rect2"
        TYPE_RECT2I: return "Rect2i"
        TYPE_VECTOR3: return "Vector3"
        TYPE_VECTOR3I: return "Vector3i"
        TYPE_TRANSFORM2D: return "Transform2D"
        TYPE_VECTOR4: return "Vector4"
        TYPE_VECTOR4I: return "Vector4i"
        TYPE_QUATERNION: return "Quaternion"
        TYPE_AABB: return "AABB"
        TYPE_BASIS: return "Basis"
        TYPE_TRANSFORM3D: return "Transform3D"
        TYPE_COLOR: return "Color"
        TYPE_STRING_NAME: return "StringName"
        TYPE_NODE_PATH: return "NodePath"
        TYPE_RID: return "RID"
        TYPE_OBJECT: return "Object"
        TYPE_CALLABLE: return "Callable"
        TYPE_SIGNAL: return "Signal"
        TYPE_DICTIONARY: return "Dictionary"
        TYPE_ARRAY: return "Array"
        TYPE_PACKED_BYTE_ARRAY: return "PackedByteArray"
        TYPE_PACKED_INT32_ARRAY: return "PackedInt32Array"
        TYPE_PACKED_INT64_ARRAY: return "PackedInt64Array"
        TYPE_PACKED_FLOAT32_ARRAY: return "PackedFloat32Array"
        TYPE_PACKED_FLOAT64_ARRAY: return "PackedFloat64Array"
        TYPE_PACKED_STRING_ARRAY: return "PackedStringArray"
        TYPE_PACKED_VECTOR2_ARRAY: return "PackedVector2Array"
        TYPE_PACKED_VECTOR3_ARRAY: return "PackedVector3Array"
        TYPE_PACKED_COLOR_ARRAY: return "PackedColorArray"
        _:
            if usage_flags & PROPERTY_USAGE_NIL_IS_VARIANT != 0:
                return "Variant"
            else:
                return ""

# TODO: parse and apply documentation comments from wrapped members to wrapper methods.
static func wrap_scripts(script_paths: PackedStringArray) -> String:
    var result: String
    for path in script_paths:
        if !path.get_file().ends_with(".gd"):
            push_error("Error, file does not have a proper gdscript extension.")
            continue
        var file_name: String = path.get_file().split(".")[0]
        var script: GDScript = load(path)
        if script:
            var global_name := script.get_global_name()

            # If script has no global name, fallback to using a preloaded const as the reference.
            if global_name.is_empty():
                global_name = file_name.to_pascal_case()
                result += "\n\n#region " + global_name
                result += "\nconst " + global_name + " := preload(\"" + path + "\")\n"
            else:
                result += "\n\n#region " + global_name

            # wrap all constants
            for constant in script.get_script_constant_map():
                result += "\nconst " + constant + " = " + global_name + "." + constant

            # wrap all public, static methods.
            result += "\n"
            for method in script.get_script_method_list():
                # check if the method is conventionally public and the static flag is set.
                if !method.name.begins_with("_") and method.flags & METHOD_FLAG_STATIC != 0:
                    # Figure out return type
                    var return_type: String = get_type_string(method.return.type, method.return.usage)
                    result += "\n\nstatic func " + method.name + "("
                    var arg_list: PackedStringArray
                    for arg in method.args:
                        var arg_type: String = get_type_string(arg.type, arg.usage)
                        if arg_type.is_empty():
                            arg_list.append(arg.name)
                        else:
                            arg_list.append(arg.name + ": " + arg_type)
                    var args: String = ", ".join(arg_list)
                    result += args
                    if return_type.is_empty():
                        result += ") -> void:\n"
                        result += "\t" + global_name + "." + method.name + "(" + args + ")"
                    else:
                        result += ") -> " + return_type + ":\n"
                        result += "\treturn " + global_name + "." + method.name + "(" + args + ")"
            result += "\n#endregion " + global_name

    return result
