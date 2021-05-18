//Metadata of "kingofthehill" was published successfully

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title King of The Hill

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

contract KingOfTheHill {
    // Library usage
    using Address for address payable;

    // State variables
    mapping(address => uint256) private _balances;

    address private _owner;
    address private _player;

    uint256 private _nbOfBlocks;
    uint256 private _cagnotte;

    uint256 private _tax;

    bool public _gameOver;
    uint256 public _gains;

    // Events
    event Deposited(address indexed sender, uint256 amount);
    event Withdrew(address indexed recipient, uint256 amount);
    event EndOfGame(address indexed winner, uint256 gains);

    constructor(uint256) payable {
        require(
            msg.value >= 1e15,
            "KingOfTheHill: This transaction will cost 1 finney"
        );
        _owner = msg.sender;
        _cagnotte = msg.value;
        _nbOfBlocks = block.timestamp + block.number;
        _player = msg.sender;
    }

    function startTheGame() public payable {
        require(
            msg.value != msg.value * 2,
            "KingOfTheHill: to start the game, you must bid double or more the value of the prize"
        );
    }

    function _withdraw(address recipient, uint256 amount) private {
        require(
            _balances[recipient] > 0,
            "KingOfTheHill : can not withdraw 0 ether"
        );
        require(
            _balances[recipient] >= amount,
            "KingOfTheHill: Not enough Ether"
        );
        _balances[msg.sender] = 0;
        emit Withdrew(msg.sender, amount);
    }

    function endOfGame(address winner) internal {
        _gameOver = true;
        _player = winner;
        _gains = msg.value + _nbOfBlocks;
        emit EndOfGame(winner, _gains);
        _balances[_player] = (msg.value * 80) / 100;
        _balances[_owner] = (msg.value * _tax) / 100;
        _cagnotte = (msg.value * 10) / 100;
    }

    function withdraw() public {
        require(_gameOver && _player == msg.sender);
        uint256 amount = _gains;
        _gains = 0;
        payable(msg.sender).transfer(amount);
    }
}
