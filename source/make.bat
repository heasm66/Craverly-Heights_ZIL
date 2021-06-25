..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zilf.exe -w craverlyheights_zil.zil
..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zapf.exe -ab craverlyheights_zil.zap > craverlyheights_zil_freq.xzap
del craverlyheights_zil_freq.zap
..\..\..\..\Source\ZIL\ZILF\zilf-0.9.0-win-x64\bin\Zapf.exe craverlyheights_zil.zap
del /F /Q ..\bin\*.*
del /F /Q ..\zapf\*.*
move *.zap ..\zapf\
move *.xzap ..\zapf\
move *.dbg ..\zapf\
move *.z5 ..\bin\
pause
