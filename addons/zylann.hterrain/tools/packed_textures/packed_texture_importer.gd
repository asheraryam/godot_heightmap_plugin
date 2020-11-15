tool
extends EditorImportPlugin

const StreamTextureImporter = preload("./stream_texture_importer.gd")
const PackedTextureUtil = preload("./packed_texture_util.gd")
const Errors = preload("../../util/errors.gd")
const Result = preload("../util/result.gd")
const Logger = preload("../../util/logger.gd")

var _logger = Logger.get_for(self)


func get_importer_name() -> String:
	return "hterrain_packed_texture_importer"


func get_visible_name() -> String:
	# This shows up next to "Import As:"
	return "HTerrainPackedTexture"


func get_recognized_extensions() -> Array:
	return ["packed_tex"]


func get_save_extension() -> String:
	return "stex"


func get_resource_type() -> String:
	return "StreamTexture"


func get_preset_count() -> int:
	return 1


func get_preset_name(preset_index: int) -> String:
	return ""


func get_import_options(preset_index: int) -> Array:
	return []


func get_option_visibility(option: String, options: Dictionary) -> bool:
	return true


func import(p_source_path: String, p_save_path: String, options: Dictionary, 
	r_platform_variants: Array, r_gen_files: Array) -> int:

	var result := _import(p_source_path, p_save_path, options, r_platform_variants, r_gen_files)
	
	if not result.success:
		_logger.error(result.get_message())
		# TODO Show detailed error in a popup if result is negative
	
	var code : int = result.value
	return code


func _import(p_source_path: String, p_save_path: String, options: Dictionary, 
	r_platform_variants: Array, r_gen_files: Array) -> Result:
	
	var f := File.new()
	var err := f.open(p_source_path, File.READ)
	if err != OK:
		return Result.new(false, "Could not open file {0}: {1}" \
			.format([p_source_path, Errors.get_message(err)])) \
			.with_value(err)
	var text := f.get_as_text()
	f.close()
	
	var json_result := JSON.parse(text)
	if json_result.error != OK:
		return Result.new(false, "Failed to parse file {0}: {1}" \
			.format([p_source_path, json_result.error_string])) \
			.with_value(json_result.error)
	var json_data : Dictionary = json_result.result
	
	var resolution : int = int(json_data.resolution)
	var contains_albedo : bool = json_data.get("contains_albedo", false)
	var sources = json_data.get("src")

	var result := PackedTextureUtil.generate_image(sources, resolution, _logger)
	
	if not result.success:
		return Result.new(false, 
			"While importing {0}".format([p_source_path]), result) \
			.with_value(result.value)

	var image : Image = result.value
	
	result = StreamTextureImporter.import(p_source_path, 
		image, p_save_path, r_platform_variants, r_gen_files, contains_albedo,
		get_visible_name())
	
	if not result.success:
		return Result.new(false, 
			"While importing {0}".format([p_source_path]), result) \
			.with_value(result.value)
	
	return Result.new(true).with_value(OK)

