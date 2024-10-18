<template>
  <div class="game-container">
    <h1>2048</h1>
    <div class="game-board"
         @touchstart="handleTouchStart"
         @touchmove="handleTouchMove"
         @touchend="handleTouchEnd"
         @mousedown="handleMouseDown"
         @mousemove="handleMouseMove"
         @mouseup="handleMouseUp"
         @mouseleave="handleMouseUp">
      <div class="board">
        <transition-group name="tile" tag="div">
          <div v-for="tile in tiles" :key="tile.id"
               class="tile" :class="[`tile-${tile.value}`, { 'tile-new': tile.isNew }]"
               :style="{ top: `${tile.row * 90}px`, left: `${tile.col * 90}px` }">
            {{ tile.value }}
          </div>
        </transition-group>
      </div>
    </div>
    <div class="game-info">
      <p>得分: {{ score }}</p>
      <button @click="newGame">新游戏</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Game2048',
  data() {
    return {
      board: [],
      score: 0,
      touchStartX: 0,
      touchStartY: 0,
      mouseDown: false,
      mouseStartX: 0,
      mouseStartY: 0,
      tileIdCounter: 0,
      tiles: [],
    }
  },
  computed: {
    flattenedBoard() {
      return this.board.flat().map((value, index) => ({
        id: this.cellIdCounter++,
        value,
        row: Math.floor(index / 4),
        col: index % 4
      }));
    }
  },
  mounted() {
    this.newGame()
    window.addEventListener('keydown', this.handleKeyDown)
  },
  beforeUnmount() {
    window.removeEventListener('keydown', this.handleKeyDown)
  },
  methods: {
    newGame() {
      this.board = Array(4).fill().map(() => Array(4).fill(0))
      this.score = 0
      this.tileIdCounter = 0
      this.tiles = []
      this.addRandomTile()
      this.addRandomTile()
    },
    addRandomTile() {
      const emptyCells = []
      for (let i = 0; i < 4; i++) {
        for (let j = 0; j < 4; j++) {
          if (this.board[i][j] === 0) {
            emptyCells.push({ row: i, col: j })
          }
        }
      }
      if (emptyCells.length > 0) {
        const { row, col } = emptyCells[Math.floor(Math.random() * emptyCells.length)]
        const value = Math.random() < 0.9 ? 2 : 4
        this.board[row][col] = value
        this.tiles.push({
          id: this.tileIdCounter++,
          value,
          row,
          col,
          isNew: true
        })
      }
    },
    handleKeyDown(e) {
      let moved = false
      switch (e.key) {
        case 'ArrowUp':
          moved = this.moveUp()
          break
        case 'ArrowDown':
          moved = this.moveDown()
          break
        case 'ArrowLeft':
          moved = this.moveLeft()
          break
        case 'ArrowRight':
          moved = this.moveRight()
          break
      }
      if (moved) {
        this.addRandomTile()
        if (this.isGameOver()) {
          alert('游戏结束!')
        }
      }
    },
    moveUp() {
      return this.move((row, col) => ({ row: row - 1, col }), (row) => row > 0)
    },
    moveDown() {
      return this.move((row, col) => ({ row: row + 1, col }), (row) => row < 3)
    },
    moveLeft() {
      return this.move((row, col) => ({ row, col: col - 1 }), (_, col) => col > 0)
    },
    moveRight() {
      return this.move((row, col) => ({ row, col: col + 1 }), (_, col) => col < 3)
    },
    move(getNext, canMove) {
      let moved = false
      const newTiles = []

      for (let row = 0; row < 4; row++) {
        for (let col = 0; col < 4; col++) {
          if (this.board[row][col] !== 0) {
            let { row: nextRow, col: nextCol } = { row, col }
            let merged = false

            while (canMove(nextRow, nextCol)) {
              const next = getNext(nextRow, nextCol)
              if (this.board[next.row][next.col] === 0) {
                this.board[next.row][next.col] = this.board[nextRow][nextCol]
                this.board[nextRow][nextCol] = 0
                nextRow = next.row
                nextCol = next.col
                moved = true
              } else if (this.board[next.row][next.col] === this.board[nextRow][nextCol] && !merged) {
                this.board[next.row][next.col] *= 2
                this.score += this.board[next.row][next.col]
                this.board[nextRow][nextCol] = 0
                nextRow = next.row
                nextCol = next.col
                moved = true
                merged = true
              } else {
                break
              }
            }

            newTiles.push({
              id: this.tileIdCounter++,
              value: this.board[nextRow][nextCol],
              row: nextRow,
              col: nextCol,
              isNew: false
            })
          }
        }
      }

      this.tiles = newTiles
      return moved
    },
    isGameOver() {
      for (let row = 0; row < 4; row++) {
        for (let col = 0; col < 4; col++) {
          if (this.board[row][col] === 0) {
            return false
          }
          if (
            (row < 3 && this.board[row][col] === this.board[row + 1][col]) ||
            (col < 3 && this.board[row][col] === this.board[row][col + 1])
          ) {
            return false
          }
        }
      }
      return true
    },
    handleTouchStart(event) {
      event.preventDefault();
      this.touchStartX = event.touches[0].clientX;
      this.touchStartY = event.touches[0].clientY;
    },

    handleTouchMove(event) {
      event.preventDefault();
    },

    handleTouchEnd(event) {
      event.preventDefault();
      const touchEndX = event.changedTouches[0].clientX;
      const touchEndY = event.changedTouches[0].clientY;

      const deltaX = touchEndX - this.touchStartX;
      const deltaY = touchEndY - this.touchStartY;

      this.handleSwipe(deltaX, deltaY);
    },

    handleMouseDown(event) {
      event.preventDefault();
      this.mouseDown = true;
      this.mouseStartX = event.clientX;
      this.mouseStartY = event.clientY;
    },

    handleMouseMove(event) {
      if (!this.mouseDown) return;
      event.preventDefault();
    },

    handleMouseUp(event) {
      if (!this.mouseDown) return;
      event.preventDefault();
      this.mouseDown = false;

      const deltaX = event.clientX - this.mouseStartX;
      const deltaY = event.clientY - this.mouseStartY;

      this.handleSwipe(deltaX, deltaY);
    },

    handleSwipe(deltaX, deltaY) {
      const minSwipeDistance = 50;
      let moved = false;

      if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > minSwipeDistance) {
        if (deltaX > 0) {
          moved = this.moveRight();
        } else {
          moved = this.moveLeft();
        }
      } else if (Math.abs(deltaY) > minSwipeDistance) {
        if (deltaY > 0) {
          moved = this.moveDown();
        } else {
          moved = this.moveUp();
        }
      }

      if (moved) {
        this.addRandomTile();
        if (this.isGameOver()) {
          alert('游戏结束!');
        }
      }
    },
  },
}
</script>

<style scoped>
/* 添加这个全局样式来移除body的滚动条 */
:global(body) {
  margin: 0;
  padding: 0;
  overflow: hidden;
}

.game-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center; /* 添加这行来垂直居中内容 */
  font-family: Arial, sans-serif;
  height: 100vh;
  overflow: hidden;
  padding: 20px; /* 添加一些内边距 */
  box-sizing: border-box; /* 确保内边距不会增加总高度 */
}

.game-board {
  background-color: #bbada0;
  padding: 10px;
  border-radius: 5px;
  touch-action: none; /* 防止移动设备上的默认触摸行为 */
  user-select: none; /* 防止文本选择 */
}

.board {
  position: relative;
  width: 360px;
  height: 360px;
  background-color: #ccc0b3;
  border-radius: 5px;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(4, 1fr);
  gap: 10px;
  padding: 10px;
}

.board::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #bbada0;
  z-index: 1;
  border-radius: 5px;
}

.board::after {
  content: '';
  position: absolute;
  top: 10px;
  left: 10px;
  right: 10px;
  bottom: 10px;
  background-color: #ccc0b3;
  z-index: 2;
  border-radius: 3px;
}

.tile {
  position: absolute;
  width: 80px;
  height: 80px;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 24px;
  font-weight: bold;
  border-radius: 5px;
  transition: all 0.15s ease-in-out;
  z-index: 3;
}

.tile-new {
  animation: appear 0.2s ease-in-out;
}

.tile-enter-active {
  transition: all 0.15s ease-in-out;
}

.tile-leave-active {
  transition: all 0.15s ease-in-out;
  z-index: 1;
}

.tile-enter-from,
.tile-leave-to {
  opacity: 0;
  transform: scale(0.5);
}

@keyframes appear {
  0% {
    opacity: 0;
    transform: scale(0);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}

.tile-2 { background-color: #eee4da; color: #776e65; }
.tile-4 { background-color: #ede0c8; color: #776e65; }
.tile-8 { background-color: #f2b179; color: #f9f6f2; }
.tile-16 { background-color: #f59563; color: #f9f6f2; }
.tile-32 { background-color: #f67c5f; color: #f9f6f2; }
.tile-64 { background-color: #f65e3b; color: #f9f6f2; }
.tile-128 { background-color: #edcf72; color: #f9f6f2; }
.tile-256 { background-color: #edcc61; color: #f9f6f2; }
.tile-512 { background-color: #edc850; color: #f9f6f2; }
.tile-1024 { background-color: #edc53f; color: #f9f6f2; }
.tile-2048 { background-color: #edc22e; color: #f9f6f2; }

.game-info {
  text-align: center;
  margin-top: 20px; /* 添加一些上边距 */
}

button {
  padding: 10px 20px;
  font-size: 16px;
  background-color: #8f7a66;
  color: #f9f6f2;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

button:hover {
  background-color: #9f8b77;
}
</style>
