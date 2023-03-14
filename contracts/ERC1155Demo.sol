// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC1155/ERC1155.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/utils/Counters.sol";

contract ERC1155Demo is ERC1155 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC1155("") {}

    function mint(address account, uint256 amount) public returns (uint256) {
        _tokenIds.increment();
        uint256 newNftId = _tokenIds.current();
        _mint(account, newNftId, amount, "");
        return newNftId;
    }
}
