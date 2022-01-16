import assert from "assert";
import { Contract } from "ethers";
import { ethers } from "hardhat";

import {
    deployNftLender,
    deployTestNft
} from "./helpers.test";

import {
    assertAddressExist
} from "./assertions.test";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

let deployer: SignerWithAddress;

let factory: Contract;
let nftLender: Contract;
let nft: Contract;

beforeEach(async function() {

    [deployer] = await ethers.getSigners();

    nft = await deployTestNft("Text", "TT", 10);
    
    const Factory = await ethers.getContractFactory("wNftFactory");
    factory = await Factory.deploy();

    nftLender = await deployNftLender(factory.address);

    await factory.setNftLender(deployer.address);
});

describe("Factory", function() {

    it("Deployed the factory", async function() {
        assertAddressExist(factory.address);
    });

    it("Deploy an NFT", async function() {
        await factory.createwNft(nft.address);
        const wNftIndex = await factory.getWErc721Index(nft.address);

        const wNftAddress = await factory.getWERC721Address(wNftIndex);

        assertAddressExist(wNftAddress);

    });

    it("Stored Nft properly", async function() {
        await factory.createwNft(nft.address);
        const wNftIndex = await factory.getWErc721Index(nft.address);

        const wNftAddress = await factory.getWERC721Address(wNftIndex);

        const allNfts = await factory.getAllWERC721Addresses();

        assertAddressExist(wNftAddress);
        assert.strictEqual(+wNftIndex, 0);
        assert.strictEqual(allNfts[0], wNftAddress);
    });

});
