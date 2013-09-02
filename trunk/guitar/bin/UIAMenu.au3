#include-once

Global $_GMAccelTable[100][2]

Global $_GMFile
Global $_GMFile_NewFile
Global $_GMFile_Oepn
Global $_GMFile_Close
Global $_GMFile_Save
Global $_GMFile_SaveAS
Global $_GMFile_OpenQuick
Global $_GMFile_OpenRecent
Global $_GMFile_OpenInclude
Global $_GMFile_ClipboardOpen
Global $_GMFile_Exit

Global $_GMEdit
Global $_GMEdit_Undo
Global $_GMEdit_Cut
Global $_GMEdit_Copy
Global $_GMEdit_Paste
Global $_GMEdit_Delete
Global $_GMEdit_SelectAll
Global $_GMEdit_Found
Global $_GMEdit_Go

Global $_GMEdit_CommentSet

Global $_GMEdit_TargetRename
Global $_GMEdit_TargetDelete
Global $_GMEdit_CommandTemplate
Global $_GMEdit_TestCaseImport

Global $_GMRum
Global $_GMRum_Run
Global $_GMRum_RunBlock
Global $_GMRum_RunLoop
Global $_GMRum_Pause
Global $_GMRum_Stop
Global $_GMRum_RestBrowser

Global $_GMImage
Global $_GMImage_Capture
Global $_GMImage_Edit
Global $_GMImage_Explorer

Global $_GMReport
Global $_GMReport_Report
Global $_GMReport_OpenReportFoler
Global $_GMReport_OpenRemoteManager

Global $_GMTool
Global $_GMTool_PreRun
Global $_GMTool_UserRun1
Global $_GMTool_UserRun2
Global $_GMTool_UserRun3
Global $_GMTool_UserRun4
Global $_GMTool_UserRun5
Global $_GMTool_RunTestCaseExport

Global $_GMHelp
Global $_GMHelp_Help
Global $_GMHelp_HelpAutoitKey
Global $_GMHelp_HelpAutoitCommand
Global $_GMHelp_About


func AllMenuDisable($bDisable)

	local $iValue
	if $bDisable then
		$iValue = $GUI_DISABLE
	else
		$iValue = $GUI_ENABLE
	endif


	GUICtrlSetState ( $_GMFile, $iValue)
	GUICtrlSetState ( $_GMImage, $iValue)
	GUICtrlSetState ( $_GMEdit, $iValue)
	GUICtrlSetState ( $_GMRum, $iValue)
	GUICtrlSetState ( $_GMImage, $iValue)
	GUICtrlSetState ( $_GMReport, $iValue)
	GUICtrlSetState ( $_GMTool, $iValue)
	GUICtrlSetState ( $_GMHelp, $iValue)

endfunc

func CreateMainMenu()


	local $iGMACount =0

	; ����
	$_GMFile = GUICtrlCreateMenu(_getLanguageMsg("mnu_file") & "(&F)")
	$_GMFile_NewFile = GUICtrlCreateMenuItem(_getLanguageMsg("mnu_file_new") & "(&N)" & @TAB & "CTRL+N", $_GMFile)
	$_GMFile_Oepn = GUICtrlCreateMenuItem("����(&O)" & @TAB & "CTRL+O", $_GMFile)
	$_GMFile_Save = GUICtrlCreateMenuItem("����(&S)" & @TAB & "CTRL+S", $_GMFile)
	$_GMFile_Close = GUICtrlCreateMenuItem("�ݱ�(&C)" & @TAB & "CTRL+W", $_GMFile)
	$_GMFile_SaveAS = GUICtrlCreateMenuItem("�ٸ� �̸����� ����(&A)", $_GMFile)
	GUICtrlCreateMenuItem("", $_GMFile)
	$_GMFile_OpenQuick = GUICtrlCreateMenuItem("���� ����(&U)", $_GMFile)
	$_GMFile_OpenRecent = GUICtrlCreateMenuItem("�ֱ����� ����(&R)", $_GMFile)
	$_GMFile_OpenInclude = GUICtrlCreateMenuItem("�������� ����(&I)", $_GMFile)
	$_GMFile_ClipboardOpen = GUICtrlCreateMenuItem("Ŭ������ ���� (&Q)" & @TAB & "CTRL+Q", $_GMFile)
	GUICtrlCreateMenuItem("", $_GMFile)
	$_GMFile_Exit = GUICtrlCreateMenuItem("������(&X)", $_GMFile)

	$_GMAccelTable[$iGMACount][0] = "^n"
	$_GMAccelTable[$iGMACount][1] = $_GMFile_NewFile

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^o"
	$_GMAccelTable[$iGMACount][1] = $_GMFile_Oepn

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^w"
	$_GMAccelTable[$iGMACount][1] = $_GMFile_Close

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^s"
	$_GMAccelTable[$iGMACount][1] = $_GMFile_Save

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^q"
	$_GMAccelTable[$iGMACount][1] = $_GMFile_ClipboardOpen

	; ����
	$_GMEdit = GUICtrlCreateMenu("����(&E)")
	$_GMEdit_Undo = GUICtrlCreateMenuItem("���� ���(&U)" & @TAB & "CTRL+Z", $_GMEdit)
	$_GMEdit_Cut = GUICtrlCreateMenuItem("�߶󳻱�(&T)" & @TAB & "CTRL+X", $_GMEdit)
	$_GMEdit_Copy = GUICtrlCreateMenuItem("����(&C)" & @TAB & "CTRL+C", $_GMEdit)
	$_GMEdit_Paste = GUICtrlCreateMenuItem("�ٿ��ֱ�(&P)" & @TAB & "CTRL+V", $_GMEdit)
	$_GMEdit_Delete = GUICtrlCreateMenuItem("����(&D)" & @TAB & "DEL", $_GMEdit)
	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_SelectAll = GUICtrlCreateMenuItem("��ü ����(&A)" & @TAB & "CTRL+A", $_GMEdit)
	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_Found = GUICtrlCreateMenuItem("ã��/�ٲٱ�(&F)" & @TAB & "CTRL+F", $_GMEdit)
	$_GMEdit_Go = GUICtrlCreateMenuItem("�̵�(&M)" & @TAB & "CTRL+G", $_GMEdit)

	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_CommentSet = GUICtrlCreateMenuItem("�ּ� ����/����(&O)" & @TAB & "CTRL+E", $_GMEdit)

	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_TargetRename = GUICtrlCreateMenuItem("��� ����(&R)", $_GMEdit)
	$_GMEdit_TargetDelete = GUICtrlCreateMenuItem("��� ����(&L)", $_GMEdit)

	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_CommandTemplate = GUICtrlCreateMenuItem("��� ���ø� �߰�(&T)" & @TAB & "CTRL+T", $_GMEdit)

	GUICtrlCreateMenuItem("", $_GMEdit)
	$_GMEdit_TestCaseImport = GUICtrlCreateMenuItem("TestCase -> Comment ��ȯ(&I)", $_GMEdit)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^e"
	$_GMAccelTable[$iGMACount][1] = $_GMEdit_CommentSet


	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^f"
	$_GMAccelTable[$iGMACount][1] = $_GMEdit_Found

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^g"
	$_GMAccelTable[$iGMACount][1] = $_GMEdit_Go

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^t"
	$_GMAccelTable[$iGMACount][1] = $_GMEdit_CommandTemplate


	; ����
	$_GMRum = GUICtrlCreateMenu("����(&R)")
	$_GMRum_Run = GUICtrlCreateMenuItem("��ü ����(&R)" & @TAB & "F5", $_GMRum)
	$_GMRum_RunBlock = GUICtrlCreateMenuItem("�κ� ����(&B)" & @TAB & "F8", $_GMRum)
	$_GMRum_RunLoop = GUICtrlCreateMenuItem("�ݺ� ����(&L)" & @TAB & "CTRL+L", $_GMRum)
	$_GMRum_Pause = GUICtrlCreateMenuItem("�Ͻ� ����(&P)" & @TAB & "PAUSE", $_GMRum)
	$_GMRum_Stop = GUICtrlCreateMenuItem("����(&S)" & @TAB & "ESC", $_GMRum)

	GUICtrlCreateMenuItem("", $_GMRum)
	$_GMRum_RestBrowser = GUICtrlCreateMenuItem("�׽�Ʈ ��� ������ �ʱ�ȭ(&C)" & @TAB & "CTRL+R", $_GMRum)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "{F5}"
	$_GMAccelTable[$iGMACount][1] = $_GMRum_Run

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "{F8}"
	$_GMAccelTable[$iGMACount][1] = $_GMRum_RunBlock

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^l"
	$_GMAccelTable[$iGMACount][1] = $_GMRum_RunLoop

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^r"
	$_GMAccelTable[$iGMACount][1] = $_GMRum_RestBrowser


	; �̹���
	$_GMImage = GUICtrlCreateMenu("�̹���(&I)")
	$_GMImage_Capture = GUICtrlCreateMenuItem("�̹��� ĸ��(&C)" & @TAB & "CTRL+SHIFT+C", $_GMImage)
	$_GMImage_Edit = GUICtrlCreateMenuItem("�̹��� ����(&I)" & @TAB & "CTRL+I", $_GMImage)
	$_GMImage_Explorer = GUICtrlCreateMenuItem("�̹��� Ž����(&M)" & @TAB & "CTRL+M", $_GMImage)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^+c"
	$_GMAccelTable[$iGMACount][1] = $_GMImage_Capture

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^i"
	$_GMAccelTable[$iGMACount][1] = $_GMImage_Edit

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^m"
	$_GMAccelTable[$iGMACount][1] = $_GMImage_Explorer


	; ����Ʈ
	$_GMReport = GUICtrlCreateMenu("����Ʈ(&P)")

	$_GMReport_Report = GUICtrlCreateMenuItem("�׽�Ʈ ��� ����Ʈ (&R)", $_GMReport)
	$_GMReport_OpenReportFoler = GUICtrlCreateMenuItem("�ֱ� �׽�Ʈ ��� ���� ���� (&p)"  & @TAB & "CTRL+P" , $_GMReport)
	GUICtrlCreateMenuItem("", $_GMReport)
	$_GMReport_OpenRemoteManager = GUICtrlCreateMenuItem("���� ���� (&M)", $_GMReport)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "^p"
	$_GMAccelTable[$iGMACount][1] = $_GMReport_OpenReportFoler


	; ����
	$_GMTool = GUICtrlCreateMenu("����(&T)")

	$_GMTool_PreRun = GUICtrlCreateMenuItem("PreRun ��� ���� (&0)" & @TAB & "ALT+0", $_GMTool)
	$_GMTool_UserRun1 = GUICtrlCreateMenuItem("��������� ���1 ���� (&1)" & @TAB & "ALT+1", $_GMTool)
	$_GMTool_UserRun2 = GUICtrlCreateMenuItem("��������� ���2 ���� (&2)" & @TAB & "ALT+2", $_GMTool)
	$_GMTool_UserRun3 = GUICtrlCreateMenuItem("��������� ���3 ���� (&3)" & @TAB & "ALT+3", $_GMTool)
	$_GMTool_UserRun4 = GUICtrlCreateMenuItem("��������� ���4 ���� (&4)" & @TAB & "ALT+4", $_GMTool)
	$_GMTool_UserRun5 = GUICtrlCreateMenuItem("��������� ���5 ���� (&5)" & @TAB & "ALT+5", $_GMTool)

	GUICtrlCreateMenuItem("", $_GMTool)

	$_GMTool_RunTestCaseExport = GUICtrlCreateMenuItem("TestCase ������ ����", $_GMTool)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!0"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_PreRun

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!1"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun1

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!2"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun2

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!3"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun3

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!4"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun4

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "!5"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun5


	; ����
	$_GMHelp = GUICtrlCreateMenu("����(&H)")

	$_GMHelp_Help = GUICtrlCreateMenuItem("���� (&H)" & @TAB & "F1", $_GMHelp)
	$_GMHelp_HelpAutoitCommand = GUICtrlCreateMenuItem("AutoIt �Լ� ��� (&F)" , $_GMHelp)
	$_GMHelp_HelpAutoitKey = GUICtrlCreateMenuItem("AutoIt Key ��� (&K)" , $_GMHelp)
	$_GMHelp_About = GUICtrlCreateMenuItem("GUITAR ���� (&A)" , $_GMHelp)

	$iGMACount += 1
	$_GMAccelTable[$iGMACount][0] = "{F1}"
	$_GMAccelTable[$iGMACount][1] = $_GMTool_UserRun1


	redim $_GMAccelTable[$iGMACount + 1][2]

	GUISetAccelerators($_GMAccelTable, $_gForm)

endfunc
