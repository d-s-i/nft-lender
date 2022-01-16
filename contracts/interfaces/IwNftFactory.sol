pragma solidity ^0.8.0;

interface IwNftFactory {

    event wERC721Created(address _initialAddress, address wERC721, address creator, string name);

    function createwNft(address _baseNft) external;

    function getAllWERC721Addresses() external view returns(address[] memory);

    function getWErc721Index(address _baseNft) external view returns(uint256);

    function getWERC721Address(uint256 _index) external view returns(address);

}