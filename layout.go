package main

import (
	"math"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/widget"
)

type gameLayout struct {
	grid        *fyne.Container
	scoreLabel  *widget.Label
	resetButton *widget.Button
}

func NewGameLayout(grid *fyne.Container, scoreLabel *widget.Label, resetButton *widget.Button) *gameLayout {
	return &gameLayout{
		grid:        grid,
		scoreLabel:  scoreLabel,
		resetButton: resetButton,
	}
}

func (g *gameLayout) Layout(objects []fyne.CanvasObject, size fyne.Size) {
	padding := float32(10)
	buttonHeight := float32(30)
	labelHeight := float32(30)

	gridSize := float32(math.Min(float64(size.Width), float64(size.Height-labelHeight-buttonHeight-3*padding)))

	verticalSpace := size.Height - gridSize - labelHeight - buttonHeight - 3*padding

	g.grid.Resize(fyne.NewSize(gridSize, gridSize))
	g.grid.Move(fyne.NewPos((size.Width-gridSize)/2, labelHeight+padding+verticalSpace/2))

	g.scoreLabel.Resize(fyne.NewSize(size.Width, labelHeight))
	g.scoreLabel.Move(fyne.NewPos(0, padding))

	g.resetButton.Resize(fyne.NewSize(size.Width, buttonHeight))
	g.resetButton.Move(fyne.NewPos(0, size.Height-buttonHeight-padding))
}

func (g *gameLayout) MinSize(objects []fyne.CanvasObject) fyne.Size {
	return fyne.NewSize(300, 350)
}
