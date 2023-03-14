// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC721/ERC721.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/utils/Counters.sol";

contract ERC721Demo is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("MyNFT", "NFT") {}

    function mint(address recipient) public returns (uint256) {
        _tokenIds.increment();
        uint256 newNftId = _tokenIds.current();
        _mint(recipient, newNftId);
        return newNftId;
    }
}
