// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/access/AccessControl.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC1155/IERC1155.sol";
import "../interfaces/NFTInfo.sol";
import "../interfaces/IDIDDocument.sol";
import "./NFTCollection.sol";

contract DIDDocument is ERC721Enumerable, AccessControl, IDIDDocument {

    uint256 public createdAt;
    NFTInfo public avatar;
    address public owner;
    address public didCentral;
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    mapping(string => TextInfo) public textInfoMapping;

    constructor(address _owner, address _didCentral) ERC721("DIDDocument", "DIDD") {
        owner = _owner;
        didCentral = _didCentral;
        createdAt = block.timestamp;
        _setupRole(OWNER_ROLE, owner);
        _setupRole(MANAGER_ROLE, owner);
    }

    modifier onlyManager {
        require(hasRole(MANAGER_ROLE, msg.sender), "Requires Manager Role");
        _;
    }

    modifier owningNFT(NFTInfo memory _nft) {
        if (_nft.tokenType == 721) {
            require(IERC721(_nft.contractAddress).ownerOf(_nft.tokenId) == owner, "Do not own this NFT");
        } else if (_nft.tokenType == 1155) {
            require(IERC1155(_nft.contractAddress).balanceOf(owner, _nft.tokenId) > 0, "Do not own this NFT");
        } else {
            revert("Invalid NFT type");
        }
        _;
    }

    function setText(string memory key, string memory value) public override onlyManager {
        textInfoMapping[key] = TextInfo({
            verified: false, 
            text: value
        });
    }

    // TODO: verify textInfo
    function textInfo(string memory key) public view override returns (TextInfo memory) {
        return textInfoMapping[key];
    }

    function setAvatar(NFTInfo memory _nft) public override owningNFT(_nft) onlyManager {
        avatar = _nft;
    }

    function mint() public override onlyManager {
        NFTCollection nftCollection = new NFTCollection(address(this));
        uint256 tokenId = uint256(uint160(address(nftCollection)));
        // mint the nft to this document, rather than the message sender
        _safeMint(address(this), tokenId);
        // emit CollectionCreated(address(nftCollection));
    }

    function addNFTLinksToCollection(address collection, NFTInfo[] memory nftsInfo) public override onlyManager {
        // TODO: check if collection exists
        NFTCollection nftCollection = NFTCollection(collection);
        nftCollection.addLinks(nftsInfo);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl, IERC165) returns (bool) {
        return ERC721Enumerable.supportsInterface(interfaceId);
    }
}
