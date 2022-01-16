import assert from "assert";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";

import { transferNftFromToId, depositErc721InContract } from "./helpers.test";
import { nft, nftLender } from "./index.test";

export const assertAddressExist = function(address: string) {
    assert.ok(typeof(address) !== "undefined");
    assert.ok(address);
}

export const assertNftTransferOk = async function(
    from: SignerWithAddress, 
    to: string, 
    tokenId: number
) {
    const initalBalance = await nft.balanceOf(to);

    await transferNftFromToId(from, to, tokenId);
    
    const finalBalance = await nft.balanceOf(to);

    assert.ok(initalBalance.add(1).eq(finalBalance));
}

export const assertNftDepositOk = async function(
    from: SignerWithAddress, 
    token: Contract, 
    tokenId: number
) {

    await depositErc721InContract(from, token, tokenId);

    const isLender = await nftLender.isAccountLenderOfTokenId(from.address, token.address, tokenId);
    assert.ok(isLender);
}