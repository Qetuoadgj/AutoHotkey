; ===================================================================================
; 											ФУНКЦИЯ ОБРАБОТКИ ПЕРЕМЕННЫХ СРЕДЫ
; ===================================================================================
; #Include Lib\ExpandEnvironmentStrings.ahk

ParseEnvironmentVariables(String)
{
  String := ExpandEnvironmentStrings(String)
  Loop, Parse, String, "\:"
  {
    Line := A_LoopField
    Line := RegExReplace(Line, "^%(.*)%$", "$1")
    if RegExMatch(Line, "^A_\w+?$")
    {
      matched = % %Line%
      String := StrReplace(String, A_LoopField, matched)
    }
  }
  Return String
}
