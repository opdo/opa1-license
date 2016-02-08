;Thi.au3
Func _ThiButton_Done()
Local $text1 = GUICtrlRead($thi_text)
if StringInStr($text1,'DAPAN') = 0 Then
Local $caudung = 0
GUICtrlSetData($thi_done,'THOÁT')
$thiTime = 0
Local $text = StringSplit($text1,'@')
GUICtrlSetData($thi_text,$text1&'@DAPAN')
Local $de = $text[2]
For $i = 0 to 19
	Local $control = $thiButton[$i]
	Local $traloi = ''
	for $j = 1 to 4
		if StringRight(GUICtrlRead($control[$j]),1) = '☑' and BitAnd(GUICtrlGetState($control[$j]),$GUI_SHOW) = $GUI_SHOW then $traloi = $traloi&$j
	Next
	
	Local $dapan = _IniRead($Database, $dethi[$de-1][$i], 'Dapan', '')
	if $dapan <> $traloi Then
			GUICtrlSetBkColor($control[5],0xFF2222)
		Else
			$caudung += 1
			GUICtrlSetBkColor($control[5],0x25C7F5)
	EndIf
Next
RegWrite($regedit,'Learn_3','REG_SZ',Number(RegRead($regedit,'Learn_3'))+1)
if $caudung >= 16 then 
	RegWrite($regedit,'Learn_4','REG_SZ',Number(RegRead($regedit,'Learn_4'))+1)
	RegWrite($regedit,'Learn_5','REG_SZ',Number(RegRead($regedit,'Learn_5'))+$caudung)
	if Number(RegRead($regedit,'Learn_5')) > 100 Then RegWrite($regedit,'Learn_5','REG_SZ',100)
	Else
	RegWrite($regedit,'Learn_5','REG_SZ',Number(RegRead($regedit,'Learn_5'))-(20-$caudung))
	if Number(RegRead($regedit,'Learn_5')) < 100 Then RegWrite($regedit,'Learn_5','REG_SZ',0)
EndIf
_KetQua_ShowGUI($caudung)
Else
_HideGUI_Thi()
EndIf

EndFunc

Func _ThiButton_Load(ByRef $control,$de)
	GUICtrlSetBkColor($thi_timeprocess,0x0063B1)  
	GUICtrlSetPos($thi_timeprocess,Default,Default,517)
	GUICtrlSetData($thi_timetext,'100%')
	$thiTime = 15*60
	GUICtrlSetData($thi_timetext2,'THỜI GIAN CÒN LẠI: 15:00')
	GUICtrlSetData($thi_text,"1@"&$de)
	for $i = 0 to 19
		Local $test = $control[$i]
		SSCtrlHover_Register($test[0], "FnNormal", 2, "FnHover", 2,"FnActive",2,"FnClick",$i+1&"@"&$de)
		GUICtrlSetBkColor($test[5],0x0063B1)
		for $j = 3 to 4
			if _IniRead($Database, $dethi[$de-1][$i], $j, '') = '' Then
				_ThiButton_Hide($control[$i],$j)
				Else
				_ThiButton_Hide($control[$i],$j,False)
			EndIf
		Next
	Next
	_thi_Load(1)
	$timeDiff = TimerInit()
EndFunc


Func _thi_Load($number)
	Local $text1 = GUICtrlRead($thi_text)
	Local $text = StringSplit($text1,'@')
	Local $control = $thiButton[$text[1]-1]
	GUICtrlSetState($control[0],$GUI_ENABLE)
	GUICtrlSetBkColor($control[0],0xFFFFFF)
	if StringInStr($text1,'DAPAN') = 0 Then 
		GUICtrlSetData($thi_text,$number&'@'&$text[2])
		Else
		GUICtrlSetData($thi_text,$number&'@'&$text[2]&'@DAPAN')
	EndIf

	$control = $thiButton[$number-1]
	GUICtrlSetBkColor($control[0],0xFFA74F)
	if StringInStr($text1,'DAPAN') = 0 then GUICtrlSetState($control[0],$GUI_DISABLE)
	Dim $thi_keyoption[8][2]=[["{F1}", $control[1]], ["{F2}", $control[2]], ["{F3}", $control[3]], ["{F4}", $control[4]], ["{up}", $thi_pre], ["{down}", $thi_next], ["{left}", $thi_up], ["{right}", $thi_down]]
	GUISetAccelerators($thi_keyoption,$GUI_Thi)
	GUICtrlSetData($thi_cauhoi,_IniRead($Database,  $dethi[$text[2]-1][$number-1], 'cauhoi', ''))
	if StringInStr($text1,'DAPAN') = 0 then 
		_myOption_Load($thiOption, $dethi[$text[2]-1][$number-1], False,True)
		Else
		_myOption_Load($thiOption, $dethi[$text[2]-1][$number-1], True,True)
	EndIf
EndFunc   ;==>_myReview_Load

Func _thiOption_Create()
	Local $control[5]
	$control[0] = GUICtrlCreatePic("", 100, 100, 310, 130, -1, -1)
	GUICtrlSetState(-1, $GUI_HIDE)
	For $i = 1 To 4
		$control[$i] = GUICtrlCreateLabel("Test", 0, 0, 0, 0)
		GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
		GUICtrlSetBkColor(-1, "-2")
		GUICtrlSetState(-1, $GUI_HIDE)
	Next
	Return $control
EndFunc   ;==>_myOption_Create

Func _thi_Next()
Local $text1 = GUICtrlRead($thi_text)
Local $text = StringSplit($text1,'@')
Local $id = Number($text[1])
if $id < 20 Then
		$id += 1
	Else
		$id = 1
EndIf
_thi_Load($id)
EndFunc
Func _thi_Pre()
Local $text1 = GUICtrlRead($thi_text)
Local $text = StringSplit($text1,'@')
Local $id = Number($text[1])
if $id > 1 Then
		$id -= 1
	Else
		$id = 20
EndIf
_thi_Load($id)
EndFunc


Func _thi_Chon1()
	_thi_Chon(1)
EndFunc
Func _thi_Chon2()
	_thi_Chon(2)
EndFunc
Func _thi_Chon3()
	_thi_Chon(3)
EndFunc
Func _thi_Chon4()
	_thi_Chon(4)
EndFunc

Func _thi_Chon($chon)
Local $text1 = GUICtrlRead($thi_text)
Local $text = StringSplit($text1,'@')
Local $id = $text[1]
Local $control = $thiButton[$id-1]
Local $idCtrl = $control[$chon]
if StringRight(GUICtrlRead($idCtrl),1) == '☐' Then
			GUICtrlSetData($idCtrl,StringTrimRight(GUICtrlRead($idCtrl),1)&'☑')
			Else
			GUICtrlSetData($idCtrl,StringTrimRight(GUICtrlRead($idCtrl),1)&'☐')
EndIf
EndFunc


Func _KetQua_ShowGUI($caudung)
	GUICtrlSetData($thi_doneText_1,'  '&$caudung)
	GUICtrlSetData($thi_doneText_2,'  '&20-$caudung)
	if $caudung >= 16 Then
		GUICtrlSetData($thi_doneText_3,'  ĐẠT')
		GUICtrlSetFont($thi_doneText_3,11,600,0,"Segoe UI Semibold")
		GUICtrlSetColor($thi_doneText_3,"0x0000FF")
	Else
		GUICtrlSetData($thi_doneText_3,'  KHÔNG ĐẠT')
		GUICtrlSetFont($thi_doneText_3,11,600,0,"Segoe UI Semibold")
		GUICtrlSetColor($thi_doneText_3,"0xFF0000")
	EndIf
	_ShowGUI($GUI_Thi_Done)
EndFunc
Func _KetQua_HideGUI()
	_HideGUI($GUI_Thi_Done)
EndFunc