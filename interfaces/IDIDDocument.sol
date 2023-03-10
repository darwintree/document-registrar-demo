// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/access/IAccessControl.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./NFTInfo.sol";

interface IDIDDocument is IERC721Enumerable {
    struct TextInfo {
        bool verified;
        string text;
    }

    function owner() external view returns (address);
    function setText(string memory key, string memory value) external;
    function textInfo(string memory key) external view returns (TextInfo memory);
    function setAvatar(NFTInfo memory _nft) external;
    function mint() external;
    function addNFTLinksToCollection(address collection, NFTInfo[] memory nftsInfo) external;
}
