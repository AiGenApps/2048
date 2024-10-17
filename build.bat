@echo off
if not exist "build" mkdir build
fyne package -os windows -icon icon.png -executable build\2048.exe

