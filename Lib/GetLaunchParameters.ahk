; ===================================================================================
; 				ФУНКЦИЯ ПОЛУЧЕНИЯ ДОПОЛНИТЕЛЬНЫХ ПАРАМЕТРОВ ЗАПУСКА ПРИЛОЖЕНИЯ
; ===================================================================================
/* ДЛЯ ПРАВИЛЬНОЙ РАБОТЫ НЕОБХОДИМО ДОБАВИТЬ В НАЧАЛО ФАЙЛА СЛЕДУЮЩИЕ СТРОКИ:
global NumberOfParameters
NumberOfParameters = %0%
*/

GetLaunchParameters(DefaultParameters) {
  If (not NumberOfParameters) {
    Parameters := DefaultParameters
  } else {
  Loop,%NumberOfParameters%
    {
      Parameter := %A_Index%
      Parameters = %Parameters% %Parameter%
    }
  }
  Return %Parameters%
}