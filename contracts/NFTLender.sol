//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IwERC721 } from "./interfaces/IwERC721.sol";
import { IwNftFactory } from "./interfaces/IwNftFactory.sol";

contract NFTLender is Ownable, IERC721Receiver, ERC165 {

    constructor(address _wNftFactory) Ownable() {
        wNftFactory = _wNftFactory;
    }

    address public wNftFactory;

    // owner => nftAddress => tokenId => boolean
    mapping(address => mapping(address => mapping(uint256 => bool))) private _isLender;
    // nftAddress => tokenId => depositor
    mapping(address =>  mapping(uint256 => address)) private _lender;
    // nftAddress => tokenId => borrower
    mapping(address => mapping(uint256 => address)) private _borrower;
    // nfAddress => tokenId => isLended
    mapping(address => mapping(uint256 => bool)) private _isLended;
    // nfAddress => tokenId => isDeposited
    mapping(address => mapping(uint256 => bool)) private _isDeposited;
    
    function getERC721Back(address _token, uint256 _tokenId) public onlyOwner {
        IERC721(_token).safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    function safeDepositERC721(address _token, uint256 _tokenId) public {
        IERC721(_token).safeTransferFrom(msg.sender, address(this), _tokenId);
        _isLender[msg.sender][_token][_tokenId] = true;
        _lender[_token][_tokenId] = msg.sender;
        _borrower[_token][_tokenId] = address(this);
        _isDeposited[_token][_tokenId] = true;
    }

    function safeWithdrawErc721(address _token, uint256 _tokenId) public {
        require(msg.sender == _lender[_token][_tokenId], "NFTLender: You are not the initial depositor");
        address lender = _lender[_token][_tokenId];
        address borrower = _borrower[_token][_tokenId];

        resetLender(_token, _tokenId);
        resetBorrower(_token, _tokenId);
        _isLender[msg.sender][_token][_tokenId] = false;
        _isDeposited[_token][_tokenId] = false;

        IERC721(_token).safeTransferFrom(borrower, lender, _tokenId);
    }

    function safeBorrowErc721(address _token, uint256 _tokenId) public {
        require(_isLended[_token][_tokenId] == false, "NFTLender: Nft already lended");
        _borrower[_token][_tokenId] = msg.sender;
        _isLended[_token][_tokenId] = true;

        uint256 index =  IwNftFactory(wNftFactory).getWErc721Index(_token);
        address wERC721Address = IwNftFactory(wNftFactory).getWERC721Address(index);

        IwERC721(wERC721Address).mint(msg.sender, _tokenId);
    }

    function isAccountLenderOfTokenId(address _depositor, address _token, uint256 _tokenId) public view returns(bool) {
        return _isLender[_depositor][_token][_tokenId];
    }

    function resetLender(address _token, uint256 _tokenId) internal {
        _lender[_token][_tokenId] = address(0);
    }

    function resetBorrower(address _token, uint256 _tokenId) internal {
        _borrower[_token][_tokenId] = address(0);
    }

    function setWNftFactory(address _newWNftFactory) public onlyOwner {
        wNftFactory = _newWNftFactory;
    }

    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

}
