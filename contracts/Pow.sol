//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

contract Pow is ERC721 {

    uint private lookBack = 5;

    // at 4 it removes an F from the front of this huge number
    uint private difficultyIncrement = 4;

    // ease is the opposite of difficulty, the higher this number is, the easier the proof of work is
    uint private ease = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // if this is set to 2 then there is a 50% chance of a difficulty adjustment on that mint
    uint inverseDifficultyAdjustmentFrequency = 10;

    uint private targetBlockHash;

    constructor() ERC721("Pow", "POW") {
        if(block.number == 0) {
            targetBlockHash = 0;
        } else {
            targetBlockHash = uint(blockhash(block.number - 1));
        }
    }

    function mint(address to, uint nonce) public {
        uint hash = getCurrentHash(to, nonce);
        // console.log("mint hash=", hash, "ease=", ease);
        require(hash < ease, "pow check failed");
        adjustDifficulty(hash);
        updateTargetBlockHash();

        _mint(to, hash);
    }

    function checkNonce(address to, uint nonce) view public returns (bool) {
        uint hash = getCurrentHash(to, nonce);
        return hash < ease;
    }

    function updateTargetBlockHash() internal {
        if(block.number % lookBack == 0) {
            targetBlockHash = uint(blockhash(block.number - lookBack));
            console.log("updating target block hash ", targetBlockHash);
        }
    }

    // There are less tokens available at an easier difficulty
    function adjustDifficulty(uint hash) internal {
        if(hash % inverseDifficultyAdjustmentFrequency == 0) {
            // adjust difficulty
            console.log("increasing difficulty");
            // todo: event
            ease = ease >> difficultyIncrement;
        }
    }

    function getHash(address to, uint blockHash, uint nonce) pure public returns (uint) {
        return uint(keccak256(abi.encodePacked(to, blockHash, nonce)));
    }

    function getCurrentHash(address to, uint nonce) view public returns (uint) {
        return getHash(to, targetBlockHash, nonce);
    }

    function getEase() view public returns (uint) {
        return ease;
    }

    function getDifficultyIncrement() view public returns (uint) {
        return difficultyIncrement;
    }

    function getLookBack() view public returns (uint) {
        return lookBack;
    }
}
