// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BobaNFTERC721 is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    IERC20 public tokenAddress;

    struct BobaNFT {
        uint256 cardId;
        string cardName;
        string description;
        uint256 createdAt;
        uint8 cardType;
    }

    mapping(uint256 => BobaNFT) private BobaMap;

    constructor(address _tokenAddress) ERC721("Shogun", "$SHOGUN") {
        tokenAddress = IERC20(_tokenAddress);
    }

    function addCard(string memory _cardName, string memory _description, uint8 _cardType) external onlyOwner {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        BobaNFT memory newBoba = BobaNFT({
            cardId: tokenId,
            cardName: _cardName,
            description: _description,
            createdAt: block.timestamp,
            cardType: _cardType
        });

         BobaMap[tokenId] = newBoba;
    }

    function safeMint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        tokenAddress.transferFrom(msg.sender, address(this), etherToWei(10));
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }


    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function etherToWei(uint valueEther) private pure returns (uint) {
       return valueEther*(10**18);
    }

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