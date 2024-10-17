@echo off
echo Building 2048 for Web...

REM Create web directory if it doesn't exist
if not exist "web" mkdir web

REM Build for WebAssembly
set GOOS=js
set GOARCH=wasm
go build -o web/2048.wasm

REM Copy wasm_exec.js from Go installation
for /f "delims=" %%i in ('go env GOROOT') do set GOROOT=%%i
copy "%GOROOT%\misc\wasm\wasm_exec.js" web\

REM Create index.html
echo ^<!doctype html^> > web\index.html
echo ^<html^> >> web\index.html
echo ^<head^> >> web\index.html
echo     ^<meta charset="utf-8"^> >> web\index.html
echo     ^<title^>2048 Game^</title^> >> web\index.html
echo     ^<style^> >> web\index.html
echo         body { font-family: Arial, sans-serif; } >> web\index.html
echo     ^</style^> >> web\index.html
echo     ^<script src="wasm_exec.js"^>^</script^> >> web\index.html
echo     ^<script^> >> web\index.html
echo         if (!WebAssembly.instantiateStreaming) { >> web\index.html
echo             WebAssembly.instantiateStreaming = async (resp, importObject) =^> { >> web\index.html
echo                 const source = await (await resp).arrayBuffer(); >> web\index.html
echo                 return await WebAssembly.instantiate(source, importObject); >> web\index.html
echo             }; >> web\index.html
echo         } >> web\index.html
echo         const go = new Go(); >> web\index.html
echo         WebAssembly.instantiateStreaming(fetch("2048.wasm"), go.importObject).then((result) =^> { >> web\index.html
echo             go.run(result.instance); >> web\index.html
echo         }); >> web\index.html
echo     ^</script^> >> web\index.html
echo ^</head^> >> web\index.html
echo ^<body^>^</body^> >> web\index.html
echo ^</html^> >> web\index.html

echo Build complete. Web files are in the 'web' directory.
echo To run, use a web server to serve the 'web' directory.
echo For example, you can use Python's built-in server:
echo python -m http.server -d web
