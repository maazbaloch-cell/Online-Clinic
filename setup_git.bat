@echo off
echo Initializing Git and Connecting to GitHub...
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/maazbaloch-cell/Online-Clinic.git
echo.
echo Trying to push to GitHub...
git push -u origin main
echo.
echo If it asks for login, please log in in the browser window.
pause
