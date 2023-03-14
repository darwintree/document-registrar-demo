import pytest
import random
from brownie import web3, DocumentRegistrar, Contract, accounts, exceptions, ERC721Demo, ERC1155Demo # type: ignore


@pytest.fixture(scope="module")
def owner() -> str:
    return accounts[0].address

@pytest.fixture(scope="module")
def registrar(owner) -> Contract:
    return DocumentRegistrar.deploy({"from": owner})

@pytest.fixture(scope="module")
def nft721_contract(owner) -> Contract:
    contract = ERC721Demo.deploy({"from": owner})

    return contract

@pytest.fixture(scope="module")
def nft721_info_list(owner, nft721_contract):
    amount = 3
    return [
        [721, nft721_contract.address, nft721_contract.mint(owner).return_value] for i in range(amount)
    ]

@pytest.fixture(scope="module")
def nft1155_contract(owner) -> Contract:
    contract = ERC1155Demo.deploy({"from": owner})
    contract.mint(owner, 1)
    contract.mint(owner, 10)
    return contract

@pytest.fixture(scope="module")
def nft1155_info_list(owner, nft1155_contract):
    amount_list = [2, 10]
    return [
        [1155, nft1155_contract.address, nft1155_contract.mint(owner, amount).return_value] for amount in amount_list
    ]

def test_mint(owner, registrar):
    registrar.mint({"from": owner})
    assert registrar.balanceOf(owner) == 1

def test_set_avatar(owner, registrar, nft721_info_list):
    # 721 NFT
    nft_info_721 = nft721_info_list[0]
    registrar.setAvatarFor(accounts[0].address, nft_info_721, {"from": owner})
    assert registrar.avatar(accounts[0].address) == nft_info_721

def test_set_text(owner, registrar):
    # Set text for key "description"
    registrar.setTextFor(accounts[0].address, "description", "Some description", {"from": owner})
    # Verify that text is set for key "description"
    assert registrar.textInfo(accounts[0].address, "description")[1] == "Some description"

@pytest.fixture(scope="function")
def collection_index(owner, registrar) -> int:
    name = f"Collection {random.randint(1, 1024)}"
    description = "Some description"
    # Create a collection for the owner
    collection_index = registrar.createCollectionFor(owner, name, description, {"from": owner}).return_value
    # Verify that the owner has a collection
    assert collection_index in registrar.nftCollectionIndexesOfOwner(owner)
    # Verify that the collection has the correct name and description
    assert registrar.nftCollection(collection_index)[0] == name
    assert registrar.nftCollection(collection_index)[1] == description
    return collection_index

# collection_index is function scope
# currently there is no nft in collection (of collection_index)
def test_add_nft_to_collection(owner, registrar, collection_index, nft721_info_list, nft1155_info_list):
    registrar.addNftsToCollection(collection_index, nft721_info_list, {"from": owner})
    registrar.addNftsToCollection(collection_index, nft1155_info_list, {"from": owner})
    addedNfts = registrar.nftsOfCollection(collection_index)
    assert addedNfts == (nft721_info_list + nft1155_info_list)

def test_access_control(owner, registrar, collection_index, nft721_info_list):
    new_manager = accounts[1].address
    with pytest.raises(exceptions.VirtualMachineError):
        registrar.addNftsToCollection(collection_index, nft721_info_list, {"from": new_manager})  # should fail without manager role
    registrar.grantManager(new_manager, {"from": owner})
    registrar.addNftsToCollection(collection_index, nft721_info_list, {"from": new_manager})  # should pass with manager role
