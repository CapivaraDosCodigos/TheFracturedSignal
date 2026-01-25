extends PanelContainer
class_name BattleSubmenuBase

signal finished(result: MenuResult)

var _active: bool = false
var _result: MenuResult

func open() -> MenuResult:
	_active = true
	visible = true
	_result = null

	while _result == null:
		await get_tree().process_frame

	_active = false
	visible = false
	return _result

func cancel() -> void:
	if not _active:
		return

	_result = MenuResult.cancel()

func confirm(data: Dictionary) -> void:
	if not _active:
		return

	_result = MenuResult.ok(data)
