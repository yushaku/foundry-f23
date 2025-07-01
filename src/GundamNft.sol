// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract GundamNft is ERC721, Ownable {
    error GundamNft__TokenUriNotFound();
    error GundamNft__BaseUriLengthInvalid();
    event BaseUriSet(string baseUri);

    string private s_baseUri;
    uint256 private s_tokenCounter;
    mapping(uint256 tokenId => string contentUri) private s_tokenIdToUri;

    constructor() ERC721("Gundam", "GUNDAM") Ownable(msg.sender) {
        s_tokenCounter = 0;
        s_baseUri = "https://ipfs.io/ipfs/";
    }

    function mintNft(address to, string memory contentUri) public onlyOwner {
        s_tokenIdToUri[s_tokenCounter] = contentUri;
        _safeMint(to, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function setBaseUri(string memory baseUri) public onlyOwner {
        // make sure baseUri is not empty and is a short string
        if (!(bytes(baseUri).length > 0 && bytes(baseUri).length < 64)) {
            revert GundamNft__BaseUriLengthInvalid();
        }

        s_baseUri = baseUri;
        emit BaseUriSet(baseUri);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert GundamNft__TokenUriNotFound();
        }

        return string.concat(s_baseUri, s_tokenIdToUri[tokenId]);
    }

    function getTokenCounter() external view returns (uint256) {
        return s_tokenCounter;
    }

    function baseURI() external view returns (string memory) {
        return s_baseUri;
    }
}
