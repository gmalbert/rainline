class_name RaceManager
extends Node

signal countdown_changed(value: int)
signal race_started
signal checkpoint_reached(index: int, split_ms: int)
signal race_finished(time_ms: int)

enum State { WAITING, COUNTDOWN, RACING, FINISHED }

@export var checkpoint_count: int = 1
@export var countdown_seconds: int = 3

var state: State = State.WAITING
var current_checkpoint: int = 0
var race_start_msec: int = 0
var finish_time_ms: int = 0

func begin_countdown() -> void:
    if state != State.WAITING:
        return
    state = State.COUNTDOWN
    _countdown_async()

func _countdown_async() -> void:
    for value in range(countdown_seconds, 0, -1):
        countdown_changed.emit(value)
        await get_tree().create_timer(1.0).timeout
    countdown_changed.emit(0)
    start_race()

func start_race() -> void:
    current_checkpoint = 0
    finish_time_ms = 0
    race_start_msec = Time.get_ticks_msec()
    state = State.RACING
    race_started.emit()

func try_checkpoint(index: int) -> bool:
    if state != State.RACING:
        return false
    if index != current_checkpoint:
        return false

    var split := elapsed_ms()
    checkpoint_reached.emit(index, split)
    current_checkpoint += 1

    if current_checkpoint >= checkpoint_count:
        finish_race()
    return true

func finish_race() -> void:
    if state != State.RACING:
        return
    finish_time_ms = elapsed_ms()
    state = State.FINISHED
    race_finished.emit(finish_time_ms)

func elapsed_ms() -> int:
    if state == State.WAITING or state == State.COUNTDOWN:
        return 0
    if state == State.FINISHED:
        return finish_time_ms
    return Time.get_ticks_msec() - race_start_msec

func restart() -> void:
    get_tree().reload_current_scene()
