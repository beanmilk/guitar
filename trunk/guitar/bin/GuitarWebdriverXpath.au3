#include-once
#include ".\_include_nhn\_webdriver.au3"
#include "GuitarWebdriver.au3"


Local Enum $_EWXP_TYPE = 1, $_EWXP_VALUE

local $x

func _WD_XpathGetShotPathlist($sElementID, byref $aShotXpathList)

	local $i
	local $aParentElementAttribute = _WD_XpathGetSearchTemplate ()
	local $aMainElementAttribute = _WD_XpathGetSearchTemplate ()
	local $aParentElementAttribute
	local $aMainElementXpathList
	local $aParentElementXpathList [1]
	local $aMainElementXpathDeleteList [1]
	local $aParentElementXpathDeleteList
	local $sParentElementID
	local $sParentElementTagName

	local $sInfoMessage
	local $bSuccess  = False

	$aShotXpathList = $aMainElementXpathDeleteList

	if $sElementID = "" then

		$sInfoMessage = "������ Xpath �� �ش��ϴ� ������ ã���� �����ϴ�."

		return $sInfoMessage
	endif

	_WD_XpathGetElementAttribute($sElementID, $aMainElementAttribute, 0)
	_debug("���� element ���� " & $sElementID)
	_debug($aMainElementAttribute)


	; �Ӽ� ������ ������� �⺻ xptah ��� ����
	$aMainElementXpathList = _WD_XpathMakeString($aMainElementAttribute, 0,  $aMainElementXpathDeleteList)
	_WD_XpathVerification($aMainElementXpathList, $aMainElementXpathDeleteList, $sElementID)


	; �ܵ� �Ӽ������� ã������ �ʴ� ���
	;if ubound($aMainElementXpathList) = 1 then
		;_msg("�� ã����")
		; ���������� ���� ���� ��� TAG ������ �⺻���� �߰���
		if ubound($aMainElementXpathDeleteList) = 1 then _ArrayAdd($aMainElementXpathDeleteList, "//" & $aMainElementAttribute[1][$_EWXP_VALUE])

		; �ִ� 10 ȸ ���� �θ� �������� ����
		$sParentElementID = $sElementID

		for $i=1 to 3

			$sParentElementID = _WD_find_element_from ($sParentElementID, "xpath","..")

			if $sParentElementID <> "" then

				$aParentElementAttribute = _WD_XpathGetSearchTemplate ()

				_WD_XpathGetElementAttribute($sParentElementID, $aParentElementAttribute, $i)

				if $i=1 then $sParentElementTagName = $aParentElementAttribute[1][$_EWXP_VALUE]

				;_debug("�θ� �˻� : " & $sParentElementID)
				;_debug($aParentElementAttribute)

				$aParentElementXpathList  = _WD_XpathMakeString($aParentElementAttribute, $i, $aMainElementXpathDeleteList)

				;_msg("����"  & $sParentElementID)
				;_msg($aParentElementXpathList)
				_WD_XpathVerification($aParentElementXpathList, $aParentElementXpathDeleteList, $sElementID)

				;_msg($aParentElementXpathList)

				if ubound($aParentElementXpathList) <> 1 then
					for $j=1 to ubound($aParentElementXpathList)-1
						_ArrayAdd($aMainElementXpathList, $aParentElementXpathList[$j])
					next
					exitloop
				endif

			endif

		next

	;endif


	$aShotXpathList = $aMainElementXpathList


	; ���� ũ��� ��Ʈ��
	if ubound($aShotXpathList) > 1 then
		for $i=1 to ubound($aShotXpathList) -2
			for $j=2 to ubound($aShotXpathList) -1
				if stringlen($aShotXpathList[$i]) > stringlen($aShotXpathList[$j]) then _Swap($aShotXpathList[$i], $aShotXpathList[$j])
			next
		next
	endif


	if ubound($aShotXpathList) > 1 then $bSuccess = True

	return $bSuccess

	;msg($aMainElementXpathList)
	;_debug($aMainElementXpathList)
	;_msg($aMainElementXpathDeleteList)

endfunc


func  _WD_XpathParentVerification($sParentElementTagName,  $aXpathDeleteList, $sElementID)

	local $aElements
	local $i
	local $aCountElements
	local $aXpathAddList [1]
	local $aIDReturn
	local $sTestXpath

	for $i=1 to ubound($aXpathDeleteList) -1
		$sTestXpath = "//" & $sParentElementTagName & StringTrimLeft($aXpathDeleteList[$i],1)
		_debug($sTestXpath)
		$aElements = _WD_find_elements_by("xpath", $sTestXpath)
		_debug("���� ã�� ���� :  -- " & ubound($aElements))

		; 10�� �̳��̸� ã���� ��
		if ubound($aElements) > 0  and ubound($aElements) < 20 then

			for $j=1 to ubound($aElements) -1
				$sTestXpath ="//" & $sParentElementTagName & "[" & $j & "]" & StringTrimLeft($aXpathDeleteList[$i],0)
				$aCountElements = _WD_find_elements_by("xpath", $sTestXpath)
				_debug($sTestXpath & " " & ubound($aCountElements))
				if ubound($aCountElements) = 1 then
					; ���� �о ���� ID��  ���� ��쿡�� �߰�
					$aIDReturn = $aCountElements[0]
					$aIDReturn = $aIDReturn[1][1]
					_debug(" ã�� ID " & $aIDReturn)
					if $aIDReturn = $sElementID then _ArrayAdd($aXpathAddList, $sTestXpath)
				else
					if ubound($aCountElements) > 0 then
						$aIDReturn = $aCountElements[0]
						_debug ($aIDReturn)
					endif
				endif
			next
		endif
	next

	return $aXpathAddList

endfunc

func  _WD_XpathVerification(byref $aXpathList, byref $aXpathDeleteList, $sElementID)

	local $aNewXpathList
	local $aXpathAddList
	local $aElements
	local $sTemp[1]
	local $sTemp[1]
	local $aIDReturn

	$aXpathDeleteList = $sTemp
	$aXpathAddList = $sTemp

	for $i=1 to ubound($aXpathList) - 1
		$aElements = _WD_find_elements_by("xpath", $aXpathList[$i])

		_debug("���� ã�� ���� : " & $aXpathList[$i] & "  -- " & ubound($aElements))
		if ubound($aElements) = 1 then
			; ���� �о ���� ID��  ���� ��쿡�� �߰�
			$aIDReturn = $aElements[0]
			$aIDReturn = $aIDReturn[1][1]

			if $aIDReturn = $sElementID then _ArrayAdd($aXpathAddList, $aXpathList[$i])

		else
			_ArrayAdd($aXpathDeleteList, $aXpathList[$i])
		endif
	next

	$aXpathList =  $aXpathAddList

	return $aXpathList

endfunc


func _WD_XpathMakeString($aElementAttribute, $iParentLevel, $aMainElementXpathDeleteList)
	; 1�� ������� ������ ��� ������ ����

	local $i, $j
	local $sNewXpath
	local $aXPath[1]
	local $aParentXPath[1]
	local $aCopy = $aXPath



	for $i=2 to ubound($aElementAttribute) -1

		if  $aElementAttribute[$i][$_EWXP_VALUE] <> "" then
			$sNewXpath = ""

			switch $aElementAttribute[$i][$_EWXP_TYPE]

				case "text"
					; �θ� �������� TEXT�� ���� (�ʹ� ���� text�� �˻��� ����)
					$sNewXpath = _WD_XpathMakeTextString ( $aElementAttribute[1][$_EWXP_VALUE], $aElementAttribute[$i][$_EWXP_VALUE])
				case else
					$sNewXpath = "//" & $aElementAttribute[1][$_EWXP_VALUE] & "[@" & $aElementAttribute[$i][$_EWXP_TYPE] & "='" & $aElementAttribute[$i][$_EWXP_VALUE] & "']"

			EndSwitch

			if $sNewXpath <> "" then _ArrayAdd($aXPath, $sNewXpath)

		endif

	next

	if $iParentLevel <> 0 then

		; �θ� ������� �߰��� �����ȰͰ� �����Ͽ� List ����
		for $i=1 to ubound($aMainElementXpathDeleteList)-1
			for $j=1 to ubound($aXPath)-1
				$sNewXpath = $aXPath[$j] & StringTrimLeft($aMainElementXpathDeleteList[$i],_iif($iParentLevel=1,1,0))
				_ArrayAdd($aParentXPath, $sNewXpath)
			next
		next

		$aXpath = $aParentXPath

	endif

	return $aXpath

endfunc


func _WD_XpathMakeTextString ($aTagName, $sText)

	local $sXpathTextString
	local $iMaxTextLen = 10

	if stringlen($sText) > $iMaxTextLen then
		$sText = Stringleft($sText, $iMaxTextLen)
		$sXpathTextString = "//" & $aTagName & "[contains(.,'" & $sText & "')]"
	else
		$sXpathTextString = "//" & $aTagName & "[.='" & $sText & "']"
	endif

	return $sXpathTextString

endfunc


func _WD_XpathGetElementAttribute($sElementID, byref $aElementAttribute, $iParentLevel)

	local $i
	local $sVaule

	;_msg(_WD_get_element_tagname($sElementID))
	$aElementAttribute[1][$_EWXP_VALUE] = _WD_get_element_tagname($sElementID)

	for $i=2 to ubound($aElementAttribute) -1
		if  $aElementAttribute[$i][1] <> "" then
			; �θ� ���� �̻��� ��� text�� ���� ����
			if not ($iParentLevel > 0 and $aElementAttribute[$i][$_EWXP_TYPE] = "text") then
				if _WD_get_element_attribute($sElementID, $aElementAttribute[$i][1], $sVaule) then $aElementAttribute[$i][2] = $sVaule
			endif
		endif
	next

endfunc

func _WD_XpathGetSearchTemplate ()

	local $i=0
	local $aPriority [100][3]

	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "tag"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "class"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "id"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "name"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "title"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "alt"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "text"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "innertext"
	$i+=1
	$aPriority[$i][$_EWXP_TYPE] = "value"

	redim $aPriority [$i][3]

	return $aPriority

endfunc

