#include ".\_include_nhn\_util.au3"
#include <Constants.au3>
#Include <Array.au3>
#include <Math.au3>

global $_kor_initial[30] = ["��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��"]
global $_kor_medial[30] = ["��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��"]
global $_kor_final[30] = ["", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��"]

SplitKoreanDetail("����")

func _iOSKoreanInput($sText, $iOSVer = "4.x")

	local $sSplitKoreanChar = SplitKoreanDetail(SplitKorean($sText), True)
	local $iChar
	local $bKeysend
	local $sKeyData
	local $aKeyData
	local $i, $j, $j

	for $i= 1 to ubound($sSplitKoreanChar) -1

		if checkScriptStopping() then exitloop

		$iChar = ascw($sSplitKoreanChar[$i])

		if ($iChar >= 12593 and $iChar <= 12643) or $iChar = ascw(" ") then
			$bKeysend = False
			$sKeyData = iOSKoreanKeyPostion($sSplitKoreanChar[$i])
		else
			$bKeysend = True
			$sKeyData = $sSplitKoreanChar[$i]
		endif

		if $bKeysend then
			_debug("send : " & $sSplitKoreanChar[$i])
			commandKeySend($sSplitKoreanChar[$i],"ANSI")
			sleep(300)
		else
			$aKeyData= StringSplit ($sKeyData,"|")
			for $j=1 to ubound($aKeyData)-1
				_debug("mouse : " & $aKeyData[$j])
				sleep(300)
				commandLocationTab($aKeyData[$j], "left")
			next
		endif

	next

EndFunc


func iOSKoreanKeyPostion($sChar)

	local $sRet
	local $iOSKeyLayout
	local $aOSKeyLayout[1][15]
	local $sTempSplit1, $sTempSplit2

	local $i, $j, $k

	local $iCharAdd = 10

	; X, Y ���� 100% ������ ����
	local $iLineX[5] = [0,6,10,20,6]
	local $iLineY[5] = [0,62,73,84,95]
	local $x, $y

	;_debug($sChar)

	; ��
	$iOSKeyLayout = "��,��,��,��,��,��,��,��,����,�Ĥ�" & "|"
	$iOSKeyLayout &= "��,��,��,��,��,��,��,��,��" & "|"
	$iOSKeyLayout &= "��,��,��,��,��,��,��" & "|"
	$iOSKeyLayout &= ",,,, "

	; ��

	; ����

	; Ư��

	$sTempSplit1 = StringSplit($iOSKeyLayout,"|")

	redim $aOSKeyLayout[ubound($sTempSplit1)][ubound($aOSKeyLayout,2)]

	; 2���� �迭�� ���ڹ迭
	for $i= 1 to ubound($sTempSplit1) -1
		$sTempSplit2 = StringSplit($sTempSplit1[$i],",")
		for $j= 1 to ubound($sTempSplit2) -1
			$aOSKeyLayout[$i][$j] = $sTempSplit2[$j]
		next
	next

	;_debug ($aOSKeyLayout)
	;_debug(ubound($aOSKeyLayout,1))
	; 2���� �迭 �ּ� Ȯ��
	for $i= 1 to ubound($aOSKeyLayout,1) -1
		for $j= 1 to ubound($aOSKeyLayout,2) -1
			if StringInStr($aOSKeyLayout[$i][$j], $sChar) <> 0 then
				if $sChar = "��" or $sChar = "��" then
					; Shift Ű �߰�
					$sRet = $iLineX[1] & "%," & $iLineY[3] & "%|"
					;_debug($sRet & "dddd")
				endif

				$x = $iLineX[$i] + (($j-1) * $iCharAdd)
				$y = $iLineY[$i]

				_debug($x, $y)

				$sRet &= $x & "%," & $y & "%"

				exitloop
			endif
		next
		if $sRet <> "" then exitloop
	next


	return $sRet

EndFunc


func SplitKorean($sText)

	local $aRet[1]
	local $i
	local $ki, $km, $kf
	local $iWordasc


	For $i = 1 To StringLen($sText)
		;�ѱ��ϰ�쿡�� �и�
		$iWordasc  = ascw(stringMid($sText, $i, 1))

		If $iWordasc >= dec("AC00") And $iWordasc <= dec("D7A3") Then

			$kf = ascw(stringMid($sText, $i, 1)) - ascw("��")
			$ki = Int($kf / (21*28))
			$kf = mod ($kf ,21*28)
			$km = Int($kf / 28)
			$kf = mod($kf, 28)

			;_debug($ki, $km, $kf)
			;_debug( $_kor_initial[$ki] & $_kor_medial[$km] & $_kor_final[$kf])
			_ArrayAdd ($aRet, $_kor_initial[$ki])
			_ArrayAdd ($aRet, $_kor_medial[$km])

			if $kf <> 0 then _ArrayAdd($aRet, $_kor_final[$kf])

		Else
			;�ѱ��� �ƴҰ�� �׳� ���
			;_debug (stringMid($sText, $i, 1))
			_ArrayAdd ($aRet, stringMid($sText, $i, 1))
		endif
	next



	return $aRet

endfunc


func SplitKoreanDetail($aText, $bArrayType = False)

	local $aRet[1]
	local $i
	local $iWordasc
	local $sNewChar1
	local $sNewChar2
	local $sNewChar3

	For $i = 1 To UBound($aText) -1

		$sNewChar1 = ""
		$sNewChar2 = ""
		$sNewChar3 = ""

		$iWordasc  = $aText[$i]

		switch  $iWordasc

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case "��"
				$sNewChar1 = "��"
				$sNewChar2 = "��"

			case else
				$sNewChar1 = $iWordasc

		EndSwitch

		if $sNewChar1 <> "" then _ArrayAdd ($aRet, $sNewChar1)
		if $sNewChar2 <> "" then _ArrayAdd ($aRet, $sNewChar2)
		if $sNewChar3 <> "" then _ArrayAdd ($aRet, $sNewChar3)

	next

	if $bArrayType = False then $aRet = _ArrayToString($aRet,"",1,0)

	return $aRet

endfunc
