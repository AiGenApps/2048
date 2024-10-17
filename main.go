package main

import (
	"image/color"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/canvas"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/widget"
)

// 从 game.go 导入
const boardSize = 4

func main() {
	a := app.New()

	icon := fyne.NewStaticResource("icon", IconResource)
	a.SetIcon(icon)

	w := a.NewWindow("2048")

	game := NewGame() // 改为大写的 NewGame
	game.window = w

	scoreLabel := widget.NewLabel("分数: 0")
	game.scoreLabel = scoreLabel

	resetButton := widget.NewButton("重新开始", func() {
		game.ResetGame() // 改为大写的 ResetGame
	})

	grid := container.NewGridWithColumns(boardSize)

	for i := 0; i < boardSize; i++ {
		for j := 0; j < boardSize; j++ {
			rect := canvas.NewRectangle(color.RGBA{220, 220, 220, 255})

			label := canvas.NewText("", color.Black)
			label.Alignment = fyne.TextAlignCenter

			tile := container.NewMax(rect, label)
			game.tiles[i][j] = tile
			grid.Add(tile)
		}
	}

	customLayout := NewGameLayout(grid, scoreLabel, resetButton) // 使用新的构造函数
	content := container.New(customLayout, scoreLabel, grid, resetButton)

	w.SetContent(content)
	w.Resize(fyne.NewSize(400, 500))
	w.SetFixedSize(false)

	game.UpdateUI() // 改为大写的 UpdateUI

	w.Canvas().SetOnTypedKey(func(k *fyne.KeyEvent) {
		if !game.gameOver {
			switch k.Name {
			case fyne.KeyUp:
				game.Move("up") // 改为大写的 Move
			case fyne.KeyDown:
				game.Move("down")
			case fyne.KeyLeft:
				game.Move("left")
			case fyne.KeyRight:
				game.Move("right")
			}
		}
	})

	w.ShowAndRun()
}
