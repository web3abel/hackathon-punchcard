// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


// participants:
// business (struct: {ownerId: address, businesPubKey: hash} )
// customer (struct: {ownerId: address})
// punchcard (erc-721: {businesPubKey: hash, mapping: {businessId: {customerId: points} } } )

contract PunchCard is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _checkinCounter;
    
    // {"businesPubKey": {"customerPubKey": "points(Int)"}}
    // businessClientPoints[businessPubKey][customerPubKey] => points

    mapping(address => bool) addressHasNFT; // First Item has Index 0

    mapping(address => mapping(address => uint256)) public businessClientPoints;

    address businessPubKey;

    constructor() ERC721("PunchCard", "PCRD") {}

    //    mint an NFT
    function safeMint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        addressHasNFT[to] = true;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function incrementCheckin(address to, string memory uri) public {
      if (addressHasNFT[to] == true) {
        _checkinCounter.increment();
      } else {
        safeMint(to, uri);
      }
    }

    function makePurchase(address to, string memory uri, uint256 amount) public {
      uint256 minimumAmountForCheckin = 1;
      if (amount > minimumAmountForCheckin) {
        // if amount is greater than threshold, increment checkin (and/or create NFT)
        incrementCheckin(to, uri);
      }

      // always transfer funds from sender account => business account
      // transferFrom(msg.sender, to, '0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1');
      // TODO: figure out how to send from msg.sender to business account above using `transferFrom`

    }

    function redeemCheckin() public {
      uint8 i = 0;
      if (_checkinCounter.current() >= 5) {
        // decrement 5 points on redeem
        for (i = 0; i < 5; i++) {
          _checkinCounter.decrement();
        }
      }
    }

    function registerBusiness(address business_pub_key) public onlyOwner {
        // update the PunchCard's `businessPubKey` attribute
        businessPubKey = business_pub_key;
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        // you can override and do your data generation and storage for the token that is being minted.
        super._beforeTokenTransfer(from, to, tokenId);
    }

    //    destroy an NFT
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    //    return IPFS url of NFT metadata
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}