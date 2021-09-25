// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Knights is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenId;

    uint public knightsCount;

    struct Knight {
        uint tokenId;
        string tokenUri;
        address owner;
        uint price;
        uint numberOfTransfers;
        bool forSale;
    }

    mapping(uint => Knight) public knightCollection;
    /* check if token URI exists */
    mapping(string => bool) public tokenURIExists;

    event KnightGenerated(uint tokenId, string tokenUri, address mintedBy, uint price, bool forSale);
    event KnightBought(uint tokenId, string tokenUri, address currentOwner, address previousOwner, uint price, uint transfers);
    event KnightForSale(uint tokenId, string tokenUri, address owner, bool forSale);


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

    function mintKnight(string memory _tokenUri, uint _price, bool _putOnSale) external returns (uint) {
        require(!tokenURIExists[_tokenUri], "Knight: URI already minted");
        uint tokenCounterId = incrementAndGet();
        _safeMint(msg.sender, tokenCounterId);
        _setTokenURI(tokenCounterId, _tokenUri);
        tokenURIExists[_tokenUri] = true;
        knightsCount = tokenCounterId;
        knightCollection[tokenCounterId] = Knight(tokenCounterId, _tokenUri, msg.sender, _price, 0, _putOnSale);
        emit KnightGenerated(tokenCounterId, _tokenUri, msg.sender, _price, _putOnSale);
        return tokenCounterId;
    }

    function buyKnight(uint _knightTokenId) external payable {
        Knight memory kInstance = knightCollection[_knightTokenId];
        require(msg.value >= kInstance.price, "Knight: Insufficient funds");
        require(kInstance.forSale, "Knight: Not for sale");
        address knightCurrentOwner = ownerOf(_knightTokenId);
        require(knightCurrentOwner == kInstance.currentOwner, "Knight: Knight ownership dispute");
        super.safeTransferFrom(knightCurrentOwner, msg.sender, _knightTokenId);
        payable(knightCurrentOwner).transfer(msg.value);
        kInstance.owner = msg.sender;
        kInstance.numberOfTransfers += 1;
        kInstance.price = msg.value;
        emit KnightBought(_knightTokenId, kInstance.tokenUri, msg.sender, knightCurrentOwner, kInstance.price, kInstance.numberOfTransfers);
        knightCollection[_knightTokenId] = kInstance;
    }
    
    function setForSale(uint _knightTokenId, bool _forSale) external knightOwnerPrivilege(_knightTokenId) {
        Knight memory knightInst = knightCollection[_knightTokenId];
        knightInst.forSale = _forSale;
        emit KnightForSale(_knightTokenId, knightInst.tokenUri, knightInst.owner, _forSale);
        knightCollection[_knightTokenId] = knightInst;
    }

}
