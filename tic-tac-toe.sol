// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract TicTacToe {
    
    enum Player { None, Player1, Player2 }
    Player[3][3] public board;
    address public player1;
    address public player2;
    address public currentPlayer;
    uint public moveCount;
    bool public gameActive;

    event GameStarted(address player1, address player2);
    event MoveMade(address player, uint row, uint col);
    event GameOver(address winner);

    modifier onlyPlayers() {
        require(msg.sender == player1 || msg.sender == player2, "Only players can make a move");
        _;
    }

    modifier gameInProgress() {
        require(gameActive, "Game is not active");
        _;
    }

    modifier gameNotStarted() {
        require(player1 == address(0) && player2 == address(0), "Game already started");
        _;
    }

    constructor() {
        player1 = address(0);
        player2 = address(0);
        currentPlayer = address(0);
        moveCount = 0;
        gameActive = false;
    }

    function startGame(address _player2) public gameNotStarted {
        require(_player2 != address(0) && _player2 != msg.sender, "Invalid player address");
        player1 = msg.sender;
        player2 = _player2;
        currentPlayer = player1;
        gameActive = true;
        emit GameStarted(player1, player2);
    }

    function makeMove(uint _row, uint _col) public onlyPlayers gameInProgress {
        require(_row < 3 && _col < 3, "Invalid board position");
        require(board[_row][_col] == Player.None, "Cell already occupied");
        require(msg.sender == currentPlayer, "It's not your turn");

        board[_row][_col] = msg.sender == player1 ? Player.Player1 : Player.Player2;
        moveCount++;

        emit MoveMade(msg.sender, _row, _col);

        if (checkWinner()) {
            gameActive = false;
            emit GameOver(msg.sender);
        } else if (moveCount == 9) {
            gameActive = false; // Draw condition
            emit GameOver(address(0));
        } else {
            currentPlayer = currentPlayer == player1 ? player2 : player1;
        }
    }

    function checkWinner() private view returns (bool) {
        // Check rows and columns
        for (uint i = 0; i < 3; i++) {
            if (board[i][0] == board[i][1] && board[i][1] == board[i][2] && board[i][0] != Player.None) {
                return true;
            }
            if (board[0][i] == board[1][i] && board[1][i] == board[2][i] && board[0][i] != Player.None) {
                return true;
            }
        }
        // Check diagonals
        if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != Player.None) {
            return true;
        }
        if (board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != Player.None) {
            return true;
        }
        return false;
    }

    function getBoard() public view returns (Player[3][3] memory) {
        return board;
    }

    function getCurrentPlayer() public view returns (address) {
        return currentPlayer;
    }

    function getGameStatus() public view returns (bool) {
        return gameActive;
    }
}

