class_name RunState
extends RefCounted
## State of one run (one island visit): whether the player is still digging,
## has returned to the boat, or has failed by being on the island at full tide.
## Pure data, no scene dependency, so it can be unit-tested without a running
## game. Implements design/game-brief.md "Player goal & fail state"
## (story-003-tide-timer); story 006 adds the return action via mark_returned().

## Phases of a run. A run starts DIGGING and ends in exactly one of RETURNED
## (back at the boat before full tide) or FAILED (full tide while on the island).
enum Phase { DIGGING, RETURNED, FAILED }

## Emitted once each time `phase` changes.
signal phase_changed(new_phase: Phase)

## Current phase of the run.
var phase: Phase = Phase.DIGGING


## Returns true while dig taps are accepted: only in the DIGGING phase.
func can_dig() -> bool:
	return phase == Phase.DIGGING


## Returns true while the treasure collected this run still counts toward the
## carry-home score. A FAILED run's treasure is lost (brief: 失敗 ... その回の宝は
## すべて失い).
func treasure_counts() -> bool:
	return phase != Phase.FAILED


## Moves DIGGING -> FAILED when `timer` has reached full tide. A run that has
## already RETURNED (the "舟に戻った" flag, set by story 006) cannot fail.
func update_from_tide(timer: TideTimer) -> void:
	if phase == Phase.DIGGING and timer.is_full():
		_set_phase(Phase.FAILED)


## Marks the player as back at the boat (DIGGING -> RETURNED). Defined here as
## the flag the fail check reads; story 006's boat-return action calls it.
## Has no effect once the run has FAILED.
func mark_returned() -> void:
	if phase == Phase.DIGGING:
		_set_phase(Phase.RETURNED)


func _set_phase(new_phase: Phase) -> void:
	phase = new_phase
	phase_changed.emit(new_phase)
