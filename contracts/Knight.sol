// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Knights is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    struct Knight {
        uint tokenId;
        string tokenUri;
        address mintedBy;
        address currentOwner;
        address previousOwner;
        uint price;
        uint numberOfTransfers;
        bool forSale;
    }

    mapping(uint => Knight) public knightCollection;
    /* check if token URI exists */
    mapping(string => bool) public tokenURIExists;

    constructor() ERC721("Knight Collectibles ", "KNC") {
    }
    
    modifier knightOwnerPrivilege(uint tId) {
        require(ownerOf(tId) == knightCollection[tId].currentOwner, "Knight: Ownership dispute");
        require(msg.sender == ownerOf(tId), "Knight: You are not permitted");
        _;
    }

    function incrementAndGet() internal returns (uint) {
        _tokenId.increment();
        return _tokenId.current();
    }

    function mintKnight(string memory _tokenUri, uint _price, bool _putOnSale) public returns (uint) {
        require(!tokenURIExists[_tokenUri], "Knight: URI already minted");
        uint tokenCounterId = incrementAndGet();
        _safeMint(msg.sender, tokenCounterId);
        _setTokenURI(tokenCounterId, _tokenUri);
        tokenURIExists[_tokenUri] = true;
        knightCollection[tokenCounterId] = Knight(tokenCounterId, _tokenUri, msg.sender, msg.sender, address(0), _price, 0, _putOnSale);
        return tokenCounterId;
    }

    function buyKnight(uint _knightTokenId) public payable {
        Knight memory kInstance = knightCollection[_knightTokenId];
        require(msg.value >= kInstance.price, "Knight: Insufficient funds");
        require(kInstance.forSale, "Knight: Not for sale");
        address knightCurrentOwner = ownerOf(_knightTokenId);
        require(knightCurrentOwner == kInstance.currentOwner, "Knight: Knight ownership dispute");
        super.safeTransferFrom(knightCurrentOwner, msg.sender, _knightTokenId);
        payable(knightCurrentOwner).transfer(msg.value);
        kInstance.previousOwner = knightCurrentOwner;
        kInstance.currentOwner = msg.sender;
        kInstance.numberOfTransfers += 1;
        kInstance.price = msg.value;
        knightCollection[_knightTokenId] = kInstance;
    }
    
    function setForSale(uint _knightTokenId, bool _forSale) public knightOwnerPrivilege(_knightTokenId) {
        Knight storage knightInst = knightCollection[_knightTokenId];
        knightInst.forSale = _forSale;
    }

}
