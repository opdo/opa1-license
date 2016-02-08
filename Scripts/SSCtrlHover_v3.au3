;~ Author			: 	binhnx
;~ Created			:	2014/09/20
;~ Last modified	:	2014/10/20




Global Const $ERR_SSCTRLHOVER_INVALIDCTRL = 1
Global Const $ERR_SSCTRLHOVER_DUPLICATEACTION = 2

; #FUNCTION# ==========================================================================================================
; Name ..........: _SSCtrlHover_Register
; Description ...: Register functions to be called when the mouse cursor is hover/down/leave the control.
; Syntax ........: SSCtrlHover_Register($idCtrl [, $fnNormalCb="" [, $vNormalData=0
;                     [, $fnHoverCb="" [, $vHoverData=0 [, $fnActiveCb="" [, $vActiveData=0
;                     [, $fnClickCb="" [, $vClickData=0 [, $fnDblClkCb="" [, $vDblClkData=0]]]]]]]]]])
; Parameters ....: $idCtrl              - The Ctrl ID to set hovering for (-1 means the last created control)
;                  $fnNormalCb, $fnHoverCb, $fnActiveCb, $fnClickCb, $fnDblClkCb:
;                                       - name or variable of the callback function
;                                         which will be called when the control receive the corresponding mouse event
;                                         (mouse left, mouse hover, mouse active(down), click, double-click)
;                  $vNormalData, $vHoverData, $vActiveData, $vClickData, $vDblClkData:
;                                       - variable will be pass to the corresponding registered callback function
; Return values .: a "handle" to the registered control. Use that handle to unregister the control.
;                     0 if fail and set @error to non-zero value.
; Author ........: binhnx
; Modified ......:
; Remarks .......: If error, @error is set to either $ERR_SSCTRLHOVER_INVALIDCTRL (=1) when the ctrlid given is invalid
;                     or $ERR_SSCTRLHOVER_DUPLICATEACTION (=2) when register an control which has already registered
;                  The callback function must have atleast 3 parameters. When the control receive an event, the
;                     registered callback function is called, then the parameter 1st is the control id received event,
;                     parameter 2nd is the handle of that control, and parameter 3rd is the data given by $v...Data.
;                     To improve performance, you can specify ByRef with the 3rd parameter, if it's large
;                     (long array or long string)
; Related .......:
; Link ..........:
; Example .......: No
; =====================================================================================================================
Func _SSCtrlHover_Register($idCtrl, $fnNormalCb='', $vNormalData=0, _
				$fnHoverCb='', $vHoverData=0, $fnActiveCb='', $vActiveData=0, _
				$fnClickCb="", $vClickData=0, $fnDblClkCb='', $vDblClkData=0)
	Return SSCtrlHover_Register($idCtrl, $fnNormalCb, $vNormalData, $fnHoverCb, $vHoverData, _
				$fnActiveCb, $vActiveData, $fnClickCb, $vClickData, $fnDblClkCb, $vDblClkData)
EndFunc


; #FUNCTION# ==========================================================================================================
; Name ..........: _SSCtrlHover_UnRegister
; Description ...: Un-register the registered hover control.
; Syntax ........: SSCtrlHover_UnRegister($idCtrl)
; Parameters ....: $idCtrl              - The ctrl "handle" returned from _SSCtrlHover_Register.
; Return values .: True if success, False and set @error on fails
; Author ........: binhnx
; Modified ......:
; Remarks .......: If error, @error is set to $ERR_SSCTRLHOVER_DUPLICATEACTION (=2),
;                     when unregister an control which is uninitialized or unregistered
; Related .......:
; Link ..........:
; Example .......: No
; =====================================================================================================================
Func _SSCtrlHover_UnRegister($zHoverCtrl)
	Return SSCtrlHover_UnRegister($zHoverCtrl)
EndFunc

;Why this function is not included in WinAPI.au3 ?
Func _WinAPI_GetCapture()
	Return DllCall("user32.dll", "HWND", "GetCapture")[0]
EndFunc


#Region Internal Global Variables

#Region Window Handle Index - 'Stolen' from Wine source :)
; 'Stolen' from Wine souce :)
Local Const $__SSCTRLHOVER_FIRST_USER_HANDLE			= 0x0020
Local Const $__SSCTRLHOVER_LAST_USER_HANDLE				= 0xFFEF
Local Const $__SSCTRLHOVER_NB_USER_HANDLES				= _	; 32744 = 255.8125KB in Windows 64bit
			BitShift(($__SSCTRLHOVER_LAST_USER_HANDLE - $__SSCTRLHOVER_FIRST_USER_HANDLE + 1), 1)
Local $__SSCtrlHover_aData[$__SSCTRLHOVER_NB_USER_HANDLES]

Func __SSCtrlHover_UserHandleToIndex($hWnd)
	Return BitShift((BitAND($hWnd, 0x0000FFFF) - $__SSCTRLHOVER_FIRST_USER_HANDLE), 1)
EndFunc
#EndRegion

Local Enum _
	$__SSCTRLHOVER_NINDEX_HWND, _
	$__SSCTRLHOVER_NINDEX_CTRLID, _
	$__SSCTRLHOVER_NINDEX_STATE, _
	$__SSCTRLHOVER_NINDEX_FNLEAVE, _
	$__SSCTRLHOVER_NINDEX_VLEAVEDATA, _
	$__SSCTRLHOVER_NINDEX_FNHOVER, _
	$__SSCTRLHOVER_NINDEX_VHOVERDATA, _
	$__SSCTRLHOVER_NINDEX_FNACTIVE, _
	$__SSCTRLHOVER_NINDEX_VACTIVEDATA, _
	$__SSCTRLHOVER_NINDEX_FNCLICK, _
	$__SSCTRLHOVER_NINDEX_VCLICKDATA, _
	$__SSCTRLHOVER_NINDEX_FNDBLCLK, _
	$__SSCTRLHOVER_NINDEX_VDBLCLKDATA, _
	$__SSCTRLHOVER_NINDEX_SIZE
#EndRegion

#Region Initialize
OnAutoItExitRegister("__SSCtrlHover_Finalize")
Local Const $__SSCTRLHOVER_HDLLCOMCTL32 = _WinAPI_LoadLibrary('comctl32.dll')
Assert($__SSCTRLHOVER_HDLLCOMCTL32 <> 0, 'This UDF requires comctl32.dll')

Local Const $__SSCTRLHOVER_PDEFSUBCLASSPROC = __SSCtrlHover_GetDefSubclassProcAddress()
Local Const $__SSCTRLHOVER_PINTERNALSUBCLASS = DllCallbackGetPtr( _
			DllCallbackRegister('__SSCtrlHover_WndProcInternal', 'NONE', 'HWND;UINT;WPARAM;LPARAM;DWORD'))

Local Const $__SSCTRLHOVER_TSUBCLASSEXE = Call(@AutoItX64? _
			'__SSCtrlHover_CreateSubclassProc_X64' : '__SSCtrlHover_CreateSubclassProc_X86')

; Needed to solve Access Violation on DEP-enabled machine
Local Const $__SSCTRLHOVER_HEXECUTABLEHEAP = DllCall('kernel32.dll', 'HANDLE', 'HeapCreate', _
			'DWORD', 0x00040000, 'ULONG_PTR', 0, 'ULONG_PTR', 0)[0]
Assert($__SSCTRLHOVER_HEXECUTABLEHEAP <> 0, 'Failed to create executable heap object')

Local Const $__SSCTRLHOVER_PSUBCLASSEXE = __SSCtrlHover_ExecutableFromStruct( _
			Call(@AutoItX64? '__SSCtrlHover_CreateSubclassProc_X64' : '__SSCtrlHover_CreateSubclassProc_X86'))
#EndRegion
Func Assert($bExpression, $sMsg = '', $sScript = @ScriptName, $sScriptPath = @ScriptFullPath, $iLine = @ScriptLineNumber, _
			$iError = @error, $iExtend = @extended)
	If (Not($bExpression)) Then
		MsgBox(BitOR(1, 0x10), 'Assertion Error!', _
				@CRLF & 'Script' & @TAB & ': ' & $sScript _
				& @CRLF & 'Path' & @TAB & ': ' & $sScriptPath _
				& @CRLF & 'Line' & @TAB & ': ' & $iLine _
				& @CRLF & 'Error' & @TAB & ': ' & ($iError > 0x7FFF? Hex($iError) : $iError) _
				& ($iExtend <> 0? '  (Extended : ' & ($iExtend > 0x7FFF?  Hex($iExtend) : $iExtend) & ')' : '') _
				& @CRLF & 'Message' & @TAB & ': ' & $sMsg _
				& @CRLF & @CRLF & 'OK: Exit Script' & @TAB & 'Cancel: Continue')
		Exit
	EndIf
EndFunc

