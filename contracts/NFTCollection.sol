// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/access/AccessControl.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC1155/IERC1155.sol";
import "../interfaces/NFTInfo.sol";
import "../interfaces/INFTCollection.sol";
import "../interfaces/IDIDDocument.sol";

contract NFTCollection is ERC721Enumerable, INFTCollection {
    IDIDDocument public parentDocument;

    mapping(uint256 => NFTInfo) idToNFTInfo;

    constructor(address _didDocument) ERC721("NFTCollection", "NFTC") {
        parentDocument = IDIDDocument(_didDocument);
    }

    modifier onlyDocument {
        require(address(parentDocument) == msg.sender, "Can only from parent document");
        _;
    }

    modifier owningNFT(NFTInfo memory _nft) {
        if (_nft.tokenType == 721) {
            require(IERC721(_nft.contractAddress).ownerOf(_nft.tokenId) == parentDocument.owner(), "Do not own this NFT");
        } else if (_nft.tokenType == 1155) {
                       require(IERC1155(_nft.contractAddress).balanceOf(parentDocument.owner(), _nft.tokenId) > 0, "Do not own this NFT");
        } else {
            revert("Invalid NFT type");
        }
        _;
    }

    function hashNFTInfo(NFTInfo memory nft) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            nft.tokenType,
            nft.contractAddress,
            nft.tokenId
        ));
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        NFTInfo memory nftInfo = idToNFTInfo[tokenId];
        // reuses the tokenURI of the original tokenURI
        // NOTE: This is a dangerous design as this may trigger infinite loop
        // TODO: should implement metadata service later on
        return ERC721(nftInfo.contractAddress).tokenURI(nftInfo.tokenId);
    }

    function addLink(NFTInfo memory _nft) public override onlyDocument owningNFT(_nft) {
        uint256 tokenId = uint256(hashNFTInfo(_nft));
        // mint to parentDocument
        _safeMint(address(parentDocument), tokenId);
        idToNFTInfo[tokenId] = _nft;
    }

    function addLinks(NFTInfo[] memory nftsInfo) public override onlyDocument {
        for (uint i = 0; i < nftsInfo.length; i ++) {
            addLink(nftsInfo[i]);
        }
    }
}
