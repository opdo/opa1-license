;GUIController.au3



; đổi tên
Func _Input_ChangeName()
	Local $AccelKeys[1][2] = [["{enter}", $name_ok]]
	GUISetAccelerators($AccelKeys, $GUI_Change_Name)
	GUICtrlSetData($name_input, '')
	GUISetState(@SW_LOCK, $GUI_Main)
	_ShowGUI($GUI_Change_Name)
EndFunc   ;==>_Input_ChangeName
Func _Change_Name()

	Local $input = GUICtrlRead($name_input)
	If $input <> '' Then
		If StringLen($input) < 10 Then
			RegWrite($regedit, 'name', 'REG_SZ', $input)
			_LoadInfo()
			_Change_Name_Close()
		Else
			WinSetOnTop($GUI_Change_Name, '', 0)
			MsgBox(16, 'Thông báo', 'Xin lỗi, bạn chỉ được nhập tối đa 10 ký tự :(')
			WinSetOnTop($GUI_Change_Name, '', 1)
		EndIf
	Else
		WinSetOnTop($GUI_Change_Name, '', 0)
		MsgBox(16, 'Thông báo', 'Bạn chưa nhập tên mà :(')
		WinSetOnTop($GUI_Change_Name, '', 1)
	EndIf
EndFunc   ;==>_Change_Name
Func _Change_Name_Close()
	GUISetState(@SW_UNLOCK, $GUI_Main)

	GUISetState(@SW_SHOW, $GUI_Main)
	_HideGUI($GUI_Change_Name)
EndFunc   ;==>_Change_Name_Close
; hiệu ứng gui
Func _ShowGUI($gui)
	WinSetTrans($gui, '', 0)
	GUISetState(@SW_SHOW, $gui)
	For $i = 1 To 255 Step 10
		Sleep(12)
		WinSetTrans($gui, '', $i)
	Next
	WinSetTrans($gui, '', 255)
EndFunc   ;==>_ShowGUI

Func _HideGUI($gui)

	For $i = 255 To 1 Step -10
		Sleep(12)
		WinSetTrans($gui, '', $i)
	Next
	GUISetState(@SW_HIDE, $gui)
	WinSetTrans($gui, '', 255)
EndFunc   ;==>_HideGUI

; linh tinh
Func _LoadGUI()


	GUISwitch($GUI_Main)
	_LoadGUIMain()
	_LoadInfo()
	GUISwitch($GUI_Learn)
	_LoadGUILearn()

	GUISwitch($GUI_Review)
	_LoadGUIReview()

	GUISwitch($GUI_Thi)
	_LoadGUIThi()

	GUISwitch($GUI_Video)
	Global $video_Control = _GUICtrl_CreateWMPlayer(@DesktopDir & '\thuchanh.mp4', 0, 82, 801, 437)
	Global $playerOBJ = _IEGetObjById($video_Control, "objWMPlayer")

EndFunc   ;==>_LoadGUI
Func _File_Help()
	ShellExecute(@ScriptDir & '\FileHelp.chm')
EndFunc   ;==>_File_Help
Func _Link_3()
	ShellExecute('http://a1.opdo.top/search/label/C%E1%BA%A9m%20nang')
	_BackToHome()
EndFunc   ;==>_Link_3
Func _Link_2()
	ShellExecute('http://a1.opdo.top/2016/02/cac-muc-phat-pho-bien-khi-tham-gia-giao.html')
	_BackToHome()
EndFunc   ;==>_Link_2
Func _Link_1()
	ShellExecute('http://a1.opdo.top/2016/02/cac-luu-y-khi-tham-gia-giao-thong.html')
	_BackToHome()
EndFunc   ;==>_Link_1
Func _LoadInfo()
	GUICtrlSetData($main_Textname, 'Chào ' & RegRead($regedit, 'name') & ',')
	Local $text = ''
	$text = 'Tiến trình học:	' & Number(RegRead($regedit, 'Learn_1')) & '/150'
	Local $temp = Number(RegRead($regedit, 'Learn_2'))
	$text = $text & @CRLF & 'Tiến trình ôn tập:	' & Int(($temp * 100) / 150) & '%'
	$text = $text & @CRLF & 'Số lần thi thử:	' & Number(RegRead($regedit, 'Learn_3'))
	$text = $text & @CRLF & 'Số lần đậu:	' & Number(RegRead($regedit, 'Learn_4'))
	$text = $text & @CRLF & 'Dự đoán tỉ lệ đậu:	' & Number(RegRead($regedit, 'Learn_5')) & '%'
	GUICtrlSetData($main_Textprocess, $text)

EndFunc   ;==>_LoadInfo
Func _Reset_Process()
	If MsgBox(32 + 4, 'Thông báo', 'Bạn có chắc chắn xóa toàn bộ tiến trình học?') = 6 Then
		For $i = 1 To 5
			RegWrite($regedit, 'Learn_' & $i, 'REG_SZ', '')
			RegWrite($regedit, 'Time_' & $i, 'REG_SZ', '')
			RegWrite($regedit, 'Help_' & $i, 'REG_SZ', '')
		Next
		_LoadInfo()
	EndIf
EndFunc   ;==>_Reset_Process

Func _Exit()
	If MsgBox(32 + 4, 'Thông báo', 'Bạn có thực sự muốn thoát?') = 6 Then
		_HideGUI($GUI_Main)
		If @Compiled Then
			ProcessClose('OPA1_License.exe')
		Else
			ProcessClose('AutoIT3.exe')
		EndIf
		Exit
	EndIf
EndFunc   ;==>_Exit

; cài font
Func _Install_Fonts()
	Local $fonts = 'segoeui,segoeuib,segoeuii,segoeuil,segoeuisl,segoeuiz,seguibl,seguibli,seguili,seguisb,seguisbi,seguisli'
	Local $temp = StringSplit($fonts, ',')
	For $i = 1 To $temp[0]
		If Not FileExists(@WindowsDir & '\Fonts\' & $temp[$i] & '.ttf') Then
			FileCopy(@ScriptDir & '\' & $temp[$i] & '.ttf', @WindowsDir & '\Fonts\' & $temp[$i] & '.ttf', 1)
			ConsoleWrite('cai font ' & $temp[$i] & @CRLF)
		EndIf
	Next

EndFunc   ;==>_Install_Fonts
Func _SelfDelete($iDelay = 0)
	Local $sCmdFile
	FileDelete(@TempDir & "\scratch.bat")
	$sCmdFile = 'ping -n ' & $iDelay & ' 127.0.0.1 > nul' & @CRLF _
			 & ':loop' & @CRLF _
			 & 'del "' & @ScriptFullPath & '"' & @CRLF _
			 & 'if exist "' & @ScriptFullPath & '" goto loop' & @CRLF _
			 & 'del %0'
	FileWrite(@TempDir & "\scratch.bat", $sCmdFile)
	Run(@TempDir & "\scratch.bat", @TempDir, @SW_HIDE)
EndFunc   ;==>_SelfDelete

; gui about
Func _Update_Download()
	Return 0
EndFunc   ;==>_Update_Download
Func _Update_DontAskAgain()
	Return 0
EndFunc   ;==>_Update_DontAskAgain

Func _About_ShowGUI()
	GUISetState(@SW_DISABLE, $GUI_Main)
	_setimage($about_logo, @ScriptDir & '\Images\opdo.top.png')
	GUICtrlSetData($about_text, 'OPA1 License v' & $version & ' - Phần mềm hỗ trợ thi bằng lái A1' & @CRLF & 'Create by VinhPham with ❤' & @CRLF & 'http://a1.opdo.top' & @CRLF & '+84 120 7575 299' & @CRLF & 'a1@opdo.top')
	WinSetTrans($GUI_About, '', 0)
	_ShowGUI($GUI_About)

EndFunc   ;==>_About_ShowGUI
Func _About_HideGUI()
	GUISetState(@SW_ENABLE, $GUI_Main)
	_HideGUI($GUI_About)
EndFunc   ;==>_About_HideGUI


; gui khác
; Chứa các hàm  tương tác chính với GUI
Global $time_learn, $time_review
Func _ShowGUI_Learn()
	GUISetState(@SW_HIDE, $GUI_Main)
	If RegRead($regedit, "Help_1") = '' Then
		GUISetState(@SW_LOCK, $GUI_Learn)
		RegWrite($regedit, "Help_1", "REG_SZ", "Seen")
		_Tip_Load_Id(1)
	Else
		$time_learn = TimerInit()
		Local $number = Number(RegRead($regedit, 'Learn_1'))
		Local $time = Int(Number(RegRead($regedit, 'Time_1')) / 60)
		GUICtrlSetData($learn_Textprocess, 'Bạn đã học đến câu ' & $number & '. Thời gian học: ' & $time & ' phút')
		If $number = 150 Then $number = 0
		_myLearn_Load($number + 1)
		_ShowGUI($GUI_Learn)

	EndIf
EndFunc   ;==>_ShowGUI_Learn
Func _ShowGUI_Review()
	GUISetState(@SW_HIDE, $GUI_Main)
	If RegRead($regedit, "Help_2") = '' Then
		GUISetState(@SW_LOCK, $GUI_Review)
		RegWrite($regedit, "Help_2", "REG_SZ", "Seen")
		_Tip_Load_Id(2)
	Else
		$time_review = TimerInit()
		Local $number = Number(RegRead($regedit, 'Learn_2'))
		Local $time = Int(Number(RegRead($regedit, 'Time_2')) / 60)
		GUICtrlSetData($review_Textprocess, 'Bạn đã học đến câu ' & $number & '. Thời gian học: ' & $time & ' phút')
		If $number = 150 Then $number = 0
		_myReview_Load($number + 1)
		_ShowGUI($GUI_Review)
	EndIf
EndFunc   ;==>_ShowGUI_Review
Func _HideGUI_Learn()
	Local $time = TimerDiff($time_learn)
	$time = Int($time / 1000)
	RegWrite($regedit, 'Time_1', 'REG_SZ', Number(RegRead($regedit, 'Time_1')) + $time)
	Local $number = Number(GUICtrlRead($learn_input))
	If $number > Number(RegRead($regedit, 'Learn_1')) Then RegWrite($regedit, 'Learn_1', 'REG_SZ', $number)
	_PageSwich_1()
	_LoadInfo()
	GUISetState(@SW_HIDE, $GUI_Learn)
	_ShowGUI($GUI_Main)
EndFunc   ;==>_HideGUI_Learn
Func _HideGUI_Review()
	Local $time = TimerDiff($time_review)
	$time = Int($time / 1000)
	RegWrite($regedit, 'Time_2', 'REG_SZ', Number(RegRead($regedit, 'Time_2')) + $time)
	Local $number = Number(GUICtrlRead($review_input))
	If $number > Number(RegRead($regedit, 'Learn_2')) Then RegWrite($regedit, 'Learn_2', 'REG_SZ', $number)
	_PageSwich_1()
	_LoadInfo()
	GUISetState(@SW_HIDE, $GUI_Review)
	_ShowGUI($GUI_Main)
EndFunc   ;==>_HideGUI_Review
Func _ShowGUI_ThiRandom()
	$de = Random(1, 8, 1)
	_ShowGUI_Thi($de)
EndFunc   ;==>_ShowGUI_ThiRandom
Func _ShowGUI_Thi($de)
	GUISetState(@SW_HIDE, $GUI_Main)

	GUICtrlSetData($thi_done, 'KẾT THÚC')
	_ThiButton_Load($thiButton, $de)
	_ShowGUI($GUI_Thi)
	If RegRead($regedit, "Help_3") = '' Then
		GUISetState(@SW_LOCK, $GUI_Thi)
		RegWrite($regedit, "Help_3", "REG_SZ", "Seen")
		_Tip_Load_Id(3)
		$thiTime = 0
	EndIf
EndFunc   ;==>_ShowGUI_Thi

Func _HideGUI_Tip()
	Local $id = Number(GUICtrlRead($tip_id))
	GUISetState(@SW_HIDE, $GUI_Tip)
	If $id = 1 Then
		GUISetState(@SW_UNLOCK, $GUI_Learn)
		_ShowGUI_Learn()
	ElseIf $id = 2 Then
		GUISetState(@SW_UNLOCK, $GUI_Review)
		_ShowGUI_Review()
	ElseIf $id = 3 Then
		GUISetState(@SW_UNLOCK, $GUI_Thi)
		$thiTime = 15 * 60
	ElseIf $id = 4 Then
		_Input_ChangeName()
	EndIf
EndFunc   ;==>_HideGUI_Tip
Func _HideGUI_Thi()
	_PageSwich_2()
	_LoadInfo()
	GUISetState(@SW_HIDE, $GUI_Thi)
	_ShowGUI($GUI_Main)
EndFunc   ;==>_HideGUI_Thi
Func _ShowGUI_Video()
	_wmpvalue($playerOBJ, 'nocontrols')
	_ShowGUI($GUI_Video)
	GUISetState(@SW_HIDE, $GUI_Main)

	_wmploadmedia($playerOBJ, @ScriptDir & '\Images\Pic\thuchanh.mp4')
EndFunc   ;==>_ShowGUI_Video

Func _Tip_1()
	_Tip_Load_Id(1)
EndFunc   ;==>_Tip_1
Func _Tip_2()
	_Tip_Load_Id(2)
EndFunc   ;==>_Tip_2
Func _Tip_3()
	_Tip_Load_Id(3)
EndFunc   ;==>_Tip_3
Func _Tip_Load_Id($id)
	If $id = 4 Then GUISetState(@SW_HIDE, $GUI_Change_Name)
	GUICtrlSetData($tip_id, $id)
	_Load_Tip(1)
	_ShowGUI($GUI_Tip)

EndFunc   ;==>_Tip_Load_Id
Func _HideGUI_Video()
	_wmpvalue($playerOBJ, "stop")
	GUISetState(@SW_HIDE, $GUI_Video)
	_ShowGUI($GUI_Main)
EndFunc   ;==>_HideGUI_Video
Func _Tip_next()
	Local $temp = StringSplit(GUICtrlRead($tip_number), '')
	Local $number = 0
	For $i = 1 to $temp[0]
		if $temp[$i] == '◦' Then
			$number = $i
			ExitLoop
		EndIf
	Next
	$temp[1] = Number($temp[1])
	_Load_Tip($number + 1)
EndFunc   ;==>_Tip_next
Func _Tip_pre()
	Local $temp = StringSplit(GUICtrlRead($tip_number), '')
		Local $number = 0
	For $i = 1 to $temp[0]
		if $temp[$i] == '◦' Then
			$number = $i
			ExitLoop
		EndIf
	Next
	_Load_Tip($number - 1)
EndFunc   ;==>_Tip_pre
Func _Load_Tip($number)
	Local $id = Number(GUICtrlRead($tip_id))
	Local $temp = StringSplit($myTip[$id], '|')
	If $number > 0 And $number <= $temp[0] Then
		;GUICtrlSetData($tip_number, $number & '/' & $temp[0])
		Local $text = ''
		For $i = 1 to $temp[0]
			if $i == $number Then
				$text = $text&'◦'
				Else
				$text = $text&'•'
			EndIf
		Next
		GUICtrlSetData($tip_number, $text)
		GUICtrlSetData($tip_text, $temp[$number])
		_SetImage($tip_pic, @ScriptDir & '\Images\Help\help' & $id & '_' & $number & '.png')
	ElseIf $number > $temp[0] Then
		_HideGUI_Tip()
	EndIf
EndFunc   ;==>_Load_Tip
Func _LoadGUIThi()
	Global $thiButton[20]
	Global $thiOption = _thiOption_Create()
	$x = 533
	For $i = 0 To 19
		;MsgBox(0,0,0)
		If $i <> 0 And Mod($i, 10) == 0 Then $x = 664
		$thiButton[$i] = _ThiButton_Create($x, 73 + 45 * Mod($i, 10))
		_thiButton_SetText($thiButton[$i], $i + 1)

	Next

EndFunc   ;==>_LoadGUIThi

Func _LoadGUIReview()
	Global $reviewOption = _myOption_Create()
	For $i = 1 To 4
		GUICtrlSetOnEvent($reviewOption[$i], '_review_Chon' & $i)
		SSCtrlHover_Register($reviewOption[$i], "FnNormal", 1, "FnHover", 1, "FnActive", 1, "FnClick", 1)
	Next
	Dim $review_AccelKeys[7][2] = [["{enter}", $reviewButton_next], ["{right}", $reviewButton_next], ["{left}", $reviewButton_pre], ["{F1}", $reviewOption[1]], ["{F2}", $reviewOption[2]], ["{F3}", $reviewOption[3]], ["{F4}", $reviewOption[4]]]
	GUISetAccelerators($review_AccelKeys, $GUI_Review)
EndFunc   ;==>_LoadGUIReview
Func _LoadGUILearn()
	SSCtrlHover_Register($learnButton_meo, "FnNormal", 10, "FnHover", 'MEO@2', "FnActive", 0, "FnClick", 0)
	Global $myOption = _myOption_Create()
	Dim $AccelKeys[2][2] = [["{right}", $learnButton_next], ["{left}", $learnButton_pre]]
	GUISetAccelerators($AccelKeys, $GUI_Learn)
EndFunc   ;==>_LoadGUILearn
Func _LoadGUIMain()
	GUISwitch($GUI_Main)
	; set logo
	_SetImage($myGUI_logo, @ScriptDir & '\Images\icon.png')
	;GUICtrlSetPos($myGUI_logo, Default, Default, 160, 160)
	$myDethi = _mainDe_Create()
	Global $meothi_Control = _meoControl_Create()
	Global $thuchanh_Control = _thuchanhControl_Create()
	; create button
	For $i = 0 To 3
		$myButton[$i] = _myButton_Create(@ScriptDir & '\' & $myButton_icon[$i], $myButton_text[$i], 'Test', 255, 125 + $i * 85)
		_myButton_SetOnEvent($myButton[$i], '_PageSwich_' & $i + 1)
	Next
	_BackToHome()
EndFunc   ;==>_LoadGUIMain
; mẹo thi
Func _meoControl_Create()
	Local $control[10]
	$control[0] = GUICtrlCreateLabel("MẸO 1", 232, 131, 77, 41, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
	GUICtrlSetFont(-1, 15, 350, 0, "Segoe UI Semilight")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	$control[1] = GUICtrlCreateLabel("", 309, 131, 372, 41, -1, -1)
	GUICtrlSetState(-1, BitOR($GUI_SHOW, $GUI_DISABLE))
	GUICtrlSetBkColor(-1, "0xDADADA")
	$control[2] = GUICtrlCreateLabel("", 232, 421, 449, 28, -1, -1)
	GUICtrlSetState(-1, BitOR($GUI_SHOW, $GUI_DISABLE))
	GUICtrlSetBkColor(-1, "0xDADADA")
	$control[3] = GUICtrlCreateLabel("◀", 374, 421, 47, 27, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
	GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI Semilight")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	GUICtrlSetCursor(-1, 0)
	SSCtrlHover_Register(-1, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 'MEO_PRE')
	$control[4] = GUICtrlCreateLabel("▶", 468, 421, 47, 27, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
	GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI Semilight")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetCursor(-1, 0)
	SSCtrlHover_Register(-1, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 'MEO_NEXT')
	GUICtrlSetBkColor(-1, "0x0063B1")
	$control[5] = GUICtrlCreateLabel("1/15", 421, 422, 47, 27, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
	GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI Semilight")
	GUICtrlSetBkColor(-1, "-2")
	$control[6] = GUICtrlCreateLabel("Trở về", 615, 421, 66, 27, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
	GUICtrlSetOnEvent(-1, '_PageSwich_1')
	GUICtrlSetCursor(-1, 0)
	SSCtrlHover_Register(-1, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI Semilight")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")

	$control[7] = GUICtrlCreateLabel("", 232, 173, 449, 247, -1, -1)
	GUICtrlSetState(-1, BitOR($GUI_SHOW, $GUI_DISABLE))
	GUICtrlSetBkColor(-1, "0xDADADA")
	$control[8] = _GUICtrlRichLabel_Create($GUI_Main, '', 259, 195, 395, 208)
	;GUICtrlCreateLabel("My Text",259,195,395,208,-1,-1)
	_meoControl_Hide($control)
	Return $control
EndFunc   ;==>_meoControl_Create
Func _meoControlGUI_Load($number)
	Local $max = Number(_IniRead($Database, 'Meo1', 'Tong', ''))
	If $number > $max Then $number = 1
	If $number < 1 Then $number = $max
	GUICtrlSetData($meothi_Control[5], $number & '/' & $max)
	GUICtrlSetData($meothi_Control[0], 'MẸO ' & $number)
	Local $temp = StringSplit(_IniRead($Database, 'Meo' & $number, 'Meo', ''), '|')
	Local $text = ''
	For $i = 1 To $temp[0]
		If $text = '' Then
			$text = $temp[$i]
		Else
			$text = $text & @CRLF & $temp[$i]
		EndIf
	Next
	_GUICtrlRichLabel_SetData($meothi_Control[8], $text)
EndFunc   ;==>_meoControlGUI_Load

Func _meoControlGUI_Show()
	GUISetState(@SW_LOCK, $GUI_Main)
	For $i = 0 To 3
		_myButton_Hide($myButton[$i])
	Next
	_meoControl_Hide($meothi_Control, False)
	_meoControlGUI_Load(1)
	GUISetState(@SW_UNLOCK, $GUI_Main)
EndFunc   ;==>_meoControlGUI_Show
Func _meoControlGUI_Hide()
	GUISetState(@SW_LOCK, $GUI_Main)
	_meoControl_Hide($meothi_Control)
	For $i = 0 To 3
		_myButton_Hide($myButton[$i], False)
	Next
	GUISetState(@SW_UNLOCK, $GUI_Main)
EndFunc   ;==>_meoControlGUI_Hide

Func _meoControl_Hide(ByRef $control, $hide = True)
	For $i = 0 To 7
		If $hide Then
			GUICtrlSetState($control[$i], $GUI_HIDE)
		Else
			GUICtrlSetState($control[$i], $GUI_SHOW)
		EndIf
	Next
	If $hide Then
		_GUICtrlRichLabel_SetPos($control[8], 0, 0, 0, 0)
	Else
		_GUICtrlRichLabel_SetPos($control[8], 259, 195, 395, 208)
	EndIf
EndFunc   ;==>_meoControl_Hide

; thực hành
Func _thuchanhControl_Create()
	Local $control[6]
	$control[1] = GUICtrlCreateLabel("", 309, 131, 372, 41, -1, -1)
	GUICtrlSetState(-1, BitOR($GUI_SHOW, $GUI_DISABLE))
	GUICtrlSetBkColor(-1, "0xDADADA")
	$control[0] = GUICtrlCreateLabel("THỰC HÀNH", 232, 131, 130, 41, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
	GUICtrlSetFont(-1, 15, 350, 0, "Segoe UI Semilight")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")

	$control[2] = GUICtrlCreateLabel("", 232, 421, 449, 28, -1, -1)
	GUICtrlSetState(-1, BitOR($GUI_SHOW, $GUI_DISABLE))
	GUICtrlSetBkColor(-1, "0xDADADA")
	$control[3] = GUICtrlCreateLabel("Trở về", 615, 421, 66, 27, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
	GUICtrlSetOnEvent(-1, '_PageSwich_3')
	GUICtrlSetCursor(-1, 0)
	SSCtrlHover_Register(-1, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	GUICtrlSetFont(-1, 10, 350, 0, "Segoe UI Semilight")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")

	$control[4] = GUICtrlCreateLabel("", 232, 173, 449, 247, -1, -1)
	GUICtrlSetState(-1, BitOR($GUI_SHOW, $GUI_DISABLE))
	GUICtrlSetBkColor(-1, "0xDADADA")
	$control[5] = GUICtrlCreatePic(@ScriptDir & '\Images\Pic\thuchanh.jpg', 259, 195, 395, 208)
	;GUICtrlCreateLabel("My Text",259,195,395,208,-1,-1)
	_thuchanhControl_Hide($control)
	Return $control
EndFunc   ;==>_thuchanhControl_Create


Func _thuchanhControlGUI_Show()
	GUISetState(@SW_LOCK, $GUI_Main)
	For $i = 0 To 3
		_myButton_Hide($myButton[$i])
	Next
	_thuchanhControl_Hide($thuchanh_Control, False)
	GUISetState(@SW_UNLOCK, $GUI_Main)
EndFunc   ;==>_thuchanhControlGUI_Show
Func _thuchanhControlGUI_Hide()
	GUISetState(@SW_LOCK, $GUI_Main)
	_thuchanhControl_Hide($thuchanh_Control)
	For $i = 0 To 3
		_myButton_Hide($myButton[$i], False)
	Next
	GUISetState(@SW_UNLOCK, $GUI_Main)
EndFunc   ;==>_thuchanhControlGUI_Hide

Func _thuchanhControl_Hide(ByRef $control, $hide = True)
	For $i = 0 To 5
		If $hide Then
			GUICtrlSetState($control[$i], $GUI_HIDE)
		Else
			GUICtrlSetState($control[$i], $GUI_SHOW)
		EndIf
	Next
EndFunc   ;==>_thuchanhControl_Hide


; đề thi control
Func _mainDe_Create()
	Local $control[9]
	$control[1] = GUICtrlCreateLabel("ĐỀ 1", 238, 157, 130, 70, BitOR($SS_CENTER, $SS_CENTERIMAGE), 0)
	GUICtrlSetFont(-1, 20, 300, 0, "Segoe UI Light")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	$control[2] = GUICtrlCreateLabel("ĐỀ 2", 397, 157, 130, 70, BitOR($SS_CENTER, $SS_CENTERIMAGE), 0)
	GUICtrlSetFont(-1, 20, 400, 0, "Segoe UI Light")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	$control[3] = GUICtrlCreateLabel("ĐỀ 3", 553, 157, 130, 70, BitOR($SS_CENTER, $SS_CENTERIMAGE), 0)
	GUICtrlSetFont(-1, 20, 400, 0, "Segoe UI Light")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	$control[6] = GUICtrlCreateLabel("ĐỀ 6", 553, 248, 130, 70, BitOR($SS_CENTER, $SS_CENTERIMAGE), 0)
	GUICtrlSetFont(-1, 20, 400, 0, "Segoe UI Light")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	$control[4] = GUICtrlCreateLabel("ĐỀ 4", 238, 248, 130, 70, BitOR($SS_CENTER, $SS_CENTERIMAGE), 0)
	GUICtrlSetFont(-1, 20, 400, 0, "Segoe UI Light")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	$control[5] = GUICtrlCreateLabel("ĐỀ 5", 397, 248, 130, 70, BitOR($SS_CENTER, $SS_CENTERIMAGE), 0)
	GUICtrlSetFont(-1, 20, 400, 0, "Segoe UI Light")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	$control[0] = GUICtrlCreateLabel("TRỞ VỀ", 553, 338, 130, 70, BitOR($SS_CENTER, $SS_CENTERIMAGE), 0)
	GUICtrlSetFont(-1, 20, 400, 0, "Segoe UI Light")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	GUICtrlSetOnEvent(-1, '_PageSwich_2')
	$control[7] = GUICtrlCreateLabel("ĐỀ 7", 238, 338, 130, 70, BitOR($SS_CENTER, $SS_CENTERIMAGE), 0)
	GUICtrlSetFont(-1, 20, 400, 0, "Segoe UI Light")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	$control[8] = GUICtrlCreateLabel("ĐỀ 8", 397, 338, 130, 70, BitOR($SS_CENTER, $SS_CENTERIMAGE), 0)
	GUICtrlSetFont(-1, 20, 400, 0, "Segoe UI Light")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	For $i = 0 To 8
		GUICtrlSetCursor($control[$i], 0)
		SSCtrlHover_Register($control[$i], "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", $i & '@THI')
		GUICtrlSetState($control[$i], $GUI_HIDE)
	Next
	Return $control
EndFunc   ;==>_mainDe_Create

Func _mainDeFunc_Hide()
	GUISetState(@SW_LOCK, $GUI_Main)
	_mainDe_Hide($myDethi)
	For $i = 0 To 3
		_myButton_Hide($myButton[$i], False)
	Next
	GUISetState(@SW_UNLOCK, $GUI_Main)
EndFunc   ;==>_mainDeFunc_Hide
Func _mainDeFunc_Show()
	GUISetState(@SW_LOCK, $GUI_Main)
	For $i = 0 To 3
		_myButton_Hide($myButton[$i])
	Next
	_mainDe_Hide($myDethi, False)
	GUISetState(@SW_UNLOCK, $GUI_Main)
EndFunc   ;==>_mainDeFunc_Show
Func _mainDe_Hide(ByRef $control, $hide = True)
	For $i = 0 To 8
		If $hide Then
			GUICtrlSetState($control[$i], $GUI_HIDE)
		Else
			GUICtrlSetState($control[$i], $GUI_SHOW)
		EndIf
	Next
EndFunc   ;==>_mainDe_Hide
; Page Swich: chuyển đổi page
Func _BackToHome()
	$text1 = $myButton_text[0] & '|' & $myButton_text[1] & '|' & $myButton_text[2] & '|' & $myButton_text[3]
	$text2 = $myButton_text2[0] & '|' & $myButton_text2[1] & '|' & $myButton_text2[2] & '|' & $myButton_text2[3]
	$text3 = $myButton_icon[0] & '|' & $myButton_icon[1] & '|' & $myButton_icon[2] & '|' & $myButton_icon[3]
	$text4 = '_PageSwich_1|_PageSwich_2|_PageSwich_3|_PageSwich_4'
	_PageLoad($text1, $text2, $text3, $text4)
EndFunc   ;==>_BackToHome

Func _PageSwich_1()
	_meoControlGUI_Hide()
	Local $temp1 = 'Bạn đã học đến câu ' & Number(RegRead($regedit, 'Learn_1')) & '/150'
	Local $temp2 = 'Bạn đã ôn tập đến câu ' & Number(RegRead($regedit, 'Learn_2')) & '/150'
	If Number(RegRead($regedit, 'Learn_1')) >= 150 Then $temp1 = 'Chúc mừng, bạn đã học hết 150 câu lý thuyết'
	If Number(RegRead($regedit, 'Learn_2')) >= 150 Then $temp2 = 'Chúc mừng, bạn đã ôn tập hết 150 câu lý thuyết'
	Local $text1 = 'HỌC 150 CÂU TRẮC NGHIỆM|XEM MẸO NHỚ|ÔN TẬP|TRỞ VỀ'
	Local $text2 = $temp1 & '|Tổng hợp các mẹo nhớ lý thuyết|' & $temp2 & '|Trở về giao diện chính'
	Local $text3 = @ScriptDir & '\Images\icon00.png|' & @ScriptDir & '\Images\icon01.png|' & @ScriptDir & '\Images\icon02.png|' & @ScriptDir & '\Images\icon03.png'
	Local $text4 = '_ShowGUI_Learn|_meoControlGUI_Show|_ShowGUI_Review|_BackToHome'
	_PageLoad($text1, $text2, $text3, $text4)
EndFunc   ;==>_PageSwich_1
Func _PageSwich_2()
	_mainDeFunc_Hide()
	Local $temp1 = 'Bạn thi ' & Number(RegRead($regedit, 'Learn_3')) & ' lần. Đạt ' & Number(RegRead($regedit, 'Learn_4')) & ' lần. Tỉ lệ đạt ' & Number(RegRead($regedit, 'Learn_5')) & '%'
	Local $text1 = 'CHỌN ĐỀ THI|THI NGẪU NHIÊN|TRỞ VỀ'
	Local $text2 = $temp1 & '|Chương trình tự chọn ngẫu nhiên 1 trong 8 đề|Trở về giao diện chính'
	Local $text3 = @ScriptDir & '\Images\icon10.png|' & @ScriptDir & '\Images\icon11.png|' & @ScriptDir & '\Images\icon03.png'
	Local $text4 = '_mainDeFunc_Show|_ShowGUI_ThiRandom|_BackToHome'
	_PageLoad($text1, $text2, $text3, $text4)
EndFunc   ;==>_PageSwich_2
Func _PageSwich_3()
	_thuchanhControlGUI_Hide()
	Local $text1 = 'XEM HƯỚNG DẪN|XEM VIDEO|TRỞ VỀ'
	Local $text2 = 'Xem hướng dẫn các bước thực hành|Xem video thực hành|Trở về giao diện chính'
	Local $text3 = @ScriptDir & '\Images\icon20.png|' & @ScriptDir & '\Images\icon21.png|' & @ScriptDir & '\Images\icon03.png'
	Local $text4 = '_thuchanhControlGUI_Show|_ShowGUI_Video|_BackToHome'
	_PageLoad($text1, $text2, $text3, $text4)
EndFunc   ;==>_PageSwich_3
Func _PageSwich_4()
	Local $text1 = 'LƯU Ý GIAO THÔNG|CÁC LỖI PHỔ BIẾN|XEM THÊM|TRỞ VỀ'
	Local $text2 = 'Các lưu ý khi tham gia giao thông đường bộ|Tổng hợp các lỗi và mức phạt phổ biến|Xem thêm trên blog của chúng tôi|Trở về giao diện chính'
	Local $text3 = @ScriptDir & '\Images\icon20.png|' & @ScriptDir & '\Images\icon31.png|' & @ScriptDir & '\Images\icon32.png|' & @ScriptDir & '\Images\icon03.png'
	Local $text4 = '_Link_1|_Link_2|_Link_3|_BackToHome'
	_PageLoad($text1, $text2, $text3, $text4)
EndFunc   ;==>_PageSwich_4
Func _PageLoad($text1, $text2, $logo, $event)
	GUISetState(@SW_LOCK, $GUI_Main)
	Local $temp1 = StringSplit($text1, '|')
	Local $temp2 = StringSplit($text2, '|')
	Local $temp3 = StringSplit($logo, '|')
	Local $temp4 = StringSplit($event, '|')
	For $i = $temp1[0] - 1 To 3
		_myButton_Hide($myButton[$i])
	Next
	For $i = 0 To $temp1[0] - 1
		_myButton_Hide($myButton[$i], False)
		_myButton_SetText1($myButton[$i], $temp1[$i + 1])
		_myButton_SetText2($myButton[$i], $temp2[$i + 1])
		_myButton_SetLogo($myButton[$i], $temp3[$i + 1])
		_myButton_SetOnEvent($myButton[$i], $temp4[$i + 1])
	Next
	GUISetState(@SW_UNLOCK, $GUI_Main)
EndFunc   ;==>_PageLoad

; Control hover

Func _SetControlHover()
	SSCtrlHover_Register($myButton_edit, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($myButton_reset, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($myButton_exit, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($myButton_help, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($myButton_info, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($learnButton_pre, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($learnButton_next, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($learnButton_exit, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($learnButton_help, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($reviewButton_pre, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($reviewButton_next, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($reviewButton_exit, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($videoButton_exit, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($reviewButton_help, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($thi_doneButton_close, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($thi_done, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($tip_NoAskAgain, "FnNormal", 1, "FnHover", 1, "FnActive", 1, "FnClick", 1)
	SSCtrlHover_Register($update_download, "FnNormal", 1, "FnHover", 1, "FnActive", 1, "FnClick", 1)
	SSCtrlHover_Register($tipButton_pre, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($tipButton_next, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($tip_close, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($about_close, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($name_close, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
	SSCtrlHover_Register($name_ok, "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)
EndFunc   ;==>_SetControlHover


Func FnNormal($idCtrl, $hWnd, $vData)
	If $vData = 0 Then
		GUICtrlSetBkColor($idCtrl, 0x0063B1)
		GUICtrlSetStyle($idCtrl, Default, 0)
	ElseIf $vData = 1 Then
		GUICtrlSetFont($idCtrl, 11, 400, 0, "Segoe UI")
	ElseIf $vData = 2 Then
		GUICtrlSetStyle($idCtrl, Default, 0)
	Else
		GUICtrlSetBkColor($idCtrl, 0x0063B1)
		GUICtrlSetStyle($idCtrl, Default, 0)
		ToolTip('')
	EndIf
EndFunc   ;==>FnNormal
Func FnHover($idCtrl, $hWnd, $vData)
	If String($vData) = '0' Then
		GUICtrlSetBkColor($idCtrl, 0x1A73B9)
	ElseIf String($vData) = '1' Then
		GUICtrlSetFont($idCtrl, 11, 600, 0, "Segoe UI Semibold")
	ElseIf String($vData) = '2' Then
		GUICtrlSetStyle($idCtrl, Default, $WS_EX_STATICEDGE)
	Else
		Local $temp = StringSplit($vData, '@')
		If $temp[1] == 'MEO' Then
			GUICtrlSetBkColor($idCtrl, 0x1A73B9)
			Local $mouse = MouseGetPos()
			ToolTip(GUICtrlRead($learn_tiphidden), $mouse[0] + 10, $mouse[1] + 10, 'Mẹo nhớ', $TIP_INFOICON)
		EndIf
	EndIf


EndFunc   ;==>FnHover
Func FnActive($idCtrl, $hWnd, $vData)
	If $vData = 0 Then
		GUICtrlSetStyle($idCtrl, Default, $WS_EX_STATICEDGE)
	EndIf
EndFunc   ;==>FnActive
Func FnClick($idCtrl, $hWnd, $vData)
	If String($vData) = '0' Then
		GUICtrlSetStyle($idCtrl, Default, 0)
	ElseIf $vData == 'MEO_NEXT' Then
		Local $temp = StringSplit(GUICtrlRead($meothi_Control[5]), '/')
		Local $number = Number($temp[1]) + 1
		_meoControlGUI_Load($number)
	ElseIf $vData == 'MEO_PRE' Then
		Local $temp = StringSplit(GUICtrlRead($meothi_Control[5]), '/')
		Local $number = Number($temp[1]) - 1
		_meoControlGUI_Load($number)
	Else
		Local $temp = StringSplit($vData, '@')
		If $temp[0] == 2 Then

			If $temp[2] == 'THI' Then
				If Number($temp[1]) > 0 Then _ShowGUI_Thi($temp[1])
			ElseIf $temp[2] == 'Ads' Then
				$temp[1] = Number($temp[1])
				ShellExecute(IniRead(@ScriptDir & '\Images\Ads\Ads.ini', 'AdsLink', $adsControl[$temp[1] + 9], 'ttp://opdo.top'))
			Else
				_thi_Load($temp[1])
			EndIf
		EndIf
	EndIf
EndFunc   ;==>FnClick

; Thi_Button Create : tạo button thi
Func _ThiButton_Hide(ByRef $control, $i, $hide = True)
	If $hide Then
		GUICtrlSetState($control[$i], $GUI_HIDE)
	Else
		GUICtrlSetState($control[$i], $GUI_SHOW)
	EndIf
EndFunc   ;==>_ThiButton_Hide
Func _ThiButton_Create($x, $y) ; 533 73
	Local $control[6]
	$control[0] = GUICtrlCreateLabel("", $x, $y, 124, 40, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
	GUICtrlSetFont(-1, 18, 700, 0, "Segoe UI")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0xFFFFFF")
	;GUICtrlSetState(-1,$GUI_DISABLE)

	$control[5] = GUICtrlCreateLabel("1", $x, $y, 33, 40, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
	GUICtrlSetFont(-1, 18, 700, 0, "Segoe UI")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")

	$control[1] = GUICtrlCreateLabel("1" & @CRLF & "☐", $x + 35, $y, 19, 40, $SS_CENTER, -1)
	GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
	;GUICtrlSetColor(-1,"0xFFFFFF")
	GUICtrlSetBkColor(-1, "-2")
	GUICtrlSetCursor(-1, 0)
	SSCtrlHover_Register(-1, "FnNormal", 1, "FnHover", 1, "FnActive", 1, "FnClick", "CHONCAUTRALOI")
	GUICtrlSetOnEvent(-1, '_thi_Chon1')
	$control[2] = GUICtrlCreateLabel("2" & @CRLF & "☐", $x + 55, $y, 19, 40, $SS_CENTER, -1)
	GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
	;GUICtrlSetColor(-1,"0xFFFFFF")
	GUICtrlSetBkColor(-1, "-2")
	GUICtrlSetCursor(-1, 0)
	SSCtrlHover_Register(-1, "FnNormal", 1, "FnHover", 1, "FnActive", 1, "FnClick", "CHONCAUTRALOI")
	GUICtrlSetOnEvent(-1, '_thi_Chon2')
	$control[3] = GUICtrlCreateLabel("3" & @CRLF & "☐", $x + 75, $y, 19, 40, $SS_CENTER, -1)
	GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
	;GUICtrlSetColor(-1,"0xFFFFFF")
	GUICtrlSetBkColor(-1, "-2")
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetOnEvent(-1, '_thi_Chon3')
	SSCtrlHover_Register(-1, "FnNormal", 1, "FnHover", 1, "FnActive", 1, "FnClick", "CHONCAUTRALOI")

	$control[4] = GUICtrlCreateLabel("4" & @CRLF & "☐", $x + 95, $y, 19, 40, $SS_CENTER, -1)
	GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
	;GUICtrlSetColor(-1,"0xFFFFFF")
	GUICtrlSetBkColor(-1, "-2")
	GUICtrlSetCursor(-1, 0)
	SSCtrlHover_Register(-1, "FnNormal", 1, "FnHover", 1, "FnActive", 1, "FnClick", "CHONCAUTRALOI")
	GUICtrlSetOnEvent(-1, '_thi_Chon4')

	Return $control
EndFunc   ;==>_ThiButton_Create
Func _thiButton_SetText(ByRef $control, $text)
	GUICtrlSetData($control[5], $text)
EndFunc   ;==>_thiButton_SetText
; Button Create: tạo button đặc biệt cho GUI
Func _myButton_Create($logo, $text1, $text2, $x, $y)
	Local $control[4]
	$control[0] = GUICtrlCreateLabel("▶ ", $x, $y, 423, 72, BitOR($SS_RIGHT, $SS_CENTERIMAGE), -1)
	GUICtrlSetFont(-1, 20, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "0x0063B1")
	GUICtrlSetCursor(-1, 0)
	$control[1] = GUICtrlCreateLabel($text1, $x + 47, $y + 7, 339, 40, -1, -1)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetFont(-1, 15, 600, 0, "Segoe UI Semibold")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "-2")
	$control[2] = GUICtrlCreateLabel($text2, $x + 47, $y + 39, 339, 27, -1, -1)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, "0xFFFFFF")
	GUICtrlSetBkColor(-1, "-2")
	$control[3] = GUICtrlCreatePic("", $x - 34, $y, 71, 70)
	GUICtrlSetCursor(-1, 0)
	_SetImage($control[3], $logo)
	GUICtrlSetPos($control[3], $x - 34, $y, 72, 72)
	SSCtrlHover_Register($control[0], "FnNormal", 0, "FnHover", 0, "FnActive", 0, "FnClick", 0)

	Return $control
EndFunc   ;==>_myButton_Create

Func _myButton_SetText1(ByRef $control, $text)
	GUICtrlSetData($control[1], $text)
EndFunc   ;==>_myButton_SetText1

Func _myButton_SetText2(ByRef $control, $text)
	GUICtrlSetData($control[2], $text)
EndFunc   ;==>_myButton_SetText2

Func _myButton_SetLogo(ByRef $control, $logo)
	_SetImage($control[3], $logo)
	GUICtrlSetPos($control[3], Default, Default, 71, 70)
	GUICtrlSetPos($control[3], Default, Default, 72, 72)
EndFunc   ;==>_myButton_SetLogo

Func _myButton_SetOnEvent(ByRef $control, $event)
	For $i = 0 To 3
		GUICtrlSetOnEvent($control[$i], $event)
	Next
EndFunc   ;==>_myButton_SetOnEvent

Func _myButton_Hide(ByRef $control, $flag = True)
	If $flag Then
		For $i = 0 To 3
			GUICtrlSetState($control[$i], $GUI_HIDE)
		Next
	Else
		For $i = 0 To 3
			GUICtrlSetState($control[$i], $GUI_SHOW)
		Next
	EndIf
EndFunc   ;==>_myButton_Hide

Func _IniRead($file, $section, $key, $deffault)
	$section = StringUpper($section)
	$key = StringUpper($key)
	Local $pass = 'Op#95'
	$section = __StringToHex($section)
	$section = _Crypt_EncryptData($section, $pass, $CALG_RC4)
	$key = __StringToHex($key)
	$key = _Crypt_EncryptData($key, $pass, $CALG_RC4)
	If IniRead($file, $section, $key, '') == '' Then Return $deffault
	Local $value
	$value = IniRead($file, $section, $key, '')
	$value = _Crypt_DecryptData($value, $pass, $CALG_RC4)
	$value = BinaryToString($value)
	$value = __HexToString($value)
	Return $value
EndFunc   ;==>_IniRead
Func __HexToString($sHex)
	If Not (StringLeft($sHex, 2) == "0x") Then $sHex = "0x" & $sHex
	Return BinaryToString($sHex, $SB_UTF8)
EndFunc   ;==>__HexToString
Func __StringToHex($sString)
	Return Hex(StringToBinary($sString, $SB_UTF8))
EndFunc   ;==>__StringToHex

