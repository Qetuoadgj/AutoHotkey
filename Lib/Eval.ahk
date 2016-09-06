; ===================================================================================
; 		 ФУНКЦИЯ ПРЕОБРАЗОВАНИЯ СТРОК В ВЫРАЖЕНИЯ
; ===================================================================================
Eval(x)
{
   StringGetPos i, x, +, R
   StringGetPos j, x, -, R
   If (i > j)
      Return Left(x,i)+Right(x,i)
   If (j > i)
      Return Left(x,j)-Right(x,j)
   StringGetPos i, x, *, R
   StringGetPos j, x, /, R
   If (i > j)
      Return Left(x,i)*Right(x,i)
   If (j > i)
      Return Left(x,j)/Right(x,j)
   Return x
}
Left(x,i)
{
   StringLeft x, x, i
   Return Eval(x)
}
Right(x,i)
{
   StringTrimLeft x, x, i+1
   Return Eval(x)
}
