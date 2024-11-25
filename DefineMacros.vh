`ifdef SIMULATION
`define DRUMNOTEADDRESSLENGTH 3
`else
`define DRUMNOTEADDRESSLENGTH 2938
`endif


`define STARTSCREEN 5'd0
`define RECORD 5'd1
`define PLAYBACK 5'd2
`define RESTARTPLAYBACK 5'd3

`define NUMBEROFKEYBOARDINPUTS 36


// -------------- Colours ----------------
`define COLOURWHITE 24'b11111111_11111111_11111111
`define COLOURBLACK 24'b00000000_00000000_00000000
`define COLOURWHENWHITEPRESSED 24'b11111111_00000000_10100101
`define COLOURWHENBLACKPRESSED 24'b11111111_10100101_00000000

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

`define keyF 28
`define keyG 29
`define keyH 30
`define keyJ 31
`define keySpacebar 32
`define keyEnter 33
`define keyReleasePulse 34
`define keyPressPulse 35

// -------- Sub-States Used in mainStatehandler ----------
`define subIDLE 4'd0
`define subSTARTNOTERECORDING 4'd1
`define subWRITESTARTOFNOTE 4'd2
`define subAWAITNOTEEND 4'd3
`define subRESETPLAYBACK 4'd4
`define subPLAYDRUMNOTE 4'd5
`define subCLEARMEMORY 4'd6

`define subWRITEENDOFNOTE 4'd4

`define subSCANMEMORYFORWRITEEND 4'd5


`define subDRAWNEWNOTEBLOCK 4'd7
`define subDRAWNOTEBLOCK 4'd8
`define subDONEDRAWING 4'd9