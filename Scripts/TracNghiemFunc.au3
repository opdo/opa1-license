;TracNghiemFunc.au3
Func _learn_CheckTip($number)
	Local $max = number(_IniRead($Database, 'Meo1', 'Tong', ''))
	Local $flag = 0
	for $i = 1 to $max
		if StringInStr(_IniRead($Database, 'Meo'&$i, 'Cauhoi', ''),','&$number&',') > 0 Then
			$flag = $i
			ExitLoop
		EndIf
	Next
	Return $flag
EndFunc

Func _learn_Next()
	Local $number = Number(GUICtrlRead($learn_input))
	If $number < 150 Then $number += 1
	_myLearn_Load($number)
EndFunc   ;==>_learn_Next

Func _learn_Pre()
	Local $number = Number(GUICtrlRead($learn_input))
	If $number > 1 Then $number -= 1
	_myLearn_Load($number)
EndFunc   ;==>_learn_Pre

Func _learn_Load()
	Local $number = Number(GUICtrlRead($learn_input))
	If $number > 0 And $number <= 150 Then _myLearn_Load($number)
EndFunc   ;==>_learn_Load

Func _myLearn_Load($number)
	GUICtrlSetData($learnText_cauhoi, _IniRead($Database, $number, 'Cauhoi', ''))
	GUICtrlSetData($learn_input, $number)
	GUICtrlSetData($learnText_number, 'CÂU ' & $number)
	Local $temp = Number(_learn_CheckTip($number))
	if $temp > 0 then
		Local $text = ''
		Local $temp2 = StringSplit(_IniRead($Database, 'Meo'&$temp, 'MeoBt', ''),'|')
		for $i=1 to $temp2[0]
			if $text = '' Then
				$text = $temp2[$i]
				Else
				$text = $text&@CRLF&$temp2[$i]
			EndIf
		Next
		;GUICtrlSetData($learn_Meo,$text)
		GUICtrlSetState($learnButton_meo,$GUI_SHOW)
		GUICtrlSetData($learn_tiphidden,$text)
		
		Else
		GUICtrlSetState($learnButton_meo,$GUI_HIDE)
		;GUICtrlSetData($learn_Meo,'')
	EndIf
	_myOption_Load($myOption, $number)
EndFunc   ;==>_myLearn_Load
; Ôn tập
Func _review_Chon1()
	_review_Chon($reviewOption[1])
EndFunc   ;==>_review_Chon1
Func _review_Chon2()
	_review_Chon($reviewOption[2])
EndFunc   ;==>_review_Chon2
Func _review_Chon3()
	_review_Chon($reviewOption[3])
EndFunc   ;==>_review_Chon3
Func _review_Chon4()
	_review_Chon($reviewOption[4])
EndFunc   ;==>_review_Chon4
Func _review_Chon($idCtrl)
	Local $text = GUICtrlRead($idCtrl)
	$text = StringLeft($text, 1)
	If $text = '☐' Then
		$text = '☑'
	Else
		$text = '☐'
	EndIf
	GUICtrlSetData($idCtrl, $text & StringTrimLeft(GUICtrlRead($idCtrl), 1))
EndFunc   ;==>_review_Chon
Func _review_Next()
	Local $number = Number(GUICtrlRead($review_input))
	If $number < 150 Then $number += 1
	If _myReview_CheckKQ() Then _myReview_Load($number)
EndFunc   ;==>_review_Next

Func _review_Pre()
	Local $number = Number(GUICtrlRead($review_input))
	If $number > 1 Then $number -= 1
	If _myReview_CheckKQ() Then _myReview_Load($number)
EndFunc   ;==>_review_Pre

Func _review_Load()
	Local $number = Number(GUICtrlRead($review_input))
	If $number > 0 And $number <= 150 And _myReview_CheckKQ() Then _myReview_Load($number)

EndFunc   ;==>_review_Load


Func _myReview_Load($number)
	GUICtrlSetData($reviewText_cauhoi, _IniRead($Database, $number, 'Cauhoi', ''))
	GUICtrlSetData($review_input, $number)
	GUICtrlSetData($reviewText_number, 'CÂU ' & $number)
	_myOption_Load($reviewOption, $number, False)
	For $i = 1 To 4
		GUICtrlSetData($reviewOption[$i], '☐ ' & GUICtrlRead($reviewOption[$i]))
	Next
EndFunc   ;==>_myReview_Load

Func _myReview_CheckKQ()
	Local $kq = ''
	Local $number = StringReplace(GUICtrlRead($reviewText_number), 'CÂU ', '')
	For $i = 1 To 4
		If _IniRead($Database, $number, $i, '') = '' Then ExitLoop
		Local $text = GUICtrlRead($reviewOption[$i])
		$text = StringLeft($text, 1)
		If $text = '☑' Then $kq = $kq & $i
	Next
	
	
	Local $dapan = _IniRead($Database, $number, 'Dapan', '')
	
	If $kq <> $dapan Then
		GUICtrlSetBkColor($reviewText_number, 0xE80000)
		
		$dapan = StringSplit($dapan, '')
		For $i = 1 To $dapan[0]
			
			GUICtrlSetColor($reviewOption[$dapan[$i]], 0xE80000)
			GUICtrlSetFont($reviewOption[$dapan[$i]], 11, 600, 0, "Segoe UI Semibold")
			

		Next
		Return False
	Else
		GUICtrlSetBkColor($reviewText_number, 0x0063B1)
		Return True
	EndIf
EndFunc   ;==>_myReview_CheckKQ
; _Option_Create tạo trắc nghiệm
Func _myOption_Load(ByRef $control, $number, $show_dap_an = True,$thi = False)
	Local $style = 1
	
	If $number >= 81 And $number <= 115 Then $style = 2
	Local $y, $x, $x_max , $w, $x
	if $thi then
	$y = 260
	$x = 50
	$x_max = 0
	$w = 435
	$x2 = $x + 240
		Else
	$y = 344
	$x = 80
	$x_max = 0
	$w = 680
	$x2 = $x + 360
	EndIf
	
	If $style = 2 Then $w = 300
	If _IniRead($Database, $number, 'Pic', '') = '' Then
		GUICtrlSetState($control[0], $GUI_HIDE)
		if $thi then
			$y = 130
			Else
			$y = 221
		EndIf
		
	Else
		If $style = 1 and not $thi Then
			$x = 170
		ElseIf $style = 1 Then
			$x = 120
		EndIf
		If $style = 2 and $thi Then
			$w = 175
		ElseIf $style = 2 Then
			$w = 300
		EndIf
		GUICtrlSetImage($control[0], @ScriptDir & '\Images\Pic\' & _IniRead($Database, $number, 'Pic', '') & '.jpg')
		GUICtrlSetState($control[0], $GUI_SHOW)
	EndIf
	For $i = 1 To 4
		Local $text = _IniRead($Database, $number, $i, '')
		If $text <> '' Then
			
			Local $test = _StringSize($text, 11, 400, 0, "Segoe UI", $w)
			GUICtrlSetData($control[$i], $text)
			If $style = 1 Then
				GUICtrlSetPos($control[$i], $x, $y, $w, $test[3])
				$y += $test[3] + 8
			Else
				If $test[3] > $x_max Then $x_max = $test[3]
				
				If Mod($i, 2) = 1 Then
					If $i <> 1 Then $y += $x_max + 8
					GUICtrlSetPos($control[$i], $x, $y, $w, $x_max)
				Else
					GUICtrlSetPos($control[$i], $x2, $y, $w, $x_max)
				EndIf
				
			EndIf
			GUICtrlSetFont($control[$i], 11, 400, 0, "Segoe UI")
			GUICtrlSetColor($control[$i], 0x000000)
			If $show_dap_an Then
				Local $dapan = _IniRead($Database, $number, 'Dapan', '')
				If StringInStr($dapan, String($i)) > 0 Then
					GUICtrlSetFont($control[$i], 11, 600, 0, "Segoe UI Semibold")
					GUICtrlSetColor($control[$i], 0x0063B1)
				EndIf
			EndIf
			GUICtrlSetState($control[$i], $GUI_SHOW)
		Else
			GUICtrlSetState($control[$i], $GUI_HIDE)
		EndIf
	Next
EndFunc   ;==>_myOption_Load

Func _myOption_Create()
	Local $control[5]
	$control[0] = GUICtrlCreatePic("", 170, 170, 385, 156, -1, -1)
	GUICtrlSetState(-1, $GUI_HIDE)
	For $i = 1 To 4
		$control[$i] = GUICtrlCreateLabel("Test", 0, 0, 0, 0)
		GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
		GUICtrlSetBkColor(-1, "-2")
		GUICtrlSetState(-1, $GUI_HIDE)
	Next
	Return $control
EndFunc   ;==>_myOption_Create
