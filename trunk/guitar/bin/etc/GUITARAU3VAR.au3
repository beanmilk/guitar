#include-once
; ������ ������Ʈ���� Ȱ���Ͽ� GUITAR�� ���� ������ ��ȯ�ϴµ� �����.

func _GUITAR_AU3VARWrite ($sName, $sValue)
	;_debug($sName, $sValue)
	return RegWrite("HKEY_LOCAL_MACHINE\Software\GUITAR\VAR" , $sName, "REG_SZ", $sValue)
endfunc

func _GUITAR_AU3VARRead ($sName)
	;_debug(RegRead("HKEY_LOCAL_MACHINE\Software\GUITAR\VAR" , $sName))
	return RegRead("HKEY_LOCAL_MACHINE\Software\GUITAR\VAR" , $sName)
endfunc

