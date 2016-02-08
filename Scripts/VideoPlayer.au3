#cs
_wmploadmedia( $object, $URL )
$object:    Object returned from the $playerOBJ = _IEGetObjById($oIE, "objWMPlayer")
$URL:       Path or URL of the media
Return: None
#ce
Func _wmploadmedia( $object, $URL)
    $object.URL = $URL
    While Not $object.controls.isAvailable("play")
        Sleep(1)
    WEnd
    $object.controls.play()
EndFunc


; Function: _GUICtrl_CreateWMPlayer
; Purpose: Embed Windows Media Player and play one file or one playlist only.
; Notes: PARAM NAME="url" is ReadOnly
; Authors: squirrely1
; borderless IE embed example: GaryFrost
; Kudos - Kare Johansson, CFire
; References:
; http://msdn2.microsoft.com/en-us/library/ms930698.aspx
; http://www.w3schools.com/media/media_playerref.asp
; clsid:6BF52A52-394A-11d3-B153-00C04F79FAA6 - wmplayer latest installed version
; clsid:22D6F312-B0F6-11D0-94AB-0080C74C7E95 - wmp 6.4
;===============================================
Func _GUICtrl_CreateWMPlayer($movieURL, $playerLeft, $playerTop, $playerWidth, $playerHeight, _
    $insetBorders = 0, $fullscreenMode = False, $showControls = True, $enableContextMenu = True, _
    $LoopMode = false, $playCount = 1, $playVolume = 100, $playBalance = 0, $enableFullScreenControls = True)

    If $fullscreenMode Then
        $fullscreenMode = "true"
    Else
        $fullscreenMode = "false"
    EndIf
    If $showControls Then
        $showControls = "true"
    Else
        $showControls = "false"
    EndIf
    If $enableContextMenu Then
        $enableContextMenu = "true"
    Else
        $enableContextMenu = "false"
    EndIf
    If $LoopMode Then
        $playCount = 999
    EndIf
    If $enableFullScreenControls Then
        $enableFullScreenControls = "true"
    Else
        $enableFullScreenControls = "false"
    EndIf

    Local $myIE_Obj = _IECreateEmbedded ()
    $IEControl = GUICtrlCreateObj($myIE_Obj, $playerLeft, $playerTop, $playerWidth, $playerHeight)
    _IENavigate($myIE_Obj, "about:blank")
    Local $htmlWMP
    $htmlWMP = '' _
                & @CR & '<body style="margin:0;padding:0" >' _
                & @CR & '<OBJECT' _
                & @CR & 'ID="objWMPlayer"' _
                & @CR & 'STYLE="margin:0;padding:0"' _
                & @CR & 'HSPACE="0"' _
                & @CR & 'VSPACE="0"' _
                & @CR & 'BORDER="0"' _
                & @CR & 'WIDTH="' & $playerWidth & '"' _
                & @CR & 'HEIGHT="' & $playerHeight & '"' _
                & @CR & 'CLASSID="clsid:6BF52A52-394A-11D3-B153-00C04F79FAA6"' _
                & @CR & 'STANDBY="Loading Windows Media Player components..."' _
                & @CR & 'TYPE="application/x-ms-wmp">' _
                & @CR & '<PARAM NAME="allowHideControls" VALUE="true">' _
                & @CR & '<PARAM NAME="autoStart" VALUE="false">' _
                & @CR & '<PARAM NAME="audioStream" VALUE="false">' _
                & @CR & '<PARAM NAME="autoSize" VALUE="false">' _
                & @CR & '<PARAM NAME="balance" VALUE="' & $playBalance & '"><!-- -100 to 100 -->' _
                & @CR & '<!-- <PARAM NAME="bufferingTime" VALUE="5"><!-- seconds -->' _
                & @CR & '<PARAM NAME="clickToPlay" VALUE="false"><!-- has no effect -->' _
                & @CR & '<PARAM NAME="currentPosition" VALUE="0"><!-- start position within video, in seconds -->' _
                & @CR & '<PARAM NAME="enableContextMenu" VALUE="' & $enableContextMenu & '">' _
                & @CR & '<PARAM NAME="enableFullScreenControls" VALUE="' & $enableFullScreenControls & '">' _
                & @CR & '<PARAM NAME="enabled" VALUE="true"><!-- whether controls are enabled -->' _
                & @CR & '<PARAM NAME="fullScreen" VALUE="' & $fullscreenMode & '">' _
                & @CR & '<PARAM NAME="mute" VALUE="false">' _
                & @CR & '<PARAM NAME="playCount" VALUE="' & $playCount & '">' _
                & @CR & '<!-- <PARAM NAME="previewMode" VALUE="true"> -->' _
                & @CR & '<PARAM NAME="rate" VALUE="1"><!-- play speed of -.5 to 2 increments of .1 -->' _
                & @CR & '<PARAM NAME="sendPlayStateChangeEvents" VALUE="false">' _
                & @CR & '<PARAM NAME="showCaptioning" VALUE="false">' _
                & @CR & '<PARAM NAME="showControls" VALUE="' & $showControls & '">' _
                & @CR & '<PARAM NAME="showGotoBar" VALUE="false">' _
                & @CR & '<PARAM NAME="showPositionControls" VALUE="true"><!-- uiMode must = "full" -->' _
                & @CR & '<PARAM NAME="showStatusBar" VALUE="false"><!-- has no effect -->' _
                & @CR & '<PARAM NAME="showDisplay" VALUE="true"><!-- has no effect - reportedly shows filename -->' _
                & @CR & '<PARAM NAME="stretchToFit" VALUE="true">' _
                & @CR & '<PARAM NAME="uiMode" VALUE="full"><!-- invisible, none, mini, full -->' _
                & @CR & '<!-- <PARAM NAME="videoBorderWidth" VALUE="0"> -->' _
                & @CR & '<PARAM NAME="volume" VALUE="' & $playVolume & '"><!-- volume percent setting of wmplayer.exe -->' _
                & @CR & '<PARAM NAME="windowlessVideo" VALUE="false"><!-- must be the default (false) for function to work in wmp 9.0, otherwise might renders video directly in the client area -->' _
                & @CR & '</OBJECT>' _
                & @CR & '</body>'
    _IEDocWriteHTML ($myIE_Obj, $htmlWMP)
    _IEAction ($myIE_Obj, "refresh")
    $myIE_Obj.document.body.scroll = "no"
    $myIE_Obj.document.body.style.border = $insetBorders
    Return $myIE_Obj
EndFunc ;==>_GUICtrl_CreateWMPlayer

Func _wmpvalue( $object, $setting, $para=1 )
    Switch $setting
        Case "play"
            If $object.controls.isAvailable("play") Then $object.controls.play()
        case "stop"
            If $object.controls.isAvailable("stop") Then $object.controls.stop()
        case "pause"
            If $object.controls.isAvailable("pause") Then $object.controls.pause()
        case "invisible"
            $object.uiMode = "invisible"
        case "controls"
            $object.uiMode = "full"
        case "nocontrols"
            $object.uiMode = "none"
        case "fullscreen"
            $object.fullscreen = "True"
        Case "step"
            If $object.controls.isAvailable("step") Then $object.controls.step($para)
        Case "fastForward"
            If $object.controls.isAvailable("fastForward") Then $object.controls.fastForward()
        Case "fastReverse"
            If $object.controls.isAvailable("fastReverse") Then $object.controls.fastReverse()
        Case "volume"
            $object.settings.volume = $para
        Case "rate"
            $object.settings.rate = $para
        Case "playcount"
            $object.settings.playCount = $para
        Case "setposition"
            $object.controls.currentPosition = $para
        Case "getposition"
            Return $object.controls.currentPosition
        Case "getpositionstring"
            Return $object.controls.currentPositionString
        Case "getduration"
            Return $object.currentMedia.duration
        Case "getname"
            Return $object.currentMedia.name
    EndSwitch
EndFunc