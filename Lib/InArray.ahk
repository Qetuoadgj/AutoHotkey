; ===================================================================================
; 											ФУНКЦИЯ ПРОВЕРКИ НАЛИЧИЯ ЗНАЧЕНЯ ВО МНОЖЕСТВЕ
; ===================================================================================
InArray(haystack,needle) {
  If(not isObject(haystack)) {
    Return,False
  }
  If(haystack.Length() == 0) {
    Return,False
  }
  For k,v in haystack {
    If(v == needle){
      Return,True
    }
  }
  Return,False
}
