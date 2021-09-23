//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

// Proof of work NFT
// Each NFT is associated with a specific hash, at every difficulty level there are some number that are expected to
//  be found. Mining is somewhat similar to bitcoin mining and is done via hashing. In this case keccak256
contract Pow is ERC721 {
    // how many powers of 2 to increase the difficulty by
    uint private difficultyIncrement = 1;

    // ease is the opposite of difficulty, the higher this number is, the easier the proof of work is
    uint private ease = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    // if this is set to 2 then there is a 50% chance of a difficulty adjustment on that mint
    uint private inverseDifficultyAdjustmentFrequency = 10;

    constructor() ERC721("Pow", "POW") {
    }

    // create a new Pow NFT
    // NOTICE the nonce is not your token id, the hash is
    function mint(address to, uint nonce) public {
        uint hash = getHash(to, nonce);
        require(hash < ease, "pow check failed");
        adjustDifficulty(hash);

        _mint(to, hash);
    }

    // for convenience, check a given nonce to determine if it could be used to mint
    function checkNonce(address to, uint nonce) view public returns (bool) {
        return getHash(to, nonce) < ease;
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

    function getHash(address to, uint nonce) pure public returns (uint) {
        return uint(keccak256(abi.encodePacked(to, nonce)));
    }

    function getEase() view public returns (uint) {
        return ease;
    }

    function getDifficultyIncrement() view public returns (uint) {
        return difficultyIncrement;
    }
}
