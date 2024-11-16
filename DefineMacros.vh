`define STARTSCREEN 5'd0
`define RECORD 5'd1
`define PLAYBACK 5'd2
`define RESTARTPLAYBACK 5'd3

`define NUMBEROFKEYBOARDINPUTS 30


// ---------- Keyboard Keys Mapped to an ID ---------
`define key0 0
`define key1 1
`define key2 2
`define key3 3
`define key4 4
`define key5 5
`define key6 6
`define key7 7
`define key8 8
`define key9 9
`define keyTilda 10
`define keyMinus 11
`define keyEquals 12
`define keyBackspace 13
`define keyTab 14
`define keyQ 15
`define keyW 16
`define keyE 17
`define keyR 18
`define keyT 19
`define keyY 20
`define keyU 21
`define keyI 22
`define keyO 23
`define keyP 24
`define keyLSquareBracket 25
`define keyRSquareBracket 26
`define keyBackslash 27
`define keySpacebar 28
`define keyReleasePulse 29
`define keyPressPulse 30

// -------- Sub-States Used in mainStatehandler ----------
`define subIDLE 4'd0
`define subSTARTNOTERECORDING 4'd1
`define subRECORDSTARTOFNOTE 4'd2
`define subWRITEENDOFNOTE 4'd3
`define subRESETPLAYBACK 4'd4
`define subDRAWNOTEBLOCK 4'd5
`define subDRAWNEWLINEOFNOTEBLOCK 4'd6
`define subDRAWNEXTNOTEBLOCK 4'd7
`define subDONEDRAWING 4'd8