ExpandEnvironmentStrings(String)
{ ; функция обработки переменных среды Windows
  local
  NULL := ""
  ; Find length of dest string:
  nSize := DllCall("ExpandEnvironmentStrings", "Str", string, "Str", NULL, "UInt", 0, "UInt")
  ,VarSetCapacity(Dest, size := (nSize * (1 << !!A_IsUnicode)) + !A_IsUnicode) ; allocate dest string
  ,DllCall("ExpandEnvironmentStrings", "Str", String, "Str", Dest, "UInt", size, "UInt") ; fill dest string
  return Dest
}

ExpandEnvironmentStringsAHK(String)
{ ; функция обработки переменных среды AHK
  local
  Loop Parse, String, "\:"
  {
    Line := A_LoopField
    if RegExMatch(Line, "^%(A_\w+)%$", Match)
    {
      Expanded := %Match1%
      String := StrReplace(String, A_LoopField, Expanded)
    }
  }
  return String
}

ExpandEnvironmentVariables(String)
{ ; функция совместной обработки переменных AHK и Windows
  return ExpandEnvironmentStringsAHK(ExpandEnvironmentStrings(String))
}
