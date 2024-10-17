package main

import (
	"fmt"
	"math/rand"
	"strconv"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/widget"
)

const (
	boardSize = 4
)

type Game struct {
	board    [boardSize][boardSize]int
	score    int
	gameOver bool
	window   fyne.Window
	tiles    [][]*widget.Label
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
			if g.board[i][j] == 0 {
				g.tiles[i][j].SetText("")
			} else {
				g.tiles[i][j].SetText(strconv.Itoa(g.board[i][j]))
			}
		}
	}
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
			// 显示游戏结束消息
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

func main() {
	fmt.Println("hello")
	a := app.New()
	w := a.NewWindow("2048")

	game := newGame()
	game.window = w

	grid := container.NewGridWithColumns(boardSize)
	game.tiles = make([][]*widget.Label, boardSize)

	for i := 0; i < boardSize; i++ {
		game.tiles[i] = make([]*widget.Label, boardSize)
		for j := 0; j < boardSize; j++ {
			tile := widget.NewLabel("")
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

	w.SetContent(grid)
	w.Resize(fyne.NewSize(300, 300))
	w.ShowAndRun()
}
