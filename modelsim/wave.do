onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLOCK_50 -radix binary /testbench/CLOCK_50
#add wave -noupdate -label KEY -radix binary /testbench/KEY
add wave -noupdate -label HEX2 -radix binary /testbench/HEX2
add wave -noupdate -label HEX1 -radix binary /testbench/HEX1
add wave -noupdate -label HEX0 -radix binary /testbench/HEX0
add wave -noupdate -divider Main
add wave -noupdate -label currentState -unsigned /testbench/U1/masterFSM/currentState
add wave -noupdate -label currentSubState -unsigned /testbench/U1/mainStateDrumsController/currentSubState
#add wave -noupdate -label inputStateStorage -radix binary {/testbench/U1/inputStateStorage[30:26]}
add wave -noupdate -label keyF -radix binary {/testbench/U1/inputStateStorage[28]}
add wave -noupdate -label keyG -radix binary {/testbench/U1/inputStateStorage[29]}
add wave -noupdate -label playDrumNote -unsigned /testbench/U1/mainStateDrumsController/playDrumNote
#add wave -noupdate -label keyY -radix binary {/testbench/U1/inputStateStorage[20]}
#add wave -noupdate -label keyT -radix binary {/testbench/U1/inputStateStorage[19]}
add wave -noupdate -divider NoteStorage
add wave -noupdate -label resetTimer -unsigned /testbench/U1/mainStateDrumsController/resetTimer
add wave -noupdate -label microSecondCounter -unsigned /testbench/U1/mainStateDrumsController/microSecondCounter
add wave -noupdate -label currentNoteDataNote -unsigned {/testbench/U1/mainStateDrumsController/currentNoteData[30:29]}
add wave -noupdate -label currentNoteDataTime -unsigned {/testbench/U1/mainStateDrumsController/currentNoteData[28:0]}
add wave -noupdate -label memoryWriteEnable -unsigned {/testbench/U1/mainStateDrumsController/memoryWriteEnable}
add wave -noupdate -label noteReadAddress -unsigned /testbench/U1/mainStateDrumsController/noteReadAddress
add wave -noupdate -label noteWriteAddress -unsigned /testbench/U1/mainStateDrumsController/noteWriteAddress
add wave -noupdate -label retrievedNoteDataNote -unsigned {/testbench/U1/mainStateDrumsController/retrievedNoteData[30:29]}
add wave -noupdate -label retrievedNoteDataTime -unsigned {/testbench/U1/mainStateDrumsController/retrievedNoteData[28:0]}

#add wave -noupdate -label leftDrumAmp -unsigned /testbench/U1/leftDrumAmplitude
#add wave -noupdate -label leftDrumAdd -radix decimal /testbench/U1/leftDrumAddress
#add wave -noupdate -label outputAmplitude -radix decimal /testbench/U1/outputAmplitude
add wave -noupdate -label outputSound -radix decimal {/testbench/U1/outputSound}
add wave -noupdate -label bassAddress -unsigned {/testbench/U1/bassAddress}
add wave -noupdate -label donePlayingDrumNote -radix binary {/testbench/U1/donePlayingDrumNote}
add wave -noupdate -divider DrumTimer
#add wave -noupdate -label DrumTimer -unsigned {/testbench/U1/timerCounter}
add wave -noupdate -label samplesPerSecondCounter -radix decimal /testbench/U1/samplesPerSecondCounter

#add wave -noupdate -divider ScreenReseter
#add wave -noupdate -label BassdrumColour -unsigned /testbench/U1/screenReseter/bassDrumColour
#add wave -noupdate -label BassdrumAddress -unsigned /testbench/U1/screenReseter/BassdrumAddress






TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 200
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
#250 us
WaveRestoreZoom {0 ps} {3 us}
