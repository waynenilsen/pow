//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

// Proof of work NFT
// Each NFT is associated with a specific hash, at every difficulty level there are some number that are expected to
//  be found. Mining is somewhat similar to bitcoin mining and is done via hashing. In this case keccak256
contract Pow is ERC721 {
    // how many blocks before the target block hash changes
    uint private window = 5;

    // how many powers of 2 to increase the difficulty by
    uint private difficultyIncrement = 1;

    // ease is the opposite of difficulty, the higher this number is, the easier the proof of work is
    uint private ease = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // if this is set to 2 then there is a 50% chance of a difficulty adjustment on that mint
    uint private inverseDifficultyAdjustmentFrequency = 10;

    // block hash prepended to the data that is to be hashed prevents use of rainbow tables and hash precomputation
    uint private targetBlockHash;

    constructor() ERC721("Pow", "POW") {
        if(block.number == 0) {
            targetBlockHash = 0;
        } else {
            targetBlockHash = uint(blockhash(block.number - 1));
        }
    }

    // create a new Pow NFT
    // NOTICE the nonce is not your token id, the hash is
    function mint(address to, uint nonce) public {
        uint hash = getCurrentHash(to, nonce);
        // console.log("mint hash=", hash, "ease=", ease);
        require(hash < ease, "pow check failed");
        adjustDifficulty(hash);
        updateTargetBlockHash();

        _mint(to, hash);
    }

    // for convenience, check a given nonce to determine if it could be used to mint
    function checkNonce(address to, uint nonce) view public returns (bool) {
        uint hash = getCurrentHash(to, nonce);
        return hash < ease;
    }

    // update the target black hash
    // this moves the target block hash to prevent any precomputed hashes from being used
    function updateTargetBlockHash() internal {
        if(block.number % window == 0) {
            targetBlockHash = uint(blockhash(block.number - window));
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
        return window;
    }
}
