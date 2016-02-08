#Region Header

#CS UDF Info
	Name.........:      GUIRichLabel.au3
	Description..:      Creates Rich Label control, to support text formatting.
	Forum link...:      
	Author.......:      G.Sandler a.k.a MrCreatoR (CreatoR's Lab, www.creator-lab.ucoz.ru, www.autoit-script.ru)
	Remarks......:  	
						1)	Nested tags does not supported, i.e: <font...>some <font...>formatted</font> data</font>. They will be removed.
						2)  Do not use @CRLFs inside tags, the result can be bad sometimes :)
	
	
	*** Version History ***
	
	v1.1
		+ Added _GUICtrlRichLabel_GetData function.
		+ Added "Running Letter Example".
		* Fixed issue with empty tags.
		* Nested tags removed now from the string.
	
	v1.0
		* First release (transformation from similar GUITFLabel UDF).
	
#CE

#include-once
#include <Array.au3>
#include <GUIRichEdit.au3>
#include <WinAPI.au3>
#include <FontConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>

#EndRegion Header

#Region Global Variables

Global $aGUIRL_Ctrls[1][1]

#EndRegion Global Variables

#Region Options

OnAutoItExitRegister('__GUIRichLabel_OnExit')
;GUIRegisterMsg($WM_NOTIFY, "__GUIRichLabel_WM_NOTIFY")

#EndRegion Options

#Region Public Functions

; #FUNCTION# ====================================================================================================
; Name...........:	_GUICtrlRichLabel_Create
; Description....:	Creates Text Formatted Label control(s).
; Syntax.........:	_GUICtrlRichLabel_Create($hWnd, $sData, $iLeft, $iTop [, $iWidth = -1 [, $iHeight = -1]])
;
; Parameters.....:	$hWnd     - GUI handle.
;                   $sData    - Formatted data. To set formatted data use <font></font> tag for data string.
;                              * This tag supports the following parameters (when used, they *can* be wrapped with quotes):
;                                   Color   - Text *Color* of data between the tags.
;                                   BkColor  - Text *Background Color* of data between the tags.
;                                   Size    - Text *Size*.
;                                   Align   - Text *Alignment* (only for current paragraph) - Supported strings: l(eft), r(ight), c(enter), j(ustify), f (justify between margins by only expanding spaces).
;                                   Attrib  - Text *Attributes* - Supported strings combined together (with + character): b(old), i(talic), u(nderline), s(trike).
;                                   Name    - Text font *Name* (the same values as used in GUICtrlSetFont()).
;
;					$iLeft    - Left position (starting point in case when <font> tags are used) of label controls.
;					$iTop     - Top position of label controls.
;					$iWidth   - [Optional] Width of label control - Not used when <font> tags found in the data.
;					$iHeight  - [Optional] Height of label control - Not used when <font> tags found in the data.
;					
; Return values..:	Success   - Returns rich label handle.
;					Failure   - Returns 0.
; Author.........:	G.Sandler (a.k.a MrCreatoR)
; Modified.......:	
; Remarks........:	
; Related........:	
; Link...........:	
; Example........:	Yes.
; ===============================================================================================================
Func _GUICtrlRichLabel_Create($hWnd, $sData, $iLeft, $iTop, $iWidth = -1, $iHeight = -1) ;, $fAutoDetectURL = False)
	Local $hRichLabel
	
	$_GRE_sRTFClassName = '' ;Fix for AutoIt 3.3.8.1 to create more than one RichEdit control
	$hRichLabel = _GUICtrlRichEdit_Create($hWnd, "", $iLeft, $iTop, $iWidth, $iHeight, BitOR($ES_MULTILINE, $ES_AUTOVSCROLL), $WS_EX_TRANSPARENT)
	WinSetState($hRichLabel, '', @SW_DISABLE)
	
	;_GUICtrlRichEdit_SetEventMask($hRichLabel, BitOR($ENM_LINK, $ENM_MOUSEEVENTS))
	;_GUICtrlRichEdit_AutoDetectURL($hRichLabel, $fAutoDetectURL)
	;_GUICtrlRichEdit_HideSelection($hRichLabel)
	
	$aGUIRL_Ctrls[0][0] += 1
	ReDim $aGUIRL_Ctrls[$aGUIRL_Ctrls[0][0]+1][2]
	$aGUIRL_Ctrls[$aGUIRL_Ctrls[0][0]][0] = $hRichLabel
	$aGUIRL_Ctrls[$aGUIRL_Ctrls[0][0]][1] = $sData
	
	If Not StringRegExp($sData, '(?i)<font.*?>(.*?)</font>') Then
		_GUICtrlRichEdit_AppendText($hRichLabel, $sData)
		_GUICtrlRichEdit_SetCharColor($hRichLabel, 0x000000)
		Return $hRichLabel
	EndIf
	
	_GUICtrlRichLabel_SetData($hRichLabel, $sData)
	Return $hRichLabel
EndFunc

Func _GUICtrlRichLabel_GetData($hRichLabel)
	For $i = 1 To $aGUIRL_Ctrls[0][0]
		If $aGUIRL_Ctrls[$i][0] = $hRichLabel Then
			Return $aGUIRL_Ctrls[$i][1]
		EndIf
	Next
	
	Return ''
EndFunc

Func _GUICtrlRichLabel_SetData($hRichLabel, $sData)
	Local $aSplit_Data, $aFontData, $iFont_Color, $iFont_BkColor, $iFont_Size, $sFont_Attrib, $sFont_Name, $sFont_Align
	Local $sIn_Data, $aSplit_Attribs, $iData_Len, $iData_Pos = 0
	
	;$sData = StringRegExpReplace($sData, '<font[^>]*?></font>', '')
	$sData = StringRegExpReplace($sData, '(\r\n|\r)', @LF)
	$aSplit_Data = __GUIRichLabel_StringGetTags($sData, '<font>', '</font>') ;StringRegExp($sData, "(?si)(.*?)(<font[^>]*?>.*?</font>|$)(.*?)", 3)
	
	_GUICtrlRichEdit_SetText($hRichLabel, "")
	
	$aFontData = __GUIRichLabel_GUIGetFont()
	
	If @error Then
		Dim $aFontData[6] = [5, 8.3, 400, 0, "Arial", 0]
	EndIf
	
	For $i = 0 To UBound($aSplit_Data)-1
		If $aSplit_Data[$i] == "" Then
			ContinueLoop
		EndIf
		
		$iFont_Color = 0x000000
		$iFont_BkColor = -1
		$iFont_Size = $aFontData[1]
		$iFont_Attrib = $aFontData[3]
		$sFont_Name = $aFontData[4]
		$sFont_Align = ""
		
		If StringInStr($sData, @LF) Then
			$sFont_Align = "l"
		EndIf
		
		If StringRegExp($aSplit_Data[$i], '(?si)<font .*?>(.*?)</font>') Then
			$sIn_Data = StringRegExpReplace($aSplit_Data[$i], '(?si)<font .*?>(.*?)</font>', '\1')
			
			__GUIRichLabel_FontTagGetParamValue($aSplit_Data[$i], "color", $iFont_Color)
			__GUIRichLabel_FontTagGetParamValue($aSplit_Data[$i], "bkcolor", $iFont_BkColor)
			__GUIRichLabel_FontTagGetParamValue($aSplit_Data[$i], "size", $iFont_Size)
			__GUIRichLabel_FontTagGetParamValue($aSplit_Data[$i], "align", $sFont_Align)
			__GUIRichLabel_FontTagGetParamValue($aSplit_Data[$i], "attrib", $sFont_Attrib)
			__GUIRichLabel_FontTagGetParamValue($aSplit_Data[$i], "name", $sFont_Name)
			
			$sFont_Align = StringRegExpReplace($sFont_Align, "^([lrcjf]).*$", "\1")
			
			$aSplit_Attribs = StringSplit($sFont_Attrib, "+")
			$sFont_Attrib = ""
			
			For $j = 1 To $aSplit_Attribs[0]
				$aSplit_Attribs[$j] = StringRegExpReplace($aSplit_Attribs[$j], "^(bold|b)$", "+bo")
				$aSplit_Attribs[$j] = StringRegExpReplace($aSplit_Attribs[$j], "^(italic|i)$", "+it")
				$aSplit_Attribs[$j] = StringRegExpReplace($aSplit_Attribs[$j], "^(underline|u)$", "+un")
				$aSplit_Attribs[$j] = StringRegExpReplace($aSplit_Attribs[$j], "^(strike|s)$", "+st")
				
				$sFont_Attrib &= $aSplit_Attribs[$j]
			Next
			
			If Dec($iFont_Color) > 0 Then
				$iFont_Color = StringRegExpReplace("0x" & $iFont_Color, "\A0x0x", "0x")
			EndIf
			
			$iFont_Color = StringRegExpReplace($iFont_Color, "\A#", "0x")
			$iFont_BkColor = StringRegExpReplace($iFont_BkColor, "\A#", "0x")
			
			If Not StringIsInt($iFont_Color) Then
				$iFont_Color = __GUIRichLabel_ColorConvertValue($iFont_Color)
			EndIf
			
			If Not StringIsInt($iFont_BkColor) Then
				$iFont_BkColor = __GUIRichLabel_ColorConvertValue($iFont_BkColor)
			EndIf
		Else
			If StringRegExp($aSplit_Data[$i], '(?si)<font\h*>(.*?)</font>') Then
				$aSplit_Data[$i] = StringRegExpReplace($aSplit_Data[$i], '(?si)<font\h*>|</font>', '')
			EndIf
			
			$sIn_Data = $aSplit_Data[$i]
			$sFont_Attrib = "-bo-it-un-st"
			$iFont_Color = 0x000000
			$iFont_BkColor = Default
		EndIf
		
		$iData_Len = StringLen($sIn_Data)
		
		_GUICtrlRichEdit_AppendText($hRichLabel, $sIn_Data)
		_GUICtrlRichEdit_SetParaAlignment($hRichLabel, $sFont_Align)
		
		_GUICtrlRichEdit_SetSel($hRichLabel, $iData_Pos, $iData_Pos + $iData_Len)
		_GUICtrlRichEdit_SetCharColor($hRichLabel, __GUIRichLabel_Color_RGBToBGR($iFont_Color))
		_GUICtrlRichEdit_SetCharBkColor($hRichLabel, __GUIRichLabel_Color_RGBToBGR($iFont_BkColor))
		_GUICtrlRichEdit_SetCharAttributes($hRichLabel, $sFont_Attrib)
		_GUICtrlRichEdit_SetFont($hRichLabel, $iFont_Size, $sFont_Name)
		
		$iData_Pos += $iData_Len
	Next
	
	Return 1
EndFunc

Func _GUICtrlRichLabel_SetPos($hRichLabel, $iLeft, $iTop, $iWidth = Default, $iHeight = Default)
	WinMove($hRichLabel, '', $iLeft, $iTop, $iWidth, $iHeight)
EndFunc

Func _GUICtrlRichLabel_Destroy($hRichLabel = -1)
	If $hRichLabel = -1 Then
		For $i = 1 To $aGUIRL_Ctrls[0][0]
			_GUICtrlRichEdit_Destroy($aGUIRL_Ctrls[$i][0])
		Next
		
		$aGUIRL_Ctrls = 0
		Dim $aGUIRL_Ctrls[1][1]
		
		Return 1
	EndIf
	
	For $i = 1 To $aGUIRL_Ctrls[0][0]
		If $hRichLabel = $aGUIRL_Ctrls[$i][0] Then
			$aGUIRL_Ctrls[0][0] -= 1
			_ArrayDelete($aGUIRL_Ctrls, $i)
			ExitLoop
		EndIf
	Next
	
	Return _GUICtrlRichEdit_Destroy($hRichLabel)
EndFunc

#EndRegion Public Functions

#Region Internal Functions

; #HELPER FUNCTION - Get tags from string#
Func __GUIRichLabel_StringGetTags($sStr, $sOpenTag, $sCloseTag)
	Local $aRet, $aTmp, $iC
	
	$sOpenTag = StringRegExpReplace($sOpenTag, '^(<\S+)>.*', '\1') ;Get only the tag name (i.e: <tag)
	$sStr = StringRegExpReplace($sStr, $sOpenTag & '[^>]*>' & $sCloseTag, '') ;Remove empty tags
	$aRet = StringRegExp($sStr, $sOpenTag & '[^>]*>(.*?)' & $sCloseTag, 3)
	
	For $i = 0 To UBound($aRet)-1
		$sStr = StringReplace($sStr, $aRet[$i], StringRegExpReplace($aRet[$i], $sOpenTag & '[^>]*>', ''), 0, 1)
	Next
	
	$aTmp = StringRegExp($sStr, '(?si)(.*?)(' & $sOpenTag & '[^>]*>.*?' & $sCloseTag & '|$)(.*?)', 3)
	$sStr = ''
	
	Dim $aRet[UBound($aTmp)]
	$iC = 0
	
	For $i = 0 To UBound($aTmp)-1
		If $aTmp[$i] = '' Then ContinueLoop
		
		If Not StringRegExp($aTmp[$i], $sOpenTag & '[^>]*>.*?' & $sCloseTag) Then
			$aTmp[$i] = StringReplace($aTmp[$i], $sCloseTag, '')
		EndIf
		
		$aRet[$iC] = $aTmp[$i]
		$iC += 1
	Next
	
	If $iC = 0 Then Return SetError(1, 0, 0)
	
	ReDim $aRet[$iC]
	Return $aRet
EndFunc

; #HELPER FUNCTION - Converts RGB color To BGR#
Func __GUIRichLabel_Color_RGBToBGR($iColor)
	If $iColor = -1 Then Return -1
	If IsKeyword($iColor) And $iColor = Default Then Return Default
	
	Local $iMask = BitXOR(BitAND($iColor, 0xFF), ($iColor / 0x10000))
	Return "0x" & Hex(BitXOR($iColor, ($iMask * 0x10001)), 6)
EndFunc

; #HELPER FUNCTION - Get <font> tag's parameter value#
Func __GUIRichLabel_FontTagGetParamValue($sTag_Data, $sParamName, ByRef $sDefault)
	Local $sRet = StringRegExpReplace($sTag_Data, '(?i)<font.*? ' & $sParamName & '=(?:"|)(.*?)(?:"| |>).*?>.*?$', '\1')
	
	If @extended > 0 Then $sDefault = $sRet
	Return $sDefault
EndFunc

; #HELPER FUNCTION - Get color by it's name#
Func __GUIRichLabel_ColorConvertValue($sColor, $iMode = -1)
	If $iMode = -1 And StringRegExp($sColor, "\A0x") And StringLen($sColor) = 5 Then
		$sColor = StringRegExpReplace($sColor, "\A(0x)|(.)", "\1\2\2")
	EndIf
	
	Local $aStrColors_Table = StringSplit( _
		"White|Ivory|Lightyellow|Yellow|Snow|Floralwhite|Lemonchiffon|" & _
		"Cornsilk|Seashell|Lavenderblush|Papayawhip|Blanchedalmond|Mistyrose|Bisque|" & _
		"Moccasin|Navajowhite|Peachpuff|Gold|Pink|Lightpink|Orange|" & _
		"Lightsalmon|Darkorange|Coral|Hotpink|Tomato|Orangered|Deeppink|" & _
		"Magenta|Fuchsia|Red|Oldlace|Lightgoldenrodyellow|Linen|Antiquewhite|" & _
		"Salmon|Ghostwhite|Mintcream|Whitesmoke|Beige|Wheat|Sandybrown|" & _
		"Azure|Honeydew|Aliceblue|Khaki|Lightcoral|Palegoldenrod|Violet|" & _
		"Darksalmon|Lavender|Lightcyan|Burlywood|Plum|Gainsboro|Crimson|" & _
		"Palevioletred|Goldenrod|Orchid|Thistle|Lightgrey|Tan|Chocolate|" & _
		"Peru|Indianred|Mediumvioletred|Silver|Darkkhaki|Rosybrown|Mediumorchid|" & _
		"Darkgoldenrod|Firebrick|Powderblue|Lightsteelblue|Paleturquoise|Greenyellow|Lightblue|" & _
		"Darkgray|Brown|Sienna|Yellowgreen|Darkorchid|Palegreen|Darkviolet|" & _
		"Mediumpurple|Lightgreen|Darkseagreen|Saddlebrown|Darkmagenta|Darkred|Blueviolet|" & _
		"Lightskyblue|Skyblue|Gray|Olive|Purple|Maroon|Aquamarine|" & _
		"Chartreuse|Lawngreen|Mediumslateblue|Lightslategray|Slategray|Olivedrab|Slateblue|" & _
		"Dimgray|Mediumaquamarine|Cornflowerblue|Cadetblue|Darkolivegreen|Indigo|Mediumturquoise|" & _
		"Darkslateblue|Steelblue|Royalblue|Turquoise|Mediumseagreen|Limegreen|Darkslategray|" & _
		"Seagreen|Forestgreen|Lightseagreen|Dodgerblue|Midnightblue|Cyan|Aqua|" & _
		"Springgreen|Lime|Mediumspringgreen|Darkturquoise|Deepskyblue|Darkcyan|Teal|" & _
		"Green|Darkgreen|Blue|Mediumblue|Darkblue|Navy|Black", "|")
	
	Local $aHexColors_Table = StringSplit( _
		"FFFFFF|FFFFF0|FFFFE0|FFFF00|" & _
		"FFFAFA|FFFAF0|FFFACD|FFF8DC|FFF5EE|FFF0F5|FFEFD5|" & _
		"FFEBCD|FFE4E1|FFE4C4|FFE4B5|FFDEAD|FFDAB9|FFD700|" & _
		"FFC0CB|FFB6C1|FFA500|FFA07A|FF8C00|FF7F50|FF69B4|" & _
		"FF6347|FF4500|FF1493|FF00FF|FF00FF|FF0000|FDF5E6|" & _
		"FAFAD2|FAF0E6|FAEBD7|FA8072|F8F8FF|F5FFFA|F5F5F5|" & _
		"F5F5DC|F5DEB3|F4A460|F0FFFF|F0FFF0|F0F8FF|F0E68C|" & _
		"F08080|EEE8AA|EE82EE|E9967A|E6E6FA|E0FFFF|DEB887|" & _
		"DDA0DD|DCDCDC|DC143C|DB7093|DAA520|DA70D6|D8BFD8|" & _
		"D3D3D3|D2B48C|D2691E|CD853F|CD5C5C|C71585|C0C0C0|" & _
		"BDB76B|BC8F8F|BA55D3|B8860B|B22222|B0E0E6|B0C4DE|" & _
		"AFEEEE|ADFF2F|ADD8E6|A9A9A9|A52A2A|A0522D|9ACD32|" & _
		"9932CC|98FB98|9400D3|9370DB|90EE90|8FBC8F|8B4513|" & _
		"8B008B|8B0000|8A2BE2|87CEFA|87CEEB|808080|808000|" & _
		"800080|800000|7FFFD4|7FFF00|7CFC00|7B68EE|778899|" & _
		"708090|6B8E23|6A5ACD|696969|66CDAA|6495ED|5F9EA0|" & _
		"556B2F|4B0082|48D1CC|483D8B|4682B4|4169E1|40E0D0|" & _
		"3CB371|32CD32|2F4F4F|2E8B57|228B22|20B2AA|1E90FF|" & _
		"191970|00FFFF|00FFFF|00FF7F|00FF00|00FA9A|00CED1|" & _
		"00BFFF|008B8B|008080|008000|006400|0000FF|0000CD|" & _
		"00008B|000080|000000", "|")
	
	For $i = 1 To $aStrColors_Table[0]
		If $iMode = -1 And $sColor = $aStrColors_Table[$i] Then
			Return "0x" & $aHexColors_Table[$i]
		ElseIf $iMode <> -1 And StringRegExp($sColor, "\A(0x|#|)" & $aHexColors_Table[$i] & "$") Then
			Return $aStrColors_Table[$i]
		EndIf
	Next
	
	If $sColor = -1 Or $sColor = "" Or (IsKeyword($sColor) And $sColor = Default) Then Return -1
	Return "0x" & Hex($sColor, 6)
EndFunc

Func __GUIRichLabel_GUIGetFont($hWnd = 0)
	; [0] - 5
	; [1] - Size
	; [2] - Weight
	; [3] - Attribute
	; [4] - Name
	; [5] - Quality
	
	Local $Ret, $Label, $hLabel, $hPrev, $hDC, $hFont, $tFont
	Local $aFont = 0
	
	If $hWnd = 0 Then
		$Label = GUICtrlCreateLabel('', 0, 0)
		
		If Not $Label Then
			Return 0
		EndIf
		
		$hWnd = _WinAPI_GetParent(GUICtrlGetHandle($Label))
		
		GUICtrlDelete($Label)
	EndIf
	
	$hPrev = GUISwitch($hWnd)
	
	If Not $hPrev Then
		Return 0
	EndIf
	
	$Label = GUICtrlCreateLabel('', 0, 0, 0, 0)

	If Not $Label Then
		Return 0
	EndIf
	
	$hLabel = GUICtrlGetHandle($Label)
	$hDC = _WinAPI_GetDC($hLabel)
	$hFont = _SendMessage($hLabel, $WM_GETFONT)
	$tFont = DllStructCreate($tagLOGFONT)
	$Ret = DllCall('gdi32.dll', 'int', 'GetObjectW', 'ptr', $hFont, 'int', DllStructGetSize($tFont), 'ptr', DllStructGetPtr($tFont))
	
	If (Not @error) And ($Ret[0]) Then
		Dim $aFont[6] = [5]
		$aFont[1] = -Round(DllStructGetData($tFont, 'Height') / _WinAPI_GetDeviceCaps($hDC, $LOGPIXELSY) * 72, 1)
		$aFont[2] = DllStructGetData($tFont, 'Weight')
		$aFont[3] = BitOR(2 * (DllStructGetData($tFont, 'Italic') <> 0), 4 * (DllStructGetData($tFont, 'Underline') <> 0), 8 * (DllStructGetData($tFont, 'Strikeout') <> 0))
		$aFont[4] = DllStructGetData($tFont, 'FaceName')
		$aFont[5] = DllStructGetData($tFont, 'Quality')
	EndIf
	
	_WinAPI_ReleaseDC($hLabel, $hDC)
	GUICtrlDelete($Label)
	GUISwitch($hPrev)
	
	Return $aFont
EndFunc

Func __GUIRichLabel_WM_NOTIFY($hWnd, $iMsg, $iWparam, $iLparam)
    Local $hWndFrom, $iCode, $tNMHDR, $tMsgFilter, $iWM_Msg, $tEnLink, $cpMin, $cpMax, $sURL
	
    $tNMHDR = DllStructCreate($tagNMHDR, $iLparam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iCode = DllStructGetData($tNMHDR, "Code")
	
	$tMsgFilter = DllStructCreate($tagMSGFILTER, $iLparam)
	$iWM_Msg = DllStructGetData($tMsgFilter, "msg")
	
	Switch $iCode
		Case $EN_MSGFILTER
			Return 1
			Switch $iWM_Msg
				Case $WM_LBUTTONDOWN, $WM_RBUTTONDOWN, $WM_LBUTTONDBLCLK, 0x0206 ;$WM_RBUTTONDBLCLK
					Return 1
			EndSwitch
		Case $EN_LINK
			If $iWM_Msg = $WM_LBUTTONUP Then
				$tEnLink = DllStructCreate($tagENLINK, $iLparam)
				$cpMin = DllStructGetData($tEnLink, "cpMin")
				$cpMax = DllStructGetData($tEnLink, "cpMax")
				
				$sURL = _GUICtrlRichEdit_GetTextInRange($hWndFrom, $cpMin, $cpMax)
				ShellExecute($sURL)
			EndIf
	EndSwitch
	
    Return 'GUI_RUNDEFMSG'
EndFunc

Func __GUIRichLabel_OnExit()
	_GUICtrlRichLabel_Destroy(-1)
EndFunc

#EndRegion Internal Functions
