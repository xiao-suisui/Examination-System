@echo off
echo ========================================
echo  在线考试系统 - 前端服务启动
echo ========================================
echo.

cd /d D:\Desktop\Examination-System\frontend

echo [1/3] 检查端口占用...
netstat -ano | findstr ":3000" >nul
if %errorlevel% equ 0 (
    echo 警告: 端口3000已被占用，请先关闭占用该端口的程序
    pause
    exit
)

echo [2/3] 检查依赖...
if not exist "node_modules" (
    echo 首次运行，正在安装依赖...
    call npm install
)

echo [3/3] 启动前端服务...
echo 提示: 按 Ctrl+C 可以停止服务
echo 访问地址: http://localhost:3000
echo.

call npm run dev

pause

