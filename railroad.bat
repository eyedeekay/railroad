@echo off

if exist "%LOCALAPPDATA%\railroad" (
  echo "profile is configured"
) else (
  echo "configuring profile"
  xcopy /s /i /y "%PROGRAMFILES%\railroad" "%LOCALAPPDATA%\railroad"
)

REM start /D "%LOCALAPPDATA%\railroad" "railroad-blog" 

"%LOCALAPPDATA%/railroad/railroad.exe" 