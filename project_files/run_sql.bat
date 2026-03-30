@echo off
REM Try to find and run mysql
for /F "tokens=*" %%i in ('where mysql.exe 2^>nul') do (
    set "MYSQL_PATH=%%i"
    goto :found
)

REM If not found in PATH, try common installation directories
if not defined MYSQL_PATH (
    if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" (
        set "MYSQL_PATH=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
    )
)

if not defined MYSQL_PATH (
    echo MySQL not found
    exit /b 1
)

:found
echo Found MySQL at: %MYSQL_PATH%
"%MYSQL_PATH%" -u root -p "" spcms_db < insert_test_users.sql
echo Insert completed
