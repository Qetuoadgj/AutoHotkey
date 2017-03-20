; ===================================================================================
;                           ФУНКЦИЯ ОЧИСТКИ БУФЕРА ОБМЕНА
; ===================================================================================
ClipboardEmpty(t:=100) {
  local empty
  Try {
    Clipboard := empty ; if there is an error wait for one second and try again
  } Catch {
    Sleep,500
    Clipboard := empty 
  } 
  If (t > 0) {
    Sleep,%t%
  }
}
