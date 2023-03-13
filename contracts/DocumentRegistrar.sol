// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/access/AccessControlEnumerable.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC1155/IERC1155.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/utils/structs/EnumerableSet.sol";

contract DocumentRegistrar is ERC721Enumerable, AccessControlEnumerable {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    modifier owningNft(NftInfo memory _nft, address owner) {
        if (_nft.tokenType == 721) {
            require(
                ERC721Enumerable(_nft.contractAddress).ownerOf(_nft.tokenId) ==
                    owner,
                "Do not own this Nft"
            );
        } else if (_nft.tokenType == 1155) {
            require(
                IERC1155(_nft.contractAddress).balanceOf(owner, _nft.tokenId) >
                    0,
                "Do not own this Nft"
            );
        } else {
            revert("Invalid Nft type");
        }
        _;
    }

    // The owner will be granted manager role when mint
    modifier onlyManager(address owner) {
        bytes32 MANAGER_ROLE = keccak256(abi.encode(owner, "MANAGER_ROLE"));
        require(hasRole(MANAGER_ROLE, msg.sender), "Requires Manager Role");
        _;
    }

    struct NftInfo {
        uint8 tokenType;
        address contractAddress;
        uint256 tokenId;
    }

    // a global nft collection Counter
    // This counter is global to make each collection-nft unique
    uint256 nftCollectionCounter = 0;
    // stores collection index
    // fetch collection info using index from collectionMetaTable
    mapping(address => EnumerableSet.Bytes32Set) collections;
    mapping(bytes32 => CollectionMeta) collectionMetaTable;

    struct CollectionMeta {
        string name;
        string description;
        address owner;
        // stores nft hash
        // fetch nft info using index from nftInfoTable
    }

    // collection index => collection nft set
    mapping(bytes32 => EnumerableSet.Bytes32Set) collectionNfts;

    // NftInfoHash to NftInfo detail
    // the table items will not be reused as it will make things complex to delete an Nft link
    mapping(bytes32 => NftInfo) collectionNftInfoTable;

    function collectionNftInfoHash(
        bytes32 collectionIndex,
        NftInfo memory _nft
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    collectionIndex,
                    _nft.tokenType,
                    _nft.contractAddress,
                    _nft.tokenId
                )
            );
    }

    constructor() ERC721("DIDCentral", "DIDC") {}

    function mint() public {
        uint256 tokenId = uint256(uint160(msg.sender));
        _safeMint(msg.sender, tokenId);
        _createDocument();
        bytes32 MANAGER_ROLE = keccak256(
            abi.encode(msg.sender, "MANAGER_ROLE")
        );
        grantRole(MANAGER_ROLE, msg.sender);
    }

    // initialize DocumentInfo in documentInfoTable
    mapping(address => uint256) createdTable;

    function _createDocument() internal {
        createdTable[msg.sender] = block.timestamp;
    }

    // ======== text control ========

    struct TextInfo {
        bool verified;
        string text;
    }

    mapping(address => mapping(string => TextInfo)) textInfoTable;

    function setTextFor(
        address owner,
        string memory key,
        string memory value
    ) public onlyManager(owner) {
        textInfoTable[owner][key] = TextInfo({verified: false, text: value});
    }

    // TODO: verify textInfo
    function textInfo(
        address owner,
        string memory key
    ) public view returns (TextInfo memory) {
        return textInfoTable[owner][key];
    }

    // ======== avatar control ========

    mapping(address => NftInfo) avatars;

    function setAvatarFor(
        address owner,
        NftInfo memory _nft
    ) public owningNft(_nft, owner) onlyManager(owner) {
        avatars[owner] = _nft;
    }

    function avatar(
        address owner
    ) public view owningNft(avatars[owner], owner) returns (NftInfo memory) {
        return avatars[owner];
    }

    // ======== nft collection ========

    function createCollectionFor(
        address owner,
        string memory collectionName,
        string memory collectionDescription
    ) public onlyManager(owner) {
        bytes32 collectionIndex = bytes32(nftCollectionCounter);
        nftCollectionCounter += 1;
        collections[owner].add(collectionIndex);
        collectionMetaTable[collectionIndex] = CollectionMeta({
            name: collectionName,
            description: collectionDescription,
            owner: owner
        });
    }

    function addNftLinkToCollection(
        bytes32 collectionIndex,
        NftInfo memory _nft
    ) public onlyManager(collectionMetaTable[collectionIndex].owner) owningNft(_nft, collectionMetaTable[collectionIndex].owner) {
        // store nft in nftInfoTable
        bytes32 nftLinkIndex = collectionNftInfoHash(collectionIndex, _nft);
        collectionNftInfoTable[nftLinkIndex] = _nft;
        // add nft to collection
        collectionNfts[collectionIndex].add(nftLinkIndex);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721Enumerable, AccessControlEnumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
