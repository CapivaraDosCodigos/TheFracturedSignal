# =============================================================================
# PURPOSE: Top bar UI component for TileMapLayer3D editor plugin
# =============================================================================
# This class manages the top toolbar controls including:
#   - Enable toggle (activate/deactivate plugin)
#   - Mode buttons (Manual / Auto tiling)
#
# USAGE:
#   Created and managed by TileEditorUI
#   Added to CONTAINER_SPATIAL_EDITOR_MENU
# =============================================================================

@tool
class_name TileTopBar
extends HBoxContainer

# =============================================================================
# SECTION: SIGNALS
# =============================================================================

## Emitted when enable toggle changes
signal enabled_changed(enabled: bool)

## Emitted when tiling mode changes (Manual/Auto)
signal mode_changed(mode: int)

# =============================================================================
# SECTION: CONSTANTS
# =============================================================================

## Tiling mode constants (match GlobalConstants)
const MODE_MANUAL: int = 0
const MODE_AUTOTILE: int = 1

# =============================================================================
# SECTION: MEMBER VARIABLES
# =============================================================================

## Enable toggle button
var _enable_toggle: CheckButton = null

## Mode button group (exclusive selection)
var _mode_button_group: ButtonGroup = null

## Manual mode button
var _manual_button: Button = null

## Auto mode button
var _auto_button: Button = null

## Flag to prevent signal loops during programmatic updates
var _updating_ui: bool = false

# =============================================================================
# SECTION: INITIALIZATION
# =============================================================================

func _init() -> void:
	name = "TileMapLayer3DTopBar"


func _ready() -> void:
	_create_ui()


## Create all UI components
func _create_ui() -> void:
	# --- Enable Toggle ---
	_enable_toggle = CheckButton.new()
	_enable_toggle.text = "Enable Tiling"
	_enable_toggle.tooltip_text = "Toggle 2.5D tile placement tool (select a TileMapLayer3D node first)"
	_enable_toggle.toggled.connect(_on_enable_toggled)
	add_child(_enable_toggle)

	# --- Separator ---
	_add_separator()

	# --- Mode Buttons ---
	_mode_button_group = ButtonGroup.new()

	_manual_button = Button.new()
	_manual_button.text = "Manual"
	_manual_button.tooltip_text = "Manual tile placement mode"
	_manual_button.toggle_mode = true
	_manual_button.button_group = _mode_button_group
	_manual_button.button_pressed = true  # Default to Manual
	_manual_button.toggled.connect(_on_manual_toggled)
	add_child(_manual_button)

	_auto_button = Button.new()
	_auto_button.text = "Auto"
	_auto_button.tooltip_text = "Autotile mode (uses TileSet terrains)"
	_auto_button.toggle_mode = true
	_auto_button.button_group = _mode_button_group
	_auto_button.toggled.connect(_on_auto_toggled)
	add_child(_auto_button)


## Add a visual separator
func _add_separator() -> void:
	var separator := VSeparator.new()
	separator.custom_minimum_size.x = 8
	add_child(separator)

# =============================================================================
# SECTION: PUBLIC METHODS
# =============================================================================

## Sync UI state from node settings
## @param settings: TileMapLayerSettings resource (or null to reset)
func sync_from_settings(settings: Resource) -> void:
	if not settings:
		_reset_to_defaults()
		return

	_updating_ui = true

	# Sync tiling mode
	var tiling_mode: int = settings.get("tiling_mode") if settings.get("tiling_mode") != null else MODE_MANUAL
	if tiling_mode == MODE_AUTOTILE:
		_auto_button.button_pressed = true
	else:
		_manual_button.button_pressed = true

	_updating_ui = false


## Reset UI to default state
func _reset_to_defaults() -> void:
	_updating_ui = true
	_manual_button.button_pressed = true
	_updating_ui = false


## Set enabled state without triggering signal
## @param enabled: Whether plugin is enabled
func set_enabled(enabled: bool) -> void:
	if _enable_toggle:
		_enable_toggle.set_pressed_no_signal(enabled)


## Get whether plugin is enabled
func is_enabled() -> bool:
	if _enable_toggle:
		return _enable_toggle.button_pressed
	return false


## Set tiling mode without triggering signal
## @param mode: MODE_MANUAL or MODE_AUTOTILE
func set_mode(mode: int) -> void:
	_updating_ui = true
	if mode == MODE_AUTOTILE:
		_auto_button.button_pressed = true
	else:
		_manual_button.button_pressed = true
	_updating_ui = false


## Get current tiling mode
func get_mode() -> int:
	if _auto_button and _auto_button.button_pressed:
		return MODE_AUTOTILE
	return MODE_MANUAL

# =============================================================================
# SECTION: SIGNAL HANDLERS
# =============================================================================

func _on_enable_toggled(pressed: bool) -> void:
	enabled_changed.emit(pressed)


func _on_manual_toggled(pressed: bool) -> void:
	if _updating_ui:
		return
	if pressed:
		mode_changed.emit(MODE_MANUAL)


func _on_auto_toggled(pressed: bool) -> void:
	if _updating_ui:
		return
	if pressed:
		mode_changed.emit(MODE_AUTOTILE)
