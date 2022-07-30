// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "./utils/TestToken.sol";
import "./utils/Utilities.sol";

import "../src/Connaitre.sol";

contract ConnaitreNewTest is Test {

    address payable[] internal users;
    address payable internal anon;
    address payable internal prover;
    address payable internal bystander;

    TestToken internal bountyToken;
    Utilities internal utils;

    uint256 immutable internal BOUNTY_SIZE = 1_000_000e18;
    
    address immutable internal ANON_INFO_ADDRESS = 0x16e7663403582f8239C92724ceE6038b1e8AA4C4;
    address immutable internal BOUNTY_RECEIVER_ADDRESS = 0xEA15ffdA91B29882F0163f7eE753b920024F8822;
    uint8 immutable internal v = 27;
    bytes32 immutable internal r = 0x70f9ff850d78a6d3d078428997c0a3b7a9c3e2b40af17585380718ef09adf1bc;
    bytes32 immutable internal s = 0x71afcf2b491b7851d0a673697e7e052cc3267716c20a5d268a5069349024d396;

    function setUp() public {
        utils = new Utilities();

        // Label important addresses
        vm.label(ANON_INFO_ADDRESS, "Anon Info");
        vm.label(BOUNTY_RECEIVER_ADDRESS, "Bounty Receiver");

        // Define the anon, a prover, and a bystander
        users = utils.createUsers(3);
        anon = users[0];
        prover = users[1];
        bystander = users[2];

        vm.label(anon, "Anon");
        vm.label(prover, "Prover");
        vm.label(bystander, "Bystander");

        
        // Initialize the token
        bountyToken = new TestToken();
        vm.label(address(bountyToken), "Bounty Token");

        // Transfer BOUNTY_SIZE bounty tokens to the anon
        bountyToken.transfer(address(anon), BOUNTY_SIZE);
    }

    // 100 blocks after contract creation, test a prove and claim
    function testAtReserveStartBlockClaim() external {
        // Deploy the contract and transfer ERC20 token to it
        vm.startPrank(anon);
        Connaitre connaitreContract = new Connaitre(
            ANON_INFO_ADDRESS,
            address(bountyToken),
            BOUNTY_SIZE
        );
        vm.stopPrank();

        // Verify that it reverts if a prover tries to prove before the account is funded
        vm.startPrank(prover);
        vm.expectRevert(Connaitre.ContractNotFundedError.selector);
        connaitreContract.proveKnowledgeAndClaim(BOUNTY_RECEIVER_ADDRESS, v, r, s);
        vm.stopPrank();

        // Transfer token to the address
        vm.startPrank(anon);
        bountyToken.transfer(address(connaitreContract), BOUNTY_SIZE);
        vm.stopPrank();

        // Roll forward 100 blocks
        vm.roll(block.number + 100);

        // Show that an invalid proof will revert.
        // For instance, suppose bystander was a mempool snooper
        // participating in a PGA against the prover.
        vm.startPrank(bystander);
        vm.expectRevert(Connaitre.InvalidSignError.selector);
        connaitreContract.proveKnowledgeAndClaim(
            bystander,
            v,
            r,
            s
        );
        vm.stopPrank();

        // Prover finds the information, proves it, and sends funds to receiver
        vm.startPrank(prover);
        connaitreContract.proveKnowledgeAndClaim(
            BOUNTY_RECEIVER_ADDRESS,
            v,
            r,
            s
        );
        vm.stopPrank();

        // Assert all balances are correct in the end
        assertEq(
            bountyToken.balanceOf(BOUNTY_RECEIVER_ADDRESS),
            BOUNTY_SIZE
        );
        
        assertEq(
            bountyToken.balanceOf(address(connaitreContract)),
            0
        );

        assertEq(
            bountyToken.balanceOf(anon),
            0
        );

        assertEq(
            bountyToken.balanceOf(bystander),
            0
        );
    }
    
}
