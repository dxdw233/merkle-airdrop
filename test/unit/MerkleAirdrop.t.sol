// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {BagelToken} from "../../src/BagelToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZKSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop airdrop;
    BagelToken token;

    bytes32 public ROOT = 0x9c968373a07700fd29acf468ce47ba1245012c73a337c01fa53cf8baed36dac9;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 proof1 = 0xf884e61898c71567fd4f44aa020453ed544cb775949e2087043630858aa9e609;
    bytes32 proof2 = 0xf19a9e842b5a96e6e829203e375dfae8688610006eff2ecee5b1d5171631c970;
    bytes32[] public PROOF = [proof1, proof2];
    address user;
    uint256 userPrivKey;
    address gasPayer;

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 message = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, message);
        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance: ", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
