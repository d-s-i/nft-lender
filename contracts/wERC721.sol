pragma solidity ^0.8.0;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract wERC721 is ERC721, Ownable {

    address private _nftLender;
    address private _baseNft;

    constructor(
        string memory name, 
        string memory symbol, 
        address nftLender,
        address baseNft
    ) ERC721(name, symbol) Ownable() {
        _nftLender = nftLender;
        _baseNft = baseNft;
    }

    modifier onlyNftLender() {
        require(msg.sender == _nftLender);
        _;
    }

    // /**
    //  * @dev See {IERC721-isApprovedForAll}.
    //  */
    // function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
    //     if(msg.sender == nftLender) {
    //         return true;
    //     }
    //     return _operatorApprovals[owner][operator];
    // }

    function mint(address _to, uint256 _tokenId) public onlyNftLender {
        _safeMint(_to, _tokenId);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override onlyNftLender {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override onlyNftLender {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override onlyNftLender {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function setNftLender(address _newNftLender) public onlyOwner {
        _nftLender = _newNftLender;
    }

}