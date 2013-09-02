
#include-once

#include <WinAPI.au3>
#include <ScreenCapture.au3>
#include <GDIPlus.au3>
#include <Array.au3>

#include ".\_include_nhn\_util.au3"


;global $_iDebugTimeInit
;func writeDebugTimeLog($xxx)
;endfunc

local $iColor

;debug(getTransparentImageColor("d:\���̹�.png"))

;imagetest()

func imagetest()

local $x1
local $y1
local $left
local $top
local $width
local $height
local $result
local $aPos
local $bCrcCheck

;ocal $sFile = "D:\_Autoit\JT\����\���̾�Ÿ����ư3.png"
;local $sFile = "D:\_Autoit\JT\a.png"
;local $sFile = "D:\_Autoit\JT\�̹���\ȸ��Ұ�.png"
;local $sFile = "D:\_Autoit\JT\�̹���\�̳���.png"
;local $sFile = "D:\_Autoit\JT\�߰���ΰ�.png"
;local $sFile = "D:\_Autoit\JT\�߰���ΰ�2.png"
local $sFile = "D:\�Ÿ���.png"
;local $sFile = "D:\_Autoit\JT\�ְ���.png"
;local $sFile = "D:\_Autoit\JT\�����Ƚ�.png"

;
; find recycle bin and move to the center of it
; change 2nd argument to 0 to return the top left coord instead

$result = _ImageSearchArea2($sFile,1,1,1,2980,2084, $x1,$y1, 1, $aPos, True, $bCrcCheck)

if $result=1 Then
	;MouseMove($x1,$y1,3)
	_debug("ã�Ҿ�" )
	_debug($x1)
	_debug($y1)
	_debug($aPos)
	;MouseMove(1,1,3)
Else
	_debug("XXXXX")
EndIf

EndFunc


; ------------------------------------------------------------------------------
;
; AutoIt Version: 3.0
; Language:       English
; Description:    Functions that assist with Image Search
;                 Require that the ImageSearchDLL.dll be loadable
;
; ------------------------------------------------------------------------------

;===============================================================================
;
; Description:      Find the position of an image on the desktop
; Syntax:           _ImageSearchArea, _ImageSearch
; Parameter(s):
;                   $findImage - the image to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
; Note: Use _ImageSearch to search the entire desktop, _ImageSearchArea to specify
;       a desktop region to search
;
;===============================================================================
Func _ImageSearch($findImage,$resultPosition,ByRef $x, ByRef $y,$tolerance, byref $aPos)
   return _ImageSearchArea($findImage,$resultPosition,0,0,@DesktopWidth,@DesktopHeight,$x,$y,$tolerance, $aPos)
EndFunc


func ImageCheckSumGetSave($findImage,  $iImageWidth,  $iImageHeight)

	local $aCheckSum
	local $sHex

	$sHex = getImageHexData($findImage,  $iImageWidth,  $iImageHeight )
	$aCheckSum = setImageChecksum($sHex, $iImageWidth, $iImageHeight)

	return $aCheckSum

endfunc

Func _ImageSearchArea2($findImage,$resultPosition,$x1,$y1,$right,$bottom,ByRef $x, ByRef $y, $tolerance, byref $aPos, $bAllSearch, byref $bCRCCheck, $iTransparentColor = "")

local $sHex
local $iImageWidth
local $iImageHeight
local $aCheckSum
local $iResult
local $iCheckSum
local $tTimeInit = _TimerInit()
local $aX [1]
local $aY [1]
local $aLastPos
local $i
local $bAddSkip
local $bXSearch = False
local $iCurX
local $iCurY
local $iCurRight
local $iCurbottom
local $iLastSearchX
local $iLastSearchY
;$sHex = getImageHexData($findImage,  $iImageWidth,  $iImageHeight )
;$aCheckSum = setImageChecksum($sHex, $iImageWidth, $iImageHeight)

; ������ ���ϰ��� ����� �ƴ� ��� ���� �Ұ�
if $bAllSearch then $resultPosition = 0


$iCurX = $x1
$iCurY = $y1
$iCurRight = $right
$iCurbottom = $bottom
$bCRCCheck = False

do

	writeDebugTimeLog("�̹��� ã�� core : " &  " tolerance=" &  $tolerance & ",  x1 = " & $iCurX & " y1 = " & $iCurY & " x2 = " & $iCurRight & " y2 = " & $iCurbottom & ", file =" & $findImage )

	$iResult = _ImageSearchArea($findImage,$resultPosition,$iCurX,$iCurY,$iCurRight,$iCurbottom, $x,  $y, $tolerance,  $aPos, $iTransparentColor )
	;_debug("$findImage=" &  $findImage & " " & "x=" &  $iCurX & " " & "y=" &  $iCurY & " " & "$iCurRight=" &  $iCurRight & " " & "$iCurbottom=" &  $iCurbottom & " " & "$bXSearch=" &  $bXSearch & " " & "result=" &  $iResult )
	writeDebugTimeLog("�̹��� ã�� core �Ϸ�")
	;_debug($iResult)

	if $bXSearch and $iResult = 0 then

		$bXSearch = False
		$iCurX = $x1
		$iCurY = $iLastSearchY + 1
		$iCurbottom = $bottom
		$iResult = -1
	endif


	if $iResult = 1 then

		$bXSearch = True

		;_debug("�ӽ� ã�� : " & $findImage, $aPos[2], $aPos[3] )

		if $tolerance > 48  AND  IsArray($aCheckSum) = 0  then $aCheckSum = ImageCheckSumGetSave($findImage,  $iImageWidth,  $iImageHeight )


		if IsArray($aCheckSum) then
			$bCRCCheck = True
			writeDebugTimeLog("�̹��� ã�� checksum: " &  " " &  _TimerDiff($_iDebugTimeInit) & " x=" & $x & " y=" & $y)
			$iCheckSum = checkImageCheckSum($aCheckSum,$aPos[2], $aPos[3])
			writeDebugTimeLog("�̹��� ã�� checksum �Ϸ�: " &  " ��ġ��:" & $iCheckSum & " "  &  _TimerDiff($_iDebugTimeInit) & ", checksum ũ�� : " & ubound($aCheckSum))
			;_debug("üũ�� : " & $iCheckSum ,$x1,$y1 )
			if $iCheckSum > 70 then
				;_debug("üũ�� ã�� : " & $findImage)
				$iResult = 1
			else
				;_debug("��õ��� : " & $findImage)
				$iLastSearchX = $aPos[2]
				$iLastSearchY = $aPos[3]

				$iCurX = $iLastSearchX + 1
				$iCurY = $iLastSearchY
				$iCurbottom = $aPos[3] + $aPos[5]

				$iResult = -1
			endif
		else
			$iResult = 1
		endif


		if $iResult = 1 then
			writeDebugTimeLog("�̹��� ã�� ���� (�Ϲ�):  x=" & $x & " y=" & $y)
			if $bAllSearch Then
				; ��� ã��
				$bAddSkip = False

				for $i=1 to ubound($aX) -1
					if $aX[$i] = $x and $ay[$i] = $y then  $bAddSkip = True
				next

				if $bAddSkip = False then
					_arrayadd($aX,$x)
					_arrayadd($aY,$y)


				endif

				$aLastPos = $aPos
				;_debug($aLastPos)

				$iLastSearchX = $aPos[2]
				$iLastSearchY = $aPos[3]

				$iCurX = $iLastSearchX + 1
				$iCurY = $iLastSearchY
				$iCurbottom = $aPos[3] + $aPos[5]

				;_msg($aPos)

				$iResult = -1

				if ubound ($aX) > 100 then
					writeDebugTimeLog("�̹��� ã�� 100�� �Ѿ ���� ã�� �ߴ�!")
					$iResult = 1
				endif

			endif
		endif

	endif

until $iResult <> -1 or (_TimerDiff($tTimeInit) > 15000)

if $bAllSearch Then
	if ubound($aX) > 1 then $iResult = 1
	$x = $aX
	$y = $aY
	$aPos = $aLastPos
endif

return $iResult

EndFunc

Func _ImageSearchArea($findImage,$resultPosition,$x1,$y1,$right,$bottom,ByRef $x, ByRef $y, $tolerance, byref $aPos, $iTransparentColor = "" )

	local $array
	local $result
	local $sErrorCode

	if $tolerance>0 then $findImage = "*" & $tolerance & " " & $findImage

	if $iTransparentColor <> "" then $findImage = "*Trans0x" & $iTransparentColor & " " & $findImage

	;debug($findImage)

	;$findImage = "*Trans0xFFFFFF"

	$result = DllCall(@ScriptDir & "\ImageSearchDLL.dll","str","ImageSearch","int",$x1,"int",$y1,"int",$right,"int",$bottom,"str",$findImage)
	$sErrorCode = @error

	; If error exit
	if IsArray($result) then
		if $result[0]="0" then return 0
	Else
		_msg("�̹��� DLL ���� ���ɼ� 1�� " & $sErrorCode )
		return 0
	endif

	; Otherwise get the x,y location of the match and the size of the image to
	; compute the centre of search
	$array = StringSplit($result[0],"|")

	for $i=0 to ubound($array) -1
		if $array[$i] <> "" then $array[$i] = number($array[$i])
	next

   $x=Int(Number($array[2]))
   $y=Int(Number($array[3]))
   if $resultPosition=1 then
      $x=$x + Int(Number($array[4])/2)
      $y=$y + Int(Number($array[5])/2)
  endif

  $aPos = $array
   return 1

EndFunc

;===============================================================================
;
; Description:      Wait for a specified number of seconds for an image to appear
;
; Syntax:           _WaitForImageSearch, _WaitForImagesSearch
; Parameter(s):
;					$waitSecs  - seconds to try and find the image
;                   $findImage - the image to locate on the desktop
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
; Return Value(s):  On Success - Returns 1
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImageSearch($findImage,$waitSecs,$resultPosition,ByRef $x, ByRef $y,$tolerance, byref $aPos)
	local $startTime
	local $result
	$waitSecs = $waitSecs * 1000
	$startTime=_TimerInit()
	While _TimerDiff($startTime) < $waitSecs
		sleep(100)
		$result=_ImageSearch($findImage,$resultPosition,$x, $y,$tolerance, $aPos)
		if $result > 0 Then
			return 1
		EndIf
	WEnd
	return 0
EndFunc

;===============================================================================
;
; Description:      Wait for a specified number of seconds for any of a set of
;                   images to appear
;
; Syntax:           _WaitForImagesSearch
; Parameter(s):
;					$waitSecs  - seconds to try and find the image
;                   $findImage - the ARRAY of images to locate on the desktop
;                              - ARRAY[0] is set to the number of images to loop through
;								 ARRAY[1] is the first image
;                   $tolerance - 0 for no tolerance (0-255). Needed when colors of
;                                image differ from desktop. e.g GIF
;                   $resultPosition - Set where the returned x,y location of the image is.
;                                     1 for centre of image, 0 for top left of image
;                   $x $y - Return the x and y location of the image
;
; Return Value(s):  On Success - Returns the index of the successful find
;                   On Failure - Returns 0
;
;
;===============================================================================
Func _WaitForImagesSearch($findImage,$waitSecs,$resultPosition,ByRef $x, ByRef $y,$tolerance, byref $aPos)
	local $startTime
	local $result
	$waitSecs = $waitSecs * 1000
	$startTime=_TimerInit()
	While _TimerDiff($startTime) < $waitSecs
		for $i = 1 to $findImage[0]
		    sleep(100)
		    $result=_ImageSearch($findImage[$i],$resultPosition,$x, $y,$tolerance, $aPos)
		    if $result > 0 Then
			    return $i
		    EndIf
		Next
	WEnd
	return 0
EndFunc




func getImageHexData($sFile, byref $iImageWidth, byref $iImageHeight )

	local $hImage
	local $width
	local $height
	local $hBmp
	local $aSize
	local $tBits
	local $sHex

    _GDIPlus_Startup()

    $hImage = _GDIPlus_ImageLoadFromFile($sFile)
    $width = _GDIPlus_ImageGetWidth($hImage)
    $height = _GDIPlus_ImageGetHeight($hImage)
    $hBmp = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)

	$iImageWidth = $width
	$iImageHeight = $height

    $aSize = DllCall('gdi32.dll', 'int', 'GetBitmapBits', 'ptr', $hBmp, 'int', 0, 'ptr', 0)
    If $aSize[0] Then
        $tBits = DllStructCreate('byte[' & $aSize[0] & ']')
        DllCall('gdi32.dll', 'int', 'GetBitmapBits', 'ptr', $hBmp, 'int', $aSize[0], 'ptr', DllStructGetPtr($tBits))
        $sHex = Hex(DllStructGetData($tBits, 1))
	endif

    _WinAPI_DeleteObject($hBmp)
    _GDIPlus_ImageDispose($hImage)
    _GDIPlus_Shutdown()

	return $sHex

endfunc

func getImageSize($sFile, byref $iImageWidth, byref $iImageHeight )

	local $hImage
	local $width
	local $height
	local $hBmp
	local $aSize
	local $tBits
	local $sHex

    _GDIPlus_Startup()

    $hImage = _GDIPlus_ImageLoadFromFile($sFile)
    $width = _GDIPlus_ImageGetWidth($hImage)
    $height = _GDIPlus_ImageGetHeight($hImage)

	$iImageWidth = number($width)
	$iImageHeight = number($height)

    _GDIPlus_ImageDispose($hImage)
    _GDIPlus_Shutdown()

	return

endfunc


func getPxcel($x,$y, byref $sHex, $iImageWidth, $iImageHeight)

	local $sColor = ""
	local $iPos

	$iPos = ($y-1) * 4 * $iImageWidth
	$iPos += ($x-1) * 4
	$iPos = $iPos * 2
	$iPos += 1

	;debug($iPos )
	;_debug($sHex )

	$sColor = stringmid($sHex, $iPos + 4,2)
	$sColor = $sColor & stringmid($sHex, $iPos + 2,2)
	$sColor = $sColor & stringmid($sHex, $iPos + 0,2)

	return $sColor

Endfunc


func getTransparentImageColor($findImage)
; �簢 �𼭸� 4�� ��ǥ�� Į�� ���� ��� ������ ��� �ش� Į���� ����, �ƴ� ��� "" ����

	local $y, $x
	local $z
	local $iStepX, $iStepY
	local $iCheckSumCount = 0
	local $iImageWidth, $iImageHeight
	local $aImageCheckSum[1][4]
	local $aCheckSum
	local $sHex
	local $i
	local $aColorValue[5]
	local $iColor

	$sHex = getImageHexData($findImage,  $iImageWidth,  $iImageHeight )

	redim $aImageCheckSum[$iImageWidth * $iImageHeight + 1][4]

	$iStepY = int(($iImageHeight / 5))
	$iStepX = int(($iImageWidth / 5))

	if $iStepY <= 0 then $iStepY = 1
	if $iStepX <= 0 then $iStepX = 1

	$aColorValue[1] = getPxcel(1,1, $sHex, $iImageWidth,  $iImageHeight)
	$aColorValue[2] = getPxcel($iImageWidth,1, $sHex, $iImageWidth,  $iImageHeight)
	$aColorValue[3] = getPxcel(1,$iImageHeight, $sHex, $iImageWidth,  $iImageHeight)
	$aColorValue[4] = getPxcel($iImageWidth,$iImageHeight, $sHex, $iImageWidth,  $iImageHeight)

	;debug($iImageWidth, $iImageHeight)

	;msg($aColorValue)

	$iColor = $aColorValue[1]

	for $i=1 to 3
		if $aColorValue[$i] <> $aColorValue[$i+1] then $iColor = ""
	next

	return $iColor

endfunc


func setImageChecksum(byref $sHex, $iImageWidth, $iImageHeight)

	local $y, $x
	local $z
	local $iStepX, $iStepY
	local $iCheckSumCount = 0
	local $aImageCheckSum[$iImageWidth * $iImageHeight + 1][4]

	$iStepY = int(($iImageHeight / 5))
	$iStepX = int(($iImageWidth / 5))

	if $iStepY <= 0 then $iStepY = 1
	if $iStepX <= 0 then $iStepX = 1

	for $y=1 to $iImageHeight step $iStepY
		$z=$z+1
		for $x=$z to $iImageWidth step $iStepX
			$iCheckSumCount +=1
			$aImageCheckSum [$iCheckSumCount][1] = $x
			$aImageCheckSum [$iCheckSumCount][2] = $y
			$aImageCheckSum [$iCheckSumCount][3] = getPxcel($x,$y, $sHex, $iImageWidth, $iImageHeight)
		next
	next

	redim $aImageCheckSum[$iCheckSumCount+1][4]
	return $aImageCheckSum

endfunc


func checkImageCheckSum($aImageCheckSum, $iBaseX,  $iBaseY)

	local $i
	local $x
	local $y
	local $iColor
	local $iGetColor
	local $aSearchResult
	local $iSuccessCount
	local $iResult
	local $iTimer

	;$iTimer = _TimerInit()
	;_debug("�̹��� checksum ���� : " & ubound($aImageCheckSum))

	for $i=1 to ubound ($aImageCheckSum) -1

		$x = $iBaseX + $aImageCheckSum[$i][1] - 1
		$y = $iBaseY + $aImageCheckSum[$i][2] - 1
		$iColor = $aImageCheckSum[$i][3]

		$aSearchResult = PixelSearch ( $x, $y, $x, $y, "0x" & $iColor, 30)
		if IsArray($aSearchResult) Then $iSuccessCount += 1

		;_debug ("�ȼ�Į�� : " & $iColor & " " & hex(PixelGetColor ($x, $y),6) & " " & IsArray($aSearchResult) & " " & TimerDiff($_iDebugTimeInit) )

		;if Dec($iColor) = PixelGetColor ($x, $y) then $iSuccessCount += 1

	next

	;_debug("�ҿ�ð� : " & _TimerDiff($iTimer))


	$iResult = ($iSuccessCount / (ubound ($aImageCheckSum) -1)) * 100

	;_debug("�ȼ� �˻�% : " & $iResult)

	return $iResult

endfunc