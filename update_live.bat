@echo off
echo Updating your live project...
git add .
set /p msg="Enter update message (e.g. fixed login): "
git commit -m "%msg%"
git push origin main
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Push failed! Trying 'master' branch...
    git push origin master
)
echo.
echo [SUCCESS] Project updated! Wait 1-2 minutes for the live link to refresh.
pause
de