#include-once

#include <StaticConstants.au3>
#include <GuiConstantsEx.au3>
#include <GuiListView.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#Include <Misc.au3>
#Include <Array.au3>
#include <GUIComboBox.au3>

#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_ImageGetInfo.au3"

#include "UIACommon.au3"

Global enum $_iImageLstName ,$_iImageLstFullPath, $_iImageLstUse,  $_iImageLstEnd

Global $_gImageForm
Global $_gImageListView
Global $_gListViewData [1][$_iImageLstEnd]
Global $_gLastListImageIndex
Global $_gListViewImage
Global $_gListViewImageFrame
Global $_gListViewImagePositionY
Global $_gListViewMsPaint

Global $_sLastListViewPath
Global $_gListViewSearch
Global $_gListViewNameCopy
Global $_gListViewDelete
Global $_gListViewRename
Global $_gListViewMove
Global $_gListViewEnd
Global $_gListViewRun
Global $_gFileSearch
Global $_gRadioScript
Global $_gRadioPath
Global $_gListViewPath
Global $_gListViewPathOpen
Global $_gListViewPathSelect
Global $_gListViewScript

Global $_gListViewCurPath
Global $_gListViewCurScript

Global $_sListviewFirstImageFolder

func _checkSelectImageList()

	local $aSelectInfo
	local $iNewIndex
	local $bSelect

	local $bResult = False

	$aSelectInfo = _GUICtrlListView_GetSelectedIndices($_gImageListView, True)

	if IsArray($aSelectInfo) then
		if UBound($aSelectInfo) > 1 then $bSelect = True
	endif

	if $bSelect then

		$iNewIndex = $aSelectInfo[ubound($aSelectInfo)-1]
		;DEBUG($iNewIndex)
		if $_gLastListImageIndex <> $iNewIndex then
			$_gLastListImageIndex = $iNewIndex
			;debug($iNewIndex)
			viewSelecteListviewImage ($iNewIndex)
			$bResult =  True
			;msg("ã��")
		endif

	Else
		;msg("��ã��")
		$_gLastListImageIndex = -1
	endif

	Return $bResult

endfunc

func setListViewLastImageFolderComboListUpdate()

	local $i
	local $sList = ""
	local $aFolderList = _getRecentImageFolder()

	_GUICtrlComboBox_ResetContent($_gListViewPath)

	_GUICtrlComboBox_BeginUpdate($_gListViewPath)

	_GUICtrlComboBox_AddString($_gListViewPath, $_sListviewFirstImageFolder )

	for $i=1 to ubound($aFolderList) -1
		if $_sListviewFirstImageFolder <> $aFolderList[$i] then _GUICtrlComboBox_AddString($_gListViewPath, $aFolderList[$i])
		;debug($_aDefaultCaptureFileList[$i])
	next

	_GUICtrlComboBox_EndUpdate($_gListViewPath)
	sleep(10)
	_GUICtrlComboBox_SetCurSel($_gListViewPath, 0)

endfunc

func _loadMngImage($bSearchSkip)

	local $x, $y , $xadd, $yadd
	local $aListWidth[$_iImageLstEnd]
	local $i
	local $iWidthSum = 10
	local $iDefaultTextWidth = 20
	local $iDefaultButtonWidth = 30
	local $iFormLeft = 10
	local $iFormTop = 10
	local $iFormWidth = 980
	local $iLVStyle, $iLVExtStyle
	Local $iExWindowStyle = BitOR($WS_EX_DLGMODALFRAME, $WS_EX_CLIENTEDGE)
	Local $iExListViewStyle = BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES, $LVS_EX_GRIDLINES, $LVS_EX_CHECKBOXES, $LVS_EX_DOUBLEBUFFER)
	local $sDefaultSearchText
	local $iLastFormX
	local $iLastFormY
	local $iStartPos, $iEndPos

	if $bSearchSkip = False then
		$sDefaultSearchText = getTargetFormRichEdit($_gEditScript, "CURSOR", False, $iStartPos, $iEndPos)
		;debug("���� : "  & $sDefaultSearchText)
		if checkImageTarget($sDefaultSearchText) = False then $sDefaultSearchText = ""
		;debug("���� : "  & $sDefaultSearchText)
	endif


	; ��ư ����

	;Opt("GuiOnEventMode", 0)

	$x = $iFormLeft + 10
	$y = $iFormTop + 15


	AutoItSetOption("GUICloseOnESC", 1)

	guisetstate(@SW_DISABLE,$_gForm)

	$iLastFormX = _readSettingReg ("LastImageListX")
	$iLastFormY = _readSettingReg ("LastImageListY")

	; ����ͻ� �ִ� ��ǥ���� Ȯ��
	if number(GetMonitorFromPoint($iLastFormX, $iLastFormY)) = 0 then
		$iLastFormX = 0
		$iLastFormY = 0
	endif


	$_gImageForm = GUICreate($_sProgramName & " Image Manager", $iFormWidth, 700,$iLastFormX,$iLastFormY,default,default)

	$x += 10
	$xAdd = 100
	$yAdd = 30
	$_gRadioScript = GUICtrlCreateRadio("��ũ��Ʈ ����", $x, $y, $xAdd, $iDefaultButtonWidth)
	$_gListViewScript = GUICtrlCreateInput($_gListViewCurScript , $x + $xAdd  , $y + 5 , 500, $iDefaultTextWidth, $ES_READONLY)


	$y += $yAdd
	$_gRadioPath = GUICtrlCreateRadio("�̹��� ���", $x, $y, $xAdd, $iDefaultButtonWidth)

	$x += $xAdd
	$xAdd = 500
	$_gListViewPath = GUICtrlCreateCombo($_gListViewCurPath , $x , $y + 5 , $xAdd, $iDefaultButtonWidth, $CBS_DROPDOWNLIST)
	$_sListviewFirstImageFolder = $_gListViewCurPath

	$x += $xAdd + 10
	$xAdd = 90
	$_gListViewPathSelect = GUICtrlCreateButton("��κ���",$x , $y + 5,$xAdd,$iDefaultTextWidth)
	$x += $xAdd + 5
	$_gListViewPathOpen = GUICtrlCreateButton("Ž���⿭��",$x , $y + 5,$xAdd,$iDefaultTextWidth)
	;_GUICtrlButton_Enable($_gListViewPathSelect,False)
	;_GUICtrlButton_Enable($_gListViewPathOpen,False)
	;GUICtrlSetState($_gListViewPath, $GUI_DISABLE)

	$y += 40
	$x = $iFormLeft + 10 + 10

	$xAdd = 100
	$yAdd = 30

	GUICtrlCreateLabel("�˻��� :", $x, $y + 5 , $xAdd, $iDefaultButtonWidth)
	$x += $xAdd
	$xAdd = 200
	$_gFileSearch = GUICtrlCreateInput($sDefaultSearchText, $x  , $y , $xAdd, $iDefaultTextWidth)
	GUICtrlSetState($_gFileSearch, $GUI_FOCUS)


	$x += $xAdd + 10
	$xAdd = 110
	;GUICtrlCreateLabel("���� ���� : ",$x , $y + 20, $xadd, $yadd)
	$_gListViewRun = GUICtrlCreateButton("�˻�(S)",$x , $y -5  ,$xAdd,$iDefaultButtonWidth, $BS_DEFPUSHBUTTON)


	;;GUICtrlCreateButton("�˻�", 10,700,10,10)
	;$xadd = 100
	;$_gListViewSearch = GUICtrlCreateButton("�˻�(&S)", $x, $y, $xadd, $iDefaultButtonWidth)

	$x = 500
	$xAdd = 110

	; ����Ʈ��
	$x = $iFormLeft + 10
	$y += 40

	$aListWidth[$_iImageLstName] = 200
	$aListWidth[$_iImageLstFullPath] = 630
	$aListWidth[$_iImageLstUse] = 100

	for $i= 0 to ubound($aListWidth) -1
		$iWidthSum += $aListWidth[$i]
	next

	$iLVStyle = BitOR($LVS_REPORT, $LVS_SHOWSELALWAYS)
	$iLVExtStyle = BitOR($WS_EX_CLIENTEDGE, $LVS_EX_GRIDLINES, $LVS_EX_CHECKBOXES, $LVS_EX_FULLROWSELECT)
	$yadd = 300
	$_gImageListView = GUICtrlCreateListView("�̸�|���|��뿩��", $x , $y, $iWidthSum, $yadd, $iLVStyle, $iLVExtStyle)
	;$_gImageListView = GUICtrlCreateListView("�̸�|���|��뿩��", $x , $y, $iWidthSum, $yadd, -1, $iExWindowStyle)

	_GUICtrlListView_SetExtendedListViewStyle($_gImageListView, $iExListViewStyle)

	for $i=  0 to ubound($aListWidth) -1
		GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, $i, $aListWidth[$i])
	next

	$y += $yadd + 10
	$x = 250
	$xadd = 110
	$yadd = 20

	$_gListViewNameCopy =GUICtrlCreateButton("�̸�����(&N)", $x, $y, $xadd, $iDefaultButtonWidth)
	$x += $xadd + 10

	$_gListViewMsPaint =GUICtrlCreateButton("����(&P)", $x, $y, $xadd, $iDefaultButtonWidth)
	;GUICtrlSetOnEvent(-1, "_deleteImageList")
	$x += $xadd + 10


	$_gListViewRename = GUICtrlCreateButton("�̸�����(&R)", $x, $y, $xadd, $iDefaultButtonWidth)

	$x += $xadd + 10
	$_gListViewMove = GUICtrlCreateButton("�̵�(&M)", $x, $y, $xadd, $iDefaultButtonWidth)

	$x += $xadd + 10
	$_gListViewDelete = GUICtrlCreateButton("����(&D)", $x, $y, $xadd, $iDefaultButtonWidth)

	;GUICtrlSetOnEvent(-1, "_BtnHit")

	$x += $xadd + 10
	$_gListViewEnd = GUICtrlCreateButton("�ݱ�(&X)", $x, $y, $xadd, $iDefaultButtonWidth)
	;GUICtrlSetOnEvent(-1, "_unloadMngImage")


	GUICtrlCreateGroup("�̹��� ����",$iFormLeft, $iFormTop, $iFormWidth - $iFormLeft * 2  , 430)

	$y += 50

	GUICtrlCreateGroup("���� �̹���",$iFormLeft, $y, $iFormWidth - $iFormLeft * 2 , 190)

	$_gListViewImageFrame = GUICtrlCreateLabel(" ",10000, -1000 ,0, 0, $SS_BLACKFRAME)

	$y += $yadd + 5
	$_gListViewImagePositionY = $y


	$_gListViewImage = GUICtrlCreatePic("", -1,  -1, 1, 1)


	if $sDefaultSearchText <> ""  then
		GUICtrlSetState($_gRadioScript, $GUI_CHECKED)
		GUICtrlSetState($_gRadioPath, $GUI_UNCHECKED)
		getImageListDataFormScript()

	Else
		GUICtrlSetState($_gRadioPath, $GUI_CHECKED)
		GUICtrlSetState($_gRadioScript, $GUI_UNCHECKED)

		_GUICtrlButton_Enable($_gListViewPathSelect,True)
		_GUICtrlButton_Enable($_gListViewPathOpen,True)
		GUICtrlSetState($_gListViewPath, $GUI_ENABLE)
		getImageListDataFormPath ($_gListViewCurPath)

	endif


	;GUISetOnEvent($GUI_EVENT_CLOSE, "_unloadMngImage", $_gImageForm )

	$_sLastListViewPath = GUICtrlRead ($_gListViewPath)

	setListViewLastImageFolderComboListUpdate()

	GUISetState(@SW_SHOW)


endfunc

func _changeImagePath()

	local $sNewPath

	$sNewPath = FileSelectFolder("Choose a folder.", "",1,GUICtrlRead ($_gListViewPath), $_gImageForm)

	if $sNewPath <> "" then
		_writeRecentImageFolder ($sNewPath)
		$_sListviewFirstImageFolder = $sNewPath
		GUICtrlSetData  ($_gListViewPath, $sNewPath)
		setListViewLastImageFolderComboListUpdate()
	endif

endfunc


func _waitListView()

	local $nMsg

	_GUICtrlListView_RegisterSortCallBack($_gImageListView)

	Do
		sleep (1)
		$nMsg = GUIGetMsg()

		Switch $nMsg

			Case $GUI_EVENT_CLOSE, $_gListViewEnd
				_unloadMngImage()
				return ""
			;case $_gListViewSearch
			;	_refreshImageList()
			case $_gListViewDelete
				_deleteImageList()
			case $_gListViewRename
				_renameImageList()
			case $_gListViewMove
				_moveImageList()
			case $_gListViewMsPaint
				_runMsPaint()
			case $_gListViewPathSelect
				_changeImagePath ()
			case $_gListViewRun
				_GUICtrlButton_Enable($_gListViewRun,False)
				sleep(500)
				_refreshImageList ()
				;sleep(100)
				_GUICtrlButton_Enable($_gListViewRun,True)
			case $_gListViewNameCopy
				_copyImageName ()

			case $_gListViewPathOpen
				ShellExecute("explorer.exe" , GUICtrlRead  ($_gListViewPath))


			Case $_gRadioScript
				if (BitAND(GUICtrlRead($_gRadioScript), $GUI_CHECKED) = $GUI_CHECKED) then
					;_GUICtrlButton_Enable($_gListViewPathSelect,False)
					;_GUICtrlButton_Enable($_gListViewPathOpen,False)
					;GUICtrlSetState($_gListViewPath, $GUI_DISABLE)

					;Debug ("��ũ��Ʈ" & $nMsg & $_gRadioScript )
				endif
			Case $_gRadioPath
				if (BitAND(GUICtrlRead($_gRadioPath), $GUI_CHECKED) = $GUI_CHECKED) then
					_GUICtrlButton_Enable($_gListViewPathSelect,True)
					_GUICtrlButton_Enable($_gListViewPathOpen,True)
					_GUICtrlButton_Enable($_gListViewPath,True)
					GUICtrlSetState($_gListViewPath, $GUI_ENABLE)

					;Debug ("���" & $nMsg )
				endif
			case $_gImageListView
				;debug("�Ծ�")
				_GUICtrlListView_SortItems($_gImageListView, GUICtrlGetState($_gImageListView))
				;_GUICtrlListView_SortItems($_gImageListView, 1)
				GUISetState()

		EndSwitch

				;sleep(10)
        _checkSelectImageList ()

    Until False

endfunc

func _runMsPaint()

    Local $hLV = ControlGetHandle($_gImageForm, "", $_gImageListView)
    Local $iCnt
	local $bDelete =False
	local $aItem
	local $sImageFile
	local $bFound = False


	$iCnt = ControlListView($_gImageForm, "", $hLV, "GetItemCount")

	For $n = 0 To $iCnt - 1
		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n)  OR ControlListView($_gImageForm, "", $hLV, "IsSelected", $n)  then
			$sImageFile = getImageListViewFullPathName($n)
			MouseBusy (True)
			ShellExecuteWait ($_runImageEditor,"""" & $sImageFile & """")
			viewSelecteListviewImage ($n)
			MouseBusy (False)

			$bFound = True
			ExitLoop
		endif
	Next

	if $bFound = False then  _ProgramInformation("���õ� �̹����� �����ϴ�.")

endfunc

func _copyImageName ()


    Local $hLV = ControlGetHandle($_gImageForm, "", $_gImageListView)
    Local $iCnt
	local $bDelete =False
	local $aItem
	local $sImageFile
	local $sClip = ""

	$iCnt = ControlListView($_gImageForm, "", $hLV, "GetItemCount")

	For $n = 0 To $iCnt - 1
		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n)  OR ControlListView($_gImageForm, "", $hLV, "IsSelected", $n)  then

			$sClip = $sClip  & getPrefImageName(_GetFileName(getImageListViewFullPathName($n))) & @crlf

		endif
	Next

	if $sClip  <> "" then ClipPut($sClip)


endfunc

func getImageListViewFullPathName($iIndex)

	local $aItem

	$aItem = _GUICtrlListView_GetItem(GUICtrlGetHandle($_gImageListView), $iIndex, $_iImageLstFullPath)

	return $aItem [3]

endfunc

func setImageListView()

	local $i
	local $sSearchText = _trim(GUICtrlRead($_gFileSearch))

	$sSearchText = stringreplace($sSearchText,"*","")
	$sSearchText = stringreplace($sSearchText,"?","")

	_GuICtrlListView_DeleteAllItems(GUICtrlGetHandle($_gImageListView))


	;msg($_gListViewData)
	;msg($_gListViewData [0][$_iImageLstName])


		;_GUICtrlListView_AddArray($_gImageListView, $_gListViewData)
		;debug(ubound($_gListViewData) -1)
		for $i=1 to ubound($_gListViewData) -1

			if stringinstr($_gListViewData [$i][$_iImageLstName], $sSearchText) <> 0  or $sSearchText = "" then
				_AddListViewRow($_gImageListView, $i, _iif($i = ubound($_gListViewData) -1, True, False))
			endif

		next


		$_gLastListImageIndex = -1
		if ubound($_gListViewData) > 1 then
			sleep(10)
			_GUICtrlListView_ClickItem(GUICtrlGetHandle($_gImageListView), 0, "left", False, 1)
			sleep(10)
			_GUICtrlListView_ClickItem(GUICtrlGetHandle($_gImageListView), 0, "left", False, 1)
			_checkSelectImageList()
		endif

endfunc


Func _AddListViewRow($hWnd, $i, $bAutoResize  )

	;debug($_gListViewData[$i][0])
	Local $iIndex = _GUICtrlListView_AddItem($hWnd, $_gListViewData[$i][0], -1, _GUICtrlListView_GetItemCount($hWnd) + 9999)
	if $bAutoResize then _GUICtrlListView_SetColumnWidth($hWnd, 0, $LVSCW_AUTOSIZE_USEHEADER)

	For $x = 1 To ubound($_gListViewData,2) -1
		;debug($_gListViewData[$i][$x])
		_GUICtrlListView_AddSubItem($hWnd, $iIndex, $_gListViewData[$i][$x], $x , -1)
		if $bAutoResize then  _GUICtrlListView_SetColumnWidth($hWnd, $x - 1, $LVSCW_AUTOSIZE)
	Next

EndFunc   ;==>_AddRow


func _unloadMngImage()

	local $aWinPos

	$aWinPos = WinGetPos($_gImageForm)

	_writeSettingReg ("LastImageListX", $aWinPos[0])
	_writeSettingReg ("LastImageListY", $aWinPos[1])


	AutoItSetOption("GUICloseOnESC", 0)

	_GUICtrlListView_UnRegisterSortCallBack($_gImageListView)
	guisetstate(@SW_ENABLE,$_gForm)
	GUIDelete($_gImageForm)
	;debug("�Ծ�")

	if $_bUpdateForderFileList then onClickRefresh()


endfunc

func _renameImageList()

    Local $hLV = ControlGetHandle($_gImageForm, "", $_gImageListView)
    Local $iCnt
	local $bFound = False
	local $aItem
	local $sImageFile
	local $sNewFile
	local $sOldFile
	local $iRenameCoount = 0
	local $n

	$iCnt = ControlListView($_gImageForm, "", $hLV, "GetItemCount")


	For $n = 0 To $iCnt - 1
		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n)  then $iRenameCoount += 1
	next

	if $iRenameCoount > 1 then
		_ProgramInformation("1�� �̻��� �̹����� ���õǾ����ϴ�.")
		return
	endif

	For $n = 0 To $iCnt - 1

		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n) or (ControlListView($_gImageForm, "", $hLV, "IsSelected", $n) and  $iRenameCoount = 0)  then

			$bFound = True
			$sOldFile = _GetFileName(getImageListViewFullPathName($n))
			$sNewFile = _Trim(InputBox($_sProgramName & " �̸� ����", "���� �� �̹����� �Է�",  $sOldFile ,"",500,150,Default,Default,0,$_gImageForm))

			if $sNewFile <> "" and $sOldFile <> $sNewFile then

				if stringlower(Stringright("       " & $sNewFile,4)) <> ".png" then $sNewFile = $sNewFile & ".png"

				$sNewFile = Stringreplace(getImageListViewFullPathName($n),$sOldFile & ".png", $sNewFile)

				FileMove(getImageListViewFullPathName($n), $sNewFile)


				;debug("�Ծ�1:" & $sNewFile)
				$_bUpdateForderFileList = True

				;_refreshImageList ()

				; ���� ���� �ٲܰ�
				;debug("�Ծ�2:" & $sNewFile)
				_GUICtrlListView_SetItem(GUICtrlGetHandle($_gImageListView), getPrefImageName(_GetFileName($sNewFile)), $n, $_iImageLstName)
				_GUICtrlListView_SetItem(GUICtrlGetHandle($_gImageListView), $sNewFile, $n, $_iImageLstFullPath)

			endif

			exitloop

		endif
	Next

	if $bFound = False then
		_ProgramInformation("���õ� �̹����� �����ϴ�.")
	Else
		viewSelecteListviewImage (-1)
		$_gLastListImageIndex = -1
	endif

EndFunc



func _moveImageList()

    Local $hLV = ControlGetHandle($_gImageForm, "", $_gImageListView)
    Local $iCnt
	local $bDelete =False
	local $aItem
	local $sImageFile
	local $sNewPath
	local $iRenameCoount = 0
	local $n


	$iCnt = ControlListView($_gImageForm, "", $hLV, "GetItemCount")


	For $n = 0 To $iCnt - 1
		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n)  then $iRenameCoount += 1
	next


	_writeRecentImageFolder ($sNewPath)

	For $n = 0 To $iCnt - 1

		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n) or  (ControlListView($_gImageForm, "", $hLV, "IsSelected", $n) and  $iRenameCoount = 0) then

			;if $sNewPath = "" then $sNewPath = FileSelectFolder("Choose a folder.", "",1,GUICtrlRead ($_gListViewPath), $_gImageForm)

			$sNewPath = GUICtrlRead ($_gListViewPath)

			if $sNewPath = $_sLastListViewPath then
				_ProgramInformation("�̵� �� ��ΰ� �������� �ʾҽ��ϴ�." & @crlf &  "ȭ�� ����� ""�̹��� ���""�� �̵� �� ������ �����Ͻñ� �ٶ��ϴ�.")
				return
			endif

			if FileExists($sNewPath) = 0 then
				_ProgramInformation("�̵� �� ��ΰ� �������� �ʽ��ϴ�." & @crlf & @crlf & $sNewPath )
				return
			endif


			if $sNewPath = "" then return

			if $bDelete = False then
				if _ProgramQuestion("������ �̹����� �Ʒ� ��η� �̵��Ͻðڽ��ϱ�?" & @crlf & @crlf &  $sNewPath) = False then	return
			endif

			$sImageFile = getImageListViewFullPathName($n)
			_GUICtrlListView_DeleteItem($hLV, $n)
			$bDelete = True

			;msg($sImageFile)

			;debug($sImageFile, $sNewPath & "\" & _GetFilename($sImageFile)  & ".png")
			FileMove($sImageFile, $sNewPath & "\" & _GetFilename($sImageFile)  & ".png")

			$n=$n-1
		endif
	Next

	if $bDelete = False then
		_ProgramInformation("���õ� �̹����� �����ϴ�.")
	Else
		viewSelecteListviewImage (-1)
		$_gLastListImageIndex = -1
		$_bUpdateForderFileList = True
	endif

EndFunc

func _deleteImageList()

    Local $hLV = ControlGetHandle($_gImageForm, "", $_gImageListView)
    Local $iCnt
	local $bDelete =False
	local $aItem
	local $sImageFile
	local $iRenameCoount = 0
	local $n

	$iCnt = ControlListView($_gImageForm, "", $hLV, "GetItemCount")



	For $n = 0 To $iCnt - 1
		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n)  then $iRenameCoount += 1
	next


	For $n = 0 To $iCnt - 1

		;if _GUICtrlListView_GetItemChecked ($_gImageListView, $n)  OR ControlListView($_gImageForm, "", $hLV, "IsSelected", $n)  then
		if _GUICtrlListView_GetItemChecked ($_gImageListView, $n) or  (ControlListView($_gImageForm, "", $hLV, "IsSelected", $n) and  $iRenameCoount = 0)  then
			if $bDelete = False then
				if _ProgramQuestion("���õ� �̹����� �����Ͻðڽ��ϱ�?") = False then return ""
			endif

			$sImageFile = getImageListViewFullPathName($n)
			_GUICtrlListView_DeleteItem($hLV, $n)
			$bDelete = True

			;debug($sImageFile)
			FileDelete($sImageFile)

			$n=$n-1
		endif
	Next

	if $bDelete = False then
		_ProgramInformation("���õ� �̹����� �����ϴ�.")
	Else
		viewSelecteListviewImage (-1)
		$_gLastListImageIndex = -1
		$_bUpdateForderFileList = True
	endif

EndFunc

Func _refreshImageList()

	MouseBusy (True)

	_UpdateFolderFileInfo(False)

 	if GUICtrlRead($_gRadioScript) = $GUI_CHECKED then
 		getImageListDataFormScript()
 	Else
 		getImageListDataFormPath(GUICtrlRead ($_gListViewPath))
 		;msg($_gListViewData)
 	endif

	$_sLastListViewPath = GUICtrlRead ($_gListViewPath)

 	setImageListView()

	MouseBusy (False)

EndFunc

func viewSelecteListviewImage($iIndex)

	local $x = 20
	local $y = $_gListViewImagePositionY
	local $iWidth
	local $iHeight
	local $iTempBMP = @TempDir & "\listview.bmp"
	local $aImageInfo
	local $sImageFile
	local $aItem

	;debug($_gListViewImagePositionY)

	if $iIndex <> -1 then

		$sImageFile = getImageListViewFullPathName($iIndex)


		GUICtrlDelete($_gListViewImage)
		_PNG2BMP ($sImageFile, $iTempBMP)

		$aImageInfo = _ImageGetInfo($iTempBMP)
		$iWidth = _ImageGetParam($aImageInfo, "Width")
		$iHeight = _ImageGetParam($aImageInfo, "Height")

		$_gListViewImage = GUICtrlCreatePic($iTempBMP, $x,  $y, $iWidth, $iHeight)
		GUICtrlSetPos ( $_gListViewImageFrame , $x-1,$y-1, $iWidth+2,$iHeight+2)

	Else
		GUICtrlSetPos($_gListViewImage ,10000,10000,0,0)
		GUICtrlSetPos ( $_gListViewImageFrame,  10000,10000,0,0)
		GUISetState()
	endif

	GUISetState()

	;FileDelete($iTempBMP)

endfunc


func getImageListDataFormPath($sPath)

	local $i
	local $aSearchList[1]
	redim $_gListViewData[1][$_iImageLstEnd]


	$aSearchList = _GetFileNameFromDir($sPath,"*.png", 1)
	;debug($sPath)
	;msg($aSearchList)
	if IsArray($aSearchList) then
		redim $_gListViewData[ubound($aSearchList) ][$_iImageLstEnd]

		for $i= 1 to ubound($aSearchList) -1

			$_gListViewData[$i][$_iImageLstName] = getPrefImageName(_GetFileName($aSearchList[$i]))
			$_gListViewData[$i][$_iImageLstFullPath] = $aSearchList[$i]
			$_gListViewData[$i][$_iImageLstUse] = ""

		next
	endif

EndFunc


func getPrefImageName($sStr)

	local $iLen = StringLen($sStr)

	if StringInStr($sStr,"_") > 0 Then $iLen = StringInStr($sStr,"_") -1

	return stringleft($sStr,$iLen)

endfunc
