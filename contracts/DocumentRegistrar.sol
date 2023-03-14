// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/access/AccessControlEnumerable.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/token/ERC1155/IERC1155.sol";
import "../OpenZeppelin/openzeppelin-contracts@4.8.2/contracts/utils/structs/EnumerableSet.sol";

contract DocumentRegistrar is ERC721Enumerable, AccessControlEnumerable {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // event CollectionCreated
    // event
    event CollectionCreated(
        address indexed owner,
        bytes32 indexed collectionIndex
    );

    struct NftInfo {
        uint16 tokenType;
        address contractAddress;
        uint256 tokenId;
    }

    // used as query returns
    struct NftInfoWithIndex {
        NftInfo content;
        bytes32 index;
    }

    struct TextInfo {
        bool verified;
        string text;
    }

    struct CollectionMeta {
        string name;
        string description;
        address owner;
    }

    // used as query returns
    struct CollectionMetaWithIndex {
        CollectionMeta content;
        bytes32 index;
    }

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

    // TODO: add this modifier to addNftToCollection
    modifier nftInWhitelist(NftInfo memory _nft) {
        require(
            nftContractWhitelist[_nft.contractAddress],
            string(
                abi.encodePacked(
                    "NFT Contract not in whitelist: ",
                    Strings.toHexString(_nft.contractAddress)
                )
            )
        );
        _;
    }

    // a global nft collection Counter
    // This counter is global to make each collection-nft unique
    uint256 nftCollectionCounter = 0;

    // owner => collectionIndexes
    mapping(address => EnumerableSet.Bytes32Set) collections;
    // fetch collection info using index from collectionMetaTable
    mapping(bytes32 => CollectionMeta) collectionMetaTable;

    // collection index => collection nft indexes
    mapping(bytes32 => EnumerableSet.Bytes32Set) collectionNfts;
    // NftInfoHash to NftInfo detail
    // the table items will not be reused as it will make things complex to delete an Nft
    mapping(bytes32 => NftInfo) collectionNftInfoTable;

    // only nft in whitelist can be added
    mapping(address => bool) nftContractWhitelist;

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

    constructor() ERC721("DocumentRegistrar", "DR") {}

    function mint() public returns (uint256) {
        uint256 tokenId = uint256(uint160(msg.sender));
        _safeMint(msg.sender, tokenId);
        _createDocument();
        bytes32 MANAGER_ROLE = keccak256(
            abi.encode(msg.sender, "MANAGER_ROLE")
        );
        bytes32 ADMIN_ROLE = keccak256(abi.encode(msg.sender, "ADMIN_ROLE"));
        _setRoleAdmin(MANAGER_ROLE, ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);
        return tokenId;
    }

    function grantManager(address new_manager) public {
        require(_exists(uint256(uint160(msg.sender))), "Should mint before granting manager");
        bytes32 MANAGER_ROLE = keccak256(
            abi.encode(msg.sender, "MANAGER_ROLE")
        );
        _grantRole(MANAGER_ROLE, new_manager);
    }

    // ==== block token transfer ====

    function transferFrom(
        address,
        address,
        uint256
    ) public pure override(ERC721, IERC721) {
        require(false, "Token transfers are currently disabled.");
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public pure override(ERC721, IERC721) {
        require(false, "Token transfers are currently disabled.");
    }

    // initialize DocumentInfo in documentInfoTable
    mapping(address => uint256) createdTable;

    function _createDocument() internal {
        createdTable[msg.sender] = block.timestamp;
    }

    // ======== text control ========

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
    ) public onlyManager(owner) returns (bytes32) {
        bytes32 collectionIndex = bytes32(nftCollectionCounter);
        nftCollectionCounter += 1;
        collections[owner].add(collectionIndex);
        collectionMetaTable[collectionIndex] = CollectionMeta({
            name: collectionName,
            description: collectionDescription,
            owner: owner
        });
        emit CollectionCreated(owner, collectionIndex);
        return collectionIndex;
    }

    function nftCollection(
        bytes32 collectionIndex
    ) public view returns (CollectionMeta memory) {
        return collectionMetaTable[collectionIndex];
    }

    function nftCollectionIndexesOfOwner(
        address owner
    ) public view returns (bytes32[] memory) {
        return collections[owner].values();
    }

    function nftCollectionsOfOwner(
        address owner
    ) public view returns (CollectionMetaWithIndex[] memory) {
        bytes32[] memory indexes = collections[owner].values();
        CollectionMetaWithIndex[]
            memory ownerCollections = new CollectionMetaWithIndex[](
                indexes.length
            );
        for (uint i = 0; i < indexes.length; i++) {
            ownerCollections[i] = CollectionMetaWithIndex({
                content: collectionMetaTable[indexes[i]],
                index: indexes[i]
            });
        }
        return ownerCollections;
    }

    function nft(bytes32 nftIndex) public view returns (NftInfo memory) {
        return collectionNftInfoTable[nftIndex];
    }

    function nftIndexesOfCollection(
        bytes32 collectionIndex
    ) public view returns (bytes32[] memory) {
        return collectionNfts[collectionIndex].values();
    }

    function nftsOfCollection(
        bytes32 collectionIndex
    ) public view returns (NftInfo[] memory) {
        bytes32[] memory indexes = nftIndexesOfCollection(collectionIndex);
        NftInfo[] memory nfts = new NftInfo[](indexes.length);
        for (uint i = 0; i < indexes.length; i++) {
            nfts[i] = collectionNftInfoTable[indexes[i]];
        }
        return nfts;
    }

    // this is not a public api,
    // the manager check is done in `addNftLinksToCollection`
    function addNftToCollection(
        bytes32 collectionIndex,
        NftInfo memory _nft
    ) internal owningNft(_nft, collectionMetaTable[collectionIndex].owner) {
        // store nft in nftInfoTable
        bytes32 nftLinkIndex = collectionNftInfoHash(collectionIndex, _nft);
        collectionNftInfoTable[nftLinkIndex] = _nft;
        // add nft to collection
        collectionNfts[collectionIndex].add(nftLinkIndex);
    }

    function addNftsToCollection(
        bytes32 collectionIndex,
        NftInfo[] memory nfts
    ) public onlyManager(collectionMetaTable[collectionIndex].owner) {
        for (uint i = 0; i < nfts.length; i++) {
            addNftToCollection(collectionIndex, nfts[i]);
        }
    }

    // TODO: check implementation
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
