BattleCommand_batonpass:
	call CheckAnyOtherAliveMons
	jr z, .failed

	call BattleCommand_lowersub
	call LoadMoveAnim
	ld c, 20
	call DelayFrames
	ld a, 1 << SWITCH_DEFERRED | 1 << SWITCH_BATON_PASS
	jmp SetDeferredSwitch

.failed
	call AnimateFailedMove
	jmp PrintButItFailed
