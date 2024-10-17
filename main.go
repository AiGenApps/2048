package main

import (
	"fmt"
	"math"
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
		tiles:    make([][]*fyne.Container, boardSize),
	}
	for i := range g.tiles {
		g.tiles[i] = make([]*fyne.Container, boardSize)
	}
	g.initBoard()
	return g
}

func (g *Game) initBoard() {
	g.board = [boardSize][boardSize]int{}
	g.addRandomTile()
	g.addRandomTile()
	// 移除这里的 g.updateUI() 调用
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
	if g.window == nil {
		return // 如果窗口还未初始化，直接返回
	}
	gridSize := float32(math.Min(float64(g.window.Canvas().Size().Width), float64(g.window.Canvas().Size().Height-70)))
	tileSize := gridSize / float32(boardSize)

	for i := 0; i < boardSize; i++ {
		for j := 0; j < boardSize; j++ {
			value := g.board[i][j]
			container := g.tiles[i][j]
			rect := container.Objects[0].(*canvas.Rectangle)
			label := container.Objects[1].(*canvas.Text)

			container.Resize(fyne.NewSize(tileSize, tileSize))
			container.Move(fyne.NewPos(float32(j)*tileSize, float32(i)*tileSize))

			if value == 0 {
				label.Text = ""
				rect.FillColor = color.RGBA{220, 220, 220, 255}
			} else {
				label.Text = strconv.Itoa(value)
				rect.FillColor = getTileColor(value)
				if value <= 4 {
					label.Color = color.RGBA{119, 110, 101, 255}
				} else {
					label.Color = color.RGBA{249, 246, 242, 255}
				}
			}
			label.TextSize = tileSize / 3
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

// 新增自定义布局
type gameLayout struct {
	grid        *fyne.Container
	scoreLabel  *widget.Label
	resetButton *widget.Button
}

func (g *gameLayout) Layout(objects []fyne.CanvasObject, size fyne.Size) {
	padding := float32(10)
	buttonHeight := float32(30)
	labelHeight := float32(30)

	// 计算可用于游戏网格的最大正方形尺寸
	gridSize := float32(math.Min(float64(size.Width), float64(size.Height-labelHeight-buttonHeight-3*padding)))

	// 计算垂直方向上的剩余空间
	verticalSpace := size.Height - gridSize - labelHeight - buttonHeight - 3*padding

	// 居中放置游戏网格
	g.grid.Resize(fyne.NewSize(gridSize, gridSize))
	g.grid.Move(fyne.NewPos((size.Width-gridSize)/2, labelHeight+padding+verticalSpace/2))

	// 放置分数标签
	g.scoreLabel.Resize(fyne.NewSize(size.Width, labelHeight))
	g.scoreLabel.Move(fyne.NewPos(0, padding))

	// 放置重置按钮
	g.resetButton.Resize(fyne.NewSize(size.Width, buttonHeight))
	g.resetButton.Move(fyne.NewPos(0, size.Height-buttonHeight-padding))
}

func (g *gameLayout) MinSize(objects []fyne.CanvasObject) fyne.Size {
	return fyne.NewSize(300, 350)
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

	customLayout := &gameLayout{
		grid:        grid,
		scoreLabel:  scoreLabel,
		resetButton: resetButton,
	}
	content := container.New(customLayout, scoreLabel, grid, resetButton)

	w.SetContent(content)
	w.Resize(fyne.NewSize(400, 500))
	w.SetFixedSize(false)

	// 在设置窗口内容后更新UI
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

	w.ShowAndRun()
}
