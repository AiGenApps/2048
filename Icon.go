package main

import (
	_ "embed"
)

//go:embed icon.png
var IconResource []byte // 注意这里改为大写字母开头
