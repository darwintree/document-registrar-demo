# 智能合约文档：DocumentRegistrar

DocumentRegistrar 是一个智能合约，继承了 ERC721Enumerable 和 AccessControlEnumerable 合约，并通过 OpenZeppelin 框架实现了NFT的创建、管理和集合的维护。本合约用于管理文档的注册和存储，并提供以下功能：

- 创建和管理 NFT
- 创建和管理 NFT 集合
- 设置和管理文本信息
- 设置和管理头像

## 合约信息

- 版权声明：MIT
- Solidity 版本：^0.8.0
- 依赖的库：OpenZeppelin

## 函数和事件

### 事件

#### CollectionCreated

创建 NFT 集合时会触发 CollectionCreated 事件。

```solidity
event CollectionCreated(
    address indexed owner,
    bytes32 indexed collectionIndex
);
```

### 函数

#### mint

创建 NFT 并将其分配给调用者。

```solidity
function mint() public returns (uint256);
```

- 返回：uint256，新创建的 NFT ID。

#### grantManager

授予新管理员管理角色。

```solidity
function grantManager(address new_manager) public;
```

- 参数：
  - new_manager (address): 新管理员的地址。
- 返回：无。

#### setTextFor

设置文本信息的值。

```solidity
function setTextFor(
    address owner,
    string memory key,
    string memory value
) public onlyManager(owner);
```

- 参数：
  - owner (address): 所有者地址。
  - key (string): 文本信息的键。
  - value (string): 文本信息的值。
- 返回：无。

#### textInfo

获取文本信息。

```solidity
function textInfo(
    address owner,
    string memory key
) public view returns (TextInfo memory);
```

- 参数：
  - owner (address): 所有者地址。
  - key (string): 文本信息的键。
- 返回：
  - TextInfo (struct): 包含文本信息是否经过验证和文本内容的结构。

#### setAvatarFor

设置所有者的头像。

```solidity
function setAvatarFor(
    address owner,
    NftInfo memory _nft
) public owningNft(_nft, owner) onlyManager(owner);
```

- 参数：
  - owner (address): 所有者地址。
  - _nft (NftInfo): 包含头像 NFT 信息的结构。
- 返回：无。

#### avatar

获取所有者的头像。

```solidity
function avatar(
    address owner
) public view owningNft(avatars[owner], owner) returns (NftInfo memory);
```

- 参数：
  - owner (address): 所有者地址。
- 返回：
  - NftInfo (struct): 包含头像 NFT 信息的结构。

#### createCollectionFor

为所有者创建 NFT 集合。

```solidity
function createCollectionFor(
    address owner,
    string memory collectionName,
    string memory collectionDescription
) public onlyManager(owner) returns (bytes32);
```

- 参数：
  - owner (address): 所有者地址。
  - collectionName (string): 集合的名称。
  - collectionDescription (string): 集合的描述。
- 返回：
 
继续

  - bytes32: 新创建的集合的索引。

#### nftCollection

获取 NFT 集合的元数据。

```solidity
function nftCollection(
    bytes32 collectionIndex
) public view returns (CollectionMeta memory);
```

- 参数：
  - collectionIndex (bytes32): NFT 集合的索引。
- 返回：
  - CollectionMeta (struct): 包含 NFT 集合名称、描述和所有者地址的结构。

#### nftCollectionIndexesOfOwner

获取所有者拥有的 NFT 集合的索引数组。

```solidity
function nftCollectionIndexesOfOwner(
    address owner
) public view returns (bytes32[] memory);
```

- 参数：
  - owner (address): 所有者地址。
- 返回：
  - bytes32[]: 所有者拥有的 NFT 集合的索引数组。

#### nftCollectionsOfOwner

获取所有者拥有的 NFT 集合及其元数据。

```solidity
function nftCollectionsOfOwner(
    address owner
) public view returns (CollectionMetaWithIndex[] memory);
```

- 参数：
  - owner (address): 所有者地址。
- 返回：
  - CollectionMetaWithIndex[]: 所有者拥有的 NFT 集合及其元数据的数组。

#### nft

获取 NFT 信息。

```solidity
function nft(bytes32 nftIndex) public view returns (NftInfo memory);
```

- 参数：
  - nftIndex (bytes32): NFT 的索引。
- 返回：
  - NftInfo (struct): 包含 NFT 类型、合约地址和 ID 的结构。

#### nftIndexesOfCollection

获取 NFT 集合中 NFT 的索引数组。

```solidity
function nftIndexesOfCollection(
    bytes32 collectionIndex
) public view returns (bytes32[] memory);
```

- 参数：
  - collectionIndex (bytes32): NFT 集合的索引。
- 返回：
  - bytes32[]: NFT 集合中 NFT 的索引数组。

#### nftsOfCollection

获取 NFT 集合中 NFT 的信息。

```solidity
function nftsOfCollection(
    bytes32 collectionIndex
) public view returns (NftInfo[] memory);
```

- 参数：
  - collectionIndex (bytes32): NFT 集合的索引。
- 返回：
  - NftInfo[]: NFT 集合中 NFT 的信息数组。

#### addNftsToCollection

将多个 NFT 添加到集合中。

```solidity
function addNftsToCollection(
    bytes32 collectionIndex,
    NftInfo[] memory nfts
) public onlyManager(collectionMetaTable[collectionIndex].owner);
```

- 参数：
  - collectionIndex (bytes32): NFT 集合的索引。
  - nfts (NftInfo[]): 包含要添加到集合中的 NFT 信息的数组。
- 返回：无。
