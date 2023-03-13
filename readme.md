## 功能

1. 帮我创建一个ERC721智能合约，称之为DIDCentral

2. 任何地址都可以mint，mint得到的nft的id为自己的地址（因此如果已经mint过，则会报错），一旦创建，nft不可转移。mint生成nft的同时会创建一个具有enumerable拓展的ERC721智能合约`NFTCollectionFactory`。这个合约的地址会与mint生成的nft绑定。不同地址进行DIDCentral的mint都会有一个独立的NFTCollectionFactory生成。CollectionFactory中记录了DIDCentral的地址。

3. DIDCentral具有一套权限管理系统：NFT的拥有者可以设置多位管理员；除了不能设置管理员外，每位管理员拥有与拥有者相同的权限。

4. ERC721合约 NFTCollectionFactory拥有接口`createCollection`（注意，这个接口不是DIDCentral的）, DIDCentral对应NFT的拥有者/管理员可以任意调用该接口。调用该接口会使ERC721 合约 NFTCollectionFactory mint NFT， 同时创建一个智能合约`NFTCollection`，该合约同样也为具有enumerable拓展的ERC721合约。NFTCollectionFactory mint 生成的NFT与NFTCollection相绑定。

5. `NFTCollection`拥有接口 `addNFTLink(address contractAddress, uint256 tokenId, uint8 tokenType)` （注意，这个接口不是NFTCollectionFactory或DIDCentral的）. tokenType可以为721或1155，代表contractAddress代表的合约类型. 调用该接口时会进行验证，NFT的拥有者/管理者是否具有指定合约下指定tokenId的所有权。如果具有，则会mint一个nft，`NFTCollection`mint生成的该nft会记录contractAddress，tokenId，tokenType这三个信息。

## 待添加功能


