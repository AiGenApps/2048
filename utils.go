package main

import (
	"image/color"
)

func GetTileColor(value int) color.Color {
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
		return color.RGBA{205, 193, 180, 255}
	}
}

func GetTileTextColor(value int) color.Color {
	if value <= 4 {
		return color.RGBA{119, 110, 101, 255}
	}
	return color.RGBA{249, 246, 242, 255}
}
