; $oImg.scrollIntoView ����� ����


#include-once

#include <IE.AU3>
#include <ARRAY.AU3>

#include ".\_include_nhn\_util.au3"
#include ".\_include_nhn\_file.au3"

;maintest2()

func maintest2()


	local $oIE=_IEAttach("����")

	;debug( IEObjectGetAllInnerHtml($oIE))

endfunc


func maintest()

	;local $oIE=_IEAttach("����")
	local $oIE=_IEAttach("����")
	local $aRetInfo,$aRetObj, $sCondition

	$sCondition = "body::0363429051"
	;$sCondition = "body::������"
	;$sCondition = "div:class=detail:��ĥ�� ������\img:title=�Ÿ���"
	;$sCondition = "li:class=_locsearch_site_item::4\img:alt=�Ÿ���:5"
	;$sCondition = "a:::10000"

	;$sCondition = "a:title=����1�ܰ�"

	WinActivate(HWnd(_IEPropertyGet ($oIE, "hwnd" )))

	;debug( IEObjectGetAllInnerHtml($oIE))

	if IsObj($oIE) then
		if IEObjectSearch($oIE, $sCondition,True, $aRetInfo) then
			;debug("ã��")
			;debug($aRetInfo)
			MouseMove($aRetInfo[2],$aRetInfo[3])
			sleep (1000)
		endif
	endif

endfunc


func IEObjectSearch($oIE, $sCondition, $bMove,  byref $aRetInfo)

	local $aObject
	local $bFound = False
	local $aObjectInfo[8] ; 0=����, 1=������Ʈ, 2,3 = X,Y, 4~7 (��ü ũ��)
	local $i
	local $iRetObjID

	local $aObjectPos

	$aObject = IEObjectSearchFromObject($oIE, $sCondition, False)

	if ubound($aObject) > 1  then

		$iRetObjID = ubound($aObject)-1

		$aObjectPos = IEOjectPotison($oIE, $aObject[$iRetObjID][1],$aObject[$iRetObjID][2], $aObject[$iRetObjID][3], $bMove)

		if $aObjectPos[0] = False then
			$bFound = False
			$aObjectInfo[0] = _getLanguageMsg("ieobj_compatibility")
		else
			; ������ ���ϵ� �׸��� ����
			$bFound = True
			$aObjectInfo[0] = ""
			$aObjectInfo[1] = $aObject[$iRetObjID][1]
			$aObjectInfo[2] = $aObjectPos[1] + ($aObjectPos[3]- $aObjectPos[1]) / 2
			$aObjectInfo[3] = $aObjectPos[2] + ($aObjectPos[4]- $aObjectPos[2]) / 2
			$aObjectInfo[4] = $aObjectPos[1]
			$aObjectInfo[5] = $aObjectPos[2]
			$aObjectInfo[6] = $aObjectPos[3]
			$aObjectInfo[7] = $aObjectPos[4]
		endif

	else
		$bFound = False
		$aObjectInfo[0] = _getLanguageMsg("ieobj_objnotfound")
	Endif

	for $i=1 to ubound($aObject) -1
		;debug("ã����� : " & $i, $aObject[$i][1].innertext, $bFound)
	next

	;debug($aObjectInfo)

	$aRetInfo = $aObjectInfo

	;debug(ubound($aRetObj))

	;_msg($aObject)
	;_msg($aObject)

	return $bFound

endfunc


func IEObjectGetAllInnerHtml($oIE)


	local $aObject, $oItem, $sInnerHtml


	$aObject = IEObjectSearchFromObject($oIE, "body::", False)


	for $i=1 to ubound($aObject) -1

		$oItem = $aObject[$i][1]
		$sInnerHtml &= $oItem.outertext
		;msg($oItem.outertext)
	next


	;debug($sInnerHtml)
	return $sInnerHtml

endfunc


func IEObjectGetAllInnerHtml_old($oIE)

	local $colFrames = _IEFrameGetCollection($oIE)
	local $iFrameCnt = @extended
	local $i, $oFrame, $sInnerHtml = ""
	local $oItems, $oItem

	local $oMyError = ObjEvent("AutoIt.Error","UIAIE_NavigateError")


	;debug($iFrameCnt)
	;debug(_IEPropertyGet ($oIE, "outertext"))
	For $i = 0 To $iFrameCnt
		;debug($iFrameCnt, $i, "�Ծ�0")
		if $i =0 then
			$oFrame = $oie
		else
			$oFrame = _IEFrameGetCollection($oIE, $i-1)
		endif

		;debug($iFrameCnt, $i, "�Ծ�1")

		;debug($i, $oFrame.name, _IEPropertyGet ($oFrame, "locationurl"))
		;debug($i, _IEPropertyGet ($oFrame, "outertext"))


		;local $oItems = _IETagNameGetCollection($oIE,"a")
		;debug(@extended)

		;$sInnerHtml &= $oFrame.document.body.outertext
		;$sInnerHtml &= $oFrame.document.body.innettext

		$oItems = _IETagNameGetCollection($oFrame,"body")

		;debug($iFrameCnt, $i, "�Ծ�2")

		For $oItem In $oItems

			$sInnerHtml &= $oItem.outertext

			;debug($oItem.innertext)
		next

	Next

	;debug("�Ծ�1")


	$oMyError = ObjEvent("AutoIt.Error")

	return $sInnerHtml

endfunc


func IEObjectSearchFromObject($oIE, $sCondition, $bCountCheck)

	local $i
	local $aCondition
	local $aRetObject [1][4]
	local $bContinue
	local $sGroupSplt = "\"
	local $sItemSplt = ":"
	local $sAttribSplit= "^"
	local $aItem

	local $iNumFrames
	local $sSplitTemp

	local $sIFrameURL

	local $iframeX
	local $iframeY

	local $oFrames
	local $oFrame
	local $aCondition[1][5]

	local $oMyError



	; 2014-04-26 ���� ���� ���� ã�� �Ҷ� ���� ���� AUTOIT�� ����Ǵ� ������ �־� ����

	;$oMyError = ObjEvent("AutoIt.Error","UIAIE_NavigateError")



	$sSplitTemp = StringSplit($sCondition, $sGroupSplt)

	redim $aCondition[ubound($sSplitTemp)][5]

	for $j=1 to ubound($sSplitTemp) -1

		$aItem = StringSplit($sSplitTemp[$j] & $sItemSplt & $sItemSplt & $sItemSplt, $sItemSplt)
		;debug($i, _Trim($aItem[1]), _Trim($aItem[2]), _Trim($aItem[3]))
		; 0 = ã�� ����, 1 = tag, 2 = attrb , 3=text, 4=number

		$aCondition[$j][0] = 0
		$aCondition[$j][1] = _Trim($aItem[1])
		$aCondition[$j][2] = _Trim($aItem[2])
		$aCondition[$j][3] = _Trim($aItem[3])
		$aCondition[$j][4] = number(_Trim($aItem[4]))


		; �������� ��� 1��, �������� �ƴѰ�� ���Ѵ� (-1)�� ã���� ��
		if $aCondition[$j][4] < 1 then
			$aCondition[$j][4] = -1
			if $j = ubound($sSplitTemp) -1 then
				if $bCountCheck = False then $aCondition[$j][4] = 1
			endif
		endif

		;debug("���� " & $j & " : " & $aCondition[$j][1] , $aCondition[$j][4])
		convertHtmlChar($aCondition[$j][3])

	next

	$oFrames = _IEFrameGetCollection ($oIE)

	if $oFrames <> 0 then
		$iNumFrames = @extended
	else
		$iNumFrames = -1
	endif

	for $i = 0 to $iNumFrames
		;debug("������ ���� : " & $iNumFrames )
		if $i=0 then
			$oFrame = $oIE
			$iframeX = 0
			$iframeY = 0
		else
			$oFrame = _IEFrameGetCollection ($oIE, $i - 1)
			$iframeX = $oFrame.screenleft()
			$iframeY = $oFrame.screentop()
		endif

		$sIFrameURL = _IEPropertyGet ($oFrame, "locationurl")

		;debug("������ URL : " & $sIFrameURL, $i )
		;debug("text :" & $oFrame.name)
		;debug(_IEBodyReadHTML($oFrame))

		if $sIFrameURL <> "" then
			$bContinue = IEOjectCollectionCheck ($oFrame, $aCondition, 1, $sAttribSplit, $aRetObject, $iframeX, $iframeY, $bCountCheck)
			if $bContinue = False then exitloop
		endif

	next


	$oMyError = ObjEvent("AutoIt.Error")

	return $aRetObject

endfunc


func IEOjectCollectionCheck($aObject, $aCondition, $iIndex, $sAttribSplit, byref $aRetObject, $iframeX, $iframeY, $bCountCheck)

	local $oNewItem
	local $oItem, $oItems
	local $bMatch = True
	local $iRetObjectCount
	local $bContinue = True
	local $sTextSplit
	local $i
	local $iMaxCondition = ubound($aCondition) -1
	local $iLocalItemCount = 0

	;debug("���Ǽ��� : " & $iIndex & "/" & $iMaxCondition  )
	;debug("������� : TAG=" & $aCondition[$iIndex][1] & ", ����=" & $aCondition[$iIndex][4] &  ", TEXT=" & $aObject.innertext)

	$oItems = _IETagNameGetCollection($aObject,$aCondition[$iIndex][1])

	For $oItem In $oItems

		$bMatch = True

		;debug($aCondition[$iIndex][1])
		if $aCondition[$iIndex][2] <> "" and $bMatch then
			;debug($aCondition[$iIndex][2], $sAttribSplit)
			;debug($oItem.title)
			$bMatch = IEOjectAttribCheck($oItem, $aCondition[$iIndex][2], $sAttribSplit)

		endif

		if $aCondition[$iIndex][3] <> "" and $bMatch then

			$sTextSplit = StringSplit($aCondition[$iIndex][3], $sAttribSplit)
			for $i=1 to ubound($sTextSplit) -1
			;debug($oItem.innertext, $sTextSplit[$i] )
				;debug(StringInStr($oItem.innertext ,$sTextSplit[$i]))
				if StringInStr($oItem.innertext ,$sTextSplit[$i]) = 0  then $bMatch = False
			next

			;debug("�Ծ�1" & $bMatch, $aCondition[$iIndex][3])
		endif

		if $bMatch = True then

			$iLocalItemCount += 1

			;debug("ã��Ϸ� : TEXT=" & $oItem.innertext & ", ����ī��Ʈ : " & $iLocalItemCount & ", TAG=" & $aCondition[$iIndex][1])


			if $iMaxCondition = $iIndex then

				$aCondition[$iIndex][0] += 1

				$iRetObjectCount = ubound($aRetObject)

				redim $aRetObject [$iRetObjectCount + 1][4]

				$aRetObject [$iRetObjectCount][1] = $oItem
				$aRetObject [$iRetObjectCount][2] = $iframeX
				$aRetObject [$iRetObjectCount][3] = $iframeY

				if $bCountCheck = False and $aCondition[$iIndex][0] = $aCondition[$iIndex][4] then
					;debug("ã��3")
					$bContinue = False
				endif
				;debug("����2 " & $aCondition[$iIndex][4], $iLocalItemCount, $bContinue)

			else
				;debug("ã��5")

				; ��Į���� ã�� ������ ���ų�, ���Ѵ�� ã�ƾ� �ϴ� ��� 2�� �˻� ����
				if $aCondition[$iIndex][4] = $iLocalItemCount or $aCondition[$iIndex][4] =-1 then
					$bContinue = IEOjectCollectionCheck($oItem, $aCondition, $iIndex + 1, $sAttribSplit, $aRetObject, $iframeX, $iframeY, $bCountCheck)
				endif

			endif



			if $bContinue = False then exitloop

		endif


	next

	; ��� �˻簡 ������ �������� �� ���Ǻ��� �ִ� ������ ä���� ���ϸ� ������ ����� ��� �ʱ�ȭ��
	if $aCondition[$iIndex][4] <> $iLocalItemCount and $aCondition[$iIndex][4] <>-1 then
		if $iLocalItemCount > 0 then
			;debug("����1 " & $iRetObjectCount, $iLocalItemCount)
			redim $aRetObject [1][4]
		endif
	endif


	return $bContinue

endfunc


func IEOjectAttribCheck($Object, $sAttrib, $sSplitChar)

	local $aSplit, $i
	local $aItem, $sAttribValue,  $sTagAttribName
	local $bFound = True
	local $sCompareValue


	$aSplit = StringSplit($sAttrib, $sSplitChar)

	;msg($aSplit)

	for $i= 1 to ubound($aSplit) -1

		$aItem = StringSplit($aSplit[$i] & "=", "=")
		;debug($aItem[1])
		$sTagAttribName = _Trim($aItem[1])

		if $sTagAttribName = "style" then
			$sAttribValue = Execute("$Object.style.cssText")
			;debug($sAttribValue)
		else

			;debug($sTagAttribName)

			$sAttribValue = Execute("$Object." & $sTagAttribName)

			if @error <> 0 then

				$sAttribValue = Execute("$Object.attributes." & $sTagAttribName & ".value()")
				;debug("1 :" & $sAttribValue)



				;$sAttribValue = Execute("$Object.attributes." & $sTagAttribName & ".nodevalue()")
				;debug("2 :" & $sAttribValue)

				;for $i=0 to $Object.attributes.length -1
				;	if $Object.attributes($i).specified then
				;		if $Object.attributes($i).nodeName = $sTagAttribName then $sAttribValue = $Object.attributes($i).nodeValue
				;	endif
				;next

			endif

			;$sAttribValue = Execute("$Object.attributes." & $sTagAttribName & ".value()")

		endif


		$sCompareValue  = _Trim($aItem[2])
		convertHtmlChar($sCompareValue)

		;if $sAttribValue <> $sCompareValue Then
		;debug("�� : " & $sAttribValue & " : " & $sCompareValue )
		if StringInStr($sAttribValue, $sCompareValue) = 0 Then
			$bFound = False
			ExitLoop
		endif

		;debug("ã�� : " & $aItem[1] , $aItem[2] )
	next

	;debug("���  : " & $bFound)

	return $bFound

endfunc


func IEOjectPotison(byref $oIE, byref $oIEObj, $iframeX, $iframeY, $bMove = False)


	local $aRetPos[5]
	local $IEhwnd

	local $ibodyLeft
	local $ibodyTop
	local $ibodyWidth
	local $ibodyHeight

	local $iObjWidth
	local $iObjHeight
	local $iObjLeft
	local $iObjTop

	local $aIEFramePosion

	local $iScrollX = 0
	local $iScrollY = 0

	local $iBoderAddHeight
	local $iBoderAddWidth

	local $iOSAddValue = 0

	if @OSVersion = "WIN_7" or @OSVersion = "WIN_VISTA" then $iOSAddValue = 2

	$IEhwnd = _IEPropertyGet ($oIE, "hwnd" )

	WinActivate ($IEhwnd, "")

	$aIEFramePosion = _WinAPI_GetWindowRect (ControlGetHandle (HWnd($IEhwnd),"","[CLASS:Internet Explorer_Server; INSTANCE:1]"))
	$ibodyLeft = DllStructGetData($aIEFramePosion, "Left")
	$ibodyTop = DllStructGetData($aIEFramePosion, "Top")

	if $iframeX <> "" then
		$ibodyLeft = $iframeX
		$ibodyTop = $iframeY
	endif

	;msg($ibodyTop)

	$ibodyWidth = $oIE.document.documentElement.clientWidth()
	$ibodyHeight = $oIE.document.documentElement.clientHeight()
	;debug("$ibodyWidth 1 : " & $ibodyWidth)
	;debug("$ibodyHeight 1 : " & $ibodyHeight)


	if $ibodyHeight = 0 and $ibodyHeight = 0 then
		$ibodyWidth = $oIE.document.body.clientWidth()
		$ibodyHeight = $oIE.document.body.clientHeight()

		;debug("$ibodyWidth 2 : " & $ibodyWidth)
		;debug("$ibodyHeight 2 : " & $ibodyHeight)
	endif

	if Number($oIEObj.getBoundingClientRect().top) < 0 then $iScrollY = $oIE.document.body.scrollTop + Number($oIEObj.getBoundingClientRect().top) - 50
	if Number($oIEObj.getBoundingClientRect().bottom) > $ibodyHeight then $iScrollY = $oIE.document.body.scrollTop + (Number($oIEObj.getBoundingClientRect().bottom) - $ibodyHeight) + 50
	if Number($oIEObj.getBoundingClientRect().left) < 0 then $iScrollX = $oIE.document.body.scrollLeft + Number($oIEObj.getBoundingClientRect().Left) -50
	if Number($oIEObj.getBoundingClientRect().right) > $ibodyWidth then $iScrollX = $oIE.document.body.scrollLeft + (Number($oIEObj.getBoundingClientRect().right) - $ibodyWidth) + 50

	;if Number($oIEObj.getBoundingClientRect().top) < 0 then $iScrollY = $oIE.document.body.scrollLeft + $iObjTop
	;if Number($oIEObj.getBoundingClientRect().top) > $ibodyHeight then $iScrollY = $iObjTop

	if ($iScrollY <> 0 or $iScrollX <> 0 ) and $bMove = True then

		;ConsoleWrite ("����")
		;ConsoleWrite ("X:" & $iScrollX & @cr)
		;ConsoleWrite ("Y:" & $iScrollY & @cr)

		if $iScrollX = 0 then $iScrollX = $oIE.document.body.scrollLeft
		if $iScrollY = 0 then $iScrollY = $oIE.document.body.scrollTop

		$oIE.document.parentWindow.scroll($iScrollX, $iScrollY)
		sleep (500)
	endif

	$iObjLeft = $oIEObj.getBoundingClientRect().left + $ibodyLeft + $iOSAddValue
	$iObjTop = $oIEObj.getBoundingClientRect().top + $ibodyTop + $iOSAddValue
	$iObjWidth = $oIEObj.getBoundingClientRect().right + $ibodyLeft + $iOSAddValue
	$iObjHeight = $oIEObj.getBoundingClientRect().bottom + $ibodyTop + $iOSAddValue

	;msg($oIEObj.getClientRects().left + $ibodyLeft + $iOSAddValue & " " & $iObjLeft)

	$aRetPos[1] = $iObjLeft
	$aRetPos[2] = $iObjTop
	$aRetPos[3] = $iObjWidth
	$aRetPos[4] = $iObjHeight

	;ConsoleWrite ( "$iObjLeft=" & $iObjLeft & " $iObjTop=" & $iObjTop & @cr)
	;ConsoleWrite ( "$iObjWidth" & $iObjWidth & " $iObjHeight=" & $iObjHeight & @cr)
	;ConsoleWrite ( "$iObjLeft=" & $oIEObj.offsetLeft & " $iObjTop=" & $oIEObj.offsetWidth & @cr)

	$iBoderAddHeight = ($iObjHeight - $iObjTop)
	$iBoderAddWidth = ($iObjWidth - $iObjLeft)

	if $iBoderAddWidth > $iBoderAddHeight then $iBoderAddWidth = $iBoderAddHeight

	;MouseMove( $iObjLeft, int($iObjTop ))
	;MouseClick("", $iObjLeft + ($iObjWidth -$iObjLeft) / 2, $iObjTop + ($iObjHeight- $iObjTop) / 2)
	;_ScreenCapture_Capture ( $sImageFile, int($iObjLeft - $iBoderAddWidth), int($iObjTop - $iBoderAddHeight), int($iObjWidth +  $iBoderAddWidth), int($iObjHeight + $iBoderAddHeight), False)


	; IE9�� ȣȯ�� ��������� ���� ��ǥ�� �������� ���ϴ� ��� ������ ����
	if IsNumber($oIEObj.getBoundingClientRect().left) = False then
		$aRetPos[0] =  False
	else
		$aRetPos[0] =  True
	endif

	return $aRetPos

EndFunc


;local $x = "1&2=:3#"
;convertHtmlChar($x, True)
;convertHtmlCharReverse($x)
;debug($x)

func convertHtmlChar(byref $sText, $bReverse = False)


	if $bReverse then

		convertHtmlCharItem($sText,chr(1), ";", $bReverse)
		convertHtmlCharItem($sText,chr(2), "&", $bReverse)

	else
		convertHtmlCharItem($sText,"&#59;", ";", $bReverse)
		convertHtmlCharItem($sText,"&#amp;", "&", $bReverse)
		convertHtmlCharItem($sText,"&#38;", "&", $bReverse)

	endif

	convertHtmlCharItem($sText,"&#58;", ":", $bReverse)
	convertHtmlCharItem($sText,"&#44;", ",", $bReverse)
	convertHtmlCharItem($sText,"&#61;", "=", $bReverse)
	convertHtmlCharItem($sText,"&#36;", "$", $bReverse)
	convertHtmlCharItem($sText,"&#34;", """", $bReverse)
	convertHtmlCharItem($sText,"&quot;", """", $bReverse)
	convertHtmlCharItem($sText,"&#92;", "\", $bReverse)
	convertHtmlCharItem($sText,"&#91;", "[", $bReverse)
	convertHtmlCharItem($sText,"&#93;", "]", $bReverse)
	convertHtmlCharItem($sText,"&gt;", ">", $bReverse)
	convertHtmlCharItem($sText,"&62;", ">", $bReverse)
	convertHtmlCharItem($sText,"&lt;", "<", $bReverse)
	convertHtmlCharItem($sText,"&60;", "<", $bReverse)
	convertHtmlCharItem($sText,"&#94;", "^", $bReverse)
	convertHtmlCharItem($sText,"&#124;", "|", $bReverse)
	convertHtmlCharItem($sText,"&#123;", "}", $bReverse)
	convertHtmlCharItem($sText,"&#125;", "{", $bReverse)
	convertHtmlCharItem($sText,"&nbsp;", " ", $bReverse)

	if $bReverse then

		convertHtmlCharItem($sText,"&#59;", chr(1), $bReverse)
		convertHtmlCharItem($sText,"&#amp;", chr(2), $bReverse)

	endif


endfunc


func convertHtmlCharItem(byref $sText, $sTxt1, $sTxt2, $bReverse)

	local $sTemp

	if $bReverse = True then
		$sTemp = $sTxt1
		$sTxt1 = $sTxt2
		$sTxt2 = $sTemp
	endif

	$sText = StringReplace($sText,$sTxt1, $sTxt2)

endfunc