pragma solidity ^0.8.0;

import "./wERC721.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract wNftFactory is Ownable {

    address private _nftLender;

    address[] private _allWrappedNft;
    // baseNft => index
    mapping(address => uint256) private _wNftIndex;
    uint256 private _nftCreated;

    event wERC721Created(address _initialAddress, address wERC721, address creator, string name);

    constructor() {
        _nftCreated = 0;
    }

    modifier onlyNftLender() {
        require(msg.sender == _nftLender);
        _;
    }
    
    function createwNft(address _baseNft) public {
        require(_wNftIndex[_baseNft] == 0, "wNftFactory: Nft already wrapped");
        wERC721 wErc721 = new wERC721(
            IERC721Metadata(_baseNft).name(), 
            IERC721Metadata(_baseNft).symbol(), 
            _nftLender, 
            _baseNft
        );
        _wNftIndex[_baseNft] = _nftCreated;
        _allWrappedNft.push(address(wErc721));
        _nftCreated++;

        emit wERC721Created(_baseNft, address(wErc721), msg.sender, IERC721Metadata(_baseNft).name());
    }

    function getAllWERC721Addresses() public view returns(address[] memory) {
        return _allWrappedNft;
    }

    function getWErc721Index(address _baseNft) public view returns(uint256) {
        return _wNftIndex[_baseNft];
    }

    function getWERC721Address(uint256 _index) public view returns(address) {
        return _allWrappedNft[_index];
    }

    function setNftLender(address _newNftLender) public onlyOwner {
        _nftLender = _newNftLender;
    }
}