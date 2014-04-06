#include-once


Global enum $_sLogText_Start = "���� : "
Global enum $_sLogText_Testing = "���� : "
Global enum $_sLogText_Error = "���� : "
Global enum $_sLogText_Info = "���� : "
Global enum $_sLogText_PreError = "�غ� : "
Global enum $_sLogText_End = "���� : "
Global enum $_sLogText_Result = "��� : "

Global enum $_sLogText_BrowserCapture = "������ ȭ�� : "
Global enum $_sLogText_BrowserAVI = "������ ȭ�� : "

Global Const $_sTransparentKey = "_����"
Global Const $_sUntitledName = "�������"

Global Const $_iColorTarget = 0xff0000
Global Const $_iColorCommand  = 0x0000AA
Global Const $_iColorTargetHtml = 0x0000ff
Global Const $_iColorCommandHtml = 0xaa0000
Global Const $_iColorComment = 0x339900
Global Const $_iColorError = 0x00ffff


Global $_iScriptRecursive
Global $_iDebugTimeInit
Global $_bLastcheckWaitCommand
Global $_bScriptRunPaused = False
Global $_sNewLoopVar = ""
Global $_iNewLoopValue = 0

Global $_sHTMLPreCahr = chr(2)

Global $_aLastUseMousePos[4]


#include <Process.au3>
#Include <ScreenCapture.au3>
#include <Math.au3>

#include "UIACommon.au3"
#include "UIAFormMain.au3"
#include "UIAAnalysis.au3"
#include "GUITARAU3VAR.au3"
#include "GUITARWEBDRIVER.au3"


#include ".\_include_nhn\_ImageGetInfo.au3"
#include ".\_include_nhn\_ImageSearch.au3"
#include ".\_include_nhn\_monitor.au3"


func getScriptLevelName($sScriptName, $_iScriptRecursive, $bIsEnd)

	local $sLevelName

	if $_iScriptRecursive > 1 then
		;$sLevelName = "��" & _StringRepeat("��",$_iScriptRecursive-2) & "��"

		$sLevelName = _StringRepeat("��",$_iScriptRecursive-2)

		$sLevelName = $sLevelName  & _iif( $bIsEnd, "��","��")
		$sLevelName = $sLevelName  & "�� "

	endif
	$sLevelName = $sLevelName & _GetFileName($sScriptName)

	return $sLevelName

endfunc


Func checkScriptEndLine(byref $aScript, $index, $iRunEnd)

	local $bEnd = True
	local $iEndCount

	$iEndCount = _iif ($iRunEnd = -1 ,ubound($aScript) -1 , $iRunEnd)

	;debug($index + 1, $iEndCount, ubound($aScript))

	for $i = $index + 1 to $iEndCount

		if $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckOK then
			$bEnd = False

			ExitLoop
		endif

	next

	return $bEnd

EndFunc

func runScript($sScriptName, $aScript, $iRunStart, $iRunEnd, byref $aRunCountInfo)
; ��ũ��Ʈ�� ����

	local $i
	local $j
	local $bResult = True
	local $aCommand
	local $aCommandPos
	local $aScriptRAW
	local $aPrimeCommand
	local $aTarget
	local $aTargetPos
	local $sErrorMsg
	local $aCurrentMousePos
	local $sScriptNameOnly
	local $sLogHeader
	local $iTcTotal
	local $bContineTest
	local $sNewTCID
	local $sNewTCHide
	local $sNewTCEmaillist
	local $sCommentMsg
	local $bExitLoop
	local $sTestDateTime
	local $sCurrentTarget
	local $sLastPrimeCommand
	local $sLastTestID = ""
	local $iLastAddPostion
	local $sNewTCComment
	local $bHeaderChange
	local $bSkipLine
	local $bSkipCommnad
	local $iBlockLevel = 1
	local $bLogWriteSkip
	local $aBlockSkip[100]
	local $aBlockLoop[100][6]
	local enum $iLoop_BlockLevel = 1 , $iLoop_BlockVar, $iLoop_BlockValue, $iLoop_BlockValueAdd, $iLoop_BlockStartLine
	local $bLoopStart = False
	local $bLoopRun = False
	local $iLastCommandStartTime
	local $bIncludeCommandExist
	local $iScriptEndLine
	local $bLastSkipLine
	local $sTCID

	$_runCommadLintTimeInit = _TimerInit()
	$_runCommadLintTimeStart = _Nowcalc()

	$_runScriptFileName = $sScriptName

	$aCurrentMousePos = MouseGetPos()

	if $_iScriptRecursive = 1 then
		writeRunLog($_sLogText_Start & $sScriptName)
	endif

	$_runRecursiveID [$_iScriptRecursive] = ""
	$_runRecursiveRunCount [$_iScriptRecursive] = 0
	$_runEmailAddList = ""
	$_runScriptNotRunID[$_iScriptRecursive] = ""

	$_runScriptRun[$_iScriptRecursive] = 0
	$_runRecursiveErrorCount[$_iScriptRecursive] = 0
	$_runRecursiveHide [$_iScriptRecursive] = "OFF"

	$iTcTotal = 0

	for $i = 1 to ubound ($aScript) -1
		if $iRunStart = 0 or ($i  >= $iRunStart and  $i  <= $iRunEnd - 1) then
			if $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckOK then $iTcTotal += 1

			if $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckComment then
				$sTCID = getTCID($aScript[$i][$_iScriptRaw])
				$_aRunReportInfo[$_iResultAll] += countRunReportInfoID($sTCID)
				if $sTCID <> "" then $_runScriptNotRunID[$_iScriptRecursive] &= $sTCID & @crlf
			endif

		endif
	next

	$aRunCountInfo[1] = $iTcTotal
	$aRunCountInfo[2] = 0
	$aRunCountInfo[3] = 0

	$_runScriptTotal[$_iScriptRecursive] = $iTcTotal


	$_iDebugTimeInit = _TimerInit()

	CloseUnknowWindow ($_runUnknowWindowList)

	$bIncludeCommandExist = False

	if $_iScriptRecursive = 1 and IsHWnd($_hBrowser) then hBrowswerActive ()

	; ���� ���� (Tray ��¿�)
	$iScriptEndLine = $iRunEnd
	if $iScriptEndLine = 0 then $iScriptEndLine = ubound ($aScript) -1

	for $i = 1 to ubound ($aScript) -1

		$_runCommadLintTimeInit = _TimerInit()
		$_runCommadLintTimeStart = _Nowcalc()


		$bSkipLine = False
		$bLogWriteSkip = False
		$bLoopStart = False
		$_runFullScreenWork = False
		$_runAreaWork[0] = False

		if $iRunStart = 0 or ($i  >= $iRunStart and  $i  <= $iRunEnd ) then

			$sScriptNameOnly = getScriptLevelName($sScriptName, $_iScriptRecursive, checkScriptEndLine($aScript, $i, $iRunEnd - 1))

			if $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckOK then

				; ������ �׸� ����
				if $sLastTestID <> $_runRecursiveID [$_iScriptRecursive] and $_runRecursiveID [$_iScriptRecursive] <> ""  then
					$sLastTestID = $_runRecursiveID [$_iScriptRecursive]
					$_aRunReportInfo[$_iResultSkip] -= countRunReportInfoID($_runRecursiveID [$_iScriptRecursive])
					$iLastAddPostion = StringInstr($_aRunReportInfo[$_sResultSkipList], @crlf,0,-1,stringlen($_aRunReportInfo[$_sResultSkipList]))

					if $iLastAddPostion > 0 then
						$_aRunReportInfo[$_sResultSkipList] = StringLeft($_aRunReportInfo[$_sResultSkipList], $iLastAddPostion -1)
					Else
						$_aRunReportInfo[$_sResultSkipList] = ""
					endif

				endif

				if $bLoopRun = True then $aRunCountInfo[1] += 1

				$_runScriptRun[$_iScriptRecursive] += 1
				$aRunCountInfo[2] += 1

				setProgressBar()

				$sTestDateTime = _NowCalc()

				$_runRecursiveRunCount [$_iScriptRecursive] += 1

				$sLogHeader = "[" & $sScriptNameOnly & "/" & $_runRecursiveID [$_iScriptRecursive] & "/" & $aScript[$i][$_iScriptLine] & "] - "
				;$sLogHeader = "[" & $sScriptNameOnly & "/" & $_runRecursiveID [$_iScriptRecursive] & "/" & $_runRecursiveRunCount [$_iScriptRecursive] & " (" & $aScript[$i][$_iScriptLine] & ")" & "] - "

				$sCommentMsg = ""
				$aCommand = StringSplit($aScript[$i][$_iScriptCommand],$_sCommandSplitChar)
				$aCommandPos = StringSplit($aScript[$i][$_iScriptCommandStartPos],$_sCommandSplitChar)
				$aTarget = StringSplit($aScript[$i][$_iScriptTarget],$_sCommandSplitChar)
				$aTargetPos = StringSplit($aScript[$i][$_iScriptTargetStartPos],$_sCommandSplitChar)
				$aPrimeCommand = StringSplit($aScript[$i][$_iScriptPrimeCommand],$_sCommandSplitChar)
				$aScriptRAW = $aScript[$i][$_iScriptRaw]

				$iLastCommandStartTime = _Nowcalc()

				if $_runCmdRunning = False and $_runTrayToolTip = True then
					;TrayTip($_sProgramName & " [" & StringFormat("[%4d]", $aScript[$i][$_iScriptLine]) & "/" & StringFormat("[%4d]", $iRunEnd) & "]" , $aScriptRAW,30,1)
					TrayTip($_sProgramName & " [" & $aScript[$i][$_iScriptLine] & "/" & $iScriptEndLine & "]" , $aScriptRAW,30,1)
				endif

				;msg($aTarget)
				;_ArrayDisplay($aTarget)


				for $j=1 to ubound($aCommand) -1

					; �� ����
					if $aPrimeCommand[$j] = $_sCommandBlockStart then

						$iBlockLevel += 1

						if $bSkipLine or $aBlockSkip[$iBlockLevel-1] then
							$aBlockSkip[$iBlockLevel] = True
						Else
							$aBlockSkip[$iBlockLevel] = False
							$bLogWriteSkip = False

							if $_sNewLoopVar <> "" then

								$aBlockLoop[$iBlockLevel][$iLoop_BlockLevel] = True
								$aBlockLoop[$iBlockLevel][$iLoop_BlockVar] = $_sNewLoopVar
								$aBlockLoop[$iBlockLevel][$iLoop_BlockValue] = $_iNewLoopValue
								$aBlockLoop[$iBlockLevel][$iLoop_BlockStartLine] = $i + 1
								$aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd] = 0

								$_sNewLoopVar = ""
								$_iNewLoopValue = ""

								;msg($aBlockLoop)
							endif

						endif


					endif

					; �� ����
					if $aPrimeCommand[$j] = $_sCommandBlockend  then

						if $aBlockLoop[$iBlockLevel][$iLoop_BlockLevel] = True then

							getRunVar($aBlockLoop[$iBlockLevel][$iLoop_BlockVar], $aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd])

							;debug("������ " &  $aBlockLoop[$iBlockLevel][$iLoop_BlockValue] & "," &  $aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd] )

							; �������� ���� �Ѿ�� ��� ���� ��� ����
							if $aBlockLoop[$iBlockLevel][$iLoop_BlockValue] <= $aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd]  then
								$aBlockLoop[$iBlockLevel][$iLoop_BlockLevel] = False
								$aBlockLoop[$iBlockLevel][$iLoop_BlockVar] = ""
								$aBlockLoop[$iBlockLevel][$iLoop_BlockValue] = 0
								$aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd] = 0
								$aBlockLoop[$iBlockLevel][$iLoop_BlockStartLine] = 0
								$bLoopStart = False
								$bLoopRun = False

							else
								; ���� ���� ��� ������ �κк��� �������.
								$aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd] += 1

								; ������  ������ ���뺯���� ����
								addSetVar ($aBlockLoop[$iBlockLevel][$iLoop_BlockVar] & "=" & $aBlockLoop[$iBlockLevel][$iLoop_BlockValueAdd], $_aRunVar)
								$bLoopStart = True

								;debug("������ " & $aBlockLoop[$iBlockLevel][$iLoop_BlockVar] & ":" & $aBlockLoop[$iBlockLevel][$iLoop_BlockValue] )

								; �ڿ��� �����°����� �̸� �����Ͽ� ���� level�� �����ϵ��� ��
								$iBlockLevel += 1
							endif
						endif

						$iBlockLevel -= 1
					endif

					;debug($iBlockLevel)

					if $aBlockSkip[$iBlockLevel] = true or $bSkipLine = True then
						; ó������ Skip�� ��� �α� ���� ��󿡼� �����Ұ�
						if $j=1 then
							$bLogWriteSkip = True
							; ��ü/���� ��Ͽ��� �ϳ���  ����
							;$aRunCountInfo[2] -= 1
							;$aRunCountInfo[1] -= 1
						endif

						writeDebugTimeLog("SKIP --------------------------------:" & "command:" & $aCommand[$j] & ", target:" & $aTarget [$j] )
						ContinueLoop
					endif


					$_iDebugTimeInit = _TimerInit()

					writeDebugTimeLog("���� -------------------------------------------------------------------------------------")

					writeDebugTimeLog ("command:" & $aCommand[$j] & ", target:" & $aTarget [$j])

					if $_runContinueTest and  $_runErrorResume = "LINE" then
						$bContineTest = True
					else
						$bContineTest = False
					endif

					; Ÿ���� ���� ��ɸ� �ִ°��

					if ubound($aTarget) -1 >= $j then
						$sCurrentTarget = $aTarget [$j]
					Else
						$sCurrentTarget = ""
					endif

					if $aPrimeCommand[$j] = $_sCommandInclude then



						if stringinstr($sLogHeader, "��") > 0  then
							$sLogHeader = stringreplace($sLogHeader, "��","��")
							$sScriptNameOnly = stringreplace($sScriptNameOnly, "��","��")
							$bHeaderChange = True
						else
							$bHeaderChange = False
						endif

						$bIncludeCommandExist = True
						;writeRunLog ($_sLogText_Testing & $sLogHeader & $aScriptRAW & " (����)" & writePassFail(True), $i)

						writeDebugTimeLog("����Ʈ ���� ����")
						;makeReportLogFormat($aCommand, $aCommandPos, $aTarget, $aTargetPos, $sScriptNameOnly, $_runRecursiveID [$_iScriptRecursive], $aScript[$i][$_iScriptLine] , getReportDetailTime(),  "P", $aScriptRAW & " (����) ", $_runErrorMsg, $sCommentMsg)
						writeDebugTimeLog("����Ʈ ���� ���� ����")

						if $bHeaderChange then
							$sScriptNameOnly = stringreplace($sScriptNameOnly, "��", "��")
							$sLogHeader = stringreplace($sLogHeader, "��", "��")
						endif

					endif

					$_runErrorMsg= ""

					; ��ũ��Ʈ ���� ������ ���� �ְ�, ���� �����ɾ ������ �ʿ��� ��� ����
					; ������ ��ũ��Ʈ ������ �߻��Ѱ�� �ٷ� �������� ��ũ��Ʈ ���� �˻縦 ������  (������ ���ӽô� �����Ұ�)
					if $_runScriptErrorCheck = True and checkScriptErrorCheckCommand ($sLastPrimeCommand) and $_runLastScriptErrorCheck <> True  then
						if $_runBrowser = $_sBrowserIE or $_runBrowser = $_sBrowserFF or  $_runBrowser = $_sBrowserCR  then
							if CheckScriptError($_runBrowser) then captureCurrentBorwser($_runErrorMsg, False)
						endif
					endif


					; ������ ���� ���� �ű� ��ɾ� ����
					if $_runErrorMsg= "" then $bResult = runCommand($aCommand[$j], $aPrimeCommand[$j], $sCurrentTarget , $sCommentMsg)

					;if $bResult = False then debug("���� 1" & $aScriptRAW )


					;debug("x1 = " & $bResult)

					if $aPrimeCommand[$j] = $_sCommandInclude then

						if $_runRecursiveErrorCount[$_iScriptRecursive + 1] > 0 then $bResult = False

						;writeRunLog ($_sLogText_Testing & $sLogHeader & $aScriptRAW & $sIncludeEndString, $i)
						writeDebugTimeLog("����Ʈ ���� ����")
						writeDebugTimeLog("����Ʈ ���� ���� ����")

						if $_runContinueTest = True then
							if checkScriptStopping() then
								$bContineTest = False
							Else
								$bContineTest = True
							endif
						endif

					endif

					;debug("x2 = " & $bResult)
					if $_runErrorMsg <> "" then
						;debug("���� 2" & $aScriptRAW )
						$bResult = False
						exitloop
					endif

					;debug("x22 = " & $bResult)

					; ���ǹ��� ����� Ʋ�� ���
					if ($aPrimeCommand[$j] == $_sCommandIf  or $aPrimeCommand[$j] == $_sCommandIfNot or $aPrimeCommand[$j] == $_sCommandTextIf  or $aPrimeCommand[$j] == $_sCommandTextIfNot  or  $aPrimeCommand[$j] == $_sCommandValueIf  or $aPrimeCommand[$j] == $_sCommandValueIfNot  ) then
						if $bResult == False then
						;if ($aPrimeCommand[$j] == $_sCommandIf and $bResult == False) or ($aPrimeCommand[$j] == $_sCommandIfNot and $bResult == True) then
							;debug ("���ǹ� ���� : " & $aPrimeCommand[$j] , $bResult)
							$bResult = True
							$bSkipLine = True
						endif
						$bResult = True
					endif

					;if $bResult = False then debug("���� 3" & $aScriptRAW )

					if $bResult = False or checkScriptStopping() then

						$bResult = False

						exitloop
					endif

					$sLastPrimeCommand = $aPrimeCommand[$j]

					writeDebugTimeLog("���� ------------------------------------------------------------------------------------")

				next


				writeDebugTimeLog("html �α� �����")

				if $bResult = False then

					; ���� ���������� ����Ͽ� ���߿� �Ϸ��� ��ũ�� �̵��ÿ� Ȱ��
					$_runFirstErrorLine = $i


					if $_aLastUseMousePos[1] <> "" then
						_StringAddNewLine($_runErrorMsg  , " (�ֱ� ��� �̹��� ��ǥ : " & $_aLastUseMousePos[1] & "," & $_aLastUseMousePos[2] & ")")
						;$_runErrorMsg = $_runErrorMsg  & " (�ֱ� ��� �̹��� ��ǥ : " & $_aLastUseMousePos[1] & "," & $_aLastUseMousePos[2] & ")"
					endif
				endif


				; �α׸� ���⵵�� �ϰų�, �����̸鼭 ������ ��� ���
				if (($bResult = False and $_runRecursiveHide [$_iScriptRecursive] = "ON") or ($_runRecursiveHide [$_iScriptRecursive] = "OFF") and $bLogWriteSkip = False) then

					;debug($bLogWriteSkip, $aScriptRAW )
					makeReportLogFormat($aCommand, $aCommandPos, $aTarget, $aTargetPos, $sScriptNameOnly, $_runRecursiveID [$_iScriptRecursive],  $aScript[$i][$_iScriptLine]  , getReportDetailTime(),  _iif($bResult,"P","F"), $aScriptRAW , $_runErrorMsg, $sCommentMsg)
					writeRunLog($_sLogText_Testing & $aScriptRAW & writePassFail($bResult), $i)

				endif

				writeDebugTimeLog("html �α� �����")


				if (($bResult = False and $_runRecursiveHide [$_iScriptRecursive] = "ON") or ($_runRecursiveHide [$_iScriptRecursive] = "OFF") and $bLogWriteSkip = False) then

					if $sCommentMsg <> "" then writeRunLog ($_sLogText_Info & $sLogHeader & $sCommentMsg, $i, False)
					if $_runErrorMsg <> "" then writeRunLog($_sLogText_Error & $sLogHeader & $_runErrorMsg, $i, False)

				endif

				$_runErrorMsg  = ""


				if $bResult = False then
					if	$_runLastFailTCID <> $_runRecursiveID [$_iScriptRecursive] and $_runRecursiveID [$_iScriptRecursive] <> "" then
						$_runLastFailTCID = $_runRecursiveID [$_iScriptRecursive]
						$_aRunReportInfo[$_iResultFail] += countRunReportInfoID($_runRecursiveID [$_iScriptRecursive])
					endif
				endif

				; ���� ����
				if ($bResult = False and $bContineTest = False) or checkScriptStopping() then
					$bResult = False
					exitloop
				endif

			Elseif  $aScript[$i][$_iScriptCheck] = $_iScriptAllCheckComment then

				$bResult = True

				; Skip ó���� ��� ��ü������ ���� ó���Ұ�
				if $bLogWriteSkip = False  and $aBlockSkip[$iBlockLevel] = False then

					; Ŀ��Ʈ ������� ���
					; ID���� �м��Ͽ� ����� ��
					$sNewTCID = getTCID($aScript[$i][$_iScriptRaw])
					;debug ($sNewTCID)
					if $sNewTCID <> "" then
						$_runScriptNotRunID[$_iScriptRecursive] = stringreplace($_runScriptNotRunID[$_iScriptRecursive],  $sNewTCID & @crlf, "")
						$_runRecursiveID [$_iScriptRecursive] = $sNewTCID
						$_aRunReportInfo[$_iResultRun] += countRunReportInfoID($_runRecursiveID [$_iScriptRecursive])
						$_aRunReportInfo[$_iResultSkip] += countRunReportInfoID($_runRecursiveID [$_iScriptRecursive])
						;$_aRunReportInfo[$_sResultSkipList] = countRunReportInfoID($_runRecursiveID [$_iScriptRecursive])
						;debug(_GetFileName($sScriptName) & " (" & $_runRecursiveID [$_iScriptRecursive] & ")")
						;debug($_aRunReportInfo[$_sResultSkipList])
						_StringAddNewLine($_aRunReportInfo[$_sResultSkipList], _GetFileName($sScriptName) & " : " & $_runRecursiveID [$_iScriptRecursive] )
						;debug($_aRunReportInfo[$_sResultSkipList])
					endif

					$sNewTCComment = getTCComment($aScript[$i][$_iScriptRaw])

					if $sNewTCComment <> "" then
						if (($bResult = False and $_runRecursiveHide [$_iScriptRecursive] = "ON") or ($_runRecursiveHide [$_iScriptRecursive] = "OFF") and $bLogWriteSkip = False) then
							makeReportLogFormat("", "", "", "", $sScriptNameOnly, $_runRecursiveID [$_iScriptRecursive], $aScript[$i][$_iScriptLine] , getReportDetailTime(),  "P", "","",   $sNewTCComment)
						ENDIF

					endif

					$sNewTCHide = getTCHide($aScript[$i][$_iScriptRaw])
					if $sNewTCHide <> "" then $_runRecursiveHide [$_iScriptRecursive] = $sNewTCHide

					$sNewTCEmaillist = getTCEmailList($aScript[$i][$_iScriptRaw])
					if $sNewTCEmaillist <> "" then
						if $_runEmailAddList  <> "" then $_runEmailAddList  = $_runEmailAddList  & ";"
						$_runEmailAddList = $_runEmailAddList & $sNewTCEmaillist
					endif

				endif

			else
				$bResult = True
				;debug("���� ��ɾ� : " & $aScript[$i][$_iScriptRaw])

			endif

			; �׽�Ʈ ���� �� �׽�Ʈ ��������� �ȵ� ��� ���� ����
			if $bResult = False then

				;debug("���� 5" & $aScriptRAW & " " & $bResult)
				$_runRecursiveErrorCount[$_iScriptRecursive] += 1
				$aRunCountInfo[3] += 1
				$_runErrorCount = $_runErrorCount + 1
				setTestStatusBox ("�׽�Ʈ��", True)

			endif
		endif

		if $bLoopStart then
			$bLoopRun = True
			$i = $aBlockLoop[$iBlockLevel][$iLoop_BlockStartLine] -1
		endif

		$_runLastCommandStartTime = $iLastCommandStartTime

		$bLastSkipLine = $bSkipLine

	next

	;if $bResult = False then _viewLastUseedImage()

	if $_iScriptRecursive = 1 then

		writeRunLog($_sLogText_End & $sScriptName)
		writeRunLog($_sLogText_Result & _iif($bResult,"����","����"))

	endif

	if $bResult = False and $aRunCountInfo[3] = 0 then $aRunCountInfo[3] = 1


	MouseMove($aCurrentMousePos[0], $aCurrentMousePos[1],0)


	$_aRunReportInfo[$_sResultNorRunList] &= $_runScriptNotRunID[$_iScriptRecursive]



	return $bResult

endfunc


func runCommand($sScriptCommandText, $sScriptCommand, $sScriptTarget, byref $sCommentMsg)
; ��ɾ�(����)�� ����

	local $bResult = False
	local $sNewVarName
	local $sNewVarValue
	local $iCommandTimeInit
	local $bVarAddInfo
	local $iCommandSleep

	local $sSetValueNewName
	local $sSetValueNewValue
	local $sInputType

	writeDebugTimeLog("runCommand ��� ����")

	if checkScriptStopping() then Return False

	_setLastImageArrayInit()

	;debug($sScriptCommandText)

	; ���� ���� ���� ������ ������
	if getVarType($sScriptTarget) and ($sScriptCommand <>  $_sCommandTagCountGet and $sScriptCommand <>  $_sCommandTagAttribGet and $sScriptCommand <> $_sCommandSet and $sScriptCommand <> $_sCommandVariableSet and $sScriptCommand <> $_sCommandValueIf and $sScriptCommand <> $_sCommandValueIfNot and $sScriptCommand <> $_sCommandExcute and $sScriptCommand <> $_sCommandLoop  and $sScriptCommand <>  $_sCommandPartSet and $sScriptCommand <>  $_sCommandSingleQuotationChange and $sScriptCommand <> $_sCommandAU3VarRead and $sScriptCommand <> $_sCommandJSRun ) then

		if ConvertVarFull($sScriptTarget, $sNewVarValue, $bVarAddInfo, ",", True) = False Then
			return False
		Else
			_StringAddNewLine( $sCommentMsg,$bVarAddInfo)
			$sScriptTarget = $sNewVarValue
		endif

	endif


	; �������� click, �̰�, ���� command�� Ŭ���� ��� 2�� ������ ��.
	;if checkWaitCommand ($sScriptCommand) and $_bLastcheckWaitCommand = True then
		;writeDebugTimeLog("runCommand ���Ӹ����� ���� : " & $_runCommandSleep * 2)
		;RunSleep($_runCommandSleep * 2)
	;endif


	; ������̹� ��尡 �ƴ� ��쿡�� â ������ Ȯ��
	if $_runWebdriver = False then
		writeDebugTimeLog("runCommand ������ Active")
		;debug("��ɽ���:" & _NowCalc())
		; ������ ������ �ʿ� ���� ���� ���� !!!!!!!!!!!!!!!!! select
		Switch $sScriptCommand

			case $_sCommandClick,$_sCommandAssert, $_sCommandInput, $_sCommandBrowserEnd, $_sCommandIf, $_sCommandIfNot,  $_sCommandTextIf, $_sCommandTextIfNot, $_sCommandNavigate, $_sCommandTextAsert, $_sCommandMouseMove,  $_sCommandMouseDrag, $_sCommandMouseDrop, $_sCommandRightClick, $_sCommandCapture, $_sCommandMouseHide, $_sCommandSwipe, $_sCommandGoHome, $_sCommandTagAttribGet, $_sCommandTagAttribSet, $_sCommandTargetCapture, $_sCommandTagCountGet, $_sCommandJSRun , $_sCommandJSInsert

				; ��ü�۾������ ��� ����ó������ ����
				if IsHWnd($_hBrowser) = 0  and $_runFullScreenWork = False  then

					$_runErrorMsg = "��� ���� ����. �� �������� �������� �ʾҽ��ϴ�. "
					captureCurrentBorwser($_runErrorMsg, True)
					return False
				Else
					; �ܺ� API�� �޼��� â ������ ������ â�� �����ϴ°��� ���ܷ� ��.

					if $sScriptCommand <> $_sCommandTextAsert and $sScriptCommand <> $_sCommandKeySend  then

						; ��ũ��Ʈ ����â�� ���� ��� �������� ��.
						if $_runScriptErrorCheck = True and $_runBrowser = $_sBrowserIE then CheckScriptError($_runBrowser)



						if hBrowswerActive() = 0  and  ($_runBrowser <> $_sBrowserCR) then
							$_runErrorMsg = "��� ���� �� �� �������� Ȱ��ȭ �� �� �����ϴ� : " & $sScriptCommandText & ", " & $sScriptTarget
							captureCurrentBorwser($_runErrorMsg, True)
							return False
						endif

					endif

				endif
			EndSwitch


		;debug("�������:" & _NowCalc())

		writeDebugTimeLog("runCommand ������ Active �Ϸ�")
	endif

	;if TimerDiff($iCommandTimeInit) < $_runCommandSleep then


	; �׽�Ʈ ����� �������� �ƴ� ��� ���콺�� ���⵵�� ��.
	if checkTargetisBrowser($_runBrowser) = False and checkMouseHideCommand($sScriptCommand) then moveMouseTop(0)

	$iCommandTimeInit = _TimerInit()

	writeDebugTimeLog("runCommand ������ �ݱ�")


	;debug("��ɼ��� : " & $sScriptCommand)

	writeDebugTimeLog("runCommand ��� ���� ��")

	Switch  $sScriptCommand

		case $_sCommandClick
			$bResult = commandClick($sScriptTarget, "left")
			;if $bResult then RunSleep($_runPageSleep / 2)

		case $_sCommandBrowserRun
			$bResult = commandBrowserRun($sScriptTarget)

		case $_sCommandBrowserEnd
			$bResult = commandBrowserEnd()

		case $_sCommandNavigate
			; Ű�� �Է��� ������ �Ͽ� URL �Է�
			SetKeyDelay(0)

			$bResult = commandNavigate($sScriptTarget, True)

			if $bResult = True and $_runScriptErrorCheck = True then
				;msg("�Ծ� : " & $sScriptTarget & " " & $_runLastScriptErrorCheck)
				if CheckScriptError($_runBrowser) = True then
					$_runErrorMsg = "������ �ڹٽ�ũ��Ʈ �����߻�"
					captureCurrentBorwser($_runErrorMsg, False)
					$bResult = False
				endif
			endif

			_StringAddNewLine($sCommentMsg, "URL : " & $sScriptTarget)

			SetKeyDelay()
			;if $bResult then RunSleep($_runPageSleep * 2)

		case $_sCommandInput

			if $_runInputType = "UNICODE" or $_runInputType = "ANSI"  Then
				$sInputType = $_runInputType
			else
				$sInputType = ""
			endif

			if $sInputType = "" then $sInputType = _iif(checkTargetisBrowser($_runBrowser),"UNICODE", "ANSI")

			$bResult = commandKeySend($sScriptTarget,$sInputType)

			writeDebugTimeLog("$_sCommandInput �Ϸ�")
			runsleep($_runCommandSleep )

		case $_sCommandKeySend
			$bResult = commandKeySend($sScriptTarget,"ANSI")
			writeDebugTimeLog("$_sCommandKeySend �Ϸ�")
			runsleep($_runCommandSleep )

		case $_sCommandAssert
			$bResult = commandAssert($sScriptTarget, $_runWaitTimeOut, True, False, True )

		case $_sCommandIf
			runsleep($_runCommandSleep * 2)
			$bResult = commandAssert($sScriptTarget,2000, False, True, True)
			_StringAddNewLine($sCommentMsg, "��� ã�� : " & $sScriptTarget)
			_StringAddNewLine($sCommentMsg, "���� : " & _iif($bResult,"����","�Ҹ���"))

		case $_sCommandIfNot
			runsleep($_runCommandSleep * 2)
			$bResult = not(commandAssert($sScriptTarget,2000, False, True, False))
			_StringAddNewLine($sCommentMsg, "��� ã�� : " & $sScriptTarget)
			_StringAddNewLine($sCommentMsg, "���� : " & _iif($bResult,"����","�Ҹ���"))

		case $_sCommandValueIf
			$bResult = commandValueIf($sScriptTarget, $sCommentMsg)


		case $_sCommandValueIfNot
			$bResult = not(commandValueIf($sScriptTarget, $sCommentMsg))

		case $_sCommandTextAsert
			$bResult = commandTextAsert($sScriptTarget)

		case $_sCommandTextIf
			runsleep($_runCommandSleep * 2)
			$bResult = commandTextAsert($sScriptTarget,2000, False)
			_StringAddNewLine($sCommentMsg, "Text ã��  : " & $sScriptTarget)
			_StringAddNewLine($sCommentMsg, "����:" & _iif($bResult,"����","�Ҹ���"))

		case $_sCommandTextIfNot
			runsleep($_runCommandSleep * 2)
			$bResult = not(commandTextAsert($sScriptTarget,2000, False))
			_StringAddNewLine($sCommentMsg, "Text ã��  : " & $sScriptTarget)
			_StringAddNewLine($sCommentMsg, "����:" & _iif($bResult,"����","�Ҹ���"))

		case $_sCommandInclude
			$bResult = commandInclude($sScriptTarget)

		case $_sCommandSet
			$bResult = commandSet($sScriptTarget, $sCommentMsg)

		case $_sCommandVariableSet
			$bResult = commandVariableSet($sScriptTarget)

		case $_sCommandExcute
			$bResult = commandExcute($sScriptTarget, $sCommentMsg)


		case $_sCommandAttach
			$bResult = commandAttach($sScriptTarget)

			if $bResult = True and $_runScriptErrorCheck = True then
				if CheckScriptError($_runBrowser) = True then
					captureCurrentBorwser($_runErrorMsg, False)
					$bResult = False
				endif
			endif

			;if $bResult  = True then
			;	if  $_runDebugLog  then captureCurrentBorwser($sCommentMsg, False)
			;endif

		case $_sCommandProcessAttach
			$bResult = commandProcessAttach($sScriptTarget)


		case $_sCommandSleep
			$bResult = commandSleep($sScriptTarget)


		case $_sCommandMouseMove
			$bResult = commandMouseDragandDrop($sScriptTarget, "move")

		case $_sCommandMouseDrag
			$bResult = commandMouseDragandDrop($sScriptTarget, "drag")

		case $_sCommandMouseDrop
			$bResult = commandMouseDragandDrop($sScriptTarget, "drop")

		case $_sCommandRightClick
			$bResult = commandClick($sScriptTarget, "right")

		case $_sCommandSuccess
			$bResult = True

		case $_sCommandFail

			captureCurrentBorwser($_runErrorMsg, False)
			$bResult = False

		case $_sCommandCapture
			$bResult  = captureCurrentBorwser($sCommentMsg, False)
			if $bResult  = False then _StringAddNewLine ( $_runErrorMsg , "�̹���ĸ�Ŀ� �����Ͽ����ϴ�.")

		case $_sCommandMouseHide
			moveMouseTop()
			$bResult = True

		case $_sCommandMouseWheelUp
			MouseWheel("up")
			runsleep($_runCommandSleep * 2)
			$bResult = True

		case $_sCommandMouseWheelDown
			MouseWheel("down")
			runsleep($_runCommandSleep * 2)
			$bResult = True

		case $_sCommandDoubleClick
			$bResult = commandClick($sScriptTarget, "double")

		case $_sCommandComma
			; ������ $_runCommandSleep �ð� ��ŭ ����.
			runsleep($_runCommaDelay)

			$bResult = True

		case $_sCommandSwipe
			; X1Y1 -> X2Y2 ��ǥ�� �巡��&����Ѵ�. (1~9 ��ġ)
			$bResult = commandSwipe($sScriptTarget)

		case $_sCommandGoHome
			$bResult = commandGoHome()

			; �� ����, ����
		case $_sCommandBlockStart, $_sCommandBlockend
			$bResult = True

		case $_sCommandLoop
			$bResult = commandLoop($sScriptTarget, $_sNewLoopVar, $_iNewLoopValue)

		case $_sCommandFullScreenWork
			$_runFullScreenWork = True
			$bResult = True

		case $_sCommandAreaCapture
			$bResult = commandAreaCapture($sScriptTarget, $sCommentMsg)

		case $_sCommandTagAttribGet
			$bResult = commandTagAttribGet($sScriptTarget, $sCommentMsg)

		case $_sCommandTagAttribSet
			$bResult = commandTagAttribSet($sScriptTarget, $sCommentMsg)

		case $_sCommandAreaWork
			$bResult = commandAreaWork($sScriptTarget, $sCommentMsg)

		case $_sCommandPartSet
			$bResult = commandPartSet($sScriptTarget, $sCommentMsg)

		case $_sCommandLogWrite
			$sCommentMsg = $sScriptTarget
			$bResult = True

		case $_sCommandSingleQuotationChange
			$bResult = CommandSingleQuotationChange($sScriptTarget)

		case $_sCommandAU3Run
			$bResult = CommandAU3Run($sScriptTarget)

		case $_sCommandAU3VarRead
			$bResult = CommandAU3VarRead($sScriptTarget, $sCommentMsg)

		case $_sCommandAU3VarWrite
			$bResult = CommandAU3VarWrite($sScriptTarget)

		case $_sCommandLongTab
			$bResult = commandClick($sScriptTarget, "long")

		case $_sCommandLocationTab
			$bResult = commandLocationTab($sScriptTarget, "location")

		case $_sCommandLocationLongTab
			$bResult = commandLocationTab($sScriptTarget, "locationlong")

		case $_sCommandLocationDoubleTab
			$bResult = commandLocationTab($sScriptTarget, "locationdouble")

		case $_sCommandTargetCapture
			$bResult = commandTargetCapture($sScriptTarget)

		case $_sCommandTagCountGet
			$bResult = commandTagCountGet($sScriptTarget, $sCommentMsg)

		case $_sCommandJSRun
			$bResult = commandJSRun($sScriptTarget, $sCommentMsg)

		case $_sCommandJSInsert
			$bResult = commandJSInsert($sScriptTarget, $sCommentMsg)

		case $_sCommandWDSessionCreate
			$bResult = commandWDSessionCreate($sScriptTarget, $sCommentMsg)

		case $_sCommandWDSessionDelete
			$bResult = commandWDSessionDelete()

		case Else
			$_runErrorMsg = "ó�� ������ ��ɰ� �ƴ� : " & $sScriptCommand
			$bResult = False


EndSwitch


writeDebugTimeLog("runCommand ��� ���� �� : " & $sScriptTarget )

;RunSleep(10)

if checkWaitCommand ($sScriptCommand) then

	if checkScriptErrorCheckCommand ($sScriptCommand) then
		$iCommandSleep = $_runCommandSleep
	else
		$iCommandSleep = $_runCommandSleep - 60
	endif

	writeDebugTimeLog("runCommand Commond Sleep : " & $iCommandSleep  )
	RunSleep($iCommandSleep)

	$_bLastcheckWaitCommand = True
Else
	$_bLastcheckWaitCommand = False
endif

writeDebugTimeLog("runCommand �б��� : " & $sScriptTarget  )

	;debug("��ɼ��� ��� : " & $bResult)

	;if $bResult = True then $_runErrorImageTarget =""

	if $bResult <> True then $bResult = False

	return $bResult

endfunc



func checkTagType($sNewValue, $iArgCount)

	local $iCount
	local $bRet  = False


	StringReplace($sNewValue, ":", "")
	$iCount = @extended

	if StringLeft($sNewValue,1) = "[" and StringRight($sNewValue,1) = "]"  and $iCount = $iArgCount then $bRet = True

	return $bRet

endfunc
; ----------------------------------------- Command ------------------------------------------------


Func commandWDSessionDelete()
; ��������
	local $shost, $aParamInfo
	local $bReturn = False

	if $_webdriver_current_sessionid = "" then
		WriteGuitarWebDriverError ( "������ Webdriver ���������� �����ϴ�." )
	else
		if _WD_delete_session () then
			$bReturn = True
			$_runWebdriver = False
			$_webdriver_current_sessionid =  ""
			$_webdriver_connection_host = ""
			_setCurrentBrowserInfo()
		else

			WriteGuitarWebDriverError ("Webdriver ���� ���ῡ �����Ͽ����ϴ�. " )
		endif
	endif

	return $bReturn

EndFunc


Func commandWDSessionCreate($sScriptTarget, byref $sCommentMsg)
;���ǻ���

	local $shost, $aParamInfo
	local $bReturn = False

	if getWebdriverConnectionInfo($sScriptTarget, $shost, $aParamInfo) then
		if _WD_create_session ($shost, $aParamInfo) then
			$bReturn = True
			$_runWebdriver = True
			_setCurrentBrowserInfo()
			; ������ ũ�� ����
			_setBrowserWindowsSize ("")
		else
			_StringAddNewLine ( $_runErrorMsg , "Webdriver ���� ������ �����Ͽ����ϴ�. " & $_webdriver_last_errormsg)
		endif
	else
		_StringAddNewLine ( $_runErrorMsg , "Webdriver ���� ���� ������ �ٸ��� �ʽ��ϴ�. {host=ȣ��Ʈ����,ȯ������1=��1,ȯ������n=��n}")
	endif
	_StringAddNewLine($sCommentMsg, "�������� : " & $shost & " , " & $_webdriver_current_sessionid)
	return $bReturn

EndFunc


func commandTargetCapture($sScriptTarget)
;���ĸ��

	local $bRet = False
	local $sCommentMsg
	local $iTagEndLoc
	local $iImageFileNameStartLoc
	local $sTagInfo = $sScriptTarget
	local $sImageFileName

	$iTagEndLoc = Stringinstr($sScriptTarget,"]",0,-1,Stringlen($sScriptTarget))

	if $iTagEndLoc  = 0 then
		_StringAddNewLine ( $_runErrorMsg , "���ĸ�� ����� Tag���� ������θ� ��� �����մϴ�.")
		return $bRet
	endif

	$iImageFileNameStartLoc = Stringinstr($sScriptTarget,",",0,-1,Stringlen($sScriptTarget))

	if $iImageFileNameStartLoc > $iTagEndLoc then
	; ���ϸ��� ������ ��� �и�
		$sTagInfo = _Trim(Stringleft($sScriptTarget,$iImageFileNameStartLoc-1))
		$sImageFileName = "," & _Trim(StringTrimLeft($sScriptTarget,$iImageFileNameStartLoc))

		;debug($sTagInfo, $sImageFileName)

	endif

	$bRet = commandAssert($sTagInfo, $_runWaitTimeOut, True, False, True )

	if $bRet then
		$bRet  = commandAreaCapture($_aLastUseMousePos[3] & $sImageFileName, $sCommentMsg)
		if $bRet  = False then _StringAddNewLine ( $_runErrorMsg , "�̹���ĸ�Ŀ� �����Ͽ����ϴ�.")
	endif


	return $bRet

endfunc


func commandProcessAttach($sScriptTarget)

	local $bRet  = False
	local $sProcessExe
	local $aPlist, $aWinList
	local $i

	getBrowserFullName ($sScriptTarget)

	$sProcessExe = getBrowserExe($sScriptTarget)


	;10 �� ���� ���
	if $sProcessExe = "" then
		_StringAddNewLine ( $_runErrorMsg , "�������� �������Ͽ� ���� ������ �����ϴ�. : " & $sScriptTarget)
		Return False
	endif


	for $i=1 to 5

		$aPlist = getBrowserWindowAll($sProcessExe, $aWinList)

		; ���μ����� �������� �ʰų�, �迭�� ã�� ��� �ٷ� ����
		if ProcessExists($sProcessExe) = 0 or  ubound($aPlist) > 1 then exitloop

		sleep (1000)

	next

	if ubound($aPlist) > 1 then
		$_runBrowser = $sScriptTarget
		$_hBrowser = $aPlist [1]

		;debug($_runBrowser, $_hBrowser)
		;msg($aPlist )

		_setCurrentBrowserInfo()

		WinActivate($_hBrowser)

		$bRet = True
	Else
		_StringAddNewLine ( $_runErrorMsg , "������ ���μ������� ���������� �ʽ��ϴ�. : " & $sProcessExe)
	endif

	return $bRet

endfunc


Func CommandAU3VarWrite($sScriptTarget)

	local $bRet  = False
	local $sNewName, $sNewValue, $iValueStart, $bTargetError

	$iValueStart = StringInStr($sScriptTarget,"=",True,1)

	$sNewName = _Trim(stringleft($sScriptTarget, $iValueStart-1))
	$sNewValue = stringTrimleft($sScriptTarget, $iValueStart)

	if $sNewName = "" or $sNewValue = "" then $bTargetError = True
	;if $sNewName = "" then $bTargetError = True

	if $bTargetError then
		_StringAddNewLine ( $_runErrorMsg , "��� ��� ���� �߸� ���� �Ǿ����ϴ�. ""AU3������=���� �� ��""")
		Return False
	endif

	_GUITAR_AU3VARWrite ($sNewName, $sNewValue)

	$bRet = True

	return $bRet

endfunc


Func CommandAU3VarRead($sScriptTarget,byref $sCommentMsg)

	local $bResult = True
	local $sNewValue
	local $sNewName
	local $bExtractCheck = False

	if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue,"," ,$bExtractCheck) = False then
		$bResult = False
		_StringAddNewLine ( $_runErrorMsg , "���� ���� ������ �߸��Ǿ����ϴ�.  ""$������=AU3������""")
	else
		$sNewValue = _GUITAR_AU3VARRead(_Trim($sNewValue))
		_StringAddNewLine($sCommentMsg, "�������� : " & $sNewName & "=" & $sNewValue)

		if addSetVar ($sNewName & "=" & $sNewValue, $_aRunVar, $bExtractCheck) = False Then
			_StringAddNewLine ( $_runErrorMsg , "���� ���� ������ �߸��Ǿ����ϴ�.  ""$������=AU3������""")
			$bResult = False
		endif

	endif

	return $bResult

endfunc


Func CommandAU3Run($sScriptTarget)

	local $bRet  = False
	local $iExitCode
	local $sAutoitExe = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\Autoit" , "InstallDir") & "\AutoIt3.exe"
	local $sWorkPath

	$sWorkPath = @WorkingDir
	FileChangeDir (_GetPathName($_runScriptFileName))
	$sScriptTarget = FileGetShortName($sScriptTarget, 1)
	FileChangeDir ($sWorkPath)

	if FileExists($sScriptTarget) = 0 Then
		_StringAddNewLine( $_runErrorMsg, 'AU3 ������ �������� �ʽ��ϴ�. : ' & $sScriptTarget)
		return $bRet
	endif

	if FileExists($sAutoitExe) = 0 Then
		_StringAddNewLine( $_runErrorMsg, 'AutoIt V3�� ��ġ���� �ʾҽ��ϴ�.')
		return $bRet
	endif

	$iExitCode = ShellExecuteWait($sAutoitExe, $sScriptTarget)

	if $iExitCode = 0 then
		$bRet = True
	else
		_StringAddNewLine( $_runErrorMsg, 'AU3 ���� �������� �ڵ尡 ���� �Դϴ�. Exitcode : ' & $iExitCode)
	endif

	return $bRet

endfunc


Func CommandSingleQuotationChange ($sScriptTarget)

	local $sGetVar
	local $sNewName = $sScriptTarget

	if getRunVar($sNewName, $sGetVar) = False then
		_StringAddNewLine( $_runErrorMsg, "���� ���� ������ �߸� �Ǿ��ų� ���� �������� �ʾҽ��ϴ�. : " &  _Trim($sNewName))
		;debug($sNewName,  $sGetVar)
		Return False
	endif

	$sGetVar = stringreplace($sGetVar, "'", "''")

	;debug($sNewName, $sGetVar)

	addSetVar ($sNewName & "=" & $sGetVar, $_aRunVar, True)

	return true

endfunc


;�κм���
Func commandPartSet($sScriptTarget,byref $sCommentMsg)

	local $bReturn = False
	local $sPartVar
	local $sFullVar
	local $sFullVarContext
	local $sPartNumber
	local $aTempSplit
	local $sSplitChar = chr(1)
	local $iSplitCount
	local $sSetVar

	if StringRegExp($sScriptTarget,"^\$.+\s*=\s*\$.+,\s*\d",0) = 0 then
		_StringAddNewLine( $_runErrorMsg, '��� ���� ���°� �ٸ��� �ʽ��ϴ�. (��, "$�κ�=$��ü,3") : ' & $sScriptTarget)
		return $bReturn
	endif

	$aTempSplit = StringSplit($sScriptTarget,"=")
	$sPartVar = _trim($aTempSplit[1])
	$aTempSplit = StringSplit($aTempSplit[2],",")



	$sFullVar = _trim($aTempSplit[1])
	$sPartNumber = number($aTempSplit[2])

	; ���� ���� ���� ������
	if getRunVar($sFullVar, $sFullVarContext) = False then
		_StringAddNewLine( $_runErrorMsg, "���� ���� ������ �߸� �Ǿ��ų� ���� �������� �ʾҽ��ϴ�. : " &  _Trim($sFullVar))
		Return False
	endif

	$sFullVarContext = StringReplace($sFullVarContext, ",", $sSplitChar)
	$sFullVarContext = StringReplace($sFullVarContext, @TAB, $sSplitChar)

	$aTempSplit = StringSplit($sFullVarContext,$sSplitChar)

	$iSplitCount = ubound($aTempSplit) - 1
	if not ($sPartNumber >= 1 and  $sPartNumber <= $iSplitCount) then
		_StringAddNewLine( $_runErrorMsg, "�κм��� �� ������ �߸� ���� �Ǿ����ϴ�. ��ü : " &  $iSplitCount & "��")
		Return False
	endif

	$sSetVar = $sPartVar & "=" & $aTempSplit[$sPartNumber]

	$bReturn = commandSet($sSetVar, $sCommentMsg)

	return $bReturn

endfunc


;�κд���۾�
Func commandAreaWork($sXY, byref $sCommentMsg)

	local $bReturn = False
	local $iX1, $iX2, $iY1, $iY2
	local $aAreaPos
	local $sCaptureFileName
	local $bParsingError


	$aAreaPos = getXYAreaPosition($sXY , $sCommentMsg, $bParsingError)

	if ubound($aAreaPos)-1 <> 4 or $bParsingError = True  then
		;debug($bParsingError)
		$_runErrorMsg = '��� ��ǥ���� �ٸ��� �ʽ��ϴ�. ������ ���� �����ǥ�� "X1,Y1,X2,Y2" �����̾�� �մϴ�. (��, "100,100,120,150") : ' & $sXY
		return $bReturn
	endif

	$bReturn = True

	; 0 = �κ��۾�����, 1~4 ��ǥ�� (�Ź� ����� ���� �ʱ�ȭ��)
	$_runAreaWork[0] = True
	$_runAreaWork[1] = Number($aAreaPos[1])
	$_runAreaWork[2] = Number($aAreaPos[2])
	$_runAreaWork[3] = Number($aAreaPos[3])
	$_runAreaWork[4] = Number($aAreaPos[4])

	; �����ǥ�� ����
	$_runAreaWork[5] = True

	return $bReturn

endfunc


func commandJSRun($sScriptTarget, byref $sCommentMsg)

	local $bTargetError = False
	local $sJSScriptName
	local $bResult
	local $aImageFile
	local $x, $y
	local $bFileNotFoundError
	local $sTempSplit
	local $Object
	local $oMyError
	local $bVarAddInfo
	local $sNewName, $sNewValue
	local $sJSReturn = ""

	$sNewValue = $sScriptTarget

	if $_runWebdriver = False then

		$bTargetError = NOT( getIEObjectType($sNewValue))

		if $bTargetError = False then

			$sTempSplit = StringSplit(StringTrimRight($sNewValue,1),":")
			;debug($sTempSplit)
			if ubound($sTempSplit) < 6 then $bTargetError = tRUE
		endif

		if $bTargetError then
			_StringAddNewLine ( $_runErrorMsg , "��� ���� �߸� ���� �Ǿ����ϴ�. ""[TAG��:TAG�Ӽ��񱳰�:ã�� TEXT��:����:���ེũ��Ʈ��]""")
			Return False
		endif

		$sJSScriptName = _Trim($sTempSplit [ubound($sTempSplit)-1])

		if $sJSScriptName = "" then
			_StringAddNewLine ( $_runErrorMsg , "������ JS�� �������� �ʾҽ��ϴ�." )
			Return False
		endif

		;"$�̹�������=[sdsdsds:Text]" �Ӽ��б� �Ѵ�.
		$bResult = getRunCommnadImageAndSearchTarget ($sNewValue, $aImageFile,  $x , $y, True , $_runWaitTimeOut, $bFileNotFoundError, False)

		if $bResult  then
			; ã�����

			$Object = $aImageFile[1]
			$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")

			SetError(0)
			;debug($Object.document.domain)
			$Object.document.parentWindow.execScript($sJSScriptName)
			;$Object.document.parentWindow.eval($sJSScriptName)


			if @error <> 0 then
				$bResult = False
				;msg("����")
				_StringAddNewLine ( $_runErrorMsg , "JS ���࿡ ���� �Ͽ����ϴ�. " & $sScriptTarget )
			Else

				;addSetVar ($sNewName & "=" & $sJSReturn, $_aRunVar)
				;_StringAddNewLine( $sCommentMsg, "�������� : " & $sNewName & "=" & $sJSReturn)
			endif

			$oMyError = ObjEvent("AutoIt.Error")

		endif

	else
		; WEB����̹� ������ ���

		; �и����� ���� chr(0)���� ����


		if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue, chr(0)) = False then $bTargetError = True

		IF $bTargetError = False THEN $bTargetError = NOT(isWebdriverParam($sNewValue))

		if $bTargetError then
			_StringAddNewLine ( $_runErrorMsg , "��� ���� �߸� ���� �Ǿ����ϴ�. ""$������={�ڹٽ�ũ��Ʈ}""")
			Return False
		endif

		$sJSScriptName = StringTrimRight(StringTrimLeft($sNewValue,1),1)

		if $sJSScriptName = "" then
			_StringAddNewLine ( $_runErrorMsg , "������ JS�� �������� �ʾҽ��ϴ�." )
			Return False
		endif
		;debug($sJSScriptName, $sJSReturn)
		$bResult = _WD_execute_script ($sJSScriptName, $sJSReturn)

		if $bResult Then
			addSetVar ($sNewName & "=" & $sJSReturn, $_aRunVar, True)
			_StringAddNewLine( $sCommentMsg, "�������� : " & $sNewName & "=" & $sJSReturn)
		else
			WriteGuitarWebDriverError ()
		endif


	endif

	return $bResult

endfunc


func commandJSInsert($sScriptTarget, byref $sCommentMsg)

	local $bTargetError = False
	local $sJSScriptContents
	local $bResult
	local $aImageFile
	local $x, $y
	local $bFileNotFoundError
	local $sTempSplit
	local $Object
	local $oMyError

	$bTargetError = NOT( getIEObjectType($sScriptTarget))

	if $bTargetError = False then
		$sTempSplit = StringSplit(StringTrimRight($sScriptTarget,1),":")
		;debug($sTempSplit)
		if ubound($sTempSplit) < 6 then $bTargetError = tRUE
	endif

	if $bTargetError then
		_StringAddNewLine ( $_runErrorMsg , "��� ���� �߸� ���� �Ǿ����ϴ�. ""[TAG��:TAG�Ӽ��񱳰�:ã�� TEXT��:����:�߰��� JS��ũ��Ʈ����]""")
		Return False
	endif

	$sJSScriptContents = _Trim($sTempSplit [ubound($sTempSplit)-1])

	if $sJSScriptContents = "" then
		_StringAddNewLine ( $_runErrorMsg , "�߰��� JS�� �� �����Դϴ�." )
		Return False
	endif

	;"$�̹�������=[sdsdsds:Text]" �Ӽ��б� �Ѵ�.
	$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, True , $_runWaitTimeOut, $bFileNotFoundError, False)

	if $bResult  then
		; ã�����

		$Object = $aImageFile[1]
		$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")

		SetError(0)
		;debug ($sJSScriptContents)
		_IEHeadInsertEventScript2($Object, "", "", $sJSScriptContents)
		;ConsoleWrite(_IEDocReadHTML($Object) & @CRLF)

		if @error <> 0 then
			$bResult = False
			;msg("����")
			_StringAddNewLine ( $_runErrorMsg , "JS �߰��� ���� �Ͽ����ϴ�. " & $sJSScriptContents )
		endif

		$oMyError = ObjEvent("AutoIt.Error")

	endif

	return $bResult


endfunc


func commandTagCountGet($sScriptTarget, byref $sCommentMsg)

	local $sNewName, $sNewValue
	local $bTargetError = False
	local $bResult

	local $bFileNotFoundError
	local $iTagCount

	local $sTempSplit
	local $Object

	local $oMyError
	local $sTempBrowser

	if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue) = False then $bTargetError = True

	IF $bTargetError = False THEN $bTargetError = NOT( getIEObjectType($sNewValue))

	if $bTargetError then
		_StringAddNewLine ( $_runErrorMsg , "��� ��� ���� �߸� ���� �Ǿ����ϴ�. ""$������=[TAG��:�Ӽ���:TEXT��]""")
		Return False
	endif

	$sNewValue = getIEObjectCondtion($sNewValue)

	seterror(0)
	$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")
	$sTempBrowser = _IEAttach2($_hBrowser,"HWND")

	if _IEPropertyGet ($sTempBrowser, "hwnd") <> $_hBrowser then
		_StringAddNewLine ( $_runErrorMsg , "IE ������������ Object������� ����� �����մϴ�." )
		return False
	endif

	$Object = IEObjectSearchFromObject($sTempBrowser, $sNewValue, True)

	$iTagCount = number(ubound($Object) -1)
	if $iTagCount < 0 then $iTagCount = 0

	addSetVar ($sNewName & "=" & $iTagCount, $_aRunVar)
	_StringAddNewLine( $sCommentMsg, "�������� : " & $sNewName & "=" & $iTagCount)

	return True

endfunc



func commandTagAttribGet($sScriptTarget, byref $sCommentMsg)

	local $bResult
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError
	local $aWinPos
	local $sTagAttribValue
	local $sTagAttribName
	local $sNewName
	local $sNewValue
	local $bTargetError = False
	local $battributeError = False
	local $sTempSplit
	local $Object
	local $i
	local $oMyError
	local $bSpecified
	local $sWEbElementID


	if $_runWebdriver = False then

		if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue) = False then $bTargetError = True

		IF $bTargetError = False THEN $bTargetError = NOT(getIEObjectType($sNewValue))

		if $bTargetError = False then
			$sTempSplit = StringSplit(StringTrimRight($sNewValue,1),":")
			if ubound($sTempSplit) < 6 then $bTargetError = tRUE
		endif

		if $bTargetError then
			_StringAddNewLine ( $_runErrorMsg , "��� ��� ���� �߸� ���� �Ǿ����ϴ�. ""$������=[TAG��:TAG�Ӽ��񱳰�:ã�� TEXT��:����:���� �Ӽ���]""")
			Return False
		endif

		$sTagAttribName = _Trim($sTempSplit [ubound($sTempSplit)-1])

		if $sTagAttribName = "" then
			_StringAddNewLine ( $_runErrorMsg , "���� �Ӽ����� �������� �ʾҽ��ϴ�." )
			Return False
		endif

		;"$�̹�������=[sdsdsds:Text]" �Ӽ��б� �Ѵ�.
		$bResult = getRunCommnadImageAndSearchTarget ($sNewValue, $aImageFile,  $x , $y, True , $_runWaitTimeOut, $bFileNotFoundError, False)

		if $bResult  then
			; ã�����

			$Object = $aImageFile[1]

			if $sTagAttribName <> "style" then

				$sTagAttribValue = Execute("$Object." & $sTagAttribName)

				if @error <> 0 then
					;msg($sTagAttribValue)
					;$sTagAttribValue = Execute("$Object.attributes." & $sTagAttribName & ".value()")
					;debug($Object.getAttributeNode(_Trim($sTagAttribName)))

					;ieattribdebug($Object)

					;$sTagAttribValue = Execute("$Object.attributes." & _Trim($sTagAttribName) & ".nodevalue()")


					for $i=0 to $Object.attributes.length -1
						$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")
						$bSpecified = $Object.attributes($i).specified
						if @error <> 0 then $battributeError = True
						if $bSpecified then

							if $Object.attributes($i).nodeName = _Trim($sTagAttribName) then
								$sTagAttribValue = $Object.attributes($i).nodeValue
							endif
						endif
						$oMyError = ObjEvent("AutoIt.Error")
					next


				endif
			Else
				$sTagAttribValue = Execute("$Object.style.cssText")

			endif

			if @error <> 0 then
				$bResult = False
				;msg("����")
				_StringAddNewLine ( $_runErrorMsg , "����� ã������, �Ӽ� ���� �б⿡ ���� �Ͽ����ϴ�. " & $sTagAttribName )
			elseif $battributeError = True  then
				$bResult = False
				_StringAddNewLine ( $_runErrorMsg , "�Ӽ� ���� �б⿡ ���� �Ͽ����ϴ�. " & $sTagAttribName )
			else
				;msg($sTagAttribName & " " &  $sTagAttribValue)
				; ����� Ư�� ���ڴ� html ���·� encoding �� ��
				addSetVar ($sNewName & "=" & $sTagAttribValue, $_aRunVar, True)
				_StringAddNewLine( $sCommentMsg, "�������� : " & $sNewName & "=" & $sTagAttribValue)
				;debug($sTagAttribValue, $sTagAttribValue)

			endif
		endif
	else

		; ������̹� ����� ���

		; �и����� ���� chr(0)���� ����
		if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue, chr(0)) = False then $bTargetError = True

		IF $bTargetError = False THEN $bTargetError = NOT(isWebdriverParam($sNewValue))

		if $bTargetError = False then
			$sTempSplit = StringSplit(StringTrimLeft(StringTrimRight($sNewValue,1),1),":")
			if ubound($sTempSplit) <> 4  then $bTargetError = tRUE
		endif

		if $bTargetError then
			_StringAddNewLine ( $_runErrorMsg , "��� ��� ���� �߸� ���� �Ǿ����ϴ�. ""$������={�˻����:�˻�����:���� �Ӽ���]""")
			Return False
		endif

		$sTagAttribName = _Trim($sTempSplit [ubound($sTempSplit)-1])

		if $sTagAttribName = "" then
			_StringAddNewLine ( $_runErrorMsg , "���� �Ӽ����� �������� �ʾҽ��ϴ�." )
			Return False
		endif


		$sWEbElementID = _WD_find_element_with_highlight_by (_Trim($sTempSplit[1]), $sTempSplit[2], $_runRetryRun , $_runHighlightDelay )

		if $sWEbElementID <> "" then
			$bResult = _WD_get_element_attribute($sWEbElementID, _Trim($sTempSplit[3]), $sTagAttribValue)
		endif

		if $bResult Then
			addSetVar ($sNewName & "=" & $sTagAttribValue, $_aRunVar, True)
			_StringAddNewLine( $sCommentMsg, "�������� : " & $sNewName & "=" & $sTagAttribValue)
		else
			WriteGuitarWebDriverError ()
		endif


	endif

	return $bResult

endfunc


; �Ӽ�����
func commandTagAttribSet($sScriptTarget, byref $sCommentMsg)

	local $bResult
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError
	local $aWinPos
	local $sTagAttribValue
	local $sTagAttribName
	local $sNewName
	local $sNewValue
	local $bTargetError = False
	local $sTempSplit
	local $Object
	local $iValueStart
	local $sExcute
	local $iErrorCode

	local $oMyError



	$iValueStart = StringInStr($sScriptTarget,"]")
	$iValueStart = StringInStr($sScriptTarget,"=",True,1,$iValueStart)

	$sNewName = _Trim(stringleft($sScriptTarget, $iValueStart-1))
	$sNewValue = _Trim(stringTrimleft($sScriptTarget, $iValueStart))

	if $sNewName = "" or $sNewValue = "" then $bTargetError = True

	;debug($sNewName, $sNewValue)

	if $bTargetError = False then $bTargetError = NOT(getIEObjectType($sNewName))

	if $bTargetError = False then
		$sTempSplit = StringSplit(StringTrimRight($sNewName,1),":")
		if ubound($sTempSplit) < 6 then $bTargetError = True
	endif

	if $bTargetError then
		_StringAddNewLine ( $_runErrorMsg , "��� ��� ���� �߸� ���� �Ǿ����ϴ�. ""{TAG��:TAG�Ӽ��񱳰�:ã�� TEXT��:����:���� �� �Ӽ���]=���� �� �Ӽ� ��""")
		Return False
	endif

	$sTagAttribName = _Trim($sTempSplit [ubound($sTempSplit)-1])

	if $sTagAttribName = "" then
		_StringAddNewLine ( $_runErrorMsg , "������ �Ӽ����� �������� �ʾҽ��ϴ�." )
		Return False
	endif

	;"$�̹�������=[sdsdsds:Text]" �Ӽ��б� �Ѵ�.
	$bResult = getRunCommnadImageAndSearchTarget ($sNewName, $aImageFile,  $x , $y, True , $_runWaitTimeOut, $bFileNotFoundError, False)

	if $bResult  then
		; ã�����

		$Object = $aImageFile[1]
		;$sExcute = "$__Objectx." & $sTagAttribName & " = """  & $sNewValue & """"
		;debug($sExcute)
		;$x= Execute($sExcute)

		; http://msdn.microsoft.com/en-us/library/ms533043.aspx



		$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")

		SetError(0)

		;debug("2 " & @error)


		if $sNewValue = "False" then
			$sNewValue = False
		elseif $sNewValue = "True" then
			$sNewValue = True
		endif


		;debug("3 " & @error)

		switch  $sTagAttribName

			case "border"
				$Object.border = $sNewValue

			case "caption"
				$Object.caption = $sNewValue

			case "checked"
				$Object.checked = $sNewValue

			case "disabled"
				$Object.disabled = $sNewValue

			case "height"
				$Object.height = $sNewValue

			case "href"
				$Object.href= $sNewValue

			case "id"
				$Object.id = $sNewValue

			case "index"
				$Object.index = $sNewValue

			case "innertext"
				$Object.innertext = $sNewValue

			case "link"
				$Object.link = $sNewValue

			case "name"
				$Object.name = $sNewValue

			case "readOnly"
				$Object.readOnly = $sNewValue

			case "selected"
				$Object.selected = $sNewValue
				;$iErrorCode = @error
				;debug($iErrorCode)

			case "src"
				$Object.src = $sNewValue

			case "target"
				$Object.target = $sNewValue

			case "text"
				$Object.text = $sNewValue

			case "title"
				$Object.title = $sNewValue

			case "value"
				$Object.value = $sNewValue

			case "width"
				$Object.width = $sNewValue

			case Else
				$bResult = False
				_StringAddNewLine ( $_runErrorMsg , "���� �� �� ���� �Ӽ� �Դϴ�. ")

		EndSwitch

		;debug("4 " & @error)

		if @error <> 0 then
			$bResult = False
			_StringAddNewLine ( $_runErrorMsg , "����� ã������, �Ӽ� ���� ���濡 ���� �Ͽ����ϴ�. " & $sTagAttribName )
		else
			;$Object.fireEvent("OnChange")
			;$Object.fireEvent("OnClick")
		endif

		$oMyError = ObjEvent("AutoIt.Error")

	endif


	return $bResult

endfunc


func commandLoop($sScriptTarget , byref $sLoopVar, byref $iLoopValue)

	local $sNewName, $sNewValue, $sGetVar
	local $bReturn
	local $sResultString
	local $sConvertType = " "

	;���� ���� �ʱ�ȭ

	if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue, $sConvertType) = False then
		_StringAddNewLine ( $_runErrorMsg , "��� ��� ���� �߸� ���� �Ǿ����ϴ�. ""$������=�ݺ�Ƚ��""")
		;debug($sScriptTarget,  $sNewName, $sNewValue)
		Return False
	endif

	$sNewValue = number($sNewValue)

	if $sNewValue = 0 then
		_StringAddNewLine ( $_runErrorMsg , "�ݺ�ȸ���� 1 �̻����� �����Ǿ�� �մϴ�.")
		Return False
	endif

	$sLoopVar = $sNewName
	$iLoopValue = $sNewValue

	Return True

endfunc


Func commandGohome()

	local $bReturn = False
	local $aWinPos, $aMousePos
	local $iX1, $iY1
	local $sOSType

	getRunVar("$GUITAR_�����OS",$sOSType)

	if $sOSType = "IOS" then
		; ������ �ػ󵵸� ã��
		$aWinPos = WinGetPos($_hBrowser)
		$aMousePos = MouseGetPos()

		if IsArray($aWinPos) then

			$bReturn = True

			$iX1 = $aWinPos[0] + ($aWinPos[2] /2)
			$iY1 = $aWinPos[1] + ($aWinPos[3] /2)

			MouseClick("right",$ix1, $iy1,1, $_runMouseDelay)

		endif

		MouseMove($aMousePos[0],$aMousePos[1] ,0)
	elseif $sOSType = "ANDROID" then
		$bReturn = commandKeySend("{HOME}","ANSI")
	else
		_StringAddNewLine ( $_runErrorMsg , '"$GUITAR_�����OS" �ý��� ������ �������� ����, "IOS" Ȥ�� "ANDROID"�� �����Ǿ�� ��')
	endif

	return $bReturn

endfunc


;�κ�ĸ��
Func commandAreaCapture($sXY, byref $sCommentMsg)

	local $bReturn = False
	local $iX1, $iX2, $iY1, $iY2
	local $aAreaPos
	local $sCaptureFileName
	local $i
	local $bWindowCapture = True
	local $bScreenCapture = True
	local $bParsingError

	$aAreaPos = getXYAreaPosition($sXY & ",", $sCommentMsg, $bParsingError)

	;debug($aAreaPos)
	;debug($bParsingError)

	;if StringRegExp($sXY,"^\d{1,4},\d{1,4},\d{1,4},\d{1,4}",0) = 0 and (not (stringleft($sXY,7) = "0,0,0,0" or stringleft($sXY,11) = "-1,-1,-1,-1")) then
	;	$_runErrorMsg = '��� ��ǥ���� �ٸ��� �ʽ��ϴ�. ������ ���� �����ǥ�� "X1,Y2,X2,Y2,���ϸ�(�ɼ�)" �����̾�� �մϴ�. (��, "100,100,120,150") : ' & $sXY
	;	return False
	;endif

	if ubound($aAreaPos) -1 < 4 then
		$_runErrorMsg = '��� ��ǥ���� �ٸ��� �ʽ��ϴ�. ������ ���� �����ǥ�� "X1,Y2,X2,Y2,���ϸ�(�ɼ�)" �����̾�� �մϴ�. (��, "100,100,120,150") : ' & $sXY
		return False
	endif

	;debug($aAreaPos)

	for $i=1 to 4
		$aAreaPos[$i] = number($aAreaPos[$i])
		$bWindowCapture = $bWindowCapture and ($aAreaPos[$i] = 0)
		$bScreenCapture = $bScreenCapture and ($aAreaPos[$i] = -1)
	next

	$sCaptureFileName = _Trim($aAreaPos[5])
	if $sCaptureFileName <> "" then
		if stringright($sCaptureFileName,4) <> $_cImageExt then $sCaptureFileName = $sCaptureFileName & $_cImageExt
	endif


	;debug($aAreaPos)

	; �����쳪, ��ũ�� ĸ���� ��� ��ǥ�� �����Ұ�
	if $bWindowCapture then

		$bReturn  = captureCurrentBorwser($sCommentMsg, False, $_hBrowser, "", $sCaptureFileName)

	elseif $bScreenCapture  then

		$bReturn  = captureCurrentBorwser($sCommentMsg, True, $_hBrowser, "", $sCaptureFileName)

	else

		$bReturn  = captureCurrentBorwser($sCommentMsg, False, $_hBrowser, $aAreaPos, $sCaptureFileName)

	endif


	if $bReturn  = False then _StringAddNewLine ( $_runErrorMsg , "�̹���ĸ�Ŀ� �����Ͽ����ϴ�.")

	$_runAreaCpatureExists = True

	return $bReturn

endfunc


Func commandSwipe($sXY)

	local $bReturn = False
	local $iX1, $iX2, $iY1, $iY2 , $sCommentMsg
	local $aWinPos
	local $aXY
	local $iWidth
	local $iHeight
	local $iAddx1, $iAddx2, $iAddy1, $iAddy2
	local $iStepX, $iStepY
	local $iStep = 10, $iMouseSpeed = 100
	local $iLoopCount
	local $x, $y
	local $iMax, $bError

	$aXY = getXYAreaPositionPercent($sXY, 4,  $bError)

	if $bError = True then
		;msg($sCommentMsg)
		$_runErrorMsg = "��ǥ ������ �ٸ��� ����. X1%,Y1%,X2%,Y2% ���� (��:0~100%, ��: ���������� ����ѱ�� = 90%,50%,10%,50%) : " & $sXY
		$bReturn = False
		return $bReturn
	endif

	; ������ �ػ󵵸� ã��
	$aWinPos = _WinGetClientPos($_hBrowser)

	if IsArray($aWinPos) then

		$bReturn = True

		$iX1 = $aWinPos[0] + ($aWinPos[2] * ($aXY[1] / 100) - ($aWinPos[2]/100/2))
		$iY1 = $aWinPos[1] + ($aWinPos[3] * ($aXY[2] / 100) - ($aWinPos[3]/100/2))
		$iX2 = $aWinPos[0] + ($aWinPos[2] * ($aXY[3] / 100) - ($aWinPos[2]/100/2))
		$iY2 = $aWinPos[1] + ($aWinPos[3] * ($aXY[4] / 100) - ($aWinPos[3]/100/2))

		if $iX2 > $aWinPos[0] + $aWinPos[2] then $iX2 = $aWinPos[0] + $aWinPos[2]
		if $iY2 > $aWinPos[1] + $aWinPos[3] then $iY2 = $aWinPos[1] + $aWinPos[3]


		MouseMove($ix1, $iy1, 1)

		if $_runMobileOS = "IOS" then
			MouseClickDrag("left",$ix1, $iy1,$ix2, $iy2,30)
		else
			sleep(100)
			MouseDown("")
			sleep(100)

			MouseMove($ix1 + ($ix2-$ix1)*0.1, $iy1 + ($iy2-$iy1)*0.1, 100)
			;MouseMove($ix1 - ($ix2-$ix1)*0.1, $iy1 - ($iy2-$iy1)*0.1, 10)
			MouseMove($ix1 + ($ix2-$ix1)*1.1, $iy1 + ($iy2-$iy1)*1.1, 10)

			sleep(100)
			MouseMove($ix2, $iy2, 10)

			sleep(1000)
			Mouseup("")

		endif

	endif


	return $bReturn

endfunc



Func commandExcute($sScriptTarget, byref $sCommentMsg)

	local $sNewName, $sNewValue, $sGetVar
	local $bReturn
	local $sExcuteReturn
	local $sResultString
	local $sConvertType = " "

	if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue, $sConvertType) = False then
		_StringAddNewLine ( $_runErrorMsg , "��� ��� ���� �߸� ���� �Ǿ����ϴ�. ""$������=�񱳰�""")
		;debug($sScriptTarget,  $sNewName, $sNewValue)
		Return False
	endif

	convertHtmlChar ($sNewValue)


	$sExcuteReturn = Execute($sNewValue)

	if @error <> 0 then
		;debug(@error, $sExcuteReturn)
		;debug("�����:" & $sNewValue)
		$sResultString = " (������ : �������)"
		$bReturn = False
	Else
		$sResultString = " (������ : " & $sExcuteReturn & ")"
		;debug($sNewName & "=" & $sExcuteReturn, $_aRunVar)
		addSetVar ($sNewName & "=" & $sExcuteReturn, $_aRunVar)
		$bReturn = True
	endif

	_StringAddNewLine($sCommentMsg, "��ɼ��� : "  &  $sNewValue & $sResultString)

	return $bReturn

EndFunc

; ������

Func commandValueIf($sScriptTarget, byref $sCommentMsg)

	local $sNewName, $sNewValue, $sGetVar
	local $sConvertNewValue
	local $sConvertGetValue
	local $bReturn

	if getVarNameValue($sScriptTarget,  $sNewName, $sNewValue) = False then
		_StringAddNewLine ( $_runErrorMsg , "��� ��� ���� �߸� ���� �Ǿ����ϴ�.2 ""$������=�񱳰�""")
		;debug($sScriptTarget,  $sNewName, $sNewValue)
		Return False
	endif

	if getRunVar($sNewName, $sGetVar) = False then
		_StringAddNewLine( $_runErrorMsg, "���� ���� ������ �߸� �Ǿ��ų� ���� �������� �ʾҽ��ϴ�. : " &  _Trim($sNewName))
		;debug($sNewName,  $sGetVar)
		Return False
	endif


	$sConvertNewValue = $sNewValue
	convertHtmlChar ($sConvertNewValue)

	$sConvertGetValue = $sGetVar
	convertHtmlChar ($sConvertGetValue)

	;debug($sConvertNewValue, $sConvertGetValue)
	if $sConvertNewValue <> $sConvertGetValue then
		$bReturn = False
	Else
		$bReturn = True

	endif

	_StringAddNewLine($sCommentMsg, "������ : " & $sGetVar & "=" &  $sNewValue & " (" & _iif($bReturn,"��ġ","����ġ") & ")")

	return $bReturn

EndFunc


func commandAttach($sScriptTarget, $iTimeOut = $_runWaitTimeOut)
;����

	local $tTimeInit
	local $bResult = False
	local $aImageFile
	local $i
	local $aBrowserExe [1]
	local $sWinTitleList
	local $iLastCount = 0
	local $bScreenCapture = False
	local $bImageSearch = False
	local $bObjectSearch = False
	local $iRetHandle
	local $bObjectSearch
	local $sSearchType, $sSearchValue, $sSearchResultID


	sleep (1000)


	if $_runWebdriver = False then

		if $_runLastBrowser <> "" then

			_ArrayAdd($aBrowserExe,$_runLastBrowser)
		Else

			for $i=1 to ubound($_aBrowserOTHER)-1
				if _ArraySearch($aBrowserExe,$_aBrowserOTHER[$i][1],1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_aBrowserOTHER[$i][1])
			next

			if _ArraySearch($aBrowserExe,$_sBrowserIE,1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_sBrowserIE)
			if _ArraySearch($aBrowserExe,$_sBrowserFF,1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_sBrowserFF)
			if _ArraySearch($aBrowserExe,$_sBrowserSA,1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_sBrowserSA)
			if _ArraySearch($aBrowserExe,$_sBrowserCR,1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_sBrowserCR)
			if _ArraySearch($aBrowserExe,$_sBrowserOP,1,0,0,0,1) = -1 then _ArrayAdd($aBrowserExe,$_sBrowserOP)

		endif

		;debug ($_runLastBrowser)

		Opt("WinDetectHiddenText", 1)

			$sScriptTarget = _Trim($sScriptTarget)

			writeDebugTimeLog("attach ������ handle " & $_hBrowser)

				RunSleep (100)
				$tTimeInit = _TimerInit()



				do
					for $i = 1 to ubound($aBrowserExe) -1

						;debug($aImageFile)

						; ù��°�� �ƴϸ鼭 IE�� �ƴ� ��쿡�� �˻��õ� ���� ������
						;if $bObjectSearch and $i > 1 and $aBrowserExe[$i] <> $_sBrowserIE then ContinueLoop

						;debug("ã���� " & $aBrowserExe[$i] & $i )

						if $iLastCount = 1 then $bScreenCapture = True

						;debug($iLastCount, $bScreenCapture)

						if $_runScriptErrorCheck = True then CheckScriptError($aBrowserExe[$i])


						if $_runErrorMsg = "" then $bResult = searchBrowserWindow($aBrowserExe[$i] , $sScriptTarget, $sWinTitleList, $bScreenCapture, $iRetHandle)

						if $bResult then

							writeDebugTimeLog("attach ���� 1��")
							$_runBrowser = $aBrowserExe[$i]
							$_hBrowser = $iRetHandle
							;msg($_hBrowser)



							if hBrowswerActive() = 0 then
								_StringAddNewLine ( $_runErrorMsg , "���õ� ������ �����츦 Ȱ��ȭ �� �� �����ϴ�.")
								$bResult = False
							endif

							_setCurrentBrowserInfo()

							writeDebugTimeLog("attach ���� 2��")
						endif

						RunSleep (10)

						; �׽�Ʈ �ߴ�
						if checkScriptStopping() then return False
						if $_runErrorMsg <> "" then exitloop
						if $bResult then exitloop

					next

					if _TimerDiff($tTimeInit) > $iTimeOut then $iLastCount += 1

				until $bResult or $iLastCount > 1 or $_runErrorMsg <> ""



		if $bResult = False then
			_StringAddNewLine ( $_runErrorMsg , "������ �����츦 ã�� �� �����ϴ�. : " & $sScriptTarget & @crlf & " ������ List : " & $sWinTitleList)

			captureCurrentBorwser($_runErrorMsg, True)
		else
			; ������ ��� ���� �似���� �����Ͽ� �ʱ�ȭ�� (������� �����찡 ����� ��� hwnd�� 0���� �Ǵ� ��� �� �־� �����Ⱑ ����)
			$_runErrorMsg = ""
		endif

		writeDebugTimeLog("attach ������ handle " & $_hBrowser)
		writeDebugTimeLog("attach ���� ��� " & $bResult)

		Opt("WinDetectHiddenText", 0)


	else


		if getWebdriverParamTypeAndValue($sScriptTarget, $sSearchType, $sSearchValue) then

			$tTimeInit = _TimerInit()

			do
				setStatusText (getTargetSearchRemainTimeStatusText($tTimeInit, $iTimeOut, $sScriptTarget))
				$bResult = _WD_switch_to_window($sSearchType, $sSearchValue, $_runRetryRun , $_runHighlightDelay)
				if $bResult = False then RunSleep (500)
			until ($bResult = True) or (_TimerDiff($tTimeInit) > $iTimeOut) or (checkScriptStopping())


			_debug( $bResult , checkScriptStopping())
			if $bResult  = False and checkScriptStopping() = False then
				_StringAddNewLine ( $_runErrorMsg , "������ �����츦 ã�� �� �����ϴ�. : " & $sScriptTarget )
			endif

		else

			_StringAddNewLine ( $_runErrorMsg , "Webdriver �׽�Ʈ �Է������� �ٸ��� �ʽ��ϴ�. {�˻����:�˻�����}")

		endif

	endif

	return $bResult

endfunc


func commandVariableSet($sScriptName)
;��������

	local $bResult = True

	local $sNewValue
	local $sNewName

	if getVarNameValue($sScriptName,  $sNewName, $sNewValue) = False then
		$bResult = False
		_StringAddNewLine ( $_runErrorMsg , "���� ������ �߸��Ǿ����ϴ�.  ""$���̺�����=����Line��""")
	elseif number($sNewValue) < 1 then
		$bResult = False
		_StringAddNewLine ( $_runErrorMsg , "���� ���� ���� 0���� ū ���� �Է��ؾ� �մϴ�. : " & number($sNewValue))
	else
		RestTableValueIndex($sNewName, number($sNewValue))
		;debug ($bResult)
	endif

	return $bResult

endfunc


func commandSet($sScriptName, byref $sCommentMsg)

	; ���� ���� ������ ���� �����Ѵ�.
	local $bResult = True
	local $sNewValue
	local $sNewName
	local $bExtractCheck = True

	if getVarNameValue($sScriptName,  $sNewName, $sNewValue,"," ,$bExtractCheck) = False then
		$bResult = False
		_StringAddNewLine ( $_runErrorMsg , "���� ���� ������ �߸��Ǿ����ϴ�.  ""$������=����""")
	else
		;debug("���ο��:" , $sNewName, $sNewValue)
		_StringAddNewLine( $sCommentMsg, "�������� : " & $sNewName & "=" & $sNewValue)

		if addSetVar ($sNewName & "=" & $sNewValue, $_aRunVar, $bExtractCheck) = False Then
			_StringAddNewLine ( $_runErrorMsg , "���� ���� ������ �߸��Ǿ����ϴ�.  ""$������=����""")
			$bResult = False
		endif
		;debug("���ο�� END:" , $sNewName, $sNewValue, $bResult)
	endif

	return $bResult

endfunc


func commandInclude($sScriptName)

	local $aRowScript
	local $sErrorMsgAll
	local $aScript
	local $bResult
	local $sSearchScriptFile
	local $aRunCountInfo [4] = [0,0,0,0]
	local $sLastImagePath
	local $oldScriptFile

	$sScriptName = FileGetLongName($sScriptName,1)

	;if FileExists($sScriptName) = 0 then
	;	$sScriptName  = FileGetLongName(_GetPathName($_runScriptFileName) & $sScriptName,1)
		;debug($sScriptName )
	;endif

	;if FileExists($sScriptName) = 0 then
		$sSearchScriptFile = searchScriptFile(_GetFileName($sScriptName) & _GetFileExt($sScriptName), $sErrorMsgAll)

		;msg($sSearchScriptFile)

		if $sSearchScriptFile <> "" then $sScriptName = $sSearchScriptFile
		if $sErrorMsgAll <> "" then
			$_runErrorMsg = $sErrorMsgAll
			return False
		endif
	;endif

	if FileExists($sScriptName) = 0 then
		$_runErrorMsg = "��ũ��Ʈ ���� ���� : " & $sScriptName
		;writeRunLog(writePassFail(False))
		return  False
	endif

	; ���� �̹��� ������ �����ϰ�, include ���Ŀ� �ٽ� �߰�
	$sLastImagePath = $_aRunImagePathList[ubound ($_aRunImagePathList) -1]

	_deleteImagePathList($sLastImagePath)
	$_bUpdateForderFileList = True
	_addImagePathList(_GetPathName($sScriptName))

	_FileReadToArray($sScriptName,$aRowScript)

	if getScript($aRowScript, $aScript, $sErrorMsgAll, True,0 ,0 ) = False then
		$_runErrorMsg = "��ũ��Ʈ ���� �м� ���� " & @crlf & $sErrorMsgAll
		;writeRunLog(writePassFail(False))
		$bResult = False
	Else
		;debug($sScriptName)

		; �α��� ¦�� �����ֱ� ���� ����
		;writeRunLog(writePassFail(True))

		$_iScriptRecursive += 1
		$oldScriptFile = $_runScriptFileName
		$bResult = runScript($sScriptName, $aScript, 0, 0, $aRunCountInfo)
		$_runScriptFileName = $oldScriptFile
		$_iScriptRecursive -= 1
	endif

	_deleteImagePathList(_GetPathName($sScriptName))
	$_bUpdateForderFileList = True
	_addImagePathList($sLastImagePath)

	return $bResult

endfunc


func commandBrowserEnd()

	local $bResult = False


	if $_runWebdriver = False  then

		Switch $_runBrowser

			;case $_sBrowserIE
			;if _IEQuit($_oBrowser) = 1 then $bResult = True

			case $_sBrowserCR, $_sBrowserOP
				hBrowswerActive ()
				sleep(100)
				send("^{F4}")
				$bResult = True

			case Else
				if WinClose($_hBrowser) <> 0 then $bResult = True

		EndSwitch

		$_runBrowser = ""
		$_hBrowser = ""

	else
		$bResult = _WD_close_window()

	endif

	_setCurrentBrowserInfo()

	if $bResult = False then
		$_runErrorMsg = "������ �ݱ⿡ ����"
		captureCurrentBorwser($_runErrorMsg, True)
	endif

	RunSleep (1000)

	return $bResult

endfunc



func commandAssert($sScriptTarget,$TimeOut, $bIsErrorCheck, $bFullSearch, $bExpect)

	local $bResult = False
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError
	local $aWinPos
	local $sSearchType, $sSearchValue

	$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, $bIsErrorCheck, $TimeOut, $bFileNotFoundError, $bFullSearch)

	;msg($bResult)
	;MouseMove($x, $y,1)
	;sleep(5000)

	if $bIsErrorCheck = False and $bFileNotFoundError = False then $_runErrorMsg = ""

	return $bResult

endfunc


func commandLocationTab($sScriptTarget, $bButton)

	local $x,$y, $bResult
	local $aWinPos, $aXY, $bError

	$bResult = False

	$aXY = getXYAreaPositionPercent($sScriptTarget, 2,  $bError)

	if $bError = False then

		$aWinPos = _WinGetClientPos($_hBrowser)

		$x = $aWinPos[0] + ($aWinPos[2] * ($aXY[1] / 100))
		$y = $aWinPos[1] + ($aWinPos[3] * ($aXY[2] / 100))

		MouseMove($x, $y,1)

		if $bButton = "locationlong" then
			MouseMove($x, $y,1)
			MouseDown("left")
			sleep (2000)
			Mouseup("left")
		elseif $bButton = "locationdouble" then
			MouseClick("left", $x, $y)
			sleep(250)
			MouseClick("left", $x, $y)
		else
			;debug("locationtab " , $x, $y)
			MouseClick("left", $x, $y)
		endif

		$bResult = True

	endif

	return $bResult

endfunc


func commandClick($sScriptTarget, $bButton)

	local $bResult = False
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError
	local $ioldClickDelay
	local $aWinPos
	local $iDelay = $_runMouseDelay
	local $iClickCount

	local $sWebElementID
	local $sWebAction
	local $iWebActionButton

	writeDebugTimeLog("Command Click �̹��� ã��")

	$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, True, $_runWaitTimeOut, $bFileNotFoundError)

	writeDebugTimeLog("Command Click �̹��� ã�� �Ϸ�")

	if  $bResult = True  then

		if $_runWebdriver = False  then

			addCorrectionYX( $x ,  $y)

			hBrowswerActive ()
			writeDebugTimeLog("Command Click active  �Ϸ�")
			runsleep(10)
			MouseMove($x, $y,$iDelay)
			runsleep(10)


			if $bButton = "double" then
				;$bButton="left"
				$iClickCount = 2
			Else
				$iClickCount = 1
			endif

			if $bButton = "double" then
				;$ioldClickDelay = AutoItSetOption("MouseClickDownDelay", 100)
				MouseClick("left", $x, $y)
				sleep(250)
				MouseClick("left", $x, $y)
				;AutoItSetOption("MouseClickDownDelay", $ioldClickDelay)
			elseif $bButton = "long" then
				MouseMove($x, $y,$iDelay)
				MouseDown("left")
				sleep (2000)
				Mouseup("left")

			Else
				MouseMove($x-1, $y-1,$iDelay)
				runsleep(10)
				MouseMove($x+1, $y+1,$iDelay)
				runsleep(10)
				MouseMove($x-1, $y-1,$iDelay)
				runsleep(10)
				MouseMove($x+1, $y+1,$iDelay)
				runsleep(10)

				;debug($iClickCount)

				MouseClick($bButton,$x, $y,$iClickCount,$iDelay)

			endif

		else
			; WEBDRIVER ����� ���

			$sWebElementID = $x

			$x=0
			$y=0

			addCorrectionYX( $x ,  $y)

			$iWebActionButton = 0
			$sWebAction = "/click"

			if $bButton = "right" then $iWebActionButton = 2
			if $bButton = "double" then $sWebAction = "/doubleclick"

			$bResult = _WD_MoveAndAction($sWebElementID, $sWebAction , $iWebActionButton, $x, $y)

			if $bResult = False then WriteGuitarWebDriverError ()

		endif
		Sleep(10)
		;moveMouseTop()

	endif

	writeDebugTimeLog("Command Click ��� �Ϸ�")

	return $bResult

endfunc


func commandMouseMove($sScriptTarget)

	local $bResult
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError

	$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, True, $_runWaitTimeOut, $bFileNotFoundError)

	writeDebugTimeLog("Command ���콺 �̵���")

	if  $bResult = True  then

		addCorrectionYX( $x ,  $y)

		hBrowswerActive ()
		MouseMove($x  , $y,$_runMouseDelay)
		RunSleep(100)
	endif

	writeDebugTimeLog("Command ���콺 �̵���")
	return $bResult

endfunc


func addCorrectionYX(byref $x , byref $y)

		if $_runCorrectionX <> 0 or $_runCorrectionY <> 0 then

			$x = $x + $_runCorrectionX
			$y = $y + $_runCorrectionY

			$_runCorrectionY = 0
			$_runCorrectionX = 0

			addSetVar ("$GUITAR_X��ǥ����=0", $_aRunVar)
			addSetVar ("$GUITAR_Y��ǥ����=0", $_aRunVar)

		endif

endfunc




func getBrowserIDFromExe($sExe)

	local $sID

	$sExe = StringLower($sExe)

	if $sExe = getReadINI("BROWSER", $_sBrowserIE) then $sID = $_sBrowserIE
	if $sExe = getReadINI("BROWSER", $_sBrowserFF) then $sID = $_sBrowserFF
	if $sExe = getReadINI("BROWSER", $_sBrowserSA) then $sID = $_sBrowserSA
	if $sExe = getReadINI("BROWSER", $_sBrowserCR) then $sID = $_sBrowserCR
	if $sExe = getReadINI("BROWSER", $_sBrowserOP) then $sID = $_sBrowserOP


	if $sID = "" then

		for $j=1 to ubound($_aBrowserOTHER) -1
			if StringLower($_aBrowserOTHER[$j][2]) = $sExe then $sID = $_aBrowserOTHER[$j][1]
		next

	endif

	return $sID

endfunc


func getBrowserExe($sBrowser)

	local $sBexe
	local $aOther
	local $aOtherItem
	local $j

	Switch $sBrowser

		case $_sBrowserIE, $_sBrowserFF, $_sBrowserSA, $_sBrowserCR, $_sBrowserOP

			$sBexe = getReadINI("BROWSER", $sBrowser)

		case Else
			for $j=1 to ubound($_aBrowserOTHER) -1
				if $_aBrowserOTHER[$j][1] = $sBrowser then $sBexe = $_aBrowserOTHER[$j][2]
			next

	EndSwitch

	return $sBexe

endfunc


func CloseAllBrowser($sBrowser ="")

	local $sBrowserEXE
	local $i, $j
	local $sWinlistText
	local $aWinlist
	local $iTimeDiff

	writeDebugTimeLog("CloseAllBrowser ����")

	if $sBrowser <> "" then

		$sBrowserEXE = getReadINI("BROWSER", $sBrowser)

		do
			ProcessClose($sBrowserEXE)

		until (ProcessExists($sBrowserEXE) = 0)

	else

		for $i=1 to 5

			switch $i

				case 1
					$sBrowserEXE =  getReadINI("BROWSER", $_sBrowserIE)
				case 2
					$sBrowserEXE =  getReadINI("BROWSER", $_sBrowserFF)
				case 3
					$sBrowserEXE =  getReadINI("BROWSER", $_sBrowserSA)
				case 4
					$sBrowserEXE =	getReadINI("BROWSER", $_sBrowserCR)
				case 5
					;������ ���� �� ��� ������ ���â�� �߻���
					$sBrowserEXE =	getReadINI("BROWSER", $_sBrowserOP)

			EndSwitch

			$aWinlist = getBrowserWindowAll($sBrowserEXE, $sWinlistText)

			for $j=1 to ubound($aWinlist) -1
				winclose($aWinlist[$j])
			next

			if ubound($aWinlist) > 1 then  sleep (1000)

			writeDebugTimeLog("CloseAllBrowser loop ��")

			$iTimeDiff = _Timerinit()

			; 5�� �̻� ���� �� ��� �ڵ����� ���� ����
			do
				ProcessClose($sBrowserEXE)
			until (ProcessExists($sBrowserEXE) = 0 or _TimerDiff($iTimeDiff) > 5)

			writeDebugTimeLog("CloseAllBrowser loop ��")

		next
	endif

	writeDebugTimeLog("CloseAllBrowser ����")

endfunc


func getBrowserFullName(byref $sScriptTarget)

	if $sScriptTarget = "FF" then $sScriptTarget = "FIREFOX"
	if $sScriptTarget = "CR" then $sScriptTarget = "CHROME"
	if $sScriptTarget = "SA" then $sScriptTarget = "SAFARI"
	if $sScriptTarget = "OP" then $sScriptTarget = "OPERA"

endfunc

func commandBrowserRun($sScriptTarget)

	local $sRunkey
	local $bResult = True
	local $sBrowserEXE
	local $aBrowserClassFF = StringSplit($_sBrowserClassFF,"|")
	local $iLoopCnt = 0
	local $sTempBrowser
	local $sTempBrowser2
	local $iTimerInit = _TimerInit()
	local $bLoadWait = True
	local $aFireFoxhWnd[1], $i, $j, $aWinList, $hFireFoxNewhwnd
	local $x, $y
	local $sTempBrowser
	local $iErrorCode
	local $i
	local $aTempPos
	local $oMyError

	getBrowserFullName ($sScriptTarget)

	if $sScriptTarget <> "" Then

		;debug($sScriptTarget)
		$sBrowserEXE = getReadINI("BROWSER", $sScriptTarget)

		if $sBrowserEXE = "" Then
			$_runErrorMsg = "������ ���� ���ϸ��� ini�� �������� ���� : " & $sScriptTarget
			$bResult = False
			return False
		endif

		;msg($_runCmdRunning)
		;msg(getIniBoolean(getReadINI("Environment","CloseAllBrowser")))

	endif


	;if $_runCmdRunning = True and getIniBoolean(getReadINI("Environment","CloseAllBrowser")) then
	;	CloseAllBrowser()
	;endif


	Switch $sScriptTarget

			case $_sBrowserIE

			$bLoadWait = False
			$iTimerInit = _TimerInit()

			$_runBrowser = $_sBrowserIE
			;$_oBrowser = _IECreate("about:blank",0,1,1,1)

			$oMyError = ObjEvent("AutoIt.Error","UIAIE_NavigateError")



			writeDebugTimeLog(" IE ���� ��")


			for $i=1 to 3


				$sTempBrowser = _IECreate("about:blank",0,1,1,1)

				writeDebugTimeLog(" IE ���� �� 1")

				$_hBrowser = _IEPropertyGet ($sTempBrowser, "hwnd")

				writeDebugTimeLog(" IE ���� �� 2")

				$sTempBrowser2 = _IEAttach2($_hBrowser,"hwnd")
				$iErrorCode=@error
				writeDebugTimeLog(" IE ���� _IEAttach2 ��� " & $iErrorCode)

				If $iErrorCode <> 0 Then
					writeDebugTimeLog("command commandBrowserRun IE HWND Error hwnd : " & $_hBrowser & ", error code : " & $iErrorCode)
				else
					exitloop
				endif

				sleep (3000)

			next


			$oMyError = ObjEvent("AutoIt.Error")

			do
				runsleep(1000)
			until (hBrowswerActive () <> 0 ) and StringInStr(WinGetTitle($_hBrowser), "Internet Explorer") > 0 OR (_TimerDiff($iTimerInit) > $_runWaitTimeOut)


		case $_sBrowserFF

			$_runBrowser = $_sBrowserFF
			$_hBrowser = ""

			for $i=1 to 2
				$aWinList = WinList("[CLASS:" & $aBrowserClassFF[$i] & "]")
				for $j=1 to ubound($aWinList) -1
					_ArrayAdd($aFireFoxhWnd, $aWinList[$j][1])
				next
			next

			;msg($aFireFoxhWnd)
			if ShellExecute($sBrowserEXE,"about:blank")  then

				$hFireFoxNewhwnd = ""

				RunSleep (1000)

				do
					RunSleep (1000)
					$iLoopCnt += 1

					for $i=1 to 2
						$aWinList = WinList("[CLASS:" & $aBrowserClassFF[$i]   &"]")
						for $j=1 to ubound($aWinList) -1

							if _ArraySearch($aFireFoxhWnd,$aWinList[$j][1],1,0) = -1 then
								if IsHWnd($aWinList[$j][1]) <> 0 then

									; ������ ������ Ÿ��Ʋ�� ��� ����
									if _Trim($aWinList[$j][0]) <> "" then

										$hFireFoxNewhwnd = $aWinList[$j][1]
										writeDebugTimeLog("FF ������ ã�� : " & $aWinList[$j][0] & " " & $aWinList[$j][1])
										$aTempPos =WinGetPos($aWinList[$j][1])
										writeDebugTimeLog("FF ������ ��ġ : " & $aTempPos[0] & $aTempPos[1] & $aTempPos[2] & $aTempPos[3] )
										exitloop
									endif
								endif
							endif
						next
					next


				until $hFireFoxNewhwnd <> ""  or $iLoopCnt > $_runWaitTimeOut / 1000

				;msg($hFireFoxNewhwnd)

				if $hFireFoxNewhwnd <> "" then
					$_hBrowser = $hFireFoxNewhwnd
				else
					$_hBrowser = ""
					$bResult = False
				endif

				;writeDebugTimeLog("New FF hwnd : " & $_hBrowser)

			Else
				$bResult = False
			endif

		case $_sBrowserSA

			$sRunkey = "about:" & Random()
			$_runBrowser = $_sBrowserSA

			if ShellExecute ($sBrowserEXE ,$sRunkey) then
				WinWait($sRunkey, "",  $_runWaitTimeOut / 1000)
				WinActivate($sRunkey)
				$_hBrowser = WinGetHandle($sRunkey)
			else
				$bResult = False
			endif

		case $_sBrowserCR

			$sRunkey = "about:blank"
			$_runBrowser = $sScriptTarget
			$_hBrowser = ""

			if ShellExecute ($sBrowserEXE ,$sRunkey) then
				WinWait($sRunkey, "",  $_runWaitTimeOut / 1000)
				WinActivate($sRunkey)
				if WinActive($sRunkey) then $_hBrowser = WinGetHandle($sRunkey)
			else
				$bResult = False
			endif

		case $_sBrowserOP

			$sRunkey = "opera:about"
			$_runBrowser = $sScriptTarget
			$_hBrowser = ""

			if ShellExecute ($sBrowserEXE ,$sRunkey) then

				$iTimerInit =  _TimerInit()

				opt("WinTitleMatchMode",2)
				do

					$sRunkey = " - Opera"
					WinActivate($sRunkey)
					if WinActive($sRunkey) then $_hBrowser = WinGetHandle($sRunkey)

					$sRunkey = "About Opera"
					WinActivate($sRunkey)
					if WinActive($sRunkey) then $_hBrowser = WinGetHandle($sRunkey)

					$sRunkey = "Welcome to Opera"
					WinActivate($sRunkey)
					if WinActive($sRunkey) then  send("{ENTER}")

					$sRunkey = "ȯ���մϴ�"
					WinActivate($sRunkey)
					if WinActive($sRunkey) then  send("{ENTER}")


			until _TimerDiff($iTimerInit) > $_runWaitTimeOut or  $_hBrowser <> ""
			opt("WinTitleMatchMode",1)

			else
				$bResult = False
			endif

		case else
			$_runErrorMsg = $_runBrowser & " ������ ���� ������ �����ϴ�."
			$bResult = False

	EndSwitch

	if IsHWnd($_hBrowser) = 0 then RunSleep(1000)
	if IsHWnd($_hBrowser) = 0 then RunSleep(1000)
	if IsHWnd($_hBrowser) = 0 then RunSleep(1000)

	if IsHWnd($_hBrowser) = False then
		$_runErrorMsg = $_runBrowser & " ������ ���� ����"
		captureCurrentBorwser($_runErrorMsg, True)
		$bResult = False

	Elseif $bResult then

		if $bLoadWait then sleep (500)

		;IE�� �ƴѰ�� ������ �ּ�â�� ���Ë� ���� ���
		if $_runBrowser <> $_sBrowserIE then

			hBrowswerActive()

			RunSleep(50)
			SendSleep("^l" , 100)
			RunSleep(50)
			SendSleep("!d", 100)

			setTestHotKey(False)
			sleep(50)
			Send("{ESC}")
			sleep(50)
			Send("{ESC}")
			setTestHotKey(True)

			for $i=1 to 20
				hBrowswerActive()
				$_runErrorMsg = ""
				if getBrowserAdressPos($_runBrowser,  $x,  $y) = True then exitloop
				sleep(500)
				writeDebugTimeLog("commandCreate �ּ�â Ȯ�� ��� " & $i)
			next

			if $_runErrorMsg <> "" then
				$_runErrorMsg = $_runBrowser & " ������ ���� ����, " & $_runErrorMsg
				captureCurrentBorwser($_runErrorMsg, True)
				$bResult = False
			endif

		endif

		_setBrowserWindowsSize($_hBrowser)
		_setCurrentBrowserInfo()

	endif

	return $bResult

endfunc

func waitForBrowserDone($sScriptTarget, $bErrorCheck, $iTimeOut)

	local $bImageSearch = False
	local $aImageList
	local $i
	local $aRetPos
	local $x, $y
	local $sLoopCount = 5
	local $iStartX, $iStartY, $iEndX, $iEndY
	local $aWinPos

	Switch $sScriptTarget

		case $_sBrowserIE
			$bImageSearch = True

		case $_sBrowserFF, $_sBrowserSA, $_sBrowserCR, $_sBrowserOP

			$aWinPos = WinGetPos($_hBrowser)

			if IsArray($aWinPos) then

				$iStartX = $aWinPos[0]
				$iStartY = $aWinPos[1]
				$iEndX = $aWinPos[0] + $aWinPos[2]
				$iEndY = $aWinPos[1] + 120

				$bImageSearch = CheckResourceImage($sScriptTarget & "_DONE", $iStartX, $iStartY, $iEndX, $iEndY, $iTimeOut, $x, $y )

			endif

	EndSwitch

	if $bImageSearch = False and $bErrorCheck = True  then
		if $_bScriptStopping = False then _StringAddNewLine($_runErrorMsg , $sScriptTarget & " �������� URL �Է� ��� ���°� �ƴմϴ�.")
	endif

	return $bImageSearch

endfunc


func commandNavigate($sURL, $bRetry)

	local $bResult = False
	local $oBrowserControlID
	local $sTempClip
	local $sTempBrowser
	local $oMyError
	local $i
	local $bTimeout = False
	local $iTimeOut
	Local $iErrorCode
	local $x, $y
	local $bNavigate

	$_runErrorMsg = ""


	if $_runWebdriver Then
		if _WD_navigate($sURL) then
			$bResult = True
		else
			_StringAddNewLine ( $_runErrorMsg , "Webdriver���� ������ �߻��Ǿ����ϴ�. : " & $_webdriver_last_errormsg)
		endif

	else


		for $i= 1 to 3

			$_runErrorMsg = ""

			writeDebugTimeLog("commandNavigate moveMouseTop �� ��õ�:" & $i)

			if hBrowswerActive () = 0 then
				$_runErrorMsg = "â�� Ȱ��ȭ �� �� �����ϴ�."
				$bResult = False
			endif

			writeDebugTimeLog("commandNavigate moveMouseTop ��")

			moveMouseTop()

			writeDebugTimeLog("commandNavigate moveMouseTop ��")

			Switch $_runBrowser

				case $_sBrowserIE

					;SendSleep("!D")
					;RunSleep(1000)
					;$oBrowserControlID = ControlGetFocus($_hBrowser,"")

					;if $oBrowserControlID = "" then
					;	$_runErrorMsg = "URL �Է�â�� ��Ŀ���� ������ �� �����ϴ�."
					;	return False
					;endif

					;ControlSetText ($_hBrowser,"",$oBrowserControlID,$sURL)
					;ControlSend($_hBrowser,"",$oBrowserControlID, "{ENTER}")

					;
					;debug("1" & $_hBrowser, $sTempBrowser)

					;debug("Attach �� " & $_hBrowser & " " & $sURL)

					;checkIE9FontSmoothingSetting()

					 writeDebugTimeLog("commandNavigate IEAttach �� : " & $_hBrowser & " " & IsHWnd($_hBrowser) )
					 $sTempBrowser = _IEAttach2($_hBrowser,"HWND")
					 $iErrorCode=@error
					 If @error <> 0 Then writeDebugTimeLog("commandNavigate error id : " & $iErrorCode)

					 writeDebugTimeLog("commandNavigate IEAttach ��")


					;debug("2" & $_hBrowser, $sTempBrowser)

					if $sTempBrowser <> 0  then
						seterror(0)
						$oMyError = ObjEvent("AutoIt.Error","UIAIE_NavigateError")

						writeDebugTimeLog("commandNavigate _IENavigate ��")

						$_aLastNavigateTime = _TimerInit()
						$bNavigate = _IENavigate($sTempBrowser, $sURL, 0)

						if $bNavigate = -1  then

							writeDebugTimeLog("commandNavigate _IELoadWait ��")
							_IELoadWait ($sTempBrowser,100, $_runWaitTimeOut / 2)
							_IELoadWait ($sTempBrowser,100, $_runWaitTimeOut / 2)
							if _IELoadWait ($sTempBrowser,100, 1000) = 1 then
								$bResult = True
								;debug(_TimerDiff($_aLastNavigateTime))
								$_aLastNavigateTime = _TimerDiff($_aLastNavigateTime)
								;debug($_aLastNavigateTime)
								writeDebugTimeLog("commandNavigate _IELoadWait �� ����")
							else

								if getIniBoolean(getReadINI("Report","FullSizeImage")) = True then
									$bResult = False
									_StringAddNewLine($_runErrorMsg , "�� ������ �ε��� �Ϸ���� �ʾҽ��ϴ�.")
									writeDebugTimeLog("commandNavigate _IELoadWait �� ����")
								else
									$bResult = False
									_StringAddNewLine($_runErrorMsg , "�� ������ �ε��� �����Ͽ����ϴ�. Timeout")
									writeDebugTimeLog("commandNavigate _IELoadWait ������ �߻��Ǿ�����, Skip")
								endif
							endif

						Else
							 ;debug($_oBrowser)
							$_runErrorMsg = $sURL & " �������� ���� �� �� �����ϴ�."
							$bResult = False

						endif


						$oMyError = ObjEvent("AutoIt.Error")

						if $_runErrorMsg <> "" then $bResult = False

					Else
						$_runErrorMsg = "Navigate �� �� ���� IE ������ â�� ���õǾ� �ֽ��ϴ�."
						$_runErrorMsg &= "Vista �̻��� �ý����� ��� ����� ���� ��Ʈ�� ������ �Ǿ� ������� ������ �߻��� �� �ֽ��ϴ�. ������ > �ý��� �� ���� > ���� ���� > ����� ���� ��Ʈ�� ������ '�ְ� ����'���� �����Ͽ� ����Ͻñ� �ٶ��ϴ�. "
						$bResult = False
					endif

					writeDebugTimeLog("commandNavigate IE �۾� �Ϸ�")

				case $_sBrowserSA, $_sBrowserFF, $_sBrowserCR, $_sBrowserOP

					WinSetOnTop($_hBrowser,"",1)

					writeDebugTimeLog("commandNavigate Top �� ")

					hBrowswerActive()

					writeDebugTimeLog("commandNavigate hBrowswerActive �� ")

					$_runErrorMsg = ""
					if getBrowserAdressPos($_runBrowser,  $x,  $y) = False then
						setTestHotKey(False)
						sleep(50)
						Send("{ESC}")
						sleep(50)
						Send("{ESC}")
						setTestHotKey(True)
					endif

					; ���콺�� ���� ����� Ŭ�� (ctrl + l�� �۵��ǵ��� ��ȭ�� Ŭ��)
					writeDebugTimeLog("commandNavigate ���콺 �̵� ��")
					;setMouseClickLeftMiddle()

					if getBrowserAdressPos($_runBrowser,  $x,  $y) = True then

						;setMouseClickLeftDown()
						;debug($x, $y)

						MouseClick("",$x,$y,10,2)

						hBrowswerActive()

						writeDebugTimeLog("hBrowswerActive()2 ��")

						setTestHotKey(False)
						sleep(50)
						Send("{ESC}")
						setTestHotKey(True)

						RunSleep(10)
						SendSleep("^l")
						SendSleep("{DEL}")
						RunSleep(10)
						SendSleep("!d")


						RunSleep(10)
						SendSleep("^a")
						RunSleep(10)
						SendSleep("{DEL}")
						RunSleep(10)
						writeDebugTimeLog("delete �߰�")

	;~ 					RunSleep(50)
	;~ 					SendSleep("^l")
	;~ 					RunSleep(50)
	;~ 					SendSleep("!d")
	;~ 					RunSleep(50)
	;~ 					SendSleep("^l")
	;~ 					RunSleep(50)
	;~ 					SendSleep("!d")
	;~ 					RunSleep(50)
	;~ 					SendSleep("^l")
	;~ 					RunSleep(50)
	;~ 					RunSleep(100)
	;~ 					SendSleep("^l")

						RunSleep(10)
						SendSleep("^a")
						RunSleep(10)
						SendSleep("{DEL}")
						RunSleep(10)
						SendSleep("^a")

						writeDebugTimeLog("hBrowswerActive()3 ��")

						hBrowswerActive()

						;_SendUnicode($sURL)
						;RunSleep(10)
						;$bResult = True

						writeDebugTimeLog("_SendClipboard ��")


						if _SendClipboard($sURL) = False then
							$_runErrorMsg = "URL �Է��� ���� Ŭ������ ����� ������ �߻��Ǿ����ϴ�."
						else
							$bResult = True
						endif

						if $bResult then SendSleep("{ENTER}")

						writeDebugTimeLog("���� :" & $sURL)

						$_aLastNavigateTime = _TimerInit()

						RunSleep(100)

					endif

					WinSetOnTop($_hBrowser,"",0)
					hBrowswerActive()


			EndSwitch

			;RunSleep(1000)

			writeDebugTimeLog("commandNavigate waitForBrowserDone ��")

			$bTimeout = False

			; debugtimeout �̶� �ּ� 20�� �̻��� Timeout���� ���

			$iTimeOut = $_runWaitTimeOut
			if $iTimeOut  < 20000 then $iTimeOut   = 20000

			; ���� ������ ��찡 �������� 1,2, $iTimeOut���� 3�� ��Ȯ�� ��,


			if $bResult and ($_runBrowser <> $_sBrowserIE) then

				if waitForBrowserDone($_runBrowser, False, $iTimeOut )  = False  then
					writeDebugTimeLog("waitForBrowserDone 4�� �Ϸ� ����")
					$bTimeout = True
					$bResult = False
					if $_bScriptStopping = False then

						if getIniBoolean(getReadINI("Report","FullSizeImage")) = True then
							_StringAddNewLine($_runErrorMsg , "�� ������ �ε��� �Ϸ���� �ʾҽ��ϴ�.")
						else
							$bResult = True
							writeDebugTimeLog("commandNavigate _IELoadWait ������ �߻��Ǿ�����, Skip")
						endif
					endif
				endif

				if $bResult = True then $_aLastNavigateTime = _TimerDiff($_aLastNavigateTime)

			endif



	;~ 		if $bResult and ($_runBrowser <> $_sBrowserIE) then

	;~ 			waitForBrowserDone($_runBrowser, False, 1000)
	;~ 			writeDebugTimeLog("waitForBrowserDone 1�� �Ϸ�")

	;~ 			if waitForBrowserDone($_runBrowser, False, 2000)  = False and $_bScriptStopping = False then
	;~ 				writeDebugTimeLog("waitForBrowserDone 2�� �Ϸ�")
	;~ 				runsleep (500)
	;~ 				if waitForBrowserDone($_runBrowser, False, 2000 )  = False and $_bScriptStopping = False then
	;~ 					writeDebugTimeLog("waitForBrowserDone 3�� �Ϸ�")
	;~ 					runsleep (500)
	;~ 					if waitForBrowserDone($_runBrowser, False, $iTimeOut )  = False  then
	;~ 						writeDebugTimeLog("waitForBrowserDone 4�� �Ϸ� ����")
	;~ 						$bTimeout = True
	;~ 						$bResult = False
	;~ 						if $_bScriptStopping = False then

	;~ 							if getIniBoolean(getReadINI("Report","FullSizeImage")) = True then
	;~ 								_StringAddNewLine($_runErrorMsg , "�� ������ �ε��� �Ϸ���� �ʾҽ��ϴ�.")
	;~ 							else
	;~ 								$bResult = True
	;~ 								writeDebugTimeLog("commandNavigate _IELoadWait ������ �߻��Ǿ�����, Skip")
	;~ 							endif
	;~ 						endif
	;~ 					endif
	;~ 					writeDebugTimeLog("waitForBrowserDone 4�� �Ϸ�")
	;~ 				endif
	;~ 			endif

	;~ 			if $bResult = True then $_aLastNavigateTime = _TimerDiff($_aLastNavigateTime)

	;~ 		endif

			writeDebugTimeLog("commandNavigate waitForBrowserDone ��, Timeout : " & $bTimeout)


			if $bResult = True or $_bScriptStopping = True then exitloop

			writeDebugTimeLog("commandNavigate ��õ�")

		next

		if $bResult = True and $i > 1 then writeDebugTimeLog("commandNavigate ��õ�����")

		if $bResult = False then
			$_aLastNavigateTime = 0
			captureCurrentBorwser($_runErrorMsg, False)
		Else
			runsleep (100)
		endif
	endif

	return $bResult

endfunc


func _SendClipboard($string)

	local $bRet
	local $sOldClipText = ClipGet()

	if Clipput($string) = 1 then
		send("^v")
		$bRet = True
	endif

	return $bRet

endfunc


func getBrowserAdressPos($sScriptTarget, byref $x, byref $y)

	local $bImageSearch = False
	local $aImageList
	local $i
	local $aRetPos
	local $iStartX, $iStartY, $iEndX, $iEndY
	local $aWinPos

	$x=0
	$y=0

	$aWinPos = WinGetPos($_hBrowser)

	if IsArray($aWinPos) then

		$iStartX = $aWinPos[0]
		$iStartY = $aWinPos[1]
		$iEndX = $aWinPos[0] + $aWinPos[2]
		$iEndY = $aWinPos[1] + 120

		$bImageSearch = CheckResourceImage($sScriptTarget & "_ADDRESS", $iStartX, $iStartY, $iEndX, $iEndY, 5000, $x, $y )

	endif

	if $bImageSearch = False then
		_StringAddNewLine($_runErrorMsg , $sScriptTarget & " �ּ�â ��ġ�� Ȯ�� �� �� �����ϴ�")
	else

		; �������� ��������� ��ǥ �̵�
		Switch $sScriptTarget

			case $_sBrowserFF
				$x -= 110

			case $_sBrowserSA
				$x -= 100

			case $_sBrowserCR
				$x -= 100

			case $_sBrowserOP
				$x -= 20
		EndSwitch

	endif

	return $bImageSearch

endfunc



func commandSleep($iSec)

	local $bResult

	RunSleep ($iSec * 1000)

	;debug($iSec * 1000)

	$bResult = True

	return $bResult

endfunc


func commandInput($sText)

	local $bResult
	local $sTemp
	local $iDelay

	;$sTemp = ClipGet()
	;ClipPut($sText)
	;sleep(10000)
	;send("^v")

	$iDelay = Number(getReadINI("Environment","InputDelay"))
	if $iDelay = 0 then $iDelay = 500
	sleep($iDelay)

	if $_runWebdriver = False  then

		if ControlSend($_hBrowser,"",ControlGetFocus($_hBrowser,""),$sText) = 0 then
			$_runErrorMsg = "���ڿ��� �Է� �� �� �ִ� Control�� ���� �������� �ʾҽ��ϴ�."
			$bResult = False
			captureCurrentBorwser($_runErrorMsg, False)
		Else
			$bResult = True
		endif

	else
		$bResult = _WD_send_keys($sText)
		if $bResult = False then WriteGuitarWebDriverError()
	endif
	sleep(100)

	return $bResult

endfunc


func commandKeySend($sText, $sType = "ANSI")

	local $bResult
	local $hCurrentWin
	local $bCorrectWindow = True
	local $sClassList
	local $iDelay


	; ��� �����찡 �������� �ƴ� ��� ANSI ������� �Է� �� ��
	convertHtmlChar($sText)


	if $_runWebdriver = False  then

		$hCurrentWin = WinGetHandle("[ACTIVE]")

		;if _ProcessGetName(WinGetProcess($hCurrentWin)) = getBrowserExe($_runBrowser) then $bCorrectWindow = True

		; ��ü�۾��� ��� �����쿡 ������ ���� �ʰ� �Է���.
		;if $_runFullScreenWork then $bCorrectWindow = True


		;debug($sType, $sText)


		if $bCorrectWindow then

			$iDelay = Number(getReadINI("Environment","InputDelay"))
			if $iDelay = 0 then $iDelay = 500
			sleep($iDelay)


			setTestHotKey(False)

			if $sType = "ANSI" then
				send($sText)
			Else

				;debug(Opt("SendKeyDelay"))
				;debug(Opt("SendKeyDownDelay"))

				_SendUnicode($sText)

			endif

			setTestHotKey(True)

			$bResult = True

		Else
			$_runErrorMsg = "Ű���带 �Է��� �� ���� ȭ���Դϴ�. Ÿ��Ʋ : " & WinGetTitle($hCurrentWin)
			;debug("ClassList : " & $sClassList )
			;debug("Porcess : " & _ProcessGetName(WinGetProcess($hCurrentWin) ))

			captureCurrentBorwser($_runErrorMsg, True)
			$bResult = False
		endif
		;SendKeepActive ("")
		;debug($sText, Stringlen($sText))
		;send($sText)
	Else
		$bResult = _WD_send_keys($sText)
		if $bResult = False then WriteGuitarWebDriverError()
	endif


	return $bResult

endfunc




func CaptureTextActiveWindow(byref $sClipText)

	local $bResult = True
	local $aMousePos
	local $sOldClipText = ClipGet()
	local $sClipError = "Clipboard �۾��� ������ �߻��Ǿ����ϴ�."
	local $i
	local $bClipBoardError = False

	$sClipText = ""

	;���콺 ��ġ ����
	$aMousePos = MouseGetPos()


	;���콺 ���� �� Ŭ��
	;setMouseClickLeftDown()
	;sleep(10)


	;mouseClick("left")
	;sleep(10)

	;CTRL + a ����
	send("^a")
	sleep(500)


	;���� Ŭ������ ������ ����
	$sOldClipText = ClipGet()

	;CTRL + c ����

	for $i= 1 to 5
		send("^c")
		sleep(500)
		if $sOldClipText <> ClipGet() then exitloop
	next


	for $i= 1 to 5
		$sClipText = ClipGet()
		if @error then $bClipBoardError = True
		if $bClipBoardError = False then ExitLoop
		sleep (500)
	next


	if @error then
		_StringAddNewLine($_runErrorMsg , "Clipboard �б� �۾��� ������ �߻��Ǿ����ϴ�. Errorcode : " & @error)
		$bResult = False
	endif

	ClipPut($sOldClipText)

	;���콺 ���� ����� Ŭ��
	;setMouseClickLeftTop()
	;sleep(100)
	;mouseClick("left")

	;�� ������ ���� TAB Ű 10��
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)
;~ 	send("{TAB}")
;~ 	sleep(10)


;~ 	send("{LEFT}")
;~ 	sleep(10)
;~ 	send("{LEFT}")
;~ 	sleep(10)
;~ 	send("{LEFT}")
;~ 	sleep(10)
;~ 	send("{LEFT}")
;~ 	sleep(10)

;~ 	send("{HOME}")
;~ 	sleep(10)



	;���콺 ��ġ ����
	MouseMove($aMousePos[0],$aMousePos[1] ,0)

	;Ŭ������ ������ ����
	return $bResult

endfunc

func commandTextAsert($sText, $iTimeOut = $_runWaitTimeOut, $bIsErrorCheck = True )

	local $bResult = False
	local $sLocalText
	local $sTemp
	local $aTextAsert
	local $i
	local $tTimeInit = _TimerInit()
	local $iFoundCount = 0
	local $sNotFoundString = ""
	local $sConvertChar
	local $sTempBrowser, $oMyError

	do

		if $_runBrowser = $_sBrowserIE then

			seterror(0)
			$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")
			$sTempBrowser = _IEAttach2($_hBrowser,"HWND")

			if _IEPropertyGet ($sTempBrowser, "hwnd") <> $_hBrowser then
				_StringAddNewLine ( $_runErrorMsg , "IE �������� ����� �� �����ϴ�.")
				return False
			endif

			$sLocalText = IEObjectGetAllInnerHtml($sTempBrowser)


			;debug("����:" & $sLocalText)

		else
			if CaptureTextActiveWindow($sLocalText) = False then exitloop
		endif
		;$sLocalText = TCaptureXCaptureActiveWindow(WinGetHandle("[ACTIVE]"))

		$aTextAsert = StringSplit($sText,",")

		$iFoundCount = 0
		$sNotFoundString = ""

		for $i=1 to ubound($aTextAsert) -1
			$aTextAsert[$i] = _Trim($aTextAsert[$i])

			; Ư�� ���ڸ� ��ȯ�ѵ� �˻��Ұ�
			$sConvertChar = $aTextAsert[$i]
			convertHtmlChar ($sConvertChar)

			if StringInStr($sLocalText,$sConvertChar,1) > 0 then
				$iFoundCount +=1
			Else
				if $sNotFoundString <> "" then $sNotFoundString = $sNotFoundString & ", "
				$sNotFoundString = $sNotFoundString & $aTextAsert[$i]
			endif
		next

		if (ubound($aTextAsert) -1 = $iFoundCount) and ($iFoundCount > 0) then  $bResult = True

		;debug("ã������ : " & $iFoundCount, $bResult)

		if $bResult = False then runsleep(1000)

	until $bResult or _TimerDiff($tTimeInit) > $iTimeOut or checkScriptStopping() = True


	if not $bResult then

		if $bIsErrorCheck then
			_StringAddNewLine($_runErrorMsg , "���ڿ��� ã�� �� ���� : " & $sNotFoundString)
			captureCurrentBorwser($_runErrorMsg, False)
		endif

		;debug("text:" & $sLocalText)

	endif

	if $bIsErrorCheck = False  then $_runErrorMsg = ""

	return $bResult

endfunc


func commandMouseDragAndDrop($sScriptTarget, $sType)

	local $bResult
	local $x
	local $y
	local $aImageFile
	local $bFileNotFoundError
	local $sWebElementID
	local $sWebDriverAction = ""

	$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, True, $_runWaitTimeOut, $bFileNotFoundError)

	if  $bResult = True  then

		if $_runWebdriver = False  then
			hBrowswerActive ()
			addCorrectionYX( $x ,  $y)
			if $sType = "drag" then
				MouseMove($x , $y,1)
				MouseDown ("left")
			elseif $sType = "drop" then
				MouseMove($x , $y,5)
				Mouseup ("left")
			elseif $sType = "move" then
				MouseMove($x , $y,1)
			endif
				RunSleep(1)
		else
			$sWebElementID = $x

			$x=0
			$y=0

			addCorrectionYX( $x ,  $y)

			if $sType = "drop" then $sWebDriverAction = "/buttonup"
			if $sType = "drag" then $sWebDriverAction = "/buttondown"
			if $sType = "move" then $sWebDriverAction = "/moveto"

			$bResult = _WD_MoveAndAction($sWebElementID, $sWebDriverAction ,  0, $x, $y)

			if $bResult = False then WriteGuitarWebDriverError()

		endif

	endif

	return $bResult

endfunc


; -----------------------------------------------------------------------------------------------------

func getRunCommnadImage($sScriptTarget,byref $aImageFile, $bPreView = True )
; ��ɾ� ������ �̹����� ã�Ƽ� �迭�� ����

	local $bResult
	local $i
	local $aTempImageFile[1]
	local $iLastArraySize
	local $aReportImage

	$aImageFile = $aTempImageFile

	;debug($_aRunImagePathList)
	;debug($sScriptTarget)

;~ 	for $i= 0 to ubound($_aRunImagePathList) -1 step 1

;~ 		$iLastArraySize = ubound($aImageFile)

;~ 		foundImageFile( $_aRunImagePathList[$i], $sScriptTarget, $aImageFile)
;~ 		;debug($aImageFile)
;~ 		sortImageListByOSBrowser ($aImageFile,$_runBrowser, $iLastArraySize)
;~ 	next
;~

	$aImageFile = _findFolderFileInfo($_sImageForderFileList, $sScriptTarget & $_cImageExt & $_sCommandImageSearchSplitChar & $sScriptTarget & "_", False)



	; ����Ʈ ������ ��� ������ ���� ��� �߰���

	$aReportImage = _GetFileNameFromDir ($_runWorkReportPath , $sScriptTarget & $_cImageExt, 1)

	if IsArray($aReportImage) then

		for $i=1 to ubound($aReportImage) -1
			_ArrayAdd($aImageFile, $aReportImage[$i])
			;debug($aReportImage[$i])
		next



	endif

	if ubound($aImageFile) <= 1 then
		$_runErrorMsg = "�̹��� ������ �������� ���� : " & $sScriptTarget
		$bResult = False
	Else
		$_runLastImageArray = $aImageFile
		$_runLastImageArray [0] = $sScriptTarget
		$bResult = True
	endif

	$_runErrorImageTarget = $sScriptTarget

	if $bResult = True then
		for $i=1 to ubound($aImageFile) -1
			writeDebugTimeLog($aImageFile[$i])
		next
		if $bPreView then _viewLastUseedImage()
		sleep(10)
	endif

	return $bResult

endfunc


; JS ���� Ȯ��
func CheckScriptError($sBrowserType)

	local $iStartX, $iStartY, $iEndX, $iEndY
	local $bScriptError = False
	local $aWinPos
	local $sErrorImageName
	local $x,$y
	local $sIEErrorMsgboxinfo = "[Class:Internet Explorer_TridentDlgFrame]"


	writeDebugTimeLog("��ũ��Ʈ ���� Ȯ�� ����")



	if $sBrowserType = $_sBrowserIE Then

		writeDebugTimeLog("IE ����â Ȯ�� : " & WinExists($sIEErrorMsgboxinfo) )
		if WinExists($sIEErrorMsgboxinfo) Then $bScriptError = True

	endif


	if $bScriptError  = False then

		Switch $sBrowserType

			case $_sBrowserIE, $_sBrowserFF, $_sBrowserCR

				$aWinPos = WinGetPos($_hBrowser)



				if IsArray($aWinPos) = False then return $bScriptError


				Switch $sBrowserType

					case $_sBrowserIE

						$iStartX = $aWinPos[0]
						$iStartY = $aWinPos[1] + $aWinPos[3] - 40
						$iEndX = $aWinPos[0] + 50
						$iEndY = $aWinPos[1]+ $aWinPos[3]

						$sErrorImageName = "SCRIPTERROR_IE"

					case $_sBrowserFF

						$iStartX = $aWinPos[0] + $aWinPos[2] - 180
						$iStartY = $aWinPos[1] + $aWinPos[3] - 30
						$iEndX = $aWinPos[0] + $aWinPos[2] - 60
						$iEndY = $aWinPos[1]+ $aWinPos[3]

						$sErrorImageName = "SCRIPTERROR_FF"

					case $_sBrowserCR

						$iStartX = $aWinPos[0] + $aWinPos[2] - 150
						$iStartY = $aWinPos[1] + 45
						$iEndX = $aWinPos[0] + $aWinPos[2] - 60
						$iEndY = $aWinPos[1] + 80

						$sErrorImageName = "SCRIPTERROR_CR"

				EndSwitch

				;debug($iStartX, $iStartY, $iEndX, $iEndY)

				if $bScriptError = False then $bScriptError = CheckResourceImage($sErrorImageName, $iStartX, $iStartY, $iEndX, $iEndY, 0, $x, $y)

			case else
				writeDebugTimeLog("��ũ��Ʈ ���� Skip")

		EndSwitch

	endif

	writeDebugTimeLog("��ũ��Ʈ ���� Ȯ�� ����")

	if $bScriptError = True then
		$_runErrorMsg = "������ �ڹٽ�ũ��Ʈ �����߻�"
		captureCurrentBorwser($_runErrorMsg, True)
		if $sBrowserType = $_sBrowserIE and  WinExists($sIEErrorMsgboxinfo) Then WinClose($sIEErrorMsgboxinfo)
	endif

	$_runLastScriptErrorCheck = $bScriptError



	return $bScriptError

endfunc


func getTransparentImageAndColor($sFile)

	local $iColor = ""

	if StringInStr($sFile,$_sTransparentKey) <> 0 then  $iColor = getTransparentImageColor($sFile)

	return $iColor

endfunc


func CheckResourceImage($sImageName, $iStartX, $iStartY, $iEndX, $iEndY, $iTimeOut, byref $x, byref $y)

	local $aResourceImage [1]

	local $aRetPos
	local $i
	local $bFound = False
	local $iTimeInit = _TimerInit()
	local $iCurTolerance
	local $bCRCCheck
	local $iTransparentColor


	$x = 0
	$y = 0

	if IsHWnd($_hBrowser) and WinExists($_hBrowser) then

		foundImageFile ($_runResourcePath, $sImageName, $aResourceImage)

		;writeDebugTimeLog("$aResourceImage ubound : " & ubound($aResourceImage))

		if ubound($aResourceImage) < 2 or $aResourceImage = "" then
			_StringAddNewLine($_runErrorMsg , "�ý��� �ʼ� �̹��� ������ ���� ���� �ʽ��ϴ�. " & $_runResourcePath & "\" & $sImageName & "*" & $_cImageExt)
			_StringAddNewLine($_runErrorMsg , "���α׷��� ��ġ�� GUITAR\BIN ������ �ֽŹ������� ������Ʈ �� �� ����Ͻñ� �ٶ��ϴ�.")
			return $bFound
		endif

		;msg($aScriptErrorImage)

		$iCurTolerance = int($_runTolerance / 10)

		do

			for $i= 1 to ubound($aResourceImage) -1

				$iTransparentColor = getTransparentImageAndColor ($aResourceImage[$i])
				if _ImageSearchArea2($aResourceImage[$i],1, $iStartX, $iStartY, $iEndX, $iEndY, $x, $y, $iCurTolerance, $aRetPos, False, $bCRCCheck, $iTransparentColor ) = 1 then $bFound = True
				if $bFound then exitloop
				;debug(checkScriptStopping())
			next

			$iCurTolerance += $iCurTolerance
			if $iCurTolerance > $_runTolerance then $iCurTolerance = $_runTolerance

			if $iTimeOut > 0 then runsleep(100)
			;debug(_TimerDiff($iTimeInit)  , $iTimeOut )

		until (_TimerDiff($iTimeInit)  > $iTimeOut or $bFound ) or $bFound or checkScriptStopping() = True

	endif

	;msg(checkScriptStopping())

	return $bFound

endfunc


Func RunSleep($iTime)

	local $iTimeDiff
	local $iTimeUnit = 10

	$iTimeDiff = _Timerinit()

	do
		;_waitFormMain()
		if $iTime > $iTimeUnit then
			sleep($iTimeUnit)
		Else
			sleep($iTime)
		endif

		_ViewRuntimeToolTip()

	;debug(_TimerDiff($iTimeDiff) , $iTime)
	until _TimerDiff($iTimeDiff) > $iTime or checkScriptStopping()

endfunc

Func SendSleep($sKey, $iTime = 10)
; ��ɾ �����ϰ� �⺻���� ��
	Send($sKey)
	RunSleep($iTime)
endfunc

func getRunCommnadImageAndSearchTarget ($sScriptTarget, byref $aImageFile,  byref $x , byref $y, $bWait, $iTimeOut, byref $bFileNotFoundError, $isFullSearch = False)

	local $bResult = False
	local $aImageList[2]
	local $a
	local $bAllSearch, $bAllSearchImage
	local $aSearchResult[1][10][6]
	local $i
	local $j
	local $aRetPos
	local $aImageRoad [1]
	local $sPositionImage
	local $aWinPos
	local $oTag = ""
	local $aTemprunAreaWork = $_runAreaWork
	local $aMaxImageInfo
	local $bMultiFastSearch, $bMultiFastSearchCount
	local $iFastTimeOut
	local $bVerify
	local $sSearchType,  $sSearchValue, $sSearchResultID
	local $tTimeInitAll

	$bFileNotFoundError = False
	$aImageFile = $aImageRoad
	$bMultiFastSearchCount = 0

	;debug ($aImageList)
	;debug($bWait)

	; TAG ����� ��� ","�� ������ �ʰ� �ϳ��� ó����
	if getIEObjectType($sScriptTarget) = False and isWebdriverParam ($sScriptTarget) = False then
		$aImageList = StringSplit($sScriptTarget,",")
	else
		$aImageList[1] = $sScriptTarget
	endif

	if $_runWebdriver = False and isWebdriverParam ($sScriptTarget) = True then
		_StringAddNewLine ( $_runErrorMsg , "Webdriver ���Ǹ�尡 �ƴմϴ�. Webdriver ���� ����� '���ǻ���' ��� ����� ����Ͻñ� �ٶ��ϴ�. " & $sScriptTarget)
		return False
	endif


	if ubound($aImageList) >  2 then
		; ���� �̹��� Ȯ���� ��� 0.5�� ����� �˻��ϵ��� ��(��� �̹����� �ε�� �� ���� ��ٸ�)
		$bAllSearch = True
		$bMultiFastSearch = True

		; ��ü �̹����߿� ����ū �̵̹��� ������ �̸� ������
		$aMaxImageInfo = getMaxSizeFormImageList($aImageList)

		;msg($aMaxImageInfo)
	Else
		$bAllSearch = False
	endif

	do
		$bMultiFastSearchCount +=1

		if $bMultiFastSearchCount > 1  then
			$bMultiFastSearch = False
		endif

		$iFastTimeOut = $iTimeOut

		if $bAllSearch then
			redim $aSearchResult[1][10][6]
			redim $aSearchResult[ubound($aImageList)][1000][6]
		endif

		for $i=1 to ubound($aImageList) -1

			$aImageList[$i] = _Trim($aImageList[$i])

			if $i = ubound($aImageList) -1 then $sPositionImage = $aImageList[$i]

			if getIEObjectType($aImageList[$i]) = False and isWebdriverParam ($aImageList[$i]) = False then
				; �̹��� ��� ���

				writeDebugTimeLog("�̹��� �о� ����" )
				if getRunCommnadImage($aImageList[$i], $aImageFile) = False  then
					$bFileNotFoundError = True
					$bResult = False
				else
					writeDebugTimeLog("�̹��� �о� ���� �Ϸ�")
					;if $i > 1 then $iTimeOut = 1

					; 2�� �̻� ���� �̹��� ã�� �϶� ã���� �ϴ� ������ �ּ�ȭ ��.
					if $i > 1 then $_runAreaWork = getMultiSearchArea ($aSearchResult, $aMaxImageInfo, $i, $_runMultiImageRange)

					; ����ã�� �̸鼭 2��° �̻��� ��� timeout�� 1�ʷ� ������ (ù��° �̹����� ã�������� ���� ����)
					if $bMultiFastSearch then $iFastTimeOut = 500

					; ���� �˻��̸鼭 ù��° �̹��� �˻��� ��� ������ ���� �˻��Ұ�
					if $i = 1  and  $bMultiFastSearch then
						$bAllSearchImage = False
						$iFastTimeOut = $iTimeOut
					else
						$bAllSearchImage = $bAllSearch
					endif

					$bVerify = not(checkTargetisBrowser($_runBrowser) and $_runVerifyTime <> 0)

					;debug($i, $_hBrowser)
					;debug($aImageFile)

					if SearchTargetVerify($_hBrowser, $aImageFile , $x , $y, $bWait, $iFastTimeOut, $bAllSearchImage, $aRetPos, $isFullSearch, $bVerify) = False then

						$bResult = False
						;debug ("ã�� ����")
						;debug ($aImageFile)

						if ($bWait = True and checkScriptStopping() = False)  then
							; ���� ã�Ⱑ �ƴ� ��쿡�� ������ �����.
							if $bMultiFastSearch = False then $_runErrorMsg = setImageSearchError ($aImageList[$i], $aImageFile)
						endif

						if $bAllSearch then _StringAddNewLine ( $_runErrorMsg ,"�̹������� ���� �����Ѱ��� ���� �ʽ��ϴ� : "  & $sScriptTarget)

						exitloop

					Else

						;debug ("ã��")
						;debug ($aImageFile)


						if $bAllSearch then
							writeDebugTimeLog("���� �ǽɱ���1")
							;debug($x)

							; ���� ����� ���� ���
							if IsArray($x) then

								for $j= 1 to ubound($x) -1
									$aSearchResult[$i][$j][1] = $x[$j]
									$aSearchResult[$i][$j][2] = $y[$j]
									$aSearchResult[$i][$j][3] = $aRetPos[4]
									$aSearchResult[$i][$j][4] = $aRetPos[5]
									$aSearchResult[$i][$j][5] = $aImageList[$i]
								next
								writeDebugTimeLog("���� �ǽɱ���2")
							else
								$aSearchResult[$i][1][1] = $aRetPos[2]
								$aSearchResult[$i][1][2] = $aRetPos[3]
								$aSearchResult[$i][1][3] = $aRetPos[4]
								$aSearchResult[$i][1][4] = $aRetPos[5]
								$aSearchResult[$i][1][5] = $aImageList[$i]
							endif

						endif

						$bResult = True
					endif
				endif

			elseif  getIEObjectType($aImageList[$i]) = True then
			; TAG ��� ã��

				; IE Object ��� ���
				; ���� �������� IE�� �ƴ� ��� ���� ó��
				if $_runBrowser = $_sBrowserIE then

					$bResult = SearchIEObjectTarget($_hBrowser,$aImageList[$i], $x, $y, $aRetPos, $oTag, $bWait , $iTimeOut)

					if $bResult  = False then
						if ($bWait = True and checkScriptStopping() = False)  then
							if IsArray($aRetPos) then
								_StringAddNewLine ( $_runErrorMsg ,$aRetPos[0] & " : "  & $aImageList[$i])
								captureCurrentBorwser($_runErrorMsg, False)
							endif
						endif
					else
						;��ǥ 0�� �迭�� ã�� Tag�� ������.
						$aImageFile = $aImageRoad
						_ArrayAdd($aImageFile, $oTag)
					endif

				else
					_StringAddNewLine ( $_runErrorMsg ,"IE ������������ Tag������� ����� ���� �� �� �ֽ��ϴ�.")
				endif
			elseif  isWebdriverParam ($aImageList[$i]) = True then
			; WEBDriver ��� ã��
				$tTimeInitAll = _TimerInit()

				if getWebdriverParamTypeAndValue($aImageList[$i],  $sSearchType,  $sSearchValue) then
					do
						setStatusText (getTargetSearchRemainTimeStatusText($tTimeInitAll, $iTimeOut, $aImageList[$i]))
						$sSearchResultID = _WD_find_element_with_highlight_by($sSearchType, $sSearchValue, $_runRetryRun , $_runHighlightDelay)
						if $sSearchResultID = "" then RunSleep (500)
					until $sSearchResultID <> "" or (_TimerDiff($tTimeInitAll) > $iTimeOut) or (checkScriptStopping())

					if $sSearchResultID <> "" then
						$bResult = True
						$x = $sSearchResultID
						; X���� �˻��� ID���� ����
					else
						if checkScriptStopping() = False then WriteGuitarWebDriverError ()
					endif
				else
					_StringAddNewLine ( $_runErrorMsg , "Webdriver �׽�Ʈ �Է������� �ٸ��� �ʽ��ϴ�. {�˻����:�˻�����}")
				endif

			endif

		next


		if $bResult and IsArray($aRetPos) then
			; �ֽ� ��� �̹��� ũ��

			$aRetPos[1] = $aRetPos[2]
			$aRetPos[2] = $aRetPos[3]
			$aRetPos[3] = $aRetPos[1] + $aRetPos[4]
			$aRetPos[4] = $aRetPos[2] + $aRetPos[5]

		endif

		;debug($aSearchResult)

		writeDebugTimeLog("�̹��� �о� ���� �Ϸ� 2�� ")

		if $bAllSearch and $bResult then
			$bResult = selectMultiImage($aSearchResult, $aImageRoad, $x, $y, $_runMultiImageRange, $sPositionImage, $aRetPos)
			if $bResult = False and $bMultiFastSearch = False then
				if $_runErrorMsg  = "" then
					$_runErrorMsg = "�̹������� ���� �����Ѱ��� ���� �ʽ��ϴ� : "  & $sScriptTarget
					;debug($_runErrorMsg)
					captureCurrentBorwser($_runErrorMsg, False)

				endif
			endif

		endif

		writeDebugTimeLog("�̹��� �о� ���� �Ϸ� 3�� " )

		if $bResult = True then

			$aWinPos = WinGetPos($_hBrowser)

			if IsArray($aWinPos) then
				$_aLastUseMousePos[1] = $x - $aWinPos[0]
				$_aLastUseMousePos[2] = $y  - $aWinPos[1]
			endif


			if IsArray($aRetPos) then
				$_aLastUseMousePos[3] = ""
				$_aLastUseMousePos[3] = $_aLastUseMousePos[3] & ($aRetPos[1] - $aWinPos[0]) & ","
				$_aLastUseMousePos[3] = $_aLastUseMousePos[3] & ($aRetPos[2] - $aWinPos[1]) & ","
				$_aLastUseMousePos[3] = $_aLastUseMousePos[3] & ($aRetPos[3] - $aWinPos[0]) & ","
				$_aLastUseMousePos[3] = $_aLastUseMousePos[3] & ($aRetPos[4] - $aWinPos[1])
			endif

		endif

		$_runAreaWork = $aTemprunAreaWork

		; ��õ��� ���� ������ ���� ������ �ʱ�ȭ ��.
		if $bMultiFastSearch and $bResult = False then
			$_runErrorMsg = ""
		endif

	until $bMultiFastSearch = False or $bResult = True or checkScriptStopping() = True

	return $bResult

endfunc


func getMaxSizeFormImageList(byref $aImageList)

	local $aImageFile, $i, $j
	local $aImageInfo, $iImageWidth, $iImageHeight
	local $aImageFile
	local $aMaxImageInfo[ubound($aImageList)][3]

	for $i=1 to ubound($aImageList) -1

		$aMaxImageInfo[$i][1] = 0
		$aMaxImageInfo[$i][2] = 0

		getRunCommnadImage(_Trim($aImageList[$i]), $aImageFile, False)
		;debug($aImageList[$i])
		;debug($aImageFile)

		for $j=1 to ubound($aImageFile) -1
			; �̹��� ���� ũ�� Ȯ��

			;debug("�̹��� Ȯ�� : " & $aImageFile[$j])
			getImageSize($aImageFile[$j], $iImageWidth, $iImageHeight)

			if $aMaxImageInfo[$i][1] < $iImageWidth then $aMaxImageInfo[$i][1] = $iImageWidth
			if $aMaxImageInfo[$i][2] < $iImageHeight then $aMaxImageInfo[$i][2] = $iImageHeight

		next

	next


	return $aMaxImageInfo

endfunc


func getMultiSearchArea(byref $aSearchResult, byref $aMaxImageInfo, $iCurrentImageIndex, $iAddBoder)

	local $aRetArea[6]
	local $i
	local $iMax = 999999
	local $iLeft=$iMax , $iTop=$iMax, $iBottom=$iMax * (-1), $iRight=$iMax * (-1)

	;msg($aSearchResult)
	; 1���� ��������� ��ü ������ ���� �������� ���ϱ� (����, ������, ��, �Ʒ�)
	for $i=1 to $iCurrentImageIndex -1

		for $j= 1 to ubound($aSearchResult,2) -1

			;writeDebugTimeLog("���� ���� ���� " & $j & " " & $aSearchResult[$i][$j][1])

			if $aSearchResult[$i][$j][1] = "" then ExitLoop

			if $iLeft > $aSearchResult[$i][$j][1] then $iLeft = $aSearchResult[$i][$j][1]
			if $iTop > $aSearchResult[$i][$j][2] then $iTop = $aSearchResult[$i][$j][2]

			if $iRight  < $aSearchResult[$i][$j][1] + $aSearchResult[$i][$j][3] then $iRight = $aSearchResult[$i][$j][1] + $aSearchResult[$i][$j][3]
			if $iBottom < $aSearchResult[$i][$j][2] + $aSearchResult[$i][$j][4] then $iBottom = $aSearchResult[$i][$j][2] + $aSearchResult[$i][$j][4]

			;debug($aSearchResult[$i][$j][1], $aSearchResult[$i][$j][2], $aSearchResult[$i][$j][3], $aSearchResult[$i][$j][4])

		next
	next


	;debug("����1 :" & $iLeft, $iTop, $iRight, $iBottom)

	for $i= $iCurrentImageIndex to ubound($aMaxImageInfo) -1
		;debug("�������� : " & $aMaxImageInfo[$i][1], $aMaxImageInfo[$i][2])
		$iLeft = $iLeft - $aMaxImageInfo[$i][1] - $iAddBoder
		$iRight += $aMaxImageInfo[$i][1] + $iAddBoder

		$iTop = $iTop - $aMaxImageInfo[$i][2] - $iAddBoder
		$iBottom += $aMaxImageInfo[$i][2] + $iAddBoder

	next

	;debug("����2 :" & $iLeft, $iTop, $iRight, $iBottom)
	; ���� �ִ� �̹������߿� �̹����� ���� ���� ū������ ã�Ƽ� �׵��� �� �� ����

	; �ӽ÷� $_runAreaWork ���� �����Ͽ� �����
	$aRetArea[0] = _iif($iLeft=$iMax, False, True)
	$aRetArea[1] = $iLeft
	$aRetArea[2] = $iTop
	$aRetArea[3] = $iRight
	$aRetArea[4] = $iBottom

	; ��ǥ ���� ���� ��ǥ�� ���
	$aRetArea[5] = False


	return $aRetArea

endfunc


func selectMultiImage(byref $aSearchResult, byref $aImageRoad, byref  $x,byref  $y, $iAddBoder, $sPositionImage, byref $aRetPos)

	local $i, $j
	local $bFound = False

	if ubound($aImageRoad) <> ubound($aSearchResult) then
		redim $aImageRoad [ubound($aSearchResult)]
	endif

	;debug($aSearchResult)

	for $i=1 to ubound($aSearchResult,2) -1

		for $j=1 to ubound($aSearchResult) -1
			$aImageRoad[$j] = ""
		next

		$aImageRoad[1] = $i

		selectMultiImageRec($aSearchResult, $aImageRoad, $iAddBoder)

		$bFound = checkMultiImageAllFound($aImageRoad)

		;debug($aSearchResult)

		if $bFound then exitloop

	next

	if $bFound then getMultiImagePos($aSearchResult, $aImageRoad, $x, $y , $sPositionImage, $aRetPos)

	return $bFound

endfunc

func selectMultiImageRec(byref $aSearchResult, byref $aImageRoad,  $iAddBoder)

	local $i, $j, $k
	local $bFound = False
	local $iUp
	local $iDown
	local $iLeft
	local $iRight
	local $iSearchIndex
	local $bWidthCompare
	local $bHeightCompare
	local $iBaseLeft, $iBaseRight, $iBaseUp, $iBaseDown
	local $iTargetLeft, $iTargetRight, $iTargetUp, $iTargetDown
	local $bCompareLeft
	local $iMax
	local $iMin
	local $bExistFound

	for $i=1 to ubound($aSearchResult) -1

		if $aImageRoad[$i] <> "" then ContinueLoop

		for $j=1 to ubound($aSearchResult,2) -1

			if $aSearchResult[$i][$j][1] = "" then exitloop

			;$bExistFound = False

			;for $k = 1 to ubound($aImageRoad)  -1
			;	if $k = $j then $bExistFound = True
			;next

			if $bExistFound then ContinueLoop

			for $iSearchIndex =1 to ubound($aImageRoad)  -1

				$bWidthCompare = False
				$bHeightCompare = False

				if $aImageRoad[$iSearchIndex] = "" or $iSearchIndex = $i then ContinueLoop

				$iBaseLeft = $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1]
				$iBaseUp = $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2]
				$iBaseRight = $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1] + $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3]
				$iBaseDown = $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2] + $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][4]

				$iTargetLeft = $aSearchResult[$i][$j][1]
				$iTargetUp = $aSearchResult[$i][$j][2]
				$iTargetRight = $aSearchResult[$i][$j][1] + $aSearchResult[$i][$j][3]
				$iTargetDown = $aSearchResult[$i][$j][2] + $aSearchResult[$i][$j][4]

				;debug("Base Left,Right: " & $iBaseLeft, $iBaseRight )
				;debug("Target Left, Right: " & $iTargetLeft, $iTargetRight)
				;debug(($iTargetLeft > $iBaseLeft) , ($iTargetRight > $iBaseRight) , ($iTargetLeft - $iBaseRight))

				; ��, �� ��


				;debug("Base : " & $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][5] & " "  & $aImageRoad & " " & $iSearchIndex)
				;debug("Target : " & $aSearchResult[$i][$j][5]&  " " & $i & " " & $j)

				;debug("Base Left, Right : " & $iBaseLeft, $iBaseRight)
				;debug("Base Up,Down : " & $iBaseUp, $iBaseDown)
				;debug("Target Left, Right: " & $iTargetLeft, $iTargetRight)
				;debug("Target Up, Down: " & $iTargetUp, $iTargetDown)


				if     (($iTargetLeft < $iBaseLeft) and ($iTargetRight < $iBaseRight) and ($iBaseLeft - $iTargetRight < $iAddBoder) ) _
				   or  (($iTargetLeft > $iBaseLeft) and ($iTargetRight > $iBaseRight) and ($iTargetLeft - $iBaseRight < $iAddBoder) ) then
					; ���̰� ������ ��� 50%�̻��� ���Ե� ��� ����
					if _Max($iTargetDown ,$iBaseDown) - _min($iTargetUp ,$iBaseUp) < $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][4] +  $aSearchResult[$i][$j][4] - (_min($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][4] ,  $aSearchResult[$i][$j][4]) / 2)  then

						$bWidthCompare= True
					endif
					;debug("Width Compare : " & $aSearchResult[$i][$j][5] & " " & $bWidthCompare &  " " & $i & " " & $j)

				endif

				; ��, �� ��
				if     (($iTargetUp < $iBaseUp) and ($iTargetDown < $iBaseDown) and ($iBaseUp - $iTargetDown < $iAddBoder) ) _
				   or  (($iTargetUp > $iBaseUp) and ($iTargetDown > $iBaseDown) and ($iTargetUp - $iBaseDown < $iAddBoder) ) then

					; ���̰��� ������ ��� 50%�̻��� ���Ե� ��� ����
					if _Max($iTargetRight ,$iBaseRight) - _min($iTargetLeft ,$iBaseLeft) < $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3] +  $aSearchResult[$i][$j][3] - (_min($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3] , $aSearchResult[$i][$j][3]) / 2 )    then
						;debug ( "$iTargetRight =" & $iTargetRight)
						;debug ( "$iBaseRight =" & $iBaseRight)
						;debug ( "$iTargetLeft =" & $iBaseLeft)
						;debug ( "$iBaseLeft =" & $iBaseLeft)
						;debug ( "max - min =" & _Max($iTargetRight ,$iBaseRight) - _min($iTargetLeft ,$iBaseLeft))


						;debug ( "base width  =" & $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3])
						;debug ( "target width  =" & $aSearchResult[$i][$j][3])
						;debug ( "- 1/2  =" & _min($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3] , $aSearchResult[$i][$j][3]) / 2 )
						;debug ( "- 1/2  =" & _min(number($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3]) , number($aSearchResult[$i][$j][3])))

						;debug ( $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3] +  $aSearchResult[$i][$j][3] - (_min($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3] , $aSearchResult[$i][$j][3]) / 2 )  )

						$bHeightCompare = True
					endif
					;debug("Height Compare : " & $aSearchResult[$i][$j][5] & " " & $bHeightCompare &  " " & $i & " " & $j)

				endif

;~ 				; ������, �Ʒ� ����
;~ 				$iLeft = ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1]) - ($aSearchResult[$i][$j][1] + $aSearchResult[$i][$j][3])
;~ 				$iRight = $aSearchResult[$i][$j][1] - ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1] + $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][3])
;~ 				$iUp = ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2]) - ($aSearchResult[$i][$j][2] + $aSearchResult[$i][$j][4])
;~ 				$iDown =  $aSearchResult[$i][$j][2]  - ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2] + $aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][4])

;~ 				$bWidthCompare = ($iLeft < $iAddBoder and $iLeft > 0 - $iAddBoder) or ($iRight < $iAddBoder and $iRight > 0 - $iAddBoder)
;~ 				$bHeightCompare = ($iUp < $iAddBoder and $iUp > 0 - $iAddBoder)  or ($iDown < $iAddBoder and $iDown > 0 - $iAddBoder)

;~ 				; ����, �� ����
;~ 				$iLeft = ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1]) - ($aSearchResult[$i][$j][1])
;~ 				$iRight = $aSearchResult[$i][$j][1] - ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][1])
;~ 				$iUp = ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2]) - ($aSearchResult[$i][$j][2] )
;~ 				$iDown =  $aSearchResult[$i][$j][2]  - ($aSearchResult[$iSearchIndex][$aImageRoad[$iSearchIndex]][2])

;~ 				$bWidthCompare = $bWidthCompare  or  ($iLeft < $iAddBoder and $iLeft > 0 - $iAddBoder) or ($iRight < $iAddBoder and $iRight > 0 - $iAddBoder)
;~ 				$bHeightCompare =$bHeightCompare or ($iUp < $iAddBoder and $iUp > 0 - $iAddBoder)  or ($iDown < $iAddBoder and $iDown > 0 - $iAddBoder)


				if $bWidthCompare or  $bHeightCompare  then

					$bFound = True

					$aImageRoad [$i] = $j

					;debug("add : " & $aSearchResult[$i][$j][5] )

					;debug($aImageRoad)
					;debug($iLeft, $iRight,$iUp,  $iDown)

					selectMultiImageRec($aSearchResult, $aImageRoad,  $iAddBoder)

					exitloop

				endif
			next

			$bFound = checkMultiImageAllFound($aImageRoad)

			if $bFound then exitloop
			$aImageRoad[$i] = ""

		next

		$bFound = checkMultiImageAllFound($aImageRoad)
		if $bFound then exitloop

	next

endfunc

func checkMultiImageAllFound(byref $aImageRoad)

	local $j
	local $bFound = True

	for $j=1 to ubound($aImageRoad) -1
		if $aImageRoad[$j] = "" then  $bFound = False
	next

	return $bFound

endfunc


func getMultiImagePos(byref $aSearchResult, $aImageRoad, byref  $x,byref  $y, $sPositionImage, byref $aRetPos)

	local $i
	local $iMaxLeft = 100000000
	local $iMaxTop =  100000000
	local $iMaxRight = -100000000
	local $iMaxBottom = -10000000
	local $aImagePos[5]

	for $i = 1 to ubound($aImageRoad) -1
		;debug($aSearchResult[$i][$aImageRoad[$i]][5], $aSearchResult[$i][$aImageRoad[$i]][1], $aSearchResult[$i][$aImageRoad[$i]][2])

		if  $aSearchResult[$i][$aImageRoad[$i]][5] = $sPositionImage then
			;msg($sPositionImage)
			if $aSearchResult[$i][$aImageRoad[$i]][1] < $iMaxLeft then $iMaxLeft = $aSearchResult[$i][$aImageRoad[$i]][1]
			if $aSearchResult[$i][$aImageRoad[$i]][2] < $iMaxTop then $iMaxTop = $aSearchResult[$i][$aImageRoad[$i]][2]

			if $aSearchResult[$i][$aImageRoad[$i]][1] + $aSearchResult[$i][$aImageRoad[$i]][3] > $iMaxRight then $iMaxRight = $aSearchResult[$i][$aImageRoad[$i]][1] + $aSearchResult[$i][$aImageRoad[$i]][3]
			if $aSearchResult[$i][$aImageRoad[$i]][2] + $aSearchResult[$i][$aImageRoad[$i]][4]  > $iMaxBottom then $iMaxBottom = $aSearchResult[$i][$aImageRoad[$i]][2] + $aSearchResult[$i][$aImageRoad[$i]][4]
		endif

	next

	$x = int($iMaxLeft + (($iMaxRight - $iMaxLeft) /2))
	$y = int($iMaxTop + (($iMaxBottom - $iMaxTop) /2))
	;debug("Left : " & $iMaxLeft)
	;debug("Top : " & $iMaxTop)
	;debug("Right : " & $iMaxRight)
	;debug("Bottom : " & $iMaxBottom)


	$aImagePos[1] = $iMaxLeft
	$aImagePos[2] = $iMaxTop
	$aImagePos[3] = $iMaxRight
	$aImagePos[4] = $iMaxBottom

	$aRetPos = $aImagePos
endfunc


Func SearchIEObjectTarget($hBrowser, $sTarget,byref $x, byref $y, byref $aRetPos, byref $oTag, $bLoopSearch, $iTimeOut)

	local $sTempBrowser
	local $oMyError
	local $bIESearch
	local $bResult = False
	local $aIEObjectInfo
	local $aRetIEPos [6]

	local $tTimeInitAll

	local $iOldStyleWidth
	local $iOldStyleStyle
	local $iOldStyleColor


	$oTag = ""
	$tTimeInitAll = _TimerInit()

	do


		seterror(0)
		$oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")
		$sTempBrowser = _IEAttach2($hBrowser,"HWND")

		if _IEPropertyGet ($sTempBrowser, "hwnd") <> $hBrowser then
			_StringAddNewLine ( $_runErrorMsg , "IE ������������ Object������� ����� �����մϴ�. : "  & $sTarget)
			return False
		endif

		setStatusText (getTargetSearchRemainTimeStatusText($tTimeInitAll, $iTimeOut, $sTarget))
		$bIESearch = IEObjectSearch($sTempBrowser, getIEObjectCondtion($sTarget),True, $aIEObjectInfo)

		$oMyError = ObjEvent("AutoIt.Error")

		if $bIESearch then

			$bResult = True
			$x = $aIEObjectInfo[2]
			$y = $aIEObjectInfo[3]

			; imageSeatch���� return �Ǵ� ��� �״�� Ȱ���ϱ� ���� �迭 ��ġ�� ����
			$aRetIEPos[2] = $aIEObjectInfo[4]
			$aRetIEPos[3] = $aIEObjectInfo[5]
			$aRetIEPos[4] = $aIEObjectInfo[6] - $aIEObjectInfo[4]
			$aRetIEPos[5] = $aIEObjectInfo[7] - $aIEObjectInfo[5]

			$aRetPos = $aRetIEPos
			$oTag = $aIEObjectInfo[1]

			; �κн����ΰ�� ������ ��带 �߰� �� ��
			if $_runRetryRun = True and $_runHighlightDelay > 0  then

				$iOldStyleWidth = $aIEObjectInfo[1].style.borderWidth
				$iOldStyleStyle = $aIEObjectInfo[1].style.borderStyle
				$iOldStyleColor = $aIEObjectInfo[1].style.borderColor

				if $iOldStyleWidth = "0" then $iOldStyleWidth = ""
				if $iOldStyleStyle = "0" then $iOldStyleStyle = ""
				if $iOldStyleColor = "0" then $iOldStyleColor = ""

				$aIEObjectInfo[1].style.borderWidth = "2"
				$aIEObjectInfo[1].style.borderStyle = "solid"
				$aIEObjectInfo[1].style.borderColor  = "red"

				sleep($_runHighlightDelay)

				$aIEObjectInfo[1].style.borderWidth = $iOldStyleWidth
				$aIEObjectInfo[1].style.borderStyle = $iOldStyleStyle
				$aIEObjectInfo[1].style.borderColor  = $iOldStyleColor

			endif
		else
			$aRetIEPos[0] = $aIEObjectInfo[0]
			$aRetPos = $aRetIEPos

		endif

		sleep (500)

	until ($bResult = True) or ((_TimerDiff($tTimeInitAll) > $iTimeOut or $bLoopSearch = False)) or (checkScriptStopping())

	return $bResult

endfunc


Func SearchTargetVerify($hWindow, $sFile, byref $x, byref $y, $bLoopSearch, $iTimeOut, $bAllSearch, Byref $aRetPos, $bFullSearch, $bVerify)

	; ����� ��� ������� �õ��� (Ư���ð� ���� �˻��� ������ ����� ������ pass)

	local $bResult = False
	local $iLastX, $iLastY, $i
	local $aLastWorkArea
	local $bNewSearch = False
	local $iNewTimeOut


	$bResult = SearchTarget($hWindow, $sFile,  $x,  $y, $bLoopSearch, $iTimeOut, $bAllSearch,  $aRetPos, $bFullSearch)

	if $bVerify = False or $bResult = False or IsArray($x) then return $bResult

	$aLastWorkArea = $_runAreaWork

	for $i=1 to 5

		$_runAreaWork[0] = True
		$_runAreaWork[1] = $aRetPos[2]
		$_runAreaWork[2] = $aRetPos[3]
		$_runAreaWork[3] = $aRetPos[2] + $aRetPos[4]
		$_runAreaWork[4] = $aRetPos[3] + $aRetPos[5]

		$iLastX = $x
		$iLastY = $y

		$iNewTimeOut = 500

		if $bNewSearch then
			$_runAreaWork[0] = False
			$bNewSearch = False
			$iNewTimeOut = $iTimeOut
		endif

		; ini ������ �ð���ŭ ����ϰ� �̹��� �����
		sleep($_runVerifyTime)

		;debug ("��Ȯ�� " & $i)
		;debug($_runAreaWork)
		if $i > 1 then writeDebugTimeLog("�̹��� ��Ȯ�� Count  : "  & $i)

		$bResult  = SearchTarget($hWindow, $sFile,  $x,  $y, $bLoopSearch, $iNewTimeOut, $bAllSearch,  $aRetPos, $bFullSearch)

		if ($bResult = True and $iLastX = $x and $iLastY = $y) or IsArray($x) then exitloop

		$bNewSearch = True

	next




	$_runAreaWork = $aLastWorkArea

	return $bResult

endfunc


Func SearchTarget($hWindow, $sFile, byref $x, byref $y, $bLoopSearch, $iTimeOut, $bAllSearch, Byref $aRetPos, $bFullSearch)
; �̹��� ã��

	local $bResult = False
	local $tTimeInitAll
	local $tTimeInitUnit
	local $aWinPos, $aWinPosOrg
	local $aMousePos
	local $sImageFiles[1]
	local $bImageFound = False
	local $iRemainTime
	local $iRetryCount
	local $sTempPos
	local $aImageRangeXY
	local $aSearchPos [4]
	local $aSearchNewPos [4]
	local $iSearchCount = 0
	local $iMouseMoveCount = 0
	local $iMouseMoveSleepTimer
	local $iTolerance
	local $iLoopCount
	local $iBaseTolerance
	local $bCRCCheck
	local $aImageTolerance[1]
	local $aFullScreenPos
	local $iTransparentColor

	if IsHWnd($hWindow) = 0  then
		$_runErrorMsg = "��� �� ������ â�� ���� ���� �ʽ��ϴ�.  Window Handle : " & $hWindow
		return
	endif

	if IsArray($sFile) = False then
		redim $sImageFiles[2]
		$sImageFiles[1]  = $sFile
	Else
		$sImageFiles = $sFile
	endif

	;msg($sImageFiles)
	for $i=1 to ubound($sImageFiles) -1
		if FileExists($sImageFiles[$i]) = 0 then
			return False
		endif
		;debug("�̹��� ã�� : " & $sImageFiles[$i])
	next


	$iBaseTolerance = 30

	;$iBaseTolerance = $iBaseTolerance  + int(($_runTolerance - $iBaseTolerance) / 2)
	;debug($_runTolerance, $iBaseTolerance )

	if $iBaseTolerance  >  $_runTolerance then  $iBaseTolerance = $_runTolerance

	$iTolerance = $iBaseTolerance

	$tTimeInitAll = _TimerInit()
	$aWinPos = WinGetPos($hWindow)
	$aWinPosOrg = $aWinPos
	$aMousePos = MouseGetPos()
	$iRetryCount = 0

	; ��ü����۾����� ������ ��� �˻� ��ġ�� ȭ�� ��ü�� ��.
	if $_runFullScreenWork then

		$aFullScreenPos = GetAareFromPoint($aWinPos[0] + ($aWinPos[2]/2) ,$aWinPos[1]  + ($aWinPos[3]/2))

		$aWinPos[0] = $aFullScreenPos[1]
		$aWinPos[1] = $aFullScreenPos[2]
		$aWinPos[2] = $aFullScreenPos[3]
		$aWinPos[3] = $aFullScreenPos[4]

		;debug("��ü ��ũ��ũ�� ����")
		;debug($aWinPos)

	endif

	if $_runAreaWork[0] = True then

		; ���� ������ ũ�⿡ �����ǥ�� �߰���
		if $_runAreaWork[5] = True then
			$aWinPos[0] = $aWinPos[0] + $_runAreaWork[1]
			$aWinPos[1] = $aWinPos[1] + $_runAreaWork[2]
			$aWinPos[2] = $_runAreaWork[3] - $_runAreaWork[1]
			$aWinPos[3] = $_runAreaWork[4] - $_runAreaWork[2]
		else
			$aWinPos[0] = $_runAreaWork[1]
			$aWinPos[1] = $_runAreaWork[2]

			; ������ ���� ū ��� ������ ũ�⸸���� ����
			if $aWinPos[0] < $aWinPosOrg[0] then $aWinPos[0] = $aWinPosOrg[0]
			if $aWinPos[1] < $aWinPosOrg[1] then $aWinPos[1] = $aWinPosOrg[1]

			$aWinPos[2] = $_runAreaWork[3] - $aWinPos[0]
			$aWinPos[3] = $_runAreaWork[4] - $aWinPos[1]

			if $aWinPos[2] > $aWinPosOrg[2] then $aWinPos[2] = $aWinPosOrg[2]
			if $aWinPos[3] > $aWinPosOrg[3] then $aWinPos[3] = $aWinPosOrg[3]


			;debug($aWinPosOrg)
			;debug($_runAreaWork)
			;debug($aWinPos)


		endif

	endif

	$iMouseMoveSleepTimer = _TimerInit()

	writeDebugTimeLog("�̹��� ã�� ���� : ������ ��ġ " & $aWinPos[0] & ", " & $aWinPos[1])

	redim $aImageTolerance[ubound($sImageFiles)]

	do
		$iLoopCount += 1
		;debug (TimerDiff($tTimeInit) , $iTimeOut)
		$tTimeInitUnit = _TimerInit()

		for $i=1 to ubound($sImageFiles) -1

			writeDebugTimeLog("�̹��� �������� " & $i & ", " & $sImageFiles[$i])

			$iRemainTime = int(($iTimeOut - _TimerDiff($tTimeInitAll )) / 1000)
			if $iRemainTime < 0 then $iRemainTime = 0

			;if (int($iTimeOut / 1000) - $iRemainTime) > 5 then  $iTolerance = $_runTolerance

			if $iLoopCount > 1 then

				; 5�� �̳��� �ִ� Tolerance���� �׽�Ʈ ����
				$iTolerance = $iBaseTolerance +  int ((_TimerDiff($tTimeInitAll) / 1000) * ($_runTolerance- $iBaseTolerance))

				;debug("$iTolerance = " &  $iTolerance)
			endif

			if $iTolerance > $_runTolerance or $bFullSearch = True then $iTolerance =  $_runTolerance

			if $iTolerance > $aImageTolerance[$i] then $aImageTolerance[$i] = $iTolerance
			;if $iTolerance > $_runTolerance then $iTolerance =  $_runTolerance


			;setStatusText ("�̹��� �˻��� : " & $sImageFiles[$i] & ", " & $iRemainTime & "�� ����" & @crlf)
			getTargetSearchRemainTimeStatusText($tTimeInitAll, $iTimeOut, $sImageFiles[$i])

			if checkScriptStopping() then Return False

			$aImageRangeXY = getImageRangeXY($sImageFiles[$i])

			$aSearchPos [0] = $aWinPos[0]
			$aSearchPos [1] = $aWinPos[1]
			$aSearchPos [2] = $aWinPos[0] + $aWinPos[2]
			$aSearchPos [3] = $aWinPos[1] + $aWinPos[3]

			;debug ($aSearchPos)


			if IsArray($aImageRangeXY) and $iRemainTime > 5 and $bLoopSearch = True and ($bAllSearch = False) then
				getImageRangeOver($aImageRangeXY, $aSearchNewPos, $aSearchPos, $iSearchCount , $iSearchCount)
				$aSearchPos = $aSearchNewPos
			endif

			; �ִ� ũ���ΰ��
			if $aSearchPos[2] = $aWinPos[0] + $aWinPos[2] and $aSearchPos [3] = $aWinPos[1] + $aWinPos[3] then
				; MAX �� ���
				if $iTolerance = $_runTolerance and $bFullSearch = False  and $bCRCCheck = False  and $aImageTolerance[$i] <  $_runTolerance + 20  then
					$aImageTolerance[$i] = $aImageTolerance[$i] + 2
				endif
			endif

			$iTolerance = $aImageTolerance[$i]

			;debug($aSearchPos)
			writeDebugTimeLog("�̹��� ã�� ���� ��¥ : "  &  " x1=" & $aSearchPos[0]  &  " y1=" & $aSearchPos[1]  &  " x2=" & $aSearchPos[2] &  " y2=" & $aSearchPos[3]  & ", SearchCount : " & $iSearchCount )

			;if WinActive($hWindow) = 0 Then WinActivate($hWindow)
			$iTransparentColor = getTransparentImageAndColor ($sImageFiles[$i])
			if _ImageSearchArea2($sImageFiles[$i],1,$aSearchPos[0],$aSearchPos[1],$aSearchPos[2],$aSearchPos[3], $x, $y, $iTolerance, $aRetPos, $bAllSearch, $bCRCCheck, $iTransparentColor) = 1 then $bImageFound = True
			writeDebugTimeLog("�̹��� ã�� ���� ��¥ ���� ")
			;debug("ã�� ���� : ")
			;debug( $aSearchPos)

			if checkScriptStopping() then exitloop
			if $bImageFound  = True then
				writeDebugTimeLog("�̹��� ã��: " &   " x=" & $x  &  " y=" & $y &  " count=" & ubound($x) &  " tolerance=" &  $iTolerance &   " x�迭=" & ubound($x) )
				writeDebugTimeLog("�̹��� ã�� (��¥): " &   " x=" & $x - $aWinPos[0] &  " y=" & $y - $aWinPos[1]  )
				$bResult =  $bImageFound
				exitloop
			endif
		next

		if $iSearchCount < 1.5 then
			$iSearchCount += 0.3
		elseif $iSearchCount < 4 then
			$iSearchCount += 1
		elseif $iSearchCount < 7 then
			$iSearchCount += 2
		endif

		; 1�ʰ� �Ѿ�� ������ MAX�� �˻��ϵ��� ��
		if _TimerDiff($tTimeInitAll) > 3000 then
			$iSearchCount  = 10
		endif

		if checkScriptStopping() or $bResult = True then exitloop

		do
			RunSleep (50)
		until $bResult or (_TimerDiff($tTimeInitUnit) > 50) or $bLoopSearch = False

		if $_runMouseMoveSleep and _TimerDiff($iMouseMoveSleepTimer) > 1000  then
			$iMouseMoveSleepTimer = _TimerInit()
			$iMouseMoveCount += 1
			;debug("���콺 �̵�")
			MouseMove($aMousePos[0],$aMousePos[1] + mod($iMouseMoveCount, 2))
		endif

	until ($bResult = True) or ((_TimerDiff($tTimeInitAll) > $iTimeOut or $bLoopSearch = False))
	;until $bResult  or (TimerDiff($tTimeInitAll) > $iTimeOut) or $bLoopSearch = False

	writeDebugTimeLog("�̹��� ����� "  & $bResult  & " " & _TimerDiff($tTimeInitAll) & " " &  $iTimeOut & " " &  $bLoopSearch)

	if _TimerDiff($tTimeInitAll) > 3000 then writeDebugTimeLog("����! 3���̻� ����")


	if $bResult  = False and  $bLoopSearch = True and (_TimerDiff($tTimeInitAll) < $iTimeOut) then
		;msg ("�̹��� ����� "  & $bResult  & " " & _TimerDiff($tTimeInitAll) & " " &  $iTimeOut & " " &  $bLoopSearch)
	endif


	return $bResult

endfunc


Func checkScriptStopping()

	checkStopRequest()

	if $_bScriptStopping = true  then
		;debug("����� ���� �ߴ� ��û")
		$_runErrorMsg = "����� ���� �ߴ�"
		Return True
	else
		Return False
	endif

endfunc


Func ScrollMoveAndCheck($bisPgTop, $isCheckEnable = True)
; ��ũ�� ����, �ֻ��� Ȥ�� ������ �Ʒ��� ����, $isCheckEnable = ��ũ�� �� �� ����ȭ��� �������� ���θ� ��

	local $bScrollNotEnd
	local $aWinPos
	local $sScrollBarBefore = @ScriptDir & "\temp_scrollbefore.png"
	local $sScrollBarAfter = @ScriptDir & "\temp_scrollafter.png"

	local $iBarLeft
	local $iBarTop
	local $iBarWidth
	local $iBarHeight
	local $aFoundPos
	local $iTolerance
	local $iloopcnt

	local $x
	local $y

	$aWinPos = WinGetPos($_hBrowser)

	$iBarLeft = $aWinPos[0] + $aWinPos[2] - 23
	$iBarTop = $aWinPos[1] + 75
	$iBarWidth = $aWinPos[0] + $aWinPos[2] - 12
	$iBarHeight = $aWinPos[1] + $aWinPos[3] - 10

	if $isCheckEnable then
		if FileExists($sScrollBarBefore) then FileDelete($sScrollBarBefore)
		_ScreenCapture_Capture($sScrollBarBefore,$iBarLeft,$iBarTop,$iBarWidth,$iBarHeight)
		sleep(100)
		if FileExists($sScrollBarBefore) = 0 then
			$_runErrorMsg = "��ũ���� ���� ��üȭ�� �̹��� ã�� �۾� ����"
			return False
		endif
	endif

	ScrollPage($bisPgTop)

	if $isCheckEnable then
		if _ImageSearchArea($sScrollBarBefore,1,$iBarLeft - 1,$iBarTop -1 ,$iBarWidth + 2,$iBarHeight + 2, $x, $y, $iTolerance, $aFoundPos) = 1 then
			$bScrollNotEnd = False
		else
			;debug("��ã��~ : " & $iTolerance)
			$iloopcnt += 1
			if $iloopcnt > 5 then $iTolerance += 10
			;_ScreenCapture_Capture($sScrollBarAfter,$iBarLeft,$iBarTop,$iBarWidth,$iBarHeight)
			$bScrollNotEnd = True
		endif
	Else
		$bScrollNotEnd = True
	endif

	return $bScrollNotEnd

endfunc



func setMouseClickLeftDown()
	; ���� ǥ������ Ŭ��

	local $aWinPos

	hBrowswerActive ()

	$aWinPos = WinGetPos($_hBrowser)

	; �����찡 max �̸� border�� ����

	if IsArray($aWinPos) then

	WinGetPosWithoutBorder($aWinPos)
	;debug($aWinPos[1], $aWinPos[3])
	;debug(WinGetClientSize("[active]"))

	; ���콺�� ������� �̵�
		MouseClick("left",$aWinPos[0] + 2,$aWinPos[1] + $aWinPos[3] -2 ,1,1)
	endif

endfunc


func setMouseClickLeftTop()
	; ���� ǥ������ Ŭ��

	local $aWinPos

	hBrowswerActive ()

	$aWinPos = WinGetPos($_hBrowser)


	if IsArray($aWinPos) then

	; ���콺�� ������� �̵�
		WinGetPosWithoutBorder($aWinPos)
		MouseClick("left",$aWinPos[0] + 30,$aWinPos[1] + 10,1,1)
	endif

endfunc

func setMouseClickLeftMiddle()

	local $aWinPos

	hBrowswerActive ()

	$aWinPos = WinGetPos($_hBrowser)

	if IsArray($aWinPos) then

		; ���콺�� ������� �̵�
		WinGetPosWithoutBorder($aWinPos)
		MouseClick("left",$aWinPos[0] + 2,$aWinPos[1] + ($aWinPos[3]/2),1,1)
	endif

endfunc

Func ScrollPage($bisPgTop = False)
; ������ ��ũ��,  ����, Ȥ�� �Ѵܰ辿 �Ʒ��� ����

	local $aWinPos

	hBrowswerActive ()

	$aWinPos = WinGetPos($_hBrowser)

	; ���콺�� ������� �̵�
	MouseClick("left",$aWinPos[0] + 10,$aWinPos[1] + ($aWinPos[3]/2),1,1)
	;sleep(100)
	;moveMouseTop()

	if $bisPgTop then

		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")
		send("{PGUP}")

		;RunSleep(200)

	Else
		send("{PGDN}")
		;RunSleep(200)
	endif

endfunc


Func moveMouseTop($sMouseDelay = $_runMouseDelay)
; ��� ������ ȭ�� ĸ�Ŀ� ���콺�� ǥ�õǰų� �߸��� ȭ���� ǥ�õǽ� �ʵ��� �ֻ�� ���� �̵�
	local $aWinPos[3]

	$aWinPos = WinGetPos($_hBrowser)

	if IsArray($aWinPos) = 0 then
		; ���� �۾�â�� ��ǥ�� ���� ���Ұ�� 0,0���� �̵�
		redim $aWinPos[3]
		$aWinPos[0] =0
		$aWinPos[1] =0
	endif

	sleep(1)
	MouseMove($aWinPos[0] + 30 ,$aWinPos[1]+ 10,$sMouseDelay)
	sleep(1)

	;debug($aWinPos)

endfunc


func writeRunLog($sMessage, $sLineNumber = "", $bNewLine = True )

	$sMessage = getLogLineNumber($sLineNumber) & " > " & getReportDetailTime()  & " "  & $sMessage

	WriteLoglist ($sMessage & @crlf)

	ControlFocus($_gEditScript, "", "")

	FileWrite($_runLogFileHanle,$sMessage & @crlf)

endfunc


func setStatusText($sMessage, $bCRLF = True )
	$sMessage = stringreplace($sMessage,@cr,"")
	$sMessage = stringreplace($sMessage,@lf,"")

	;_GUICtrlStatusBar_SetText ($_gStatusBar, $sMessage, 2)
	setStatusBarText($_iSBStatusText, $sMessage)
	sleep(1)
	_ViewRuntimeToolTip()
	writeDebugTimeLog("Status Message : " & $sMessage)
endfunc


func writeReportLog($sMessage)
	;debug($sMessage)
	FileWrite($_runReportLogHanle, $sMessage & @crlf)
endfunc


func writeDebugTimeLog($sMsg, $oTimer = $_iDebugTimeInit)
	writeDebugLog(StringFormat("[%4d] ",_TimerDiff($oTimer)) & $sMsg)
endfunc



func getLogLineNumber($iNumber)

	$iNumber = number($iNumber)

	if $iNumber = 0 Then
		return "     "
	else
		return StringFormat("%5d", $iNumber)
	endif

endfunc

func getLogRunningTime($iSec)

	local $sRet

	;debug($iSec)
	$iSec = round($iSec / 1000 ,1)
	;debug($iSec & " -")

	if $iSec = 0 Then
		$iSec = "0.1"
	endif

	;debug($iSec & " --")

	if stringinstr($iSec,".") = 0 then $iSec &= ".0"

	$sRet = "(" & $iSec & "s)"
	$sRet =  stringleft($sRet ,8)

	return $sRet

endfunc


func getReportDetailTime()

	return _DateTimeFormat($_runCommadLintTimeStart,5) & " " & getLogRunningTime(_TimerDiff($_runCommadLintTimeInit))


endfunc

func makeReportLogFormat($aCommand, $aCommandPos, $aTarget, $aTargetPos,  $sScriptName, $sID, $sNo, $sTestDateTime,  $sResult, $sScript, $sErrorMsg, $sComment)

	; $sScriptName , $sID , $sNo, $sDate , $sResult & ,$sNewScript , $sErrorMsg , $sComment

	local $sKey = Chr(1)
	local $sNewScript
	local $sNewErrorMsg
	local $sNewCommnet
	local $i
	local $iAddTextSize =0
	local $a
	local $addText


	if IsArray($aCommand) then
		$sNewScript = changeString($sScript, $aCommand, $aCommandPos, "#" & hex($_iColorCommandHtml,6) ,  $aTarget, $aTargetPos, "#" & hex ($_iColorTargetHtml,6) )
	Else
		$sNewScript = $sScript
	endif
	;debug($sScript)
	;debug($sNewScript)

	;debug($aCommand)
	;debug($aCommandPos)
	;debug($aTarget)
	;debug($aTargetPos)


	$sNewErrorMsg = $sErrorMsg
	$sNewCommnet = $sComment


	$sNewCommnet = StringReplace($sNewCommnet,$_sHTMLPreCahr & "<", $_sHTMLPreCahr & "GT;")
	$sNewCommnet = StringReplace($sNewCommnet,$_sHTMLPreCahr & ">", $_sHTMLPreCahr & "LT;")


	$sNewErrorMsg = StringReplace($sNewErrorMsg,$_sHTMLPreCahr & "<", $_sHTMLPreCahr & "GT;")
	$sNewErrorMsg = StringReplace($sNewErrorMsg,$_sHTMLPreCahr & ">", $_sHTMLPreCahr & "LT;")


	$sNewCommnet = StringReplace($sNewCommnet,"<", "&lt;")
	$sNewCommnet = StringReplace($sNewCommnet,">", "&gt;")

	$sNewErrorMsg = StringReplace($sNewErrorMsg,"<", "&lt;")
	$sNewErrorMsg = StringReplace($sNewErrorMsg,">", "&gt;")

	$sNewCommnet = StringReplace($sNewCommnet,$_sHTMLPreCahr & "GT;",  "<")
	$sNewCommnet = StringReplace($sNewCommnet,$_sHTMLPreCahr & "LT;", ">")

	$sNewErrorMsg = StringReplace($sNewErrorMsg,$_sHTMLPreCahr & "GT;",  "<")
	$sNewErrorMsg = StringReplace($sNewErrorMsg,$_sHTMLPreCahr & "LT;", ">")



	$sNewErrorMsg = StringReplace($sNewErrorMsg,@crlf, "<BR>")
	$sNewCommnet = StringReplace($sNewCommnet,@crlf, "<BR>")

	; �����ڵ� ��� ������ ���� ���� ��� null ó���ϵ��� ��
	$sNewErrorMsg = StringReplace($sNewErrorMsg,@cr, "")
	$sNewErrorMsg = StringReplace($sNewErrorMsg,@lf, "")

	$sNewCommnet = StringReplace($sNewCommnet,@cr, "")
	$sNewCommnet = StringReplace($sNewCommnet,@lf, "")

	;debug("Error1:" & $sErrorMsg)
	;debug("Error2:" & $sNewErrorMsg)
	;debug("Comment1:" & $sComment)
	;debug("Comment2:" & $sNewCommnet)

	writeReportLog($sScriptName & $sKey & $sID & $sKey &  $sNo & $sKey &  $sTestDateTime & $sKey &  $sResult & $sKey &  $sNewScript & $sKey &  $sNewErrorMsg & $sKey &  $sNewCommnet)

endfunc


func setupLogFile($sScriptName, $sReportLog )

	$_runLogFileHanle = FileOpen($sScriptName, 2)
	$_runReportLogHanle = FileOpen($sReportLog, 2)

endfunc

func setupDebugLogFile($sDebugLog)

	if $_runDebugLog then
		$_runDebugLogFileHanle = FileOpen($sDebugLog, 2)
	endif

endfunc


func closeLogFile()
; �α� ���� �ݱ�
	FileClose($_runLogFileHanle)
	FileClose($_runReportLogHanle)
	if $_runDebugLog then FileClose($_runDebugLogFileHanle)
endfunc


func getFormatImageName($aImageList, $bIncludeFileName)
; link �� ������ �̹������ڿ����� <>�� �ѷ��μ� ����, �ɼ����� �̸��� ������ ��� �ڿ� �߰�

	local $sList
	local $newImageList [2]
	local $i

	if IsArray($aImageList) = 0 then
		$newImageList[1] = $aImageList
	Else
		$newImageList = $aImageList
	endif

	for $i=1 to UBOUND($newImageList)-1
		if $sList <> "" then $sList = $sList & @crlf
		$sList = $sList  & $_sHTMLPreCahr & "<" & $newImageList[$i] & $_sHTMLPreCahr & ">" & _iif($bIncludeFileName, " " &  $newImageList[$i], "")
	next

	return $sList

endfunc


func setImageSearchError($sScriptTarget, $aImageFile)
; �̹��� ã�� ���� ���� �α� ������ ���� ����
	local $sErrorMsg
	;debug($sBrowserCapture)
	$_runErrorImageTarget = $sScriptTarget
	;_ArrayAdd($_aPreErrorImageTarget, $sScriptTarget)

	$sErrorMsg = "�̹��� ã�� ���� : " & $sScriptTarget


	if $_runRetryRun = False then
		$sErrorMsg = $sErrorMsg & @crlf
		copyErrorImage($sErrorMsg, $aImageFile)
		captureCurrentBorwser($sErrorMsg, False)
	endif

	return $sErrorMsg

endfunc


func copyErrorImage(byref $sErrorMsg, $aImageFile)

	local $sBrowserCapture
	local $i

	if $_runRunningImageCapture = False then return

	;$sErrorMsg = $sErrorMsg & @crlf & "ã�� �̹��� : "

	for $i=1 to ubound($aImageFile) -1
		$_runScreenCaptureCount += 1
		$sBrowserCapture = $_runWorkReportPath & $_runScreenCapturePreName & $_runScreenCaptureCount & $_cImageExt
		filecopy ($aImageFile[$i],   $sBrowserCapture)
		_StringAddNewLine ($sErrorMsg ,getFormatImageName($sBrowserCapture, False ) & @crlf & $aImageFile[$i] & @crlf)
	next

endfunc

func captureCurrentBorwser(byref $sErrorMsg, $bDeskTop, $hCurBrowser = $_hBrowser, $aCaptureArea = "", $sCaptureFileName = "")

	local $sBrowserCapture
	local $sCapList
	local $sAVIFile
	local $sCapturePath
	local $bRet = False

	if $_runRunningImageCapture = False then return

	if $aCaptureArea = "" Then
		$sCapturePath = $_runWorkReportPath
	Else
		$sCapturePath = $_runUserCapturePath
	endif

	if $sCaptureFileName = "" then
		$_runScreenCaptureCount += 1
		$sBrowserCapture = $sCapturePath & $_runScreenCapturePreName & StringFormat("%0003d",Number ($_runScreenCaptureCount)) & $_cImageExt
	Else
		$sBrowserCapture = $_runUserCapturePath & "\" &  $sCaptureFileName
	endif

	writeDebugTimeLog("â ĸ�� ����")

	;msg($sBrowserCapture)

	if FileExists(_GetPathName($sBrowserCapture)) = 0 then DirCreate(_GetPathName($sBrowserCapture))

	if FileExists($sBrowserCapture) then FileDelete($sBrowserCapture)

	writeDebugTimeLog("â ĸ�� �غ� �Ϸ�")

	saveBrowserScreen($sBrowserCapture, $bDeskTop, $hCurBrowser, $aCaptureArea)

	writeDebugTimeLog("â ĸ�� ����")

	if FileExists($sBrowserCapture) then  $bRet = True

	_StringAddNewLine ( $sErrorMsg , $_sLogText_BrowserCapture)
	_StringAddNewLine ( $sErrorMsg ,getFormatImageName($sBrowserCapture, False) )

;~ 	if $_runAVICapOn then

;~ 		$sAVIFile = stringreplace($sBrowserCapture,$_cImageExt , ".avi")
;~ 		$sCapList = _avi_getcapturelist()
;~ 		; 30�� �߰��ؼ� ĸ�� ��û
;~ 		$sCapList = _avi_getLastAVIList ($sCapList, _avi_getCaptureTime(30 +  _DateDiff( 's',$_runLastCommandStartTime,_NowCalc())))
;~ 		;debug("AVI ĸ�� ��û : " & $sAVIFile )
;~ 		_avi_setSavelist($sAVIFile , $sCapList)

;~ 		_StringAddNewLine ( $sErrorMsg ,$_sLogText_BrowserAVI)
;~ 		_StringAddNewLine ( $sErrorMsg ,getFormatImageName($sAVIFile, False) )

;~ 	endif

	return $bRet

endfunc


Func saveBrowserScreen($sFileName, $bDeskTop, $hCurBrowser, $aCaptureArea = "" )
;	���� ǥ�õǴ� �������� ���Ϸ� ������
	;debug("ĸ�����ϸ�:" & $sFileName)

	local $iCaptureStartX = 0
	local $iCaptureStartY = 0
	local $iCaptureWidth = -1
	local $iCaptureHeight = -1
	local $oMyError
	local $i

	if IsArray($aCaptureArea) Then

		$iCaptureStartX = $aCaptureArea[1]
		$iCaptureStartY = $aCaptureArea[2]
		$iCaptureWidth = $aCaptureArea[3]
		$iCaptureHeight = $aCaptureArea[4]

	endif

	writeDebugTimeLog("ĸ�� ������ ũ�� Ȯ�� �Ϸ� : " & $sFileName)

	if FileExists($sFileName) then FileDelete($sFileName)

	writeDebugTimeLog("ĸ�� ���� ���� ����")

	writeDebugTimeLog("��� ��� Ȯ�� : " & _isWorksatationLocked())


	;ScrollPage(True)

	if $_runWebdriver then
	; webdriver ����� ���
		writeDebugTimeLog("������̹� ĸ��")
		_WD_get_screenshot_as_file ($sFileName)

	elseif $bDeskTop then

		writeDebugTimeLog("��ü ������ ĸ��")
		_ScreenCapture_Capture ($sFileName)

	else
		;msg($iCaptureStartX & " " &  $iCaptureStarty & " " &   $iCaptureWidth & " " &  $iCaptureHeight)

		writeDebugTimeLog("�κ� ������ ĸ�� : " & $sFileName & "," &  $hCurBrowser  & "," & $iCaptureStartX  & "," & $iCaptureStarty & "," &  $iCaptureWidth & "," &  $iCaptureHeight)

		_ScreenCapture_CaptureWnd($sFileName,$hCurBrowser,$iCaptureStartX,$iCaptureStarty, $iCaptureWidth, $iCaptureHeight,True)

	endif

	writeDebugTimeLog("saveBrowserScreen ĸ�� �۾� �Ϸ�")

EndFunc


func getProcessIDandHandle(byref $sBrowserType, byref $hBrowser)
; �� �������� ����� �ڵ����� �������� �������� ���� ��� ����ڰ� �������� �����ϵ��� �� (5��)

	local $bCancel
	local $hWinHandle
	local $sProcessName
	local $i
	local $aBrowserInfo[6 + ubound($_aBrowserOTHER) -1]
	local $iTimeInit
	local $dll = DllOpen("user32.dll")


	$aBrowserInfo[1] = $_sBrowserIE
	$aBrowserInfo[2] = $_sBrowserFF
	$aBrowserInfo[3] = $_sBrowserSA
	$aBrowserInfo[4] = $_sBrowserCR
	$aBrowserInfo[5] = $_sBrowserOP

	for $i=1 to ubound($_aBrowserOTHER) -1
		$aBrowserInfo[5 + $i] = $_aBrowserOTHER[$i][1]
	next


	;msg($aBrowserInfo)

	do

		$iTimeInit = _TimerInit()

		TrayTip($_sProgramName, "�׽�Ʈ �� �������� ���� �� CTRLŰ�� ��������" & @crlf &  "CTRLŰ�� ������ ���� ��� 5�� �ڿ� �ڵ� ����˴ϴ�.",5,1)

		;debug(_TimerDiff($iTimeInit))
		;debug(checkScriptStopping())

		$_bScriptRunning = True
		$_bScriptStopping = False

		do
			;debug(_TimerDiff($iTimeInit))
			sleep(200)

		until _TimerDiff($iTimeInit) > 5000 or checkScriptStopping() or _IsPressed("11", $dll)  = 1


		if checkScriptStopping() then
			TrayTip($_sProgramName, "�׽�Ʈ�� ��� �Ͽ����ϴ�.",5,1)
			$_bScriptRunning = False
			$sBrowserType = ""
			exitloop
		endif

		$hWinHandle = WinGetHandle("[ACTIVE]")
		$sProcessName = _ProcessGetName(WinGetProcess($hWinHandle, ""))

		for $i = 1 to ubound($aBrowserInfo) -1
			if $sProcessName = getBrowserExe($aBrowserInfo[$i]) then
				;msg("ã�� " & $sProcessName & " , " & $aBrowserInfo[$i] & " " & getBrowserExe($aBrowserInfo[$i]))
				$sBrowserType = $aBrowserInfo[$i]
				$hBrowser = $hWinHandle
			endif
		next
		if $sBrowserType = "" then $bCancel = _ProgramQuestion("Ȱ��ȭ�� �������� ã�� ���Ͽ����ϴ�. ��õ��Ͻðڽ��ϱ�?")

	until $sBrowserType <> "" or $bCancel = False


endfunc


Func searchBrowserWindow($sBrowserType, $sScriptTarget, byref $sWinTitleList, $bScreenCapture, byref $iRetHandle)
;����,  ������ exe �� �������� ��� �����쿡�� ���ʴ�� �̹����� �ִ��� Ȯ���ϰ�, ���� ��� True

	local $aBrowserWindows
	local $x,$y, $j, $i, $k
	local $bResult
	local $aRetPos
	local $sErrorMsg
	local $bLogHeaderWrite = False

	local $iTabCount = 0
	local $sWinGetText
	local $oTag
	local $sLastErrorMsg
	local $hLastBrowser
	local $bObjectSearch
	local $aImageFile
	local $bFileNotFoundError

	;debug($sBrowserType)
	;debug($aBrowserWindows)

	$bObjectSearch = getIEObjectType($sScriptTarget)

	for $j=1 to 2

		writeDebugTimeLog("â ��� �������� ����")
		$aBrowserWindows = getBrowserWindowAll(getBrowserExe($sBrowserType), $sWinTitleList)
		;debug("$j=" & $j)
		;debug($sWinTitleList)
		writeDebugTimeLog("â ��� �������� �Ϸ� : " & ubound($aBrowserWindows) -1)

		for $i=1 to ubound($aBrowserWindows) -1

			runsleep(1)
			if checkScriptStopping()  then return False

			do

				; ��Ȯ��
				for $k= 2 to 2

					$iRetHandle = WinGetHandle($aBrowserWindows[$i])

					if $iRetHandle <> "" then
						writeDebugTimeLog("â ���� : " & WinGetTitle($aBrowserWindows[$i]))

						; ũ���� �ƴϸ鼭 �ڵ��� ������ ��� �˻� ��󿡼� ����
						;debug($_hBrowser , $iRetHandle, $sBrowserType, $_sBrowserCR)
						;if $_hBrowser = $iRetHandle and ($sBrowserType <> $_sBrowserCR ) then ContinueLoop

						;debug($i  & $aBrowserWindows[$i] & WinGetTitle($aBrowserWindows[$i]))

						;if $k = 2 then WinMinimizeAll ()


						;WinSetOnTop($aBrowserWindows[$i],"",1)

						if WinActive($aBrowserWindows[$i]) = 0 then WinActivate($aBrowserWindows[$i])

						writeDebugTimeLog("attach WinActive �Ϸ�")

						if WinActive($aBrowserWindows[$i]) <> 0  then


							;WinSetOnTop($aBrowserWindows[$i],"",1)

							; ���� PC���� ���� ȭ�� ��ȭ�ϰ� ��ü �̹����� ����� �����ִµ� ���� �ɸ��� ��찡 ����
							sleep(100)
							;debug($bScreenCapture , $j, $bLogHeaderWrite)
							if $bScreenCapture and $j = 2 then

								if $bLogHeaderWrite = False then

									$bLogHeaderWrite = True
									;_StringAddNewLine($_runErrorMsg,"������ �����츦 ã�� �� �����ϴ�." & _NowCalc())
									;_StringAddNewLine($_runErrorMsg,"")
									_StringAddNewLine($_runErrorMsg,"������ ȭ�� ���")

									; �̹����� ĸ���� (ã���� �ϴ� â�� �̹���)

									;if $bObjectSearch = False then copyErrorImage($sErrorMsg, $sScriptTarget)
									copyErrorImage($sErrorMsg, $sScriptTarget)
									_StringAddNewLine($_runErrorMsg,$sErrorMsg)

									;debug ("�Ѳ����� ����Ծ�")
								endif

								writeDebugTimeLog("â attach ���� Ȯ�� ȭ�� ĸ��")
								_StringAddNewLine($_runErrorMsg,"������ : " & WinGetTitle($aBrowserWindows[$i]))
								writeDebugTimeLog("â attach ���� Ȯ�� ȭ�� ĸ��2")
								captureCurrentBorwser($_runErrorMsg, False, $aBrowserWindows[$i])
								writeDebugTimeLog("â attach ���� Ȯ�� ȭ�� ĸ��3")
								_StringAddNewLine($_runErrorMsg,"")

								;WinSetOnTop($aBrowserWindows[$i],"",0)

							endif

							writeDebugTimeLog("attach �̹��� ã�� ��û")
							sleep(100)

							if $bObjectSearch then
								;debug(WinGetTitle($aBrowserWindows[$i]))
								$sLastErrorMsg = $_runErrorMsg
								$bResult = SearchIEObjectTarget($aBrowserWindows[$i], $sScriptTarget, $x, $y, $aRetPos, $oTag, False , $_runWaitTimeOut)
								$_runErrorMsg = $sLastErrorMsg
							else
								;$bResult = SearchTarget($aBrowserWindows[$i], $sScriptTarget,$x,$y, False, $_runWaitTimeOut, False  ,$aRetPos, False )
								$hLastBrowser =  $_hBrowser
								$_hBrowser = $aBrowserWindows[$i]
								;debug($i, $_hBrowser)
								;debug($sScriptTarget)
								$sLastErrorMsg = $_runErrorMsg
								;debug("$sLastErrorMsg : " & $sLastErrorMsg)

								$bResult = getRunCommnadImageAndSearchTarget ($sScriptTarget, $aImageFile,  $x , $y, False , $_runWaitTimeOut, $bFileNotFoundError)
								;debug("$_runErrorMsg : " & $_runErrorMsg)
								; ��� ������ �����ϵ��� ��

								; ����ã�� ������ ��� �ش� ������ �켱���� ǥ��
								if $bFileNotFoundError = False then $_runErrorMsg = $sLastErrorMsg

								$_hBrowser = $hLastBrowser

							endif

							writeDebugTimeLog("attach top off")
							;WinSetOnTop($aBrowserWindows[$i],"",0)

							;debug ($bResult)

							writeDebugTimeLog("attach �̹��� ã�� �Ϸ�")

							;�ι�° ��Ȯ�ν� ã���� ã�������� �� ��

							if $bResult = False then exitloop

							if $bResult = True then
								if $k = 2 then
									writeDebugTimeLog("attach �̹��� ã��! : " & WinGetTitle($aBrowserWindows[$i]) )
									return $bResult
								else
									sleep (500)
									writeDebugTimeLog("attach �̹��� ã�� ����� : " & WinGetTitle($aBrowserWindows[$i]) )
									$bResult = False
								endif
							endif

						endif

						WinSetOnTop($aBrowserWindows[$i],"",0)
					else
						writeDebugTimeLog("�߰��� ������ �ڵ��� ������ : " & $aBrowserWindows[$i] )
					endif



				next


				;debug("error : " & $_runErrorMsg)

				if $sBrowserType = $_sBrowserCR then
					;if  StringInStr(WinGetText(""),"DummyWindowForActivation") then
						writeDebugTimeLog("ũ�� TAB Ŭ��")
						send("^{TAB}")
					;endif
				endif

				if checkScriptStopping() then Return False

				writeDebugTimeLog("Tab count : " & $iTabCount)

			;until $iTabCount > 2 or $sBrowserType <> $_sBrowserCR
			until 1
		next

		RunSleep(10)
	next

	return False

EndFunc


func getBrowserWindowAll($sBrowserType, byref $sWinTitleList)
; ������ exe ���� �������� ���� ��� ������ �ڵ��� ����

	local $handle
	local $aBrowserWindows[1]
	local $var, $i
	local $hCurrentWin = $_hBrowser
	local $sTempHandle

	writeDebugTimeLog("â winlist ����")
	$var = WinList()
	writeDebugTimeLog("â winlist �Ϸ�")


	$sWinTitleList = ""


	if IsArray($var) then

		For $i = 1 to $var[0][0]

		  If $var[$i][0] <> "" AND BitAnd( WinGetState($var[$i][1]), 2)  Then

				if $sBrowserType = _ProcessGetName( WinGetProcess($var[$i][1])) then
					if $sWinTitleList  <> "" then $sWinTitleList  = $sWinTitleList  & ", "
					$sWinTitleList = $sWinTitleList & WinGetTitle($var[$i][1])
					_ArrayAdd($aBrowserWindows, $var[$i][1])
					;debug("Details", "Title=" & $var[$i][0] & @LF & _ProcessGetName( WinGetProcess($var[$i][1])))
				endif
			EndIf
		Next
	endif

	; �۾����� ������� �� �������� ��ġ�ϵ��� �Ұ�
	For $i = 1 to ubound($aBrowserWindows) -2
		if $hCurrentWin = $aBrowserWindows[$i] then
			$aBrowserWindows[$i] = $aBrowserWindows[ubound($aBrowserWindows)-1]
			$aBrowserWindows[ubound($aBrowserWindows)-1] = $hCurrentWin
			exitloop
		endif
	next

	;debug($hCurrentWin)
	;debug($aBrowserWindows)


	writeDebugTimeLog("â getBrowserWindowAll �Ϸ�")

	return $aBrowserWindows

EndFunc



Func _setCurrentBrowserInfo()
; �ڵ� ����� �ڵ����� ������Ʈ���� ������

	_writeSettingReg ("LastBrowserType", $_runBrowser)
	_writeSettingReg ("LastBrowserName", $_hBrowser)

	;msg($_webdriver_current_sessionid)
	;msg($_webdriver_connection_host)

	_writeSettingReg ("LastWebdriverSessionid", $_webdriver_current_sessionid)
	_writeSettingReg ("LastWebdriverHost", $_webdriver_connection_host)

	if $_runBrowser <> "" then $_runLastBrowser = $_runBrowser
	;debug($_runBrowser, $_hBrowser)

EndFunc



Func _getLastBrowserInfo()
; ������Ʈ������ �ֽ� ���� ������ �ڵ��� ����

	local $browserType
	local $hbrowser

	$browserType =  _readSettingReg("LastBrowserType")
	$hbrowser = _readSettingReg("LastBrowserName")

	$_webdriver_current_sessionid =  _readSettingReg("LastWebdriverSessionid")
	$_webdriver_connection_host = _readSettingReg("LastWebdriverHost")
	;msg($_webdriver_current_sessionid)
	;msg($_webdriver_connection_host)

	$hbrowser = Ptr ($hbrowser)
	;debug($browserType, $hbrowser)

	if WinExists( $hbrowser) Then
		$_runBrowser = $browserType
		$_hBrowser =  $hbrowser
	endif

EndFunc


Func writePassFail($bResult)
; �׽�Ʈ ������
	return _iif($bResult," -> P", " -> F")
endfunc


func getRunVar($sScriptTarget, byref $sNewValue)
; ���� ������ ���� ã�Ƽ� ����

	local $i

	$sNewValue = ""

	switch $sScriptTarget

		case "$GUITAR_���糯¥�ͽð�", "$GUITAR_CurrentDateTime"
			;$sNewValue = StringFormat("%04d�� %02d�� %02d�� %02d�� %02d�� %02d��", @YEAR, @MON ,@MDAY ,@HOUR , @MIN, @SEC, @MSEC)
			$sNewValue = StringFormat("%04d_%02d_%02d_%02d_%02d_%02d", @YEAR, @MON ,@MDAY ,@HOUR , @MIN, @SEC, @MSEC)
			return true

		case "$GUITAR_���ǰ�", "$GUITAR_Random"
			$sNewValue =  StringFormat("%010d",Random(1,9999999999,1))
			return true

		case "$GUITAR_���������", "$GUITAR_CurrentBrowser"
			$sNewValue =  $_runBrowser
			return true

		caSE "$GUITAR_�ֱ�X��ǥ", "$GUITAR_RecentXPos"
			$sNewValue =  $_aLastUseMousePos[1]
			return true

		CASE "$GUITAR_�ֱ�Y��ǥ", "$GUITAR_RecentYPos"
			$sNewValue =  $_aLastUseMousePos[2]
			return true

		caSE "$GUITAR_�ֱ���ü��ǥ", "$GUITAR_RecentXYPos"
			$sNewValue =  $_aLastUseMousePos[3]
			return true

		CASE "$GUITAR_����Ʈ���", "$GUITAR_RrportPath"
			$sNewValue =  $_runWorkReportPath
			return true

		CASE "$GUITAR_XML���", "$GUITAR_XMLPath"
			$sNewValue =  $_runXMLPath
			return true

		CASE "$GUITAR_��ũ��Ʈ���", "$GUITAR_ScriptPath"
			$sNewValue =  StringTrimRight(_GetPathName($_runScriptFileName),1)
			return true

		CASE "$GUITAR_�۾����", "$GUITAR_WorkPath"
			$sNewValue =  $_runWorkPath
			return true

		CASE "$GUITAR_�ֱ����Ӽҿ�ð�", "$GUITAR_RecentLoadingTime"
			$sNewValue =  $_aLastNavigateTime
			return true

		CASE "$GUITAR_X��ǥ����", "$GUITAR_AdjustXPos"
			$sNewValue =  $_runCorrectionX
			return true

		CASE "$GUITAR_Y��ǥ����", "$GUITAR_AdjustYPos"
			$sNewValue =  $_runCorrectionY
			return true

		CASE "$GUITAR_������âũ��", "$GUITAR_BrowserSize"
			$sNewValue =  $_runBrowserWidth & "," & $_runBrowserHeight
			return true

		CASE "$GUITAR_������URL", "$GUITAR_BrowserURL"

			if $_runWebdriver = False then
				$sNewValue =  getCurrentURL()
			Else
				$sNewValue = _WD_get_url()
			endif
			return true

		CASE "$GUITAR_�����OS", "$GUITAR_MobileOS"
			$sNewValue =  $_runMobileOS
			return true

		CASE "$GUITAR_�Է¹��", "$GUITAR_InputType"
			$sNewValue =  $_runInputType
			return true

		CASE "$GUITAR_�Է¹��", "$GUITAR_Webdriver"
			$sNewValue =  _Boolean($_runWebdriver)
			return true


		CASE "$GUITAR_CMDLINE1"
			$sNewValue =  $_runCmdLine[1]
			return true

		CASE "$GUITAR_CMDLINE2"
			$sNewValue =  $_runCmdLine[2]
			return true

		CASE "$GUITAR_CMDLINE3"
			$sNewValue =  $_runCmdLine[3]
			return true

		CASE "$GUITAR_CMDLINE4"
			$sNewValue =  $_runCmdLine[4]
			return true

		CASE "$GUITAR_CMDLINE5"
			$sNewValue =  $_runCmdLine[5]
			return true

		CASE "$GUITAR_CMDLINE6"
			$sNewValue =  $_runCmdLine[6]
			return true

		CASE "$GUITAR_CMDLINE7"
			$sNewValue =  $_runCmdLine[7]
			return true

		CASE "$GUITAR_CMDLINE8"
			$sNewValue =  $_runCmdLine[8]
			return true

		CASE "$GUITAR_CMDLINE9"
			$sNewValue =  $_runCmdLine[9]
			return true

		case Else

			checkTableValue($sScriptTarget)

			for $i= 1 to ubound($_aRunVar) -1

				if $_aRunVar[$i][$_iVarName] = $sScriptTarget then

					;debug($_aRunVar[$i][$_iVarName], $sScriptTarget)

					; ���� ���̺����̸� �ֽ� ������ ����
					$sNewValue = $_aRunVar[$i][$_iVarValue]

					return true

				endif
			next

	EndSwitch

	return False

endfunc


func checkTableValue($sScriptTarget)

	local $iVarIndex = 0
	local $aFileReadArray
	local $iNewCount
	local $sVarFile
	local $bisTableVar = False

	$sVarFile = _GetPathName($_runScriptFileName) & $sScriptTarget & ".txt"

	; ���̺� ���� �� ���
	;debug("�������� Ȯ�� :" & FileExists($sVarFile), $sVarFile )
	if FileExists($sVarFile) = 1  then

		addNewTableValue($sScriptTarget, $iVarIndex, $sVarFile)

		$_aRunVar[$iVarIndex][$_iVarFile] = $sVarFile

		; ������ ��� n ��° ���� �о��
		_FileReadToArray($_aRunVar[$iVarIndex][$_iVarFile], $aFileReadArray)

		;debug($aFileReadArray)

		if ubound($aFileReadArray) -1 <= $_aRunVar[$iVarIndex][$_iVarCount] then
			$iNewCount = 1
		Else
			$iNewCount = $_aRunVar[$iVarIndex][$_iVarCount] + 1
		endif

		;debug($iNewCount)
		;debug($aFileReadArray[$iNewCount])

		$_aRunVar[$iVarIndex][$_iVarValue] = $aFileReadArray[$iNewCount]

		$_aRunVar[$iVarIndex][$_iVarCount] = $iNewCount

	endif

endfunc


func addNewTableValue($sScriptTarget, byref $iVarIndex, $sVarFile)

	; ���� ���� ���� �����ͼ� ������ �űԷ� �߰�

	$iVarIndex = getValueTableIndex($sScriptTarget)

	if $iVarIndex = 0 then
		; �ű� �߰�
		addSetVar ($sScriptTarget & "=null" , $_aRunVar)

		$iVarIndex = getValueTableIndex($sScriptTarget)

		$_aRunVar[$iVarIndex][$_iVarName] = $sScriptTarget
		$_aRunVar[$iVarIndex][$_iVarValue] = ""
		$_aRunVar[$iVarIndex][$_iVarCount] = 0
		$_aRunVar[$iVarIndex][$_iVarFile] = $sVarFile

	endif

endfunc

func RestTableValueIndex($sScriptTarget, $iResetIndex)


	local $iVarIndex = 0

	; ���� ���� ������ �̹� �߰��Ǿ� �ִ� ���
	addNewTableValue($sScriptTarget, $iVarIndex, "")

	$_aRunVar[$iVarIndex][$_iVarCount] = $iResetIndex - 1


endfunc


func getValueTableIndex($sScriptTarget)

	local $iVarIndex = 0
	local $i

		for $i=1 to ubound($_aRunVar) -1
			if $_aRunVar[$i][$_iVarName] = $sScriptTarget then
				$iVarIndex = $i
				exitloop
			endif
		next

	return  $iVarIndex

EndFunc

func checkTableValue2($sScriptTarget, $iResetIndex = "")

	local $i
	local $iVarIndex = 0
	local $aFileReadArray
	local $iNewCount
	local $sVarFile
	local $bisTableVar = False
	local $bRet = False

	; ���� ���� ������ �̹� �߰��Ǿ� �ִ� ���
	for $i=1 to ubound($_aRunVar) -1
		if $_aRunVar[$i][$_iVarName] = $sScriptTarget then
			$iVarIndex = $i
			exitloop
		endif
	next

	$sVarFile = _GetPathName($_runScriptFileName) & $sScriptTarget & ".txt"

	; ���̺� ���� �� ���
	;debug("�������� Ȯ�� :" & FileExists($sVarFile), $sVarFile )
	if FileExists($sVarFile) = 1  then

		if $iVarIndex = 0 then
			; �ű� �߰�
			addSetVar ($sScriptTarget & "=null" , $_aRunVar)

			for $i=1 to ubound($_aRunVar) -1
				if $_aRunVar[$i][$_iVarName] = $sScriptTarget then
					$iVarIndex = $i
					exitloop
				endif
			next

			$_aRunVar[$iVarIndex][$_iVarName] = $sScriptTarget
			$_aRunVar[$iVarIndex][$_iVarValue] = ""
			$_aRunVar[$iVarIndex][$_iVarCount] = 0
			$_aRunVar[$iVarIndex][$_iVarFile] = $sVarFile

		endif

		; ������ ��� n ��° ���� �о��
		_FileReadToArray($_aRunVar[$iVarIndex][$_iVarFile], $aFileReadArray)

		if ubound($aFileReadArray) -1 <= $_aRunVar[$i][$_iVarCount] then
			$iNewCount = 1
		Else
			$iNewCount = $_aRunVar[$i][$_iVarCount] + 1
		endif

		$_aRunVar[$i][$_iVarValue] = $aFileReadArray[$iNewCount]

		if $iResetIndex <> "" then
			$_aRunVar[$i][$_iVarCount] = $iResetIndex - 1
		else
			$_aRunVar[$i][$_iVarCount] = $iNewCount
		endif

		$bRet = True

	endif

	return $bRet

endfunc


; ��������
func addSetVar ($sVarString, byref $aVar, $bExtractCheck = False)
; $bExtractCheck = ��Ȯ�ϰ� ù���ڿ� ������ $�� �ִ� ��쿡�� ã��
; �׽�Ʈ ���� ���� ���� ����

	local $i
	local $sNewName
	local $iMaxVar
	local $sNewValue
	local $iNewIndex
	local $bVarAddInfo

	local $bResult
	local $aBrowserSize

	$iMaxVar = ubound($aVar)

	;debug("������:" & $sVarString)
	if getVarNameValue($sVarString,  $sNewName, $sNewValue, ",", $bExtractCheck) = False then Return False
	;debug("������:" & $sVarString)

	$iNewIndex = 0
	for $i= 1 to $iMaxVar -1
		if $aVar[$i][1] = $sNewName then
			$iNewIndex = $i
			exitloop
		endif
	next

	if $sNewName = "$GUITAR_X��ǥ����" or $sNewName = "$GUITAR_AdjustXPos" then $_runCorrectionX = Number($sNewValue)
	if $sNewName = "$GUITAR_Y��ǥ����" or $sNewName = "$GUITAR_AdjustYPos" then $_runCorrectionY = Number($sNewValue)
	if $sNewName = "$GUITAR_�����OS" or $sNewName = "$GUITAR_MobileOS" then $_runMobileOS = $sNewValue
	if $sNewName = "$GUITAR_Webdriver" then $_runWebdriver = _Boolean($sNewValue)
	if $sNewName = "$GUITAR_�Է¹��" or $sNewName = "" then $_runInputType = $sNewValue
	if $sNewName = "$GUITAR_������âũ��" or $sNewName = "$GUITAR_BrowserSize" then
		$aBrowserSize = StringSplit($sNewValue, ",")
		$_runBrowserWidth = number($aBrowserSize[1])
		$_runBrowserHeight = number($aBrowserSize[2])

		if $_runBrowserWidth = 0 or $_runBrowserHeight = 0 then
			$bResult = False
			_StringAddNewLine( $_runErrorMsg, '"$GUITAR_������âũ�� = 800,600" ���·� �����Ǿ�� �մϴ�. ')
			return $bResult
		endif
	endif


	if $iNewIndex = 0 then
		redim $aVar[$iMaxVar+1][$_iVarFile + 1]
		$iNewIndex = $iMaxVar
	endif

	$aVar[$iNewIndex][1] = $sNewName
	;$aVar[$iNewIndex][2] = $sNewValue
	;debug("addSetVar ConvertVarFull start")
	ConvertVarFull ($sNewValue, $aVar[$iNewIndex][2], $bVarAddInfo,",", $bExtractCheck)
	;debug("addSetVar ConvertVarFull end")
	;msg($aVar)

	return True

endfunc

func ConvertVarFull ($sNewValue, byref $sNewValueAll, byref $bVarAddInfo, $sConvertType=",", $bExtractCheck = False)

	local $i, $k
	local $aTempSplitTop
	local $aTempSplit
	local $sItemValue
	local $bVarType

	$sNewValueAll = ""
	$bVarAddInfo = ""
	$aTempSplitTop = StringSplit($sNewValue,$sConvertType)

	for $k=1 to ubound($aTempSplitTop) -1

		if $k > 1 then $sNewValueAll = $sNewValueAll & $sConvertType

		$aTempSplit = StringSplit($aTempSplitTop[$k],"|")

		for $i=1 to ubound($aTempSplit) -1
			; ������ ��� ���� ã�ƿͼ� �Է�
			;debug("Convert ������:" & $aTempSplit[$i]  )

			$sItemValue = $aTempSplit [$i]

			$bVarType = getVarType(_Trim($aTempSplit [$i]), $bExtractCheck)

			;debug("Convert ������:" & $sItemValue , $bExtractCheck, $bVarType )

			if $bVarType then

				if getRunVar(_Trim($aTempSplit [$i]), $sItemValue) = False then
					_StringAddNewLine( $_runErrorMsg, "���� ���� ������ �߸� �Ǿ��ų� ���� �������� �ʾҽ��ϴ�. : " &  _Trim($aTempSplit [$i]))
					;msg($aTempSplit)
					return False
				endif

				if $bVarAddInfo <> "" then $bVarAddInfo = $bVarAddInfo & ". "
				$bVarAddInfo = $bVarAddInfo & $aTempSplit[$i] & "=" & $sItemValue

				;debug("������:" & $aTempSplit[$i] & ", value =" & $sItemValue & ", $bVarAddInfo=" & $bVarAddInfo )

				; 6/28 ���ڿ� ġȯ�� �� ���鵵 ���� �����ϵ��� ��
				;$sNewValueAll = $sNewValueAll & $sItemValue
				$sNewValueAll = $sNewValueAll &  $sItemValue & StringReplace($aTempSplit [$i], _Trim($aTempSplit [$i]), "")
				;debug($aTempSplit [$i], "!!!")
			else
				$sNewValueAll = $sNewValueAll & $sItemValue
				;debug($aTempSplit [$i], "####")
			endif


		next
	next

	if $bVarAddInfo <> "" then   $bVarAddInfo = "�������� : " & $bVarAddInfo

	;_StringAddNewLine( $bVarAddInfo, "")

	return True

endfunc

;ConsoleWrite(TCaptureXCaptureActiveWindow(WinGetHandle("���̹�")))

Func TCaptureXCaptureActiveWindow($hWIn)

	local $aWinPos
	local $oTCaptureX
	local $results
	local $resultAA
	local $resultActiveWindow

	if WinActive($hWIn) = 0 then  WinActivate($hWIn)
    $aWinPos = WinGetPos($hWIn)
    $oTCaptureX = ObjCreate("TCaptureX.TextCaptureX")
	if $oTCaptureX <> 0 then

;~ 		if $_runBrowser = $_sBrowserSA then
;~ 			$results = $oTCaptureX.GetFullTextAA(Dec(StringTrimLeft($hWIn, 2)))
;~ 		Else
;~ 			$results = $oTCaptureX.CaptureActiveWindow()
;~ 		endif


 			$resultAA = $oTCaptureX.GetFullTextAA(Dec(StringTrimLeft($hWIn, 2)))

 			$resultActiveWindow = $oTCaptureX.CaptureActiveWindow()

			$results = $resultAA & $resultActiveWindow


		;$results = $oTCaptureX.GetTextFromRect(Dec(StringTrimLeft($hWIn, 2)), $aWinPos[0]  , $aWinPos[1] , $aWinPos[2], $aWinPos[3])
	Else
		$_runErrorMsg = "TCaptureX.TextCaptureX �� ��ġ���� �ʾҽ��ϴ�."
		$results = False
	endif

	;debug ($results)
    return $results
EndFunc



;getImageRangeOver($aOldPos,$aNewPos, $aMaxPos, 2 , 100)
;msg($aNewPos)
func getImageRangeOver($aOldPos, byref $aNewPos, $aMaxPos, $iXPer, $iYPer)

	local $iBaseX = 100
	local $iBaseY = 100

	$aNewPos[0] = $aMaxPos [0] +  $aOldPos[0] - $iBaseX * $iXPer
	if $aNewPos[0] < $aMaxPos [0] then $aNewPos[0] = $aMaxPos [0]

	$aNewPos[1] = $aMaxPos [1] +  $aOldPos[1] - $iBaseY * $iYPer
	if $aNewPos[1] < $aMaxPos [1] then $aNewPos[1] = $aMaxPos [1]

	$aNewPos[2] = $aMaxPos [0] + $aOldPos[0] + $aOldPos[2] + $iBaseX * $iXPer
	if $aNewPos[2] > $aMaxPos [2] then $aNewPos[2] = $aMaxPos [2]

	$aNewPos[3] = $aMaxPos [1] + $aOldPos[1] + $aOldPos[3] + $iBaseY * $iYPer
	if $aNewPos[3] > $aMaxPos [3] then $aNewPos[3] = $aMaxPos [3]


;~ 	$aNewPos[0] = $aMaxPos [0] +  $aOldPos[0] - ($aOldPos[2]) * ($iXPer -1)
;~ 	if $aNewPos[0] < $aMaxPos [0] then $aNewPos[0] = $aMaxPos [0]

;~ 	$aNewPos[1] = $aMaxPos [1] +  $aOldPos[1] - ($aOldPos[3]) * ($iYPer -1)
;~ 	if $aNewPos[1] < $aMaxPos [1] then $aNewPos[1] = $aMaxPos [1]

;~ 	$aNewPos[2] = $aMaxPos [0] + $aOldPos[0] + $aOldPos[2] + ($aOldPos[2]) * ($iXPer -1)
;~ 	if $aNewPos[2] > $aMaxPos [2] then $aNewPos[2] = $aMaxPos [2]

;~ 	$aNewPos[3] = $aMaxPos [1] + $aOldPos[1] + $aOldPos[3] + ($aOldPos[3]) * ($iYPer -1)
;~ 	if $aNewPos[3] > $aMaxPos [3] then $aNewPos[3] = $aMaxPos [3]



endfunc

;debug(getImageRangeXY("����_WIN2K_IE7_[071.258.010.020].png"))

func getImageRangeXY($sFileName)

	local $sPos
	local $i
	local $aNewPos = ""

	$sPos = _getmidstring($sFileName,"[","]",1)

	if $sPos <> "" then

		$aNewPos = StringSplit($sPos,".",2)

		for $i = 0 to ubound($aNewPos) -1
			$aNewPos [$i] = int ($aNewPos[$i])
		next

	endif

	return $aNewPos

endfunc


func _setBrowserWindowsSize($hWin, $bMoveOnly = False)

	local $aWinPos
	local $iWidth
	local $iHeight
	local $aCurWindowPos

	;debug("������")

	$iWidth = $_runBrowserWidth
	$iHeight = $_runBrowserHeight


	if $_runWebdriver = False then


		if WinActive($hWin) = 0 then  WinActivate($hWin)

		;WinSetState($hWin,"", @SW_MAXIMIZE )

		sleep (100)

		$aWinPos = WinGetPos($hWin)

		;msg($aWinPos )


		if IsArray($aWinPos) then

			;debug("Width = " & $iWidth & ", Height = " & $iHeight)


			$aCurWindowPos = GetAareFromPoint($aWinPos[0] + ($aWinPos[2]/2) ,$aWinPos[1]  + ($aWinPos[3]/2))


			;if IsArray($aCurWindowPos) = 0  then writeRunLog("GetAareFromPoint ����� ����")

			;msg($aCurWindowPos)

			if $bMoveOnly then

				_MoveWindowtoWorkArea($hWin)

			else

				if $iHeight > $aCurWindowPos[4] or $iWidth > $aCurWindowPos[3] then
					WinSetState($hWin,"", @SW_MAXIMIZE )
				Else

					if BitAnd(WinGetState ( $hWin) , 32) then WinSetState($hWin,"", @SW_SHOWNORMAL)

					sleep (100)

					$aWinPos = WinGetPos($hWin)

					if IsArray($aWinPos) then
						$aCurWindowPos = GetAareFromPoint($aWinPos[0] + ($aWinPos[2]/2) ,$aWinPos[1]  + ($aWinPos[3]/2))


						if $iWidth > 0 then
							WinMove($hWin,"",$aWinPos[0], $aWinPos[1],$iWidth, $aWinPos[3])

						endif

						$aWinPos = WinGetPos($hWin)

						if $iHeight > 0 then
							WinMove($hWin,"",$aWinPos[0], $aWinPos[1],$aWinPos[2], $iHeight)

						endif

						sleep(200)

						_MoveWindowtoWorkArea($hWin)
					endif

				endif
			endif
		endif

		sleep(100)
	else
	;WEBdriver ��忡�� �ػ� ����
		_WD_set_windowsize ($_webdriver_current_sessionid, $iWidth,$iHeight)
	endif

endfunc


Func TestCancelRequest()
; ESCŰ�� ������ �� ó��

	;debug("ESC ����")
	;debug("ESC��û : " & _NowCalc())

	;debug("������û���� : " & _NowCalc())

	if $_bScriptRunning then
		;debug("������û : " & _NowCalc())
		onClickStop ()

		;$_bScriptStopping = True
		; ��ũ��Ʈ ����
	endif

Endfunc


func checkStopRequest()

	if getIniBoolean(getReadINI("environment","StopRequest")) then
		setWriteINI("environment", "StopRequest", "0")
		TestCancelRequest()
	endif

endfunc


func resetRunReportInfo()

	for $i=1 to ubound($_aRunReportInfo) - 1
		$_aRunReportInfo [$i] = 0
	next

	$_aRunReportInfo[$_sResultSkipList] = ""
	$_aRunReportInfo[$_sResultNorRunList] = ""

EndFunc



func countRunReportInfoID($sID)

	local $sTemp

	if $sID = "" then
		return 0
	Else

		StringReplace($sID,",","")
		return @extended + 1
	endif

endfunc


func UIAIE_NabigateError()

	$_runErrorMsg = "Naviagate ����� ���� �� �� �����ϴ�."

endfunc

func UIAIE_NullError()
	SetError (1)
endfunc


Func SetKeyDelay($iDefault = -1)

	if $iDefault = -1 then $iDefault = getReadINI("environment","KeyDelay")

	AutoItSetOption ( "SendKeyDelay" , $iDefault)
	AutoItSetOption ( "SendKeyDownDelay" , $iDefault)

	;debug($iDefault)
	;sleep(100)


endfunc


func CloseUnknowWindow($sTitleList)

	local $sList
	local $i

	if $sTitleList <> "" then
		$sList = stringsplit ($sTitleList,"|")

		for $i=1 to ubound($sList) -1
			if WinExists("",$sList[$i]) = 1  then  WinClose("",$sList[$i])
		next
	endif

endfunc


func hBrowswerActive()

	local $iTimeInit
	local $bRet


	if $_runFullScreenWork = False then

		if WinActive($_hBrowser) = 0 then
			WinActivate($_hBrowser)
			sleep(1)
		endif

		if WinActive($_hBrowser) = 0  then
			$iTimeInit = _TimerInit()
			do
				WinActivate($_hBrowser)
				sleep(1)
			until (_TimerDiff($iTimeInit)  > 5000)  or (WinActive($_hBrowser) <> 0)
		endif

		$bRet = WinActive($_hBrowser)
	else
		$bRet = True

	endif

	return $bRet

endfunc


func checkIE9FontSmoothingSetting()

	global $_bcheckIE9Check

	if $_bcheckIE9Check = True then
		return
	else
		$_bcheckIE9Check = True
	endif

	local $sVer = FileGetVersion(@ProgramFilesDir & "\Internet Explorer\iexplore.exe")
	local $aTempSplit = StringSplit($sVer , ".")
	local $sMSg = ""

	if $aTempSplit[1] = "9" and (FileExists(@ProgramFilesDir & "\Internet Explorer\DWrite.dll") = 0)then

		$sMSg = $sMSg & "IE 9�� �ý����� ClearType �ɼ��� ������ ������� �ʾ� ĸ�ĵ� �̹����� Ʋ���� �� �ֽ��ϴ�." & @cr
		$sMSg = $sMSg & "�Ʒ� devcode �Խ��� ���� �����Ͽ� ��ġ�� �����ѵ� ����Ͻñ� �ٶ��ϴ�." & @cr & @cr

		_ProgramInformation($sMSg)

	endif

endfunc



func getXYAreaPositionPercent($sXY, $iCount, byref $bError)

	local $bRet
	local $i
	local $sLog

	$bError = False

	$bRet = StringSplit($sXY,",")

	if $iCount <> ubound($bRet) -1 then
		$bError = True
		return $bRet
	endif

	for $i=1 to ubound($bRet) -1

		$bRet[$i] = _Trim($bRet[$i])

		if stringright($bRet[$i] ,1) = "%" then
			$bRet[$i] = Number(stringTrimRight($bRet[$i],1))
			if $bRet[$i] > 100 or $bRet[$i] < 0 then $bError = True
		else
			$bError = True
		endif

	next

	return $bRet

endfunc


func getXYAreaPosition($sXY,byref $sCommentMsg, byref $bError)

	local $bRet
	local $i
	local $sLog

	$bError = False

	$bRet = StringSplit($sXY,",")

	for $i=1 to ubound($bRet) -1

		$bRet[$i] = _Trim($bRet[$i])

		if $i <= 4 then
			$bRet[$i] = Execute($bRet[$i] )
			if @error <> 0  Then
				$bError = True
				;debug("�������:" & $bRet[$i])
			endif
			if IsNumber( $bRet[$i]) = 0  Then $bError = True
		endif

		if $i=1 then $sLog = "��ǥ���� X1=" & $bRet[$i]
		if $i=2 then $sLog &= ", Y1=" & $bRet[$i]
		if $i=3 then $sLog &= ", X2=" & $bRet[$i]
		if $i=4 then $sLog &= ", Y2=" & $bRet[$i]

	next

	if $sLog <> "" then _StringAddNewLine( $sCommentMsg,$sLog)

	return $bRet

endfunc



func openNewIEBrowser()
; �κн���� �ű� �������� ����
	local $oMyError
	local $sTempBrowser
	local $sRetBrowser = ""
	local $hBrowser

	$oMyError = ObjEvent("AutoIt.Error","UIAIE_NavigateError")


	$sTempBrowser = _IECreate("about:blank",0,1,1,1)
	$hBrowser = _IEPropertyGet ($sTempBrowser, "hwnd")

	if $sTempBrowser <> 0  then $sRetBrowser = $hBrowser


	$oMyError = ObjEvent("AutoIt.Error")

	return $sRetBrowser

endfunc


Func getScriptFileIDLIneFromClipboard($sTempClip, byref $sScript, byref $sLine)

	local $sTempScript = ""
	local $sTempLine = 0
	local $i

	$sTempClip = stringreplace($sTempClip,@crlf," ")

	replaceTCFileString($sTempClip)

	$sTempClip = _Trim($sTempClip)

	$i= stringinstr($sTempClip, " ",0,-1, stringlen($sTempClip))

	if $i <> 0 then

		$sTempLine = number(stringright($sTempClip, stringlen($sTempClip) - $i))

		$sTempClip = StringLeft($sTempClip, $i)

		if $sTempLine <> 0 then
			$i= stringinstr($sTempClip, " ")

			if $i <> 0 then
				$sTempScript = StringLeft($sTempClip, $i)

				;debug("xx " & $sTempScript)
				;debug("xx " & $sTempID)

			endif
		endif
	else
		$sTempScript = $sTempClip
	endif


	$sTempLine = _Trim($sTempLine)


	$sTempScript = _Trim($sTempScript)
	$sTempLine = _Trim($sTempLine)


	if $sTempScript <> "" then

		$sScript  = $sTempScript
		$sLine = $sTempLine

	endif

endfunc


func getCurrentURL()

	local $oMyError = ObjEvent("AutoIt.Error","UIAIE_NullError")
	local $sTempBrowser = _IEAttach2($_hBrowser,"HWND")

	if _IEPropertyGet ($sTempBrowser, "hwnd") <> $_hBrowser then
		_StringAddNewLine ( $_runErrorMsg , "IE ������������ ��� ������ ��ɾ��Դϴ�." )
		return ""
	endif

	return _IEPropertyGet ($sTempBrowser, "locationurl")

endfunc



func _setLastImageArrayInit()
	redim $_runLastImageArray [1]
	$_runLastImageArray[0] = ""
EndFunc



func  ieattribdebug($oList)
	for $i=0 to $oList.attributes.length -1
		if $oList.attributes($i).specified then
         ;debug($oList.attributes($i).nodeName &  " = " & $oList.attributes($i).nodeValue)
		endif
	next
EndFunc


func GUITAR_NullError ()
endfunc


func WriteGuitarWebDriverError ($sDefaultText = "Webdriver���� ������ �߻��Ǿ����ϴ�. ")
	_StringAddNewLine ( $_runErrorMsg , $sDefaultText & $_webdriver_last_errormsg)
endfunc



func getTargetSearchRemainTimeStatusText($tTimeInitAll, $iTimeOut, $sText)


	local $iRemainTime = int(($iTimeOut - _TimerDiff($tTimeInitAll )) / 1000)
	if $iRemainTime < 0 then $iRemainTime = 0

	return "��� �˻��� : " & $sText & ", " & $iRemainTime & "�� ����" & @crlf

EndFunc