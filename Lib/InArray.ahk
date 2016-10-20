; ===================================================================================
; 											ФУНКЦИЯ ПРОВЕРКИ НАЛИЧИЯ ЗНАЧЕНЯ ВО МНОЖЕСТВЕ
; ===================================================================================
InArray(haystack,needle) {
  if(!isObject(haystack)) {
    return false
  }
  if(haystack.Length()==0) {
    return false
  }
  for k,v in haystack {
    if(v==needle){
      return true
    }
  }
  return false
}
