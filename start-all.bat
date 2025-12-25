@echo off
chcp 65001 >nul
echo ========================================
echo  在线考试系统 - 一键启动
echo ========================================
echo.
echo 正在启动系统，请稍候...
echo.

cd /d D:\Desktop\Examination-System

echo [1/2] 启动后端服务（端口8080）...
start "后端服务" cmd /k "start-backend.bat"
timeout /t 3 /nobreak >nul

echo [2/2] 启动前端服务（端口3000）...
start "前端服务" cmd /k "start-frontend.bat"

echo.
echo ========================================
echo  系统启动中...
echo ========================================
echo.
echo 后端服务: http://localhost:8080
echo 前端界面: http://localhost:3000
echo API文档:  http://localhost:8080/doc.html
echo.
echo 请等待约30秒，服务启动完成后访问前端界面
echo.
pause

