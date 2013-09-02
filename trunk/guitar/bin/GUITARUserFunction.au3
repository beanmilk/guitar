#include-once
#include ".\_include_nhn\_util.au3"
#Include <Array.au3>

global $_kor_initial[30] = ["��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��"]
global $_kor_medial[30] = ["��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��"]
global $_kor_final[30] = ["", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��", "��"]


; ���� �߼� ini ������ �����Ͽ� �߼۵�
func _SendMail($sFrom, $sToEmail, $sTitle, $sBody,  $AttachFiles = "", $bIsUseCID = False)

	local $SmtpServer = getReadINI("EMAIL","SMTPServer")
	local $IPPort = getReadINI("EMAIL","Port")
	local $Username = getReadINI("EMAIL","ID")
	local $Password = getReadINI("EMAIL","Password")
	local $FromAddress = getReadINI("EMAIL","EmailAddress")

	return _SendNaverMail($sFrom, $sToEmail, $sTitle, $sBody, $AttachFiles, $bIsUseCID, $SmtpServer , $FromAddress , $Username , $Password, $IPPort)

endfunc


;_debug(_SplitKoreanChar("�R abc �ѱ�"))
; �ѱ� �ڼ� �и�

func _SplitKoreanChar($sText, $bArrayType = False)
	return SplitKoreanDetail(SplitKorean($sText,True), $bArrayType)
endfunc

func SplitKorean($sText, $bArrayType = False)

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

	if $bArrayType then
		return $aRet
	else
		return _ArrayToString($aRet,"")

	endif

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
