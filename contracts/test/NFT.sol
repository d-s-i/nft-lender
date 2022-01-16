pragma solidity ^0.8.0;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, Ownable {

    uint256 private _totalSupply;
    uint256 private MAX_SUPPLY;

    constructor(
        string memory name_, 
        string memory symbol_,
        uint256 _maxSupply
    ) ERC721(name_, symbol_) Ownable() {
        _totalSupply = 0;
        MAX_SUPPLY = _maxSupply;
    }

    modifier MaxSupplyNotReached() {
        require(_totalSupply < MAX_SUPPLY);
        _;
    }
    
    function mint(address _to) public onlyOwner MaxSupplyNotReached {
        _safeMint(_to, _totalSupply++);
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

}