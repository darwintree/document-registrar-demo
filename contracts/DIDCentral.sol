// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/access/AccessControl.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC1155/IERC1155.sol";
import "../conflux-contracts/contracts/utils/Clones.sol";
import "../interfaces/NFTInfo.sol";
import "../interfaces/IDIDCentral.sol";
import "./DIDDocument.sol";

contract DIDCentral is IDIDCentral, ERC721Enumerable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor() ERC721("DIDCentral", "DIDC") {
        // 合约升级的admin 
        // 目前没用
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint() public {
        require(balanceOf(msg.sender) == 0, "You have already minted a DID Document");
        DIDDocument didDocument = new DIDDocument(msg.sender, address(this));
        uint256 tokenId = uint256(uint160(address(didDocument)));
        _safeMint(msg.sender, tokenId);
        _setupRole(ADMIN_ROLE, address(didDocument));
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, IERC165) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
