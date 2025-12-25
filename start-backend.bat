@echo off
echo ========================================
echo  在线考试系统 - 后端服务启动
echo ========================================
echo.

cd /d D:\Desktop\Examination-System

echo [1/3] 检查端口占用...
netstat -ano | findstr ":8080" >nul
if %errorlevel% equ 0 (
    echo 警告: 端口8080已被占用，请先关闭占用该端口的程序
    pause
    exit
)

echo [2/3] 启动后端服务...
echo 提示: 按 Ctrl+C 可以停止服务
echo.

"D:\Program\IntelliJ IDEA 2024.3.4.1\plugins\maven\lib\maven3\bin\mvn.cmd" spring-boot:run

pause

