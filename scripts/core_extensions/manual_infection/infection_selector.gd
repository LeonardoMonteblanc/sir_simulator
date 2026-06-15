extends PanelContainer

# Painel para escolher quais agentes serao pacientes zero do surto.
# Feature isolada em core_extensions/manual_infection/.
# NAO modifica o core: consome SEIRDModel.set_initial_infected() (novo metodo publico).

signal confirmar_pressed(ids: Array)
signal cancelar_pressed

@onready var _grid: GridContainer = $Layout/Scroll/Grid
@onready var _btn_confirmar: Button = $Layout/Botoes/BtnConfirmar
@onready var _btn_cancelar: Button = $Layout/Botoes/BtnCancelar
@onready var _label_info: Label = $Layout/LabelInfo

const COLUNAS: int = 5

var _agentes_ref: Array = []
var _selecionados: Dictionary = {}  # id -> bool

func _ready() -> void:
	_btn_confirmar.pressed.connect(_on_confirmar)
	_btn_cancelar.pressed.connect(_on_cancelar)
	_grid.columns = COLUNAS

# Recebe lista de agentes e popula grid com checkboxes.
func popular(agentes: Array) -> void:
	_agentes_ref = agentes
	_selecionados.clear()
	# limpa grid
	for c in _grid.get_children():
		c.queue_free()
	for ag in agentes:
		var cb := CheckBox.new()
		cb.text = "Ave %d" % ag.id
		cb.name = "cb_%d" % ag.id
		cb.toggled.connect(_on_toggled.bind(ag.id))
		_grid.add_child(cb)
	_atualizar_info()

func _on_toggled(pressed: bool, agent_id: int) -> void:
	if pressed:
		_selecionados[agent_id] = true
	else:
		_selecionados.erase(agent_id)
	_atualizar_info()

func _atualizar_info() -> void:
	if is_instance_valid(_label_info):
		_label_info.text = "%d selecionados de %d" % [_selecionados.size(), _agentes_ref.size()]

func _on_confirmar() -> void:
	var ids: Array = []
	for k in _selecionados.keys():
		ids.append(int(k))
	confirmar_pressed.emit(ids)

func _on_cancelar() -> void:
	cancelar_pressed.emit()
