package main

import (
	"fmt"
	"math/rand"
	"strconv"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/canvas"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/widget"
)

type Game struct {
	board      [boardSize][boardSize]int
	score      int
	gameOver   bool
	window     fyne.Window
	tiles      [][]*fyne.Container
	scoreLabel *widget.Label
}

func NewGame() *Game {
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

func (g *Game) UpdateUI() {
	for i := 0; i < boardSize; i++ {
		for j := 0; j < boardSize; j++ {
			value := g.board[i][j]
			container := g.tiles[i][j]
			rect := container.Objects[0].(*canvas.Rectangle)
			label := container.Objects[1].(*canvas.Text)

			if value == 0 {
				label.Text = ""
				rect.FillColor = GetTileColor(0)
			} else {
				label.Text = strconv.Itoa(value)
				rect.FillColor = GetTileColor(value)
				label.Color = GetTileTextColor(value)
			}
			label.Refresh()
			rect.Refresh()
		}
	}
	g.scoreLabel.SetText(fmt.Sprintf("分数: %d", g.score))
}

func (g *Game) Move(direction string) {
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
		g.UpdateUI()
		if g.isGameOver() {
			g.gameOver = true
			g.showGameOverDialog()
		}
	}
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

func (g *Game) showGameOverDialog() {
	dialog.ShowConfirm("游戏结束", fmt.Sprintf("您的得分是: %d\n是否重新开始？", g.score), func(restart bool) {
		if restart {
			g.ResetGame()
		}
	}, g.window)
}

func (g *Game) ResetGame() {
	g.score = 0
	g.gameOver = false
	g.initBoard()
	g.UpdateUI()
}
