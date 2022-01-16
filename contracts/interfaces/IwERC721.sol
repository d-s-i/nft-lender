pragma solidity ^0.8.0;

import { IERC721 } from "./IERC721.sol";

interface IwERC721 is IERC721 {
    function mint(address _to, uint256 _tokenId) external;
    function setNftLender(address _newNftLender) external;
}