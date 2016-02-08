#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\..\Soft\Download\icon.ico
#AutoIt3Wrapper_Res_Comment=OPA1 License
#AutoIt3Wrapper_Res_Description=OPA1 License
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=VinhPham
#AutoIt3Wrapper_Res_Field=Code by|Vinh Pham
#AutoIt3Wrapper_Res_Field=Website|http://a1.opdo.top
#AutoIt3Wrapper_Res_Field=Support|a1@opdo.top
#AutoIt3Wrapper_Res_Field=Donate|www.opdo.top/p/ong-gop-cho-tac-gia.html
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

$read_me = 'Chào bạn, đây là phần mềm được code bởi Vinh Phạm (opdo.top). Tôi rất vui khi bạn có hứng thú với phần mềm này và quyết định "tọc mạch" nó, nhưng:'&@CRLF& _
			'- Sourcode này chỉ sử dụng để tham khảo, vui lòng không sao chép vào mục đích thương mại hoặc quảng cáo tư lợi.'&@CRLF& _
			'- Vui lòng không phát hành lại, hoặc phát hành tương tự phần mềm.'&@CRLF& _
			'- Xin hãy tôn trọng công sức của tôi bằng cách để lại nguồn nếu bạn sử dụng lại một phần code của tôi trong project của bạn. Tôi sẽ rất biết ơn về điều đó.'&@CRLF& _
			'Xin cảm ơn ^^'
If not @Compiled Then MsgBox(32,'Xin chào, vui lòng đọc một chút',$read_me)
if StringLeft(@ScriptName,StringLen(@ScriptName)-4) = 'OPA1_License' Then
	$ok = 'ok'
	Else
	MsgBox(16,@ScriptName,'Phần mềm sẽ khởi động lại vì lỗi sai tên file: OPA1_License.exe')
	FileCopy(@ScriptFullPath,@ScriptDir& '\OPA1_License.exe',1)
	ShellExecute('OPA1_License.exe')
	_SelfDelete()
	Exit
EndIf
;*****************************************
;OPA1_License.au3 by vinhp
;Created with ISN AutoIt Studio v. 0.99 BETA
;*****************************************
Opt("GUIOnEventMode", 1)
#include "Scripts\LoadingGUI.au3"
#include <Icons.au3>
#include <GuiEdit.au3>
#include <IE.au3>
#include <Crypt.au3>
#include <WinAPI.au3>
#include <WinAPIShellEx.au3>

#include "Forms\GUI Main.isf"
#include "Forms\GUI Learn.isf"
#include "Forms\GUI Review.isf"
#include "Forms\GUI Thi.isf"
#include "Forms\Thi Done.isf"
#include "Forms\GUI Video.isf"
#include "Forms\GUI Tip.isf"
#include "Forms\GUI About.isf"
#include "Forms\GUI Change Name.isf"

#include "Scripts\SSCtrlHover_v3.au3"
#include "Scripts\GUIController.au3"
#include "Scripts\StringSize.au3"
#include "Scripts\GUIRichLabel.au3"
#include "Scripts\TracNghiemFunc.au3"
#include "Scripts\Thi.au3"
#include "Scripts\VideoPlayer.au3"
_Install_Fonts()
; khai báo các biến cần thiết
Global $version='1.0'
Global $myTip[5]
$myTip[1] = 'Xin chào bạn, đây là giao diện học 150 câu lý thuyết thi bằng lái|Đáp án là những câu dược in nổi bật|Để chuyển câu hỏi nhanh, bạn có thể sử dụng phím tắt|Có nhiều câu có mẹo học rất hay, hãy trỏ chuột vào để xem thử nhé!'
$myTip[2] = 'Xin chào bạn, đây là giao diện ôn tập lại 150 cấu lý thuyết|Bạn chọn đáp án và Enter để tiếp tục|Bạn có thể sử dụng phím tắt để chọn nhanh đáp án|Các đáp án sai sẽ được nhắc, hãy ghi nhớ nó để tránh sai lần nữa nhé!'
$myTip[3] = 'Xin chào bạn, đây là giao diện thi thử, được thiết kế tương đương giao diện thi thật|Ngoài bấm vào đáp án và câu hỏi để chọn, bạn còn có thể sử dụng phím tắt|Các đáp án đúng sau khi nộp bài sẽ được hiển thị màu xanh, ngược lại đáp án sai là màu đỏ'
$myTip[4] = 'Xin chào bạn, tôi là OPA1 License sinh ngày 8/2/2016, trú tại http://a1.opdo.top|Cha tôi là VinhPham (opdo.top), người tạo ra tôi với ❤ dành cho bạn|Tôi sẽ hỗ trợ bạn học thi bằng lái dễ dàng hơn bằng những gì mà cha tôi đã lập trình cho tôi ❤|Nếu bạn thấy tôi có ích, hãy đóng góp cho cha tôi 10.000đ để phát triển nhiều hơn tôi như vậy ^^'
Global $regedit = 'HKEY_CURRENT_USER\SOFTWARE\OPA1'
Global $myButton[4], $myDethi
Global $myButton_text[4] = ['HỌC LÝ THUYẾT', 'THI THỬ', 'XEM THỰC HÀNH', 'CẨM NANG GIAO THÔNG']
Global $myButton_text2[4] = ['Sợ gì lý thuyết', 'Thi thử xem nào', 'Thực hành ra sao?', 'Cẩm nang cho mọi người']
Global $myButton_icon[4] = ['Images\icon0.png', 'Images\icon1.png', 'Images\icon2.png', 'Images\icon3.png']
Global $Database = @ScriptDir&'\Database.opdo'
Global $dethi[9][20] = [[47, 49, 6, 27, 12, 66, 74, 20, 38, 62, 89, 115, 81, 100, 112, 147, 125, 138, 148, 123], [51, 64, 9, 2, 23, 30, 72, 66, 35, 43, 90, 115, 104, 108, 88, 144, 124, 139, 149, 116], [60, 26, 1, 10, 37, 48, 40, 21, 17, 50, 83, 99, 109, 91, 114, 148, 128, 133, 118, 146], [25, 74, 45, 18, 3, 40, 53, 16, 59, 3, 105, 84, 98, 94, 115, 142, 149, 117, 127, 134], [63, 52, 5, 41, 22, 13, 1, 33, 58, 28, 113, 92, 87, 107, 101, 141, 121, 150, 132, 129], [46, 39, 48, 31, 8, 54, 17, 57, 11, 67, 113, 103, 111, 86, 93, 136, 120, 140, 150, 126], [7, 29, 63, 44, 34, 19, 55, 42, 58, 14, 106, 102, 85, 114, 95, 131, 137, 122, 145, 148], [4, 24, 61, 44, 36, 56, 43, 15, 38, 32, 97, 96, 110, 82, 115, 119, 143, 135, 148, 130]]
Global $thiTime = 0
Global $donate = 'http://www.opdo.top/p/ong-gop-cho-tac-gia.html'
Dim $timeDiff = TimerInit()
; GUI -------------------------------------------------------

_LoadGUI()

_SetControlHover() ; set hover control
_End_Loading()
If RegRead($regedit, 'name') = '' Then
	RegWrite($regedit, 'name', 'REG_SZ', 'bạn')

	_Tip_Load_Id(4)
	Else
	GUISetState(@SW_SHOW, $GUI_Main)
EndIf


While 1


	If $thiTime <> 0 Then
		If TimerDiff($timeDiff) >= 1000 Then
			$thiTime -= 1
			Local $sec = Mod($thiTime, 60)
			Local $min = Int($thiTime / 60)
			If $sec < 10 Then $sec = '0' & $sec
			If $min < 10 Then $min = '0' & $min
			GUICtrlSetData($thi_timetext2, 'THỜI GIAN CÒN LẠI: ' & $min & ':' & $sec)
			GUICtrlSetData($thi_timetext, Int($thiTime * 100 / (15 * 60)) & '%')
			GUICtrlSetPos($thi_timeprocess, Default, Default, Int(($thiTime / (15 * 60)) * 517))
			If Int($thiTime * 100 / (15 * 60)) < 15 Then GUICtrlSetBkColor($thi_timeprocess, 0xFF2222)
			$timeDiff = TimerInit()
		EndIf
		If $thiTime = 0 Then _ThiButton_Done()
	EndIf
	Sleep(100)
WEnd

