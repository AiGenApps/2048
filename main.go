package main

import (
	"fmt"
	"math/rand"
	"strconv"

	"image/color"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/canvas"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/widget"
)

const (
	boardSize = 4
)

type Game struct {
	board      [boardSize][boardSize]int
	score      int
	gameOver   bool
	window     fyne.Window
	tiles      [][]*fyne.Container
	scoreLabel *widget.Label
}

func newGame() *Game {
	g := &Game{
		score:    0,
		gameOver: false,
	}
	g.initBoard()
	return g
}

func (g *Game) initBoard() {
	g.board = [boardSize][boardSize]int{}
	g.addRandomTile()
	g.addRandomTile()
}

func (g *Game) addRandomTile() {
	emptyCells := []struct{ x, y int }{}
	for i := 0; i < boardSize; i++ {
		for j := 0; j < boardSize; j++ {
			if g.board[i][j] == 0 {
				emptyCells = append(emptyCells, struct{ x, y int }{i, j})
			}
		}
	}
	if len(emptyCells) > 0 {
		cell := emptyCells[rand.Intn(len(emptyCells))]
		g.board[cell.x][cell.y] = 2
	}
}

func (g *Game) updateUI() {
	for i := 0; i < boardSize; i++ {
		for j := 0; j < boardSize; j++ {
			value := g.board[i][j]
			container := g.tiles[i][j]
			rect := container.Objects[0].(*canvas.Rectangle)
			label := container.Objects[1].(*canvas.Text)

			if value == 0 {
				label.Text = ""
				rect.FillColor = color.RGBA{220, 220, 220, 255}
			} else {
				label.Text = strconv.Itoa(value)
				rect.FillColor = getTileColor(value)
				// 设置文本颜色
				if value <= 4 {
					label.Color = color.RGBA{119, 110, 101, 255} // 深棕色
				} else {
					label.Color = color.RGBA{249, 246, 242, 255} // 几乎白色
				}
			}
			label.Refresh()
			rect.Refresh()
		}
	}
	g.scoreLabel.SetText(fmt.Sprintf("分数: %d", g.score))
}

func (g *Game) move(direction string) {
	moved := false
	switch direction {
	case "up":
		moved = g.moveUp()
	case "down":
		moved = g.moveDown()
	case "left":
		moved = g.moveLeft()
	case "right":
		moved = g.moveRight()
	}

	if moved {
		g.addRandomTile()
		g.updateUI()
		if g.isGameOver() {
			g.gameOver = true
			g.showGameOverDialog()
		}
	}
}

func (g *Game) moveLeft() bool {
	moved := false
	for i := 0; i < boardSize; i++ {
		merged := false
		for j := 1; j < boardSize; j++ {
			if g.board[i][j] != 0 {
				for k := j - 1; k >= 0; k-- {
					if g.board[i][k] == 0 {
						g.board[i][k] = g.board[i][k+1]
						g.board[i][k+1] = 0
						moved = true
					} else if g.board[i][k] == g.board[i][k+1] && !merged {
						g.board[i][k] *= 2
						g.score += g.board[i][k]
						g.board[i][k+1] = 0
						merged = true
						moved = true
						break
					} else {
						break
					}
				}
			}
		}
	}
	return moved
}

func (g *Game) moveRight() bool {
	moved := false
	for i := 0; i < boardSize; i++ {
		merged := false
		for j := boardSize - 2; j >= 0; j-- {
			if g.board[i][j] != 0 {
				for k := j + 1; k < boardSize; k++ {
					if g.board[i][k] == 0 {
						g.board[i][k] = g.board[i][k-1]
						g.board[i][k-1] = 0
						moved = true
					} else if g.board[i][k] == g.board[i][k-1] && !merged {
						g.board[i][k] *= 2
						g.score += g.board[i][k]
						g.board[i][k-1] = 0
						merged = true
						moved = true
						break
					} else {
						break
					}
				}
			}
		}
	}
	return moved
}

func (g *Game) moveUp() bool {
	moved := false
	for j := 0; j < boardSize; j++ {
		merged := false
		for i := 1; i < boardSize; i++ {
			if g.board[i][j] != 0 {
				for k := i - 1; k >= 0; k-- {
					if g.board[k][j] == 0 {
						g.board[k][j] = g.board[k+1][j]
						g.board[k+1][j] = 0
						moved = true
					} else if g.board[k][j] == g.board[k+1][j] && !merged {
						g.board[k][j] *= 2
						g.score += g.board[k][j]
						g.board[k+1][j] = 0
						merged = true
						moved = true
						break
					} else {
						break
					}
				}
			}
		}
	}
	return moved
}

func (g *Game) moveDown() bool {
	moved := false
	for j := 0; j < boardSize; j++ {
		merged := false
		for i := boardSize - 2; i >= 0; i-- {
			if g.board[i][j] != 0 {
				for k := i + 1; k < boardSize; k++ {
					if g.board[k][j] == 0 {
						g.board[k][j] = g.board[k-1][j]
						g.board[k-1][j] = 0
						moved = true
					} else if g.board[k][j] == g.board[k-1][j] && !merged {
						g.board[k][j] *= 2
						g.score += g.board[k][j]
						g.board[k-1][j] = 0
						merged = true
						moved = true
						break
					} else {
						break
					}
				}
			}
		}
	}
	return moved
}

func (g *Game) isGameOver() bool {
	for i := 0; i < boardSize; i++ {
		for j := 0; j < boardSize; j++ {
			if g.board[i][j] == 0 {
				return false
			}
			if i < boardSize-1 && g.board[i][j] == g.board[i+1][j] {
				return false
			}
			if j < boardSize-1 && g.board[i][j] == g.board[i][j+1] {
				return false
			}
		}
	}
	return true
}

func getTileColor(value int) color.Color {
	switch value {
	case 2:
		return color.RGBA{238, 228, 218, 255}
	case 4:
		return color.RGBA{237, 224, 200, 255}
	case 8:
		return color.RGBA{242, 177, 121, 255}
	case 16:
		return color.RGBA{245, 149, 99, 255}
	case 32:
		return color.RGBA{246, 124, 95, 255}
	case 64:
		return color.RGBA{246, 94, 59, 255}
	case 128:
		return color.RGBA{237, 207, 114, 255}
	case 256:
		return color.RGBA{237, 204, 97, 255}
	case 512:
		return color.RGBA{237, 200, 80, 255}
	case 1024:
		return color.RGBA{237, 197, 63, 255}
	case 2048:
		return color.RGBA{237, 194, 46, 255}
	default:
		return color.RGBA{60, 58, 50, 255}
	}
}

func (g *Game) showGameOverDialog() {
	dialog.ShowConfirm("游戏结束", fmt.Sprintf("您的得分是: %d\n是否重新开始？", g.score), func(restart bool) {
		if restart {
			g.resetGame()
		}
	}, g.window)
}

func (g *Game) resetGame() {
	g.score = 0
	g.gameOver = false
	g.initBoard()
	g.updateUI()
}

func main() {
	fmt.Println("hello")
	a := app.New()

	icon := fyne.NewStaticResource("icon", IconResource)
	a.SetIcon(icon)

	w := a.NewWindow("2048")

	game := newGame()
	game.window = w

	scoreLabel := widget.NewLabel("分数: 0")
	game.scoreLabel = scoreLabel

	resetButton := widget.NewButton("重新开始", func() {
		game.resetGame()
	})

	grid := container.NewGridWithColumns(boardSize)
	game.tiles = make([][]*fyne.Container, boardSize)

	for i := 0; i < boardSize; i++ {
		game.tiles[i] = make([]*fyne.Container, boardSize)
		for j := 0; j < boardSize; j++ {
			rect := canvas.NewRectangle(color.RGBA{220, 220, 220, 255})
			rect.SetMinSize(fyne.NewSize(60, 60))

			label := canvas.NewText("", color.Black)
			label.Alignment = fyne.TextAlignCenter
			label.TextStyle = fyne.TextStyle{Bold: true}
			label.TextSize = 20

			tile := container.NewMax(rect, label)
			game.tiles[i][j] = tile
			grid.Add(tile)
		}
	}

	game.updateUI()

	w.Canvas().SetOnTypedKey(func(k *fyne.KeyEvent) {
		if !game.gameOver {
			switch k.Name {
			case fyne.KeyUp:
				game.move("up")
			case fyne.KeyDown:
				game.move("down")
			case fyne.KeyLeft:
				game.move("left")
			case fyne.KeyRight:
				game.move("right")
			}
		}
	})

	content := container.NewVBox(
		scoreLabel,
		grid,
		resetButton,
	)

	w.SetContent(content)
	w.Resize(fyne.NewSize(300, 350))
	w.ShowAndRun()
}