#Region UDF Usable Functions
Func SSCtrlHover_Register($idCtrl, $fnNormalCb='', $vNormalData=0, _
				$fnHoverCb='', $vHoverData=0, $fnActiveCb='', $vActiveData=0, _
				$fnClickCb="", $vClickData=0, $fnDblClkCb='', $vDblClkData=0)
	Assert(IsInt($idCtrl), 'Unexpected parameter type. ' _
				& 'Name: $idCtrl, Expect: Integer (ControlID), Actual: ' & VarGetType($idCtrl))
	Assert(IsString($fnNormalCb) Or IsFunc($fnNormalCb), 'Unexpected parameter type. ' _
				& 'Name: $fnNormalCb, Expect: String or Function, Actual: ' & VarGetType($fnNormalCb))
	Assert(IsString($fnHoverCb) Or IsFunc($fnHoverCb), 'Unexpected parameter type. ' _
				& 'Name: $fnHoverCb, Expect: String or Function, Actual: ' & VarGetType($fnHoverCb))
	Assert(IsString($fnActiveCb) Or IsFunc($fnActiveCb), 'Unexpected parameter type. ' _
				& 'Name: $fnActiveCb, Expect: String or Function, Actual: ' & VarGetType($fnActiveCb))
	Assert(IsString($fnClickCb) Or IsFunc($fnClickCb), 'Unexpected parameter type. ' _
				& 'Name: $fnClickCb, Expect: String or Function, Actual: ' & VarGetType($fnClickCb))
	Assert(IsString($fnDblClkCb) Or IsFunc($vDblClkData), 'Unexpected parameter type. ' _
				& 'Name: $vDblClkData, Expect: String or Function, Actual: ' & VarGetType($vDblClkData))

	Local $hWnd = GUICtrlGetHandle($idCtrl)
	If (Not(IsHWnd($hWnd))) Then Return SetError($ERR_SSCTRLHOVER_INVALIDCTRL, 0, -1)



	Local $nIndex = __SSCtrlHover_UserHandleToIndex($hWnd)
	If (IsArray($__SSCtrlHover_aData[$nIndex])) Then
		Return SetError($ERR_SSCTRLHOVER_DUPLICATEACTION, 0, -1)
	EndIf

	If ($idCtrl = -1) Then $idCtrl = _WinAPI_GetDlgCtrlID($hWnd)

	Local $aData[$__SSCTRLHOVER_NINDEX_SIZE]
	$aData[$__SSCTRLHOVER_NINDEX_HWND] 				= $hWnd
	$aData[$__SSCTRLHOVER_NINDEX_CTRLID] 			= $idCtrl
	$aData[$__SSCTRLHOVER_NINDEX_FNLEAVE] 			= $fnNormalCb
	$aData[$__SSCTRLHOVER_NINDEX_VLEAVEDATA] 		= $vNormalData
	$aData[$__SSCTRLHOVER_NINDEX_FNHOVER] 			= $fnHoverCb
	$aData[$__SSCTRLHOVER_NINDEX_VHOVERDATA] 		= $vHoverData
	$aData[$__SSCTRLHOVER_NINDEX_FNACTIVE] 			= $fnActiveCb
	$aData[$__SSCTRLHOVER_NINDEX_VACTIVEDATA] 		= $vActiveData
	$aData[$__SSCTRLHOVER_NINDEX_FNCLICK] 			= $fnClickCb
	$aData[$__SSCTRLHOVER_NINDEX_VCLICKDATA]		= $vClickData
	$aData[$__SSCTRLHOVER_NINDEX_FNDBLCLK] 			= $fnDblClkCb
	$aData[$__SSCTRLHOVER_NINDEX_VDBLCLKDATA]		= $vDblClkData
	$__SSCtrlHover_aData[$nIndex] = $aData

	_WinAPI_SetWindowSubclass($hWnd, $__SSCTRLHOVER_PSUBCLASSEXE, $hWnd, __SSCtrlHover_UserHandleToIndex($hWnd))
	Return SetExtended($hWnd, $nIndex)
EndFunc


Func SSCtrlHover_UnRegister($zHoverCtrl)
	Local $bIsHwnd = IsHWnd($zHoverCtrl)
	Assert($bIsHwnd Or IsInt($zHoverCtrl), 'Unexpected parameter type. ' _
				& 'Name: $zHoverCtrl, ' _
				& 'Expect: Window Handle (HWND) or Int (returned by _SSCtrlHover_Register), ' _
				& 'Actual: ' & VarGetType($zHoverCtrl))
	Assert($bIsHwnd Or ($zHoverCtrl > 0 And $zHoverCtrl <= $__SSCTRLHOVER_NB_USER_HANDLES), _
				'Parameter out of range. ' _
				& 'Name: $zHoverCtrl, Expected: [1, ' & $__SSCTRLHOVER_NB_USER_HANDLES & ']. Get: ' & $zHoverCtrl)

	If ($bIsHwnd) Then
		$zHoverCtrl = __SSCtrlHover_UserHandleToIndex($zHoverCtrl)
	EndIf

	Local $aData = $__SSCtrlHover_aData[$zHoverCtrl]
	If ($aData[$zHoverCtrl] = 0) Then
		Return SetError($ERR_SSCTRLHOVER_DUPLICATEACTION, 0, False)
	Else
		__SSCtrlHover_UnRegisterInternal($zHoverCtrl, $aData[$__SSCTRLHOVER_NINDEX_HWND])
		Return True
	EndIf
EndFunc
#EndRegion

#Region Internal Msg Handler
Func __SSCtrlHover_UnRegisterInternal($nCtrlHwnd, $hWnd)
	_WinAPI_RemoveWindowSubclass($hWnd, $__SSCTRLHOVER_PSUBCLASSEXE, $hWnd)
	$__SSCtrlHover_aData[$nCtrlHwnd] = 0
EndFunc

Func __SSCtrlHover_WndProcInternal($hWnd, $uMsg, $wParam, $lParam, $nCtrlHwnd)
	Switch $uMsg
		Case 0x0200
			__SSCtrlHover_OnCtrlMouseMoveRef($__SSCtrlHover_aData[$nCtrlHwnd], $hWnd, $uMsg, $wParam, $lParam)
		Case 0x0201
			__SSCtrlHover_OnCtrlMouseDownRef($__SSCtrlHover_aData[$nCtrlHwnd], $hWnd, $uMsg, $wParam, $lParam)
		Case 0x0202
			__SSCtrlHover_OnCtrlMouseUpRef($__SSCtrlHover_aData[$nCtrlHwnd], $hWnd, $uMsg, $wParam, $lParam)
			Return False
		Case 0x0203
			__SSCtrlHover_OnCtrlMouseDblClkRef($__SSCtrlHover_aData[$nCtrlHwnd], $hWnd, $uMsg, $wParam, $lParam)
		Case 0x02A3
			__SSCtrlHover_OnCtrlMouseLeaveRef($__SSCtrlHover_aData[$nCtrlHwnd], $hWnd, $uMsg, $wParam, $lParam)
		Case 0x0082
			__SSCtrlHover_UnRegisterInternal($nCtrlHwnd, $hWnd)
	EndSwitch
	Return True
EndFunc
#EndRegion

#Region Mouse Msg Handler Functions
Func __SSCtrlHover_OnCtrlMouseDownRef(ByRef $aCtrlData, $hWnd, $uMsg, ByRef $wParam, ByRef $lParam)
	_WinAPI_SetCapture($hWnd)
	__SSCtrlHover_CallFunc($aCtrlData, $__SSCTRLHOVER_NINDEX_FNACTIVE)
EndFunc

Func __SSCtrlHover_OnCtrlMouseMoveRef(ByRef $aCtrlData, $hWnd, $uMsg, ByRef $wParam, ByRef $lParam)
	If (_WinAPI_GetCapture() = $hWnd) Then
		Local $bIn = __SSCtrlHover_IsInClient($hWnd, $lParam)
		If ($aCtrlData[$__SSCTRLHOVER_NINDEX_STATE] = 0) Then
			If ($bIn) Then
				$aCtrlData[$__SSCTRLHOVER_NINDEX_STATE] = 1
				__SSCtrlHover_CallFunc($aCtrlData, $__SSCTRLHOVER_NINDEX_FNACTIVE)
			EndIf
		Else
			If (Not($bIn)) Then
				$aCtrlData[$__SSCTRLHOVER_NINDEX_STATE] = 0
				__SSCtrlHover_CallFunc($aCtrlData, $__SSCTRLHOVER_NINDEX_FNLEAVE)
			EndIf
		EndIf
	ElseIf ($aCtrlData[$__SSCTRLHOVER_NINDEX_STATE] = 0) Then
		$aCtrlData[$__SSCTRLHOVER_NINDEX_STATE] = 1
		__SSCtrlHover_CallFunc($aCtrlData, $__SSCTRLHOVER_NINDEX_FNHOVER)

		Local $tTME = DllStructCreate('DWORD;DWORD;HWND;DWORD')
		DllStructSetData($tTME, 1, DllStructGetSize($tTME))
		DllStructSetData($tTME, 2, 2);$TME_LEAVE
		DllStructSetData($tTME, 3, $hWnd)
		DllCall('user32.dll', 'BOOL', 'TrackMouseEvent', 'STRUCT*', $tTME)
	EndIf
EndFunc

Func __SSCtrlHover_OnCtrlMouseUpRef(ByRef $aCtrlData, $hWnd, $uMsg, ByRef $wParam, ByRef $lParam)
	Local $lRet = _WinAPI_DefSubclassProc($hWnd, $uMsg, $wParam, $lParam)
	If (_WinAPI_GetCapture() = $hWnd) Then
		_WinAPI_ReleaseCapture()
		If (__SSCtrlHover_IsInClient($hWnd, $lParam)) Then
			__SSCtrlHover_CallFunc($aCtrlData, $__SSCTRLHOVER_NINDEX_FNCLICK)
		EndIf
	EndIf
	Return $lRet
EndFunc

Func __SSCtrlHover_OnCtrlMouseDblClkRef(ByRef $aCtrlData, $hWnd, $uMsg, ByRef $wParam, ByRef $lParam)
	__SSCtrlHover_CallFunc($aCtrlData, $__SSCTRLHOVER_NINDEX_FNDBLCLK)
EndFunc

Func __SSCtrlHover_OnCtrlMouseLeaveRef(ByRef $aCtrlData, $hWnd, $uMsg, ByRef $wParam, ByRef $lParam)
	$aCtrlData[$__SSCTRLHOVER_NINDEX_STATE] = 0
	__SSCtrlHover_CallFunc($aCtrlData, $__SSCTRLHOVER_NINDEX_FNLEAVE)
EndFunc
#EndRegion

#Region Helpers
Func __SSCtrlHover_CallFunc(ByRef $aCtrlData, $iCallType)
	Local $idCtrl = $aCtrlData[$__SSCTRLHOVER_NINDEX_CTRLID]
	Local $hWnd = $aCtrlData[$__SSCTRLHOVER_NINDEX_HWND]
	Call($aCtrlData[$iCallType], $idCtrl, $hWnd, $aCtrlData[$iCallType+1])
EndFunc

Func __SSCtrlHover_ArrayPush(ByRef $aStackArr, Const $vSrc1=0, Const $vSrc2=0, Const $vSrc3=0, Const $vSrc4=0, _
			Const $vSrc5=0, Const $vSrc6=0, Const $vSrc7=0, Const $vSrc8=0, Const $vSrc9=0, Const $vSrc10=0, _
			Const $vSrc11=0, Const $vSrc12=0, Const $vSrc13=0, Const $vSrc14=0, Const $vSrc15=0, Const $vSrc16=0)
	While (UBound($aStackArr) < ($aStackArr[0] + @NumParams))
		ReDim $aStackArr[UBound($aStackArr)*2]
	WEnd

	For $i = 2 To @NumParams
		$aStackArr[0] += 1
		$aStackArr[$aStackArr[0]] = Eval('vSrc' & $i-1)
	Next
EndFunc

Func __SSCtrlHover_IsInClient($hWnd, $lParam)
	Local $iX = BitShift(BitShift($lParam, -16), 16)
	Local $iY = BitShift($lParam, 16)
	Local $aSize = WinGetClientSize($hWnd)
	Return Not($iX < 0 Or $iY < 0 Or $iX > $aSize[0] Or $iY > $aSize[1])
EndFunc
#EndRegion

#Region Initialize & Finalize Functions

Func __SSCtrlHover_CreateSubclassProc_X86()
	; $hWnd	 			HWND			size: 4			ESP+4			EBP+8
	; $uMsg	 			UINT			size: 4			ESP+8			EBP+12
	; $wParam			WPARAM			size: 4			ESP+12			EBP+16
	; $lParam			LPARAM			size: 4			ESP+16			EBP+20
	; $uIdSubclass		UINT_PTR		size: 4			ESP+20			EBP+24
	; $dwRefData		DWORD_PTR		size: 4			ESP+24			EBP+28		Total: 24

	; NERVER FORGET ADDING align 1 OR YOU WILL SPEND HOURS TO FIND WHAT CAUSE 0xC0000005 Access Violation
	Local $sExe = 'align 1;'
	Local $aOpCode[100]
	$aOpCode[0] = 0
	Local $nAddrOffset[5]
	Local $nElemOffset[5]

	; Func																	; __stdcall
	$sExe &= 'BYTE;BYTE;BYTE;'
	__SSCtrlHover_ArrayPush($aOpCode, 0x55)						;push	ebp
	__SSCtrlHover_ArrayPush($aOpCode, 0x8B, 0xEC)				;mov	ebp, esp

	; Save un-modified params to nv register
	$sExe &= 'BYTE;'											;push	ebx
	__SSCtrlHover_ArrayPush($aOpCode, 0x53)									;53
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	ebx, DWORD PTR [ebp+16]
	__SSCtrlHover_ArrayPush($aOpCode, 0x8B, 0x5D, 16)						;8b 5d 10
	$sExe &= 'BYTE;'											;push	esi
	__SSCtrlHover_ArrayPush($aOpCode, 0x56)									;56
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	esi, DWORD PTR [ebp+12]
	__SSCtrlHover_ArrayPush($aOpCode, 0x8B, 0x75, 12)						;8b 75 0c
	$sExe &= 'BYTE;'											;push	edi
	__SSCtrlHover_ArrayPush($aOpCode, 0x57)									;57
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	ebx, DWORD PTR [ebp+20]
	__SSCtrlHover_ArrayPush($aOpCode, 0x8B, 0x7D, 20)						;8b 7d 14


	; If ($uMsg = 0x0082) Then Goto WndProcInternal							;WM_NCDESTROY
	$sExe &= 'BYTE;BYTE;DWORD;'									;cmp	esi, 0x82
	__SSCtrlHover_ArrayPush($aOpCode, 0x81, 0xFE, 0x82)						;81 fe 82 00 00 00
	$sExe &= 'BYTE;BYTE;'										;je		short WndProcInternal
	__SSCtrlHover_ArrayPush($aOpCode, 0x74, 0)								;74 BYTE_OFFSET
	$nAddrOffset[0] = DllStructGetSize(DllStructCreate($sExe))
	$nElemOffset[0] = $aOpCode[0]

	; ElseIf ($uMsg = 0x02A3) Then Goto WndProcInternal						;WM_MOUSELEAVE
	$sExe &= 'BYTE;BYTE;DWORD;'									;cmp	esi, 0x2A3
	__SSCtrlHover_ArrayPush($aOpCode, 0x81, 0xFE, 0x2A3)					;81 fe a3 02 00 00
	$sExe &= 'BYTE;BYTE;'										;je		short WndProcInternal
	__SSCtrlHover_ArrayPush($aOpCode, 0x74, 0)								;74 BYTE_OFFSET
	$nAddrOffset[1] = DllStructGetSize(DllStructCreate($sExe))
	$nElemOffset[1] = $aOpCode[0]

	; ElseIf ($uMsg < 0x200 Or $uMsg > 0x203) Then Goto DefaultWndProc
	$sExe &= 'BYTE;BYTE;BYTE;'									;lea	eax, DWORD PTR [esi-0x200]
	__SSCtrlHover_ArrayPush($aOpCode, 0x8D, 0x86, -0x200)					;8d 86 00 02 00 00
	$sExe &= 'BYTE;BYTE;BYTE;'									;cmp	eax, 3
	__SSCtrlHover_ArrayPush($aOpCode, 0x83, 0xF8, 3)						;83 f8 03
	$sExe &= 'BYTE;BYTE;'										;ja		short DefaultWndProc
	__SSCtrlHover_ArrayPush($aOpCode, 0x77, 0)								;77 BYTE_OFFSET
	$nAddrOffset[2] = DllStructGetSize(DllStructCreate($sExe))
	$nElemOffset[2] = $aOpCode[0]

	; :WndProcInternal (HWND, UINT, WPARAM, LPARAM, DWORD)
	$aOpCode[$nElemOffset[0]] = $nAddrOffset[2] - $nAddrOffset[0]
	$aOpCode[$nElemOffset[1]] = $nAddrOffset[2] - $nAddrOffset[1]

	; Prepare stack
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	ecx, DWORD PTR [ebp+28]
	__SSCtrlHover_ArrayPush($aOpCode, 0x8B, 0x4D, 28)						;8b 4d 1c
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	edx, DWORD PTR [ebp+8]
	__SSCtrlHover_ArrayPush($aOpCode, 0x8B, 0x55, 8)						;8b 55 08
	$sExe &= 'BYTE;'											;push	ecx
	__SSCtrlHover_ArrayPush($aOpCode, 0x51)									;51
	$sExe &= 'BYTE;'											;push	edi
	__SSCtrlHover_ArrayPush($aOpCode, 0x57)									;57
	$sExe &= 'BYTE;'											;push	ebx
	__SSCtrlHover_ArrayPush($aOpCode, 0x53)									;53
	$sExe &= 'BYTE;'											;push	esi
	__SSCtrlHover_ArrayPush($aOpCode, 0x56)									;56
	$sExe &= 'BYTE;'											;push	edx
	__SSCtrlHover_ArrayPush($aOpCode, 0x52)									;52

	; Call
	$sExe &= 'BYTE;PTR;'										;mov	eax, __SSCtrlHover_WndProcInternal
	__SSCtrlHover_ArrayPush($aOpCode, 0xB8, $__SSCTRLHOVER_PINTERNALSUBCLASS)
	$sExe &= 'BYTE;BYTE;'										;call	near eax
	__SSCtrlHover_ArrayPush($aOpCode, 0xFF, 0xD0)							;ff 75 8

	; If (WndProcInternal() = 0) Then Return
	$sExe &= 'BYTE;BYTE;'										;test	eax, eax
	__SSCtrlHover_ArrayPush($aOpCode, 0x85, 0xC0)							;85 c0
	$sExe &= 'BYTE;BYTE;'										;jz		short Return
	__SSCtrlHover_ArrayPush($aOpCode, 0x74, 0)								;74 BYTE_OFFSET
	$nAddrOffset[3] = DllStructGetSize(DllStructCreate($sExe))
	$nElemOffset[3] = $aOpCode[0]

	; :DefaultWndProc (HWND, UINT, WPARAM, LPARAM)
	$aOpCode[$nElemOffset[2]] = $nAddrOffset[3] - $nAddrOffset[2]

	; Prepare stack
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	eax, DWORD PTR [ebp+8]
	__SSCtrlHover_ArrayPush($aOpCode, 0x8B, 0x45, 8)
	$sExe &= 'BYTE;'											;push	edi
	__SSCtrlHover_ArrayPush($aOpCode, 0x57)									;57
	$sExe &= 'BYTE;'											;push	ebx
	__SSCtrlHover_ArrayPush($aOpCode, 0x53)									;53
	$sExe &= 'BYTE;'											;push	esi
	__SSCtrlHover_ArrayPush($aOpCode, 0x56)									;56
	$sExe &= 'BYTE;'											;push	eax
	__SSCtrlHover_ArrayPush($aOpCode, 0x50)									;50

	;Call
	$sExe &= 'BYTE;PTR;'										;mov	eax,COMCTL32.DefSubclassProc
	__SSCtrlHover_ArrayPush($aOpCode, 0xB8, $__SSCTRLHOVER_PDEFSUBCLASSPROC)
	$sExe &= 'BYTE;BYTE;'										;call	near eax
	__SSCtrlHover_ArrayPush($aOpCode, 0xFF, 0xD0)							;ff 75 8
	$nAddrOffset[4] = DllStructGetSize(DllStructCreate($sExe))

	; :Return
	$aOpCode[$nElemOffset[3]] = $nAddrOffset[4] - $nAddrOffset[3]

	; Restore nv-register
	$sExe &= 'BYTE;BYTE;BYTE;'
	__SSCtrlHover_ArrayPush($aOpCode, 0x5F)						;pop	edi
	__SSCtrlHover_ArrayPush($aOpCode, 0x5E)						;pop	esi
	__SSCtrlHover_ArrayPush($aOpCode, 0x5B)						;pop	ebx


	; EndFunc
	$sExe &= 'BYTE;BYTE;BYTE;WORD'
	__SSCtrlHover_ArrayPush($aOpCode, 0x5D)						;pop	ebp
	__SSCtrlHover_ArrayPush($aOpCode, 0xC2, 24)					;ret	24


	Return __SSCtrlHover_PopulateOpcode($sExe, $aOpCode)
EndFunc

Func __SSCtrlHover_CreateSubclassProc_X64()
	; First four INT and UINT has size = 8 instead of 4 because they are stored in RCX, RDX, R8, R9
	; $hWnd	 			HWND			size: 8			RCX			RSP+8
	; $uMsg	 			UINT			size: 8 		EDX			RSP+16
	; $wParam			WPARAM			size: 8			R8			RSP+24
	; $lParam			LPARAM			size: 8			R9			RSP+32
	; $uIdSubclass		UINT_PTR		size: 8			RSP+40
	; $dwRefData		DWORD_PTR		size: 8			RSP+48		Total: 48
	Local $sExe = 'align 1;'
	Local $aOpCode[100]
	$aOpCode[0] = 0
	Local $nAddrOffset[5]
	Local $nElemOffset[5]


	; If ($uMsg = 0x0082) Then Goto WndProcInternal							;WM_NCDESTROY
	$sExe &= 'BYTE;BYTE;DWORD;'									;cmp	edx, 0x82
	__SSCtrlHover_ArrayPush($aOpCode, 0x81, 0xFA, 0x82)						;81 fa 82 00 00 00
	$sExe &= 'BYTE;BYTE;'										;je		short WndProcInternal
	__SSCtrlHover_ArrayPush($aOpCode, 0x74, 0)								;74 BYTE_OFFSET
	$nAddrOffset[0] = DllStructGetSize(DllStructCreate($sExe))
	$nElemOffset[0] = $aOpCode[0]

	; ElseIf ($uMsg = 0x02A3) Then Goto WndProcInternal						;WM_MOUSELEAVE
	$sExe &= 'BYTE;BYTE;DWORD;'									;cmp	edx, 0x2A3
	__SSCtrlHover_ArrayPush($aOpCode, 0x81, 0xFA, 0x2A3)					;81 fa a3 02 00 00
	$sExe &= 'BYTE;BYTE;'										;je		short WndProcInternal
	__SSCtrlHover_ArrayPush($aOpCode, 0x74, 0)								;74 BYTE_OFFSET
	$nAddrOffset[1] = DllStructGetSize(DllStructCreate($sExe))
	$nElemOffset[1] = $aOpCode[0]

	; ElseIf ($uMsg < 0x200 Or $uMsg > 0x203) Then Goto DefaultWndProc
	$sExe &= 'BYTE;BYTE;DWORD;'									;lea	eax, DWORD PTR [rdx-0x200]
	__SSCtrlHover_ArrayPush($aOpCode, 0x8D, 0x82, -0x200)					;8d 82 00 02 00 00
	$sExe &= 'BYTE;BYTE;BYTE;'									;cmp	eax, 3
	__SSCtrlHover_ArrayPush($aOpCode, 0x83, 0xF8, 3)						;83 f8 03
	$sExe &= 'BYTE;BYTE;'										;ja		short DefaultWndProc
	__SSCtrlHover_ArrayPush($aOpCode, 0x77, 0)								;77 BYTE_OFFSET
	$nAddrOffset[2] = DllStructGetSize(DllStructCreate($sExe))
	$nElemOffset[2] = $aOpCode[0]
	$aOpCode[$nElemOffset[0]] = $nAddrOffset[2] - $nAddrOffset[0]
	$aOpCode[$nElemOffset[1]] = $nAddrOffset[2] - $nAddrOffset[1]


	; :WndProcInternal (HWND rsp+8, UINT +16, WPARAM +24, LPARAM +32, DWORD +40)
	; $dwRefData = [ESP+48+48(sub rsp, 48)+8(push rdi)] = [ESP+104]
	; Save base registers:
	$sExe &= 'BYTE;BYTE;BYTE;BYTE;BYTE;'						;mov	QWORD PTR [rsp+8], rbx
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x89, 0x5C, 0x24, 8)			;48 89 5c 24 08
	$sExe &= 'BYTE;BYTE;BYTE;BYTE;BYTE;'						;mov	QWORD PTR [rsp+16], rbp
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x89, 0x6C, 0x24, 16)			;48 89 6c 24 10
	$sExe &= 'BYTE;BYTE;BYTE;BYTE;BYTE;'						;mov	QWORD PTR [rsp+24], rsi
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x89, 0x74, 0x24, 24)			;48 89 74 24 18
	$sExe &= 'BYTE;'											;push	rdi
	__SSCtrlHover_ArrayPush($aOpCode, 0x57)									;57
	; Max sub-routine params = 5 (size = 5*8 = 40), + 8 bytes for return value = 48.
	$sExe &= 'BYTE;BYTE;BYTE;BYTE;'								;sub	rsp, 48
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x83, 0xEC, 48)					;48 83 ec 30
	; rbx, rbp, rsi now at [ESP+8+56], [ESP+16+56], [ESP+24+56]

	; Save the parameters:
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	rdi, r9
	__SSCtrlHover_ArrayPush($aOpCode, 0x49, 0x8B, 0xF9)						;49 8b f9
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	rsi, r8
	__SSCtrlHover_ArrayPush($aOpCode, 0x49, 0x8B, 0xF0)						;49 8b f0
	$sExe &= 'BYTE;BYTE;'										;mov	ebx, edx
	__SSCtrlHover_ArrayPush($aOpCode, 0x8B, 0xDA)							;8b da
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	rbp, rcx
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x8B, 0xE9)						;48 8b e9

	; Prepare additional parameter for internal WndProc
	$sExe &= 'BYTE;BYTE;BYTE;BYTE;BYTE;'						;mov	rax, QWORD PTR [rsp+104]
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x8B, 0x44, 0x24, 104)			;48 8b 44 24 68
	$sExe &= 'BYTE;BYTE;BYTE;BYTE;BYTE;'						;mov	QWORD PTR [rsp+32], Rax]
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x89, 0x44, 0x24, 32)			;48 89 44 24 20

	; Call internal WndProc
	$sExe &= 'BYTE;BYTE;PTR;'									;mov	rax, QWORD PTR __SSCtrlHover_WndProcInternal
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0xB8, $__SSCTRLHOVER_PINTERNALSUBCLASS)
				;movabs	rax, __SSCtrlHover_WndProcInternal					;48 b8 QWORD_PTR
	$sExe &= 'BYTE;BYTE;'										;call	rax
	__SSCtrlHover_ArrayPush($aOpCode, 0xFF, 0xD0)							;ff d0

	; If (WndProcInternal() = 0) Then Return
	$sExe &= 'BYTE;BYTE;BYTE;'									;cmp	edx, 0x2A3
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x85, 0xC0)						;48 85 c0
	$sExe &= 'BYTE;BYTE;'										;je		short WndProcInternal
	__SSCtrlHover_ArrayPush($aOpCode, 0x74, 0)
	$nAddrOffset[3] = DllStructGetSize(DllStructCreate($sExe))
	$nElemOffset[3] = $aOpCode[0]

	; Restore parameters for DefSubclassProc call
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	r9, rdi
	__SSCtrlHover_ArrayPush($aOpCode, 0x4C, 0x8B, 0xCF)						;4c 8b cf
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	r8, rsi
	__SSCtrlHover_ArrayPush($aOpCode, 0x4C, 0x8B, 0xC6)						;4c 8b c6
	$sExe &= 'BYTE;BYTE;'										;mov	edx, ebx
	__SSCtrlHover_ArrayPush($aOpCode, 0x8B, 0xD3)							;8b d3
	$sExe &= 'BYTE;BYTE;BYTE;'									;mov	rcx, rbp
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x8B, 0xCD)						;48 8b cd

	; Restore registers value
	$aOpCode[$nElemOffset[3]] = DllStructGetSize(DllStructCreate($sExe)) - $nAddrOffset[3]
	$sExe &= 'BYTE;BYTE;BYTE;BYTE;BYTE;'						;mov	rbx, QWORD PTR [rsp+64]
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x8B, 0x5C, 0x24, 64)			;48 8b 5c 24 40
	$sExe &= 'BYTE;BYTE;BYTE;BYTE;BYTE;'						;mov	rbp, QWORD PTR [rsp+72]
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x8B, 0x6C, 0x24, 72)			;48 8b 6c 24 48
	$sExe &= 'BYTE;BYTE;BYTE;BYTE;BYTE;'						;mov	rsi, QWORD PTR [rsp+80]
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x8B, 0x74, 0x24, 80)			;48 8b 74 24 50
	$sExe &= 'BYTE;BYTE;BYTE;BYTE;'								;add	rsp, 48
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x83, 0xc4, 48)					;48 83 c4 30
	$sExe &= 'BYTE;'											;pop	rdi
	__SSCtrlHover_ArrayPush($aOpCode, 0x5F)									;5f
	$sExe &= 'BYTE;BYTE;BYTE;'									;cmp	edx, 0x2A3
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0x85, 0xC0)						;48 85 c0
	$sExe &= 'BYTE;BYTE;'										;je		short WndProcInternal
	__SSCtrlHover_ArrayPush($aOpCode, 0x74, 0)
	$nAddrOffset[4] = DllStructGetSize(DllStructCreate($sExe))
	$nElemOffset[4] = $aOpCode[0]
	$aOpCode[$nElemOffset[2]] = DllStructGetSize(DllStructCreate($sExe)) - $nAddrOffset[2]

	; :DefaultWndProc (HWND, UINT, WPARAM, LPARAM)
	$sExe &= 'BYTE;BYTE;PTR;'
	__SSCtrlHover_ArrayPush($aOpCode, 0x48, 0xB8, $__SSCTRLHOVER_PDEFSUBCLASSPROC)
	$sExe &= 'BYTE;BYTE;'
	__SSCtrlHover_ArrayPush($aOpCode, 0xFF, 0xE0)

	; :Return
	$aOpCode[$nElemOffset[4]] = DllStructGetSize(DllStructCreate($sExe)) - $nAddrOffset[4]
	$sExe &= 'BYTE;'											;ret	0
	__SSCtrlHover_ArrayPush($aOpCode, 0xC3)

	Return __SSCtrlHover_PopulateOpcode($sExe, $aOpCode)
EndFunc

Func __SSCtrlHover_PopulateOpcode(ByRef $sExe, ByRef $aOpCode)
	Local $tExe = DllStructCreate($sExe)
	Assert(@error = 0, 'DllStrucCreate Failed With Error = ' & @error)

	For $i = 1 To $aOpCode[0]
		DllStructSetData($tExe, $i, $aOpCode[$i])
	Next
	Return $tExe
EndFunc

Func __SSCtrlHover_GetDefSubclassProcAddress()
	Return _WinAPI_GetProcAddress($__SSCTRLHOVER_HDLLCOMCTL32, 'DefSubclassProc')
EndFunc

Func __SSCtrlHover_ExecutableFromStruct($tExe)
	Local $pExe = DllCall('kernel32.dll', 'PTR', 'HeapAlloc', _
				'HANDLE', $__SSCTRLHOVER_HEXECUTABLEHEAP, 'DWORD', 8, 'ULONG_PTR', DllStructGetSize($tExe))[0]
	Assert($pExe <> 0, 'Allocate memory failed')
	DllCall("kernel32.dll", "none", "RtlMoveMemory", _
				"PTR", $pExe, "PTR", DllStructGetPtr($tExe), _
				"ULONG_PTR", DllStructGetSize($tExe))
	Assert(@error = 0, 'Failed to copy memory')

	Return $pExe
EndFunc

Func __SSCtrlHover_Finalize()
	_WinAPI_FreeLibrary($__SSCTRLHOVER_HDLLCOMCTL32)
	If ($__SSCTRLHOVER_HEXECUTABLEHEAP <> 0) Then
		If ($__SSCTRLHOVER_PSUBCLASSEXE <> 0) Then
			DllCall('kernel32.dll', 'BOOL', 'HeapFree', 'HANDLE', $__SSCTRLHOVER_HEXECUTABLEHEAP, _
						'DWORD', 0, 'PTR', $__SSCTRLHOVER_PSUBCLASSEXE)
			;
		EndIf
		DllCall('kernel32.dll', 'BOOL', 'HeapDestroy', 'HANDLE', $__SSCTRLHOVER_HEXECUTABLEHEAP)
	EndIf
EndFunc
#EndRegion
;