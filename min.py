import numpy as np, random
def winner(b,p): return any(all(b[i][j]==p for i,j in l) for l in [[(0,0),(0,1),(0,2)],[(1,0),(1,1),(1,2)],[(2,0),(2,1),(2,2)],[(0,0),(1,0),(2,0)],[(0,1),(1,1),(2,1)],[(0,2),(1,2),(2,2)],[(0,0),(1,1),(2,2)],[(0,2),(1,1),(2,0)]])
board = np.full((3,3),' ')

while not any(winner(board,p) for p in 'XO') and np.any(board == ' '): 
    print(board)
    x, y = map(int, input("Move (row col): ").split())
    board[x][y] = 'X'
    if winner(board,'X') or np.all(board != ' '): break
    ai_move = random.choice(np.argwhere(board == ' '))
    board[ai_move[0]][ai_move[1]] = 'O'

print("Game Over!")
