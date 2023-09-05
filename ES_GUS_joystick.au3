;EARTHSHAKER PC-JAMMA Interface - Game Utility Script (GUS)
;
;JOYSTICK VERSION
;
;by Barito 2021 (last update sept 2023)

#include <Misc.au3>

_Singleton("ES_GUS", 0) ;allows only one instance of the program

Local $hDLL = DllOpen("user32.dll")
Local $iPID
Local $gameRom = "buggyboyjr" 		;<-- DEFINE YOUR STARTING GAME ROM HERE
Local $maxRoms = 10;
Local $a = 1

Local $prevCoor
Local $specCoor

;joystick setup
Local $joy,$coor,$h,$s,$msg
$joy = _JoyInit()

;RandomGame() ;uncomment this if you want a random game on start
GameRun()

While 1
    MainJoypad()
	Sleep(30) ;keep CPU cool
WEnd
$lpJoy = 0 ; Joyclose
DllClose($hDLL)

Func MainJoypad()
$coor = _GetJoy($joy, 0)
if $coor[7] <> $prevCoor Then ;not equal
$specCoor = $coor[7] - $prevCoor
$prevCoor = $coor[7]
  If $specCoor == 32  Then         ;<-- DEFINE THE GAME CHANGE BUTTON HERE (use "Joystick_Test.exe" to determine the correct number)
	$a = $a+1
	If $a > $maxRoms Then
		$a = 1
	EndIf
	GameSelect()
	;ProcessClose($iPID) ;MAME don't save changes if killed this way
    fESC();this will let MAME save any modification to games configuration settings and hiscores
	GameRun()
	Sleep (2000) ; cheap block against multiple presses
  EndIf
  If $specCoor == 64  Then        ;<-- DEFINE THE SHUT DOWN BUTTON HERE (use "Joystick_Test.exe" to determine the correct number)
	fESC() ;this will let MAME save any modification to games configuration settings and hiscores
	Sleep (500)
	Shutdown(5); shutdown (1) + force (4)
	Sleep (2000) ; cheap block against multiple presses
  EndIf
EndIf
EndFunc

Func RandomGame()
Local $randNum = Random(1, $maxRoms, 1)
$a = $randNum
GameSelect()
EndFunc

Func GameSelect()				;<-- DEFINE YOUR GAMES ROMS LIST HERE
If $a == 1 Then
	$gameRom = "buggyboyjr"
ElseIf $a == 2 Then
	$gameRom = "polepos2"
ElseIf $a == 3 Then
	$gameRom = "contcirc"
ElseIf $a == 4 Then
	$gameRom = "roadblst"
ElseIf $a == 5 Then
	$gameRom = "outrun"
ElseIf $a == 6 Then
	$gameRom = "pdrift"
ElseIf $a == 7 Then
	$gameRom = "radm"
ElseIf $a == 8 Then
	$gameRom = "sci"
ElseIf $a == 9 Then
	$gameRom = "wrally"
ElseIf $a == 9 Then
	$gameRom = "chasehq"
Else;If $a == 5 Then
	$gameRom = "csprint"
EndIf
EndFunc

Func GameRun()
$MAMEpath = "C:\MAME\"       ;<-- DEFINE YOUR MAME.EXE PATH HERE
$ROMpath = "C:\MAME\roms\"   ;<-- DEFINE YOUR MAME ROMS PATH HERE
$iPID = ShellExecute ("mame.exe", $ROMpath&$gameRom, $MAMEpath)
EndFunc

Func fESC()
	Send("{ESC down}") ;this will let MAME save any modification to games configuration settings and hiscores
	Sleep (100)
	Send("{ESC up}")
	Sleep (400)
EndFunc

;   _JoyInit()
Func _JoyInit()
    Local $joy
    Global $JOYINFOEX_struct    = "dword[13]"
    $joy=DllStructCreate($JOYINFOEX_struct)
    if @error Then Return 0
    DllStructSetData($joy, 1, DllStructGetSize($joy), 1);dwSize = sizeof(struct)
    DllStructSetData($joy, 1, 255, 2)              ;dwFlags = GetAll
    return $joy
 EndFunc

 ;======================================
;   _GetJoy($lpJoy,$iJoy)
;   $lpJoy  Return from _JoyInit()
;   $iJoy   Joystick # 0-15
;   Return  Array containing X-Pos, Y-Pos, Z-Pos, R-Pos, U-Pos, V-Pos,POV
;           Buttons down
;
;           *POV This is a digital game pad, not analog joystick
;           65535   = Not pressed
;           0       = U
;           4500    = UR
;           9000    = R
;           Goes around clockwise increasing 4500 for each position
;======================================
Func _GetJoy($lpJoy,$iJoy)
    Local $coor,$ret

    Dim $coor[8]
    DllCall("Winmm.dll","int","joyGetPosEx", _
            "int",$iJoy, _
            "ptr",DllStructGetPtr($lpJoy))

    if Not @error Then
        $coor[0]    = DllStructGetData($lpJoy,1,3)
        $coor[1]    = DllStructGetData($lpJoy,1,4)
        $coor[2]    = DllStructGetData($lpJoy,1,5)
        $coor[3]    = DllStructGetData($lpJoy,1,6)
        $coor[4]    = DllStructGetData($lpJoy,1,7)
        $coor[5]    = DllStructGetData($lpJoy,1,8)
        $coor[6]    = DllStructGetData($lpJoy,1,11)
        $coor[7]    = DllStructGetData($lpJoy,1,9)
    EndIf

    return $coor
EndFunc
