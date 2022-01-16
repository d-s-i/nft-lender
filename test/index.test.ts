import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import assert from "assert";
import { Contract } from "ethers";
import { ethers } from "hardhat";

import {
  assertAddressExist,
  assertNftTransferOk,
  assertNftDepositOk
} from "./assertions.test";
import {
  displayAddresses,
  deployTestNft,
  deployNftLender,
  mintNftAmountTo,
  transferNftFromToId,
  depositErc721InContract
} from "./helpers.test";

export let deployer: SignerWithAddress;
let holder: SignerWithAddress;
let borrower: SignerWithAddress;


export let nft: Contract;
export let nftLender: Contract;
export let factory: Contract;
export let wNft: Contract;

let wNftAddress: string;

const displayAddress = false;

beforeEach(async function() {

  [deployer, holder, borrower] = await ethers.getSigners();
  
  nft = await deployTestNft("ExEntric", "EXE", 10);

  const Factory = await ethers.getContractFactory("wNftFactory");
  factory = await Factory.deploy();

  nftLender = await deployNftLender(factory.address);

  await factory.setNftLender(nftLender.address);

  await mintNftAmountTo(1, holder.address);

  await factory.createwNft(nft.address);

  const wNftIndex = await factory.getWErc721Index(nft.address);

  wNftAddress = await factory.getWERC721Address(wNftIndex);

  const WNFT = await ethers.getContractFactory("wERC721");
  wNft = await new ethers.Contract(wNftAddress, WNFT.interface, deployer);

});

describe("NFT", function () {

  it("Display addresses", function() {
    
    displayAddress && displayAddresses("Deployer", deployer.address);
    displayAddress && displayAddresses("Holder", holder.address);
    displayAddress && displayAddresses("Borrower", borrower.address);
    displayAddress && displayAddresses("nftLender", nftLender.address);

  });
  
  it("Deployed the NFT Contract", async function () {
    await assertAddressExist(nft.address);
  });

  it("Deployed the NFTLender Contract", async function () {
    await assertAddressExist(nftLender.address);
  });

  it("Send an nft to the NFTLender", async function() {
    await assertNftDepositOk(holder, nft, 0);
  });

  it("Can get Nft back", async function() {

    await assertNftDepositOk(holder, nft, 0);

    nftLender = nftLender.connect(holder);
    await nftLender.safeWithdrawErc721(nft.address, 0);

    const isLender = await nftLender.isAccountLenderOfTokenId(holder.address, nft.address, 0);
    assert.ok(!isLender);

  });

  it("Borrow an nft", async function() {

    const initialBorrowerBalance = await wNft.balanceOf(borrower.address);
    
    nftLender = nftLender.connect(borrower);
    await nftLender.safeBorrowErc721(nft.address, 0);

    const finalBorrowerBalance = await wNft.balanceOf(borrower.address);

    const owner = await wNft.ownerOf(0);

    assert.ok(finalBorrowerBalance.eq(initialBorrowerBalance.add(1)));
    assert.strictEqual(owner, borrower.address);
  });
  
});
