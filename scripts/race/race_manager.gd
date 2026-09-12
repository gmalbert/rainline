class_name RaceManager
extends Node

signal countdown_changed(value: int)
signal race_started
signal checkpoint_reached(index: int, split_ms: int)
signal wrong_checkpoint(index: int, expected: int)
signal race_finished(time_ms: int, medal: String)

enum State { WAITING, COUNTDOWN, RACING, FINISHED }

@export var event: RaceEventDefinition
var state := State.WAITING
var checkpoint_count := 0
var current_checkpoint := 0
var race_start_msec := 0
var finish_time_ms := 0
var elapsed_seconds := 0.0

func _process(delta: float) -> void:
	if state == State.RACING: elapsed_seconds += delta

func configure(checkpoints: int, definition: RaceEventDefinition) -> void:
	checkpoint_count = checkpoints
	event = definition

func begin_countdown() -> void:
	if state != State.WAITING: return
	state = State.COUNTDOWN
	for value in range(3, 0, -1):
		countdown_changed.emit(value)
		await get_tree().create_timer(1.0).timeout
	countdown_changed.emit(0)
	state = State.RACING
	race_start_msec = Time.get_ticks_msec()
	elapsed_seconds = 0.0
	race_started.emit()

func try_checkpoint(index: int) -> bool:
	if state != State.RACING: return false
	if index != current_checkpoint:
		wrong_checkpoint.emit(index, current_checkpoint)
		return false
	checkpoint_reached.emit(index, elapsed_ms())
	current_checkpoint += 1
	if current_checkpoint >= checkpoint_count:
		finish_time_ms = elapsed_ms()
		state = State.FINISHED
		race_finished.emit(finish_time_ms, medal_for(finish_time_ms))
	return true

func elapsed_ms() -> int:
	if state == State.FINISHED: return finish_time_ms
	if state != State.RACING: return 0
	return roundi(elapsed_seconds * 1000.0)

func medal_for(time_ms: int) -> String:
	if time_ms <= event.gold_time_ms: return "GOLD"
	if time_ms <= event.silver_time_ms: return "SILVER"
	if time_ms <= event.bronze_time_ms: return "BRONZE"
	return "FINISH"
