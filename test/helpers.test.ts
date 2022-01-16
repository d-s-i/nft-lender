import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract, Signer } from "ethers";
import { ethers } from "hardhat";

import { deployer, nft, nftLender } from "./index.test";

export const displayAddresses = function(name: string, address: string) {
    console.log(`${name}: ${address}`);
}

export const deployNftLender = async function(factoryAddress: string) {
    const _NFTLender = await ethers.getContractFactory("NFTLender");
    const _nftLender = await _NFTLender.deploy(factoryAddress);
    return _nftLender;
}

export const deployTestNft = async function(name: string, symbol: string, maxSupply: number) {
    const _NFT = await ethers.getContractFactory("NFT");
    const _nft = await _NFT.deploy(name, symbol, maxSupply);
    return _nft;
}

export const mintNftAmountTo = async function(amount: number, address: string) {
    const contract = nft.connect(deployer);
    for(let i = 0; i < amount; i++) {
        await contract.mint(address);
    }
}

export const transferNftFromToId = async function(from: SignerWithAddress, to: string, tokenId: number) {
    const contract = nft.connect(from);
    await contract.transferFrom(from.address, to, tokenId);
}

export const depositErc721InContract = async function(
    from: SignerWithAddress,
    token: Contract,
    tokenId: number
) {
    const lender = nftLender.connect(from);

    const isApproved = await nft.isApprovedForAll(from.address, nftLender.address);

    if(!isApproved) {
        const nftContract = nft.connect(from);
        await nftContract.setApprovalForAll(nftLender.address, true);
    }
    
    await lender.safeDepositERC721(token.address, tokenId);
}