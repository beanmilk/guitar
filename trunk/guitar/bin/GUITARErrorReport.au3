#include ".\_include_nhn\_util.au3"
#include <date.au3>
#Include <Array.au3>


;global  $_sErrorSumarryFile =  "D:\_Autoit\guitar\report\errorsummary2.txt"
;global  $sScriptName = "26_���ü���_SUS_IE_REAL"
;local $a =_getErrorSumarry($sScriptName, "2,6")
;local $b, $c
;$c= _getErrorSumarryInfo("����aa", $a,False,"http://", $b)
;debug($c, $b)
;deleteSuccessListFormErrorSumarry($sScriptName)

; Ÿ�Ժ��� �޼����� ������
func _getErrorSumarryInfo($sServerName, $aErrorInfo,  $sDashBoardReport, byref $sEmailContents)

	local $sRet

	$sEmailContents = ""
	local $iCount = ubound($aErrorInfo) -1

	if $iCount <= 0 then return ""

	$sRet = "[GUITAR] ��������, " & $aErrorInfo[1][1]
	if $iCount > 1 then $sRet =  $sRet & " �� " & $iCount-1  & "��"
	$sRet =  $sRet & " (@" & $sServerName & ")"

	$sEmailContents = ""
	$sEmailContents = $sEmailContents &  "���� : " & $sServerName & @crlf
	$sEmailContents = $sEmailContents &  "���� ��ũ��Ʈ  : " & $aErrorInfo[1][1] & @crlf
	$sEmailContents = $sEmailContents & "����Ʈ : " & $sDashBoardReport & @crlf
	$sEmailContents = $sEmailContents & @crlf
	$sEmailContents = $sEmailContents & "�� " & $iCount & "��" & @crlf

	for $i = 1 to ubound($aErrorInfo) -1
		$sEmailContents = $sEmailContents & "���� " & $aErrorInfo[$i][0] & "ȸ (" & $aErrorInfo[$i][3] & @tab & $aErrorInfo[$i][4] & @tab & $aErrorInfo[$i][5] & ")" & @crlf
	next

	return $sRet

endfunc


; Ư�� Ƚ�� �̻� ������ �߻��� ��� �迭�� �����ϵ��� ��
Func _getErrorSumarry($sCount, $sScriptName, $sTestTime)

	; 26_���ü���_SUS_IE_REAL1,2014/07/17 17:34:15,���ü���_SUS_010,����SUS_TC002,8

	local $aFile
	local $aNewList [1][10]
	local $aRetList
	local $i
	local $aLine
	local $iSearchIndex
	local $bFound
	local $aCount


	$aCount = StringSplit($sCount,",")
	$aRetList = $aNewList

	_FileReadToArray ($_sErrorSumarryFile, $aFile,0)
	$aFile = _ArrayUnique($aFile,1)

	for $i=0 to ubound($aFile) -1

		$aLine = StringSplit($aFile[$i],",")
		$bFound = False

		for $j= 1 to ubound($aNewList) -1
			; ����� ��ũ��Ʈ ��������
			; ������ ���� ��� Count �� �߰�

			if $sScriptName = $aLine[1] then
				if $aLine[1] = $aNewList[$j][1] and $aLine[3] = $aNewList[$j][3]  and $aLine[4] = $aNewList[$j][4]  and $aLine[5] = $aNewList[$j][5]  then
					$bFound = True
					$aNewList[$j][0] = $aNewList[$j][0] + 1
					if $sTestTime = $aLine[2] then $aNewList[$j][2] = $sTestTime
					exitloop
				endif
			endif
		next

		; �ű� �߰�
		if $bFound = False then

			$iSearchIndex = ubound($aNewList)
			redim $aNewList[$iSearchIndex + 1][ubound($aNewList,2)]

			for $j=1 to ubound($aLine) -1
				$aNewList[$iSearchIndex][0] = 1
				$aNewList[$iSearchIndex][$j] = $aLine[$j]
			next

		endif

	next


	for $i=1 to ubound($aNewList) -1

		for $j=1 to ubound($aCount) -1

			if $aNewList[$i][0] = Number($aCount [$j])  and ($sTestTime = $aNewList[$i][2])then

				$iSearchIndex = ubound($aRetList)
				redim $aRetList[$iSearchIndex + 1][ubound($aRetList,2)]

				for $j=0 to ubound($aRetList,2) -1
					$aRetList[$iSearchIndex][$j] = $aNewList[$i][$j]
				next

			endif
		next

	next


	return $aRetList

EndFunc


; ���ν�ũ��Ʈ ���� �������� �ش� ��ũ��Ʈ �α� ������ ��� ������
func deleteSuccessListFormErrorSumarry($sScriptName)

	local $aFile
	local $i

	_FileReadToArray ($_sErrorSumarryFile, $aFile,0)

	for $i=0 to ubound($aFile) -1

		if StringInStr($aFile[$i], $sScriptName & ",") = 1 then
			$aFile[$i] = ""
		endif

	next

	$aFile = _ArrayUnique($aFile,1)
	;_msg($aFile)
	_FileWriteFromArray($_sErrorSumarryFile, $aFile,1)

endfunc