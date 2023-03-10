// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/access/IAccessControl.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./NFTInfo.sol";

interface INFTCollection is IERC721Enumerable {
    function addLink(NFTInfo memory _nft) external;
    function addLinks(NFTInfo[] memory nftsInfo) external;
}
