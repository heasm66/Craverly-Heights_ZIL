@echo off

REM *** BUILD Z3-VERSION ***
IF EXIST version.zil ( del version.zil )
echo ^<VERSION ZIP^> > version.zil
..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zilf.exe -w craverlyheights_zil.zil
IF NOT EXIST craverlyheights_zil_freq.xzap (
	..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zapf.exe -ab craverlyheights_zil.zap > craverlyheights_zil_freq.xzap )
IF EXIST craverlyheights_zil_freq.zap ( 
	del craverlyheights_zil_freq.zap )
..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zapf.exe craverlyheights_zil.zap
del /F /Q ..\zapf\*.zap
del /F /Q ..\zapf\*.xzap
move *.zap ..\zapf\

REM *** BUILD Z4-VERSION ***
IF EXIST version.zil ( del version.zil )
echo ^<VERSION EZIP^> > version.zil
..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zilf.exe -w craverlyheights_zil.zil
IF EXIST craverlyheights_zil_freq.zap ( 
	del craverlyheights_zil_freq.zap )
..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zapf.exe craverlyheights_zil.zap
del /F /Q ..\zapf\*.zap
del /F /Q ..\zapf\*.xzap
move *.zap ..\zapf\

REM *** BUILD Z8-VERSION ***
IF EXIST version.zil ( del version.zil )
echo ^<VERSION 8^> > version.zil
..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zilf.exe -w craverlyheights_zil.zil
IF EXIST craverlyheights_zil_freq.zap ( 
	del craverlyheights_zil_freq.zap )
..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zapf.exe craverlyheights_zil.zap
del /F /Q ..\zapf\*.zap
del /F /Q ..\zapf\*.xzap
move *.zap ..\zapf\

REM *** BUILD Z5-VERSION ***
IF EXIST version.zil ( del version.zil )
echo ^<VERSION XZIP^> > version.zil
..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zilf.exe -w craverlyheights_zil.zil
IF EXIST craverlyheights_zil_freq.zap ( 
	del craverlyheights_zil_freq.zap )
..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zapf.exe craverlyheights_zil.zap
del /F /Q ..\zapf\*.zap
del /F /Q ..\zapf\*.xzap
move *.zap ..\zapf\

REM Activate line below if you want to regenerate abbreviations next time
REM move *.xzap ..\zapf\
 
move *.dbg ..\zapf\
IF EXIST *.z3 (
	del /F /Q ..\bin\*.z3
	move *.z3 ..\bin\ )
IF EXIST *.z4 (
	del /F /Q ..\bin\*.z4
	move *.z4 ..\bin\ )
IF EXIST *.z5 (
	del /F /Q ..\bin\*.z5
	move *.z5 ..\bin\ )
IF EXIST *.z8 (
	del /F /Q ..\bin\*.z8
	move *.z8 ..\bin\ )	

pause
