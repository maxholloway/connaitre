// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "./utils/TestToken.sol";
import "./utils/Utilities.sol";

import "../src/Connaitre.sol";

contract ConnaitreTest is Test {

    address payable[] internal users;
    address payable internal anon;
    address payable internal prover;
    address payable internal bystander;

    TestToken internal bountyToken;
    Utilities internal utils;

    bytes32 IMAGE;
    bytes32 IMAGE_IMAGE;

    uint256 BOUNTY_SIZE = 1_000_000e18;
    uint256 ESCROW_SIZE = 10_000e18;
    uint256 ESCROW_BLOCKS = 250; // approximately 1 hour



    function setUp() public {
        utils = new Utilities();

        // Define the anon, a prover, and a bystander
        users = utils.createUsers(3);
        anon = users[0];
        prover = users[1];
        bystander = users[2];

        vm.label(anon, "Anon");
        vm.label(prover, "Prover");
        vm.label(bystander, "Bystander");

        // Set the IMAGE_IMAGE
        IMAGE = keccak256(
            abi.encodePacked(
                "My name is Giovanni Giorgio, but everybody calls me 'Giorgio'."
            )
        );
        IMAGE_IMAGE = keccak256(
            abi.encodePacked(
                IMAGE
            )
        );

        // Initialize the token

        bountyToken = new TestToken();
        vm.label(address(bountyToken), "Bounty Token");

        // Transfer BOUNTY_SIZE + ESCROW_SIZE bounty tokens to the anon
        bountyToken.transfer(address(anon), BOUNTY_SIZE + ESCROW_SIZE);

        // Transfer ESCROW_SIZE bounty tokens to the prover and the bystander
        // so that they have enough to try to prove
        bountyToken.transfer(address(prover), ESCROW_SIZE);
        bountyToken.transfer(address(bystander), ESCROW_SIZE);
        

    }

    // Test a contract creation, 100 blocks later a reservation, then same block claim
    function testAtReserveStartBlockClaim() external {
        // Anon creates contract
        vm.startPrank(anon);
        Connaitre connaitreContract = new Connaitre(
            anon,
            address(bountyToken),
            BOUNTY_SIZE,
            ESCROW_SIZE,
            ESCROW_BLOCKS,
            IMAGE_IMAGE
        );
        bountyToken.transfer(address(connaitreContract), BOUNTY_SIZE);
        vm.stopPrank();

        // Roll forward 100 blocks
        vm.roll(block.number + 100);

        // Prover finds the information, reserves, and immediately 
        vm.startPrank(prover);
        bountyToken.approve(address(connaitreContract), ESCROW_SIZE);
        connaitreContract.reserveWindow(prover);
        connaitreContract.proveKnowledgeAndClaim(IMAGE, prover);
        vm.stopPrank();

        // Assert all balances are correct in the end
        assertEq(
            bountyToken.balanceOf(prover),
            BOUNTY_SIZE + ESCROW_SIZE
        );
        
        assertEq(
            bountyToken.balanceOf(address(connaitreContract)),
            0
        );

        assertEq(
            bountyToken.balanceOf(bystander),
            ESCROW_SIZE
        );
    }

    // Test a contract creation, 100 blocks later a reservation, then <ESCROW_BLOCKS later claim
    function testPreReserveEndBlockClaim() external {
        // Anon creates contract
        vm.startPrank(anon);
        Connaitre connaitreContract = new Connaitre(
            anon,
            address(bountyToken),
            BOUNTY_SIZE,
            ESCROW_SIZE,
            ESCROW_BLOCKS,
            IMAGE_IMAGE
        );
        bountyToken.transfer(address(connaitreContract), BOUNTY_SIZE);
        vm.stopPrank();

        // Roll forward 100 blocks
        vm.roll(block.number + 100);

        // Prover finds the information, reserves, and immediately 
        vm.startPrank(prover);
        bountyToken.approve(address(connaitreContract), ESCROW_SIZE);
        connaitreContract.reserveWindow(prover);

        // Get near the end of the reservation phase
        vm.roll(block.number + (ESCROW_BLOCKS - 1));
        connaitreContract.proveKnowledgeAndClaim(IMAGE, prover);
        vm.stopPrank();

        // Assert all balances are correct in the end
        assertEq(
            bountyToken.balanceOf(prover),
            BOUNTY_SIZE + ESCROW_SIZE
        );
        
        assertEq(
            bountyToken.balanceOf(address(connaitreContract)),
            0
        );

        assertEq(
            bountyToken.balanceOf(bystander),
            ESCROW_SIZE
        );
    }

    // Test a contract creation, 100 blocks later a reservation, then ESCROW_BLOCKS later claim
    function testAtReserveEndBlockClaim() external {
        // Anon creates contract
        vm.startPrank(anon);
        Connaitre connaitreContract = new Connaitre(
            anon,
            address(bountyToken),
            BOUNTY_SIZE,
            ESCROW_SIZE,
            ESCROW_BLOCKS,
            IMAGE_IMAGE
        );
        bountyToken.transfer(address(connaitreContract), BOUNTY_SIZE);
        vm.stopPrank();

        // Roll forward 100 blocks
        vm.roll(block.number + 100);

        // Prover finds the information, reserves, and immediately 
        vm.startPrank(prover);
        bountyToken.approve(address(connaitreContract), ESCROW_SIZE);
        connaitreContract.reserveWindow(prover);

        // Get near the end of the reservation phase
        vm.roll(block.number + ESCROW_BLOCKS);
        connaitreContract.proveKnowledgeAndClaim(IMAGE, prover);
        vm.stopPrank();

        // Assert all balances are correct in the end
        assertEq(
            bountyToken.balanceOf(prover),
            BOUNTY_SIZE + ESCROW_SIZE
        );
        
        assertEq(
            bountyToken.balanceOf(address(connaitreContract)),
            0
        );

        assertEq(
            bountyToken.balanceOf(bystander),
            ESCROW_SIZE
        );
    }

    // Test that nobody can prove it before creating a reservation window
    function testNoPreReservationWindowClaims() external {
        // Anon creates contract
        vm.startPrank(anon);
        Connaitre connaitreContract = new Connaitre(
            anon,
            address(bountyToken),
            BOUNTY_SIZE,
            ESCROW_SIZE,
            ESCROW_BLOCKS,
            IMAGE_IMAGE
        );
        bountyToken.transfer(address(connaitreContract), BOUNTY_SIZE);
        vm.stopPrank();

        // Roll forward 100 blocks
        vm.roll(block.number + 100);

        // Nobody should be able to prove knowledge without 
        for (uint8 i = 0; i < 3; ++i) {
            vm.startPrank(users[i]);
            vm.expectRevert(abi.encodeWithSelector(Connaitre.NotInWindowError.selector));
            connaitreContract.proveKnowledgeAndClaim(IMAGE, users[i]);
            vm.stopPrank();
        }
    }

    // Test that nobody can prove it after a reservation window is over
    function testNoPostReservationWindowClaims() external {
        // Anon creates contract
        vm.startPrank(anon);
        Connaitre connaitreContract = new Connaitre(
            anon,
            address(bountyToken),
            BOUNTY_SIZE,
            ESCROW_SIZE,
            ESCROW_BLOCKS,
            IMAGE_IMAGE
        );
        vm.label(address(connaitreContract), "Connaitre Contract");
        bountyToken.transfer(address(connaitreContract), BOUNTY_SIZE);
        vm.stopPrank();

        // Roll forward 100 blocks
        vm.roll(block.number + 100);

        // Start a reservation window
        vm.startPrank(prover);
        bountyToken.approve(address(connaitreContract), ESCROW_SIZE);
        connaitreContract.reserveWindow(prover);
        vm.stopPrank();

        // The window elapses
        vm.roll(block.number + ESCROW_BLOCKS + 1);

        // Nobody should be able to prove since window is closed 
        for (uint8 i = 0; i < 3; ++i) {
            vm.startPrank(users[i]);
            vm.expectRevert(abi.encodeWithSelector(Connaitre.NotInWindowError.selector));
            connaitreContract.proveKnowledgeAndClaim(IMAGE, users[i]);
            vm.stopPrank();
        }
    }

    // Test that neither bystander nor anon can prove during the prover's reservation window
    function testOnlyProverCanClaim() external {
        // Anon creates contract
        vm.startPrank(anon);
        Connaitre connaitreContract = new Connaitre(
            anon,
            address(bountyToken),
            BOUNTY_SIZE,
            ESCROW_SIZE,
            ESCROW_BLOCKS,
            IMAGE_IMAGE
        );
        vm.label(address(connaitreContract), "Connaitre Contract");
        bountyToken.transfer(address(connaitreContract), BOUNTY_SIZE);
        vm.stopPrank();

        // Roll forward 100 blocks
        vm.roll(block.number + 100);

        // Start a reservation window
        vm.startPrank(prover);
        bountyToken.approve(address(connaitreContract), ESCROW_SIZE);
        connaitreContract.reserveWindow(prover);
        vm.stopPrank();

        // The window nears the end
        vm.roll(block.number + ESCROW_BLOCKS - 1);

        // The anon can't prove, since it's not their window
        vm.startPrank(anon);
        vm.expectRevert(abi.encodeWithSelector(Connaitre.InvalidProverError.selector));
        connaitreContract.proveKnowledgeAndClaim(IMAGE, anon);
        vm.stopPrank();

        // The bystander can't prove, since it's not their window
        vm.startPrank(bystander);
        vm.expectRevert(abi.encodeWithSelector(Connaitre.InvalidProverError.selector));
        connaitreContract.proveKnowledgeAndClaim(IMAGE, bystander);
        vm.stopPrank();
    }

    // Test that a fibbed image doesn't work
    function testImageMustBeCorrect() external {
        // Anon creates contract
        vm.startPrank(anon);
        Connaitre connaitreContract = new Connaitre(
            anon,
            address(bountyToken),
            BOUNTY_SIZE,
            ESCROW_SIZE,
            ESCROW_BLOCKS,
            IMAGE_IMAGE
        );
        bountyToken.transfer(address(connaitreContract), BOUNTY_SIZE);
        vm.stopPrank();

        // Roll forward 100 blocks
        vm.roll(block.number + 100);

        // Prover finds the information, reserves, and immediately
        vm.startPrank(prover);
        bountyToken.approve(address(connaitreContract), ESCROW_SIZE);
        connaitreContract.reserveWindow(prover);

        bytes32 fakeImage = keccak256(
            abi.encodePacked(
                "My name is Inigo Montoya. You killed my father. Prepare to die."
            )
        );

        vm.expectRevert(abi.encodeWithSelector(Connaitre.InvalidProofError.selector));
        connaitreContract.proveKnowledgeAndClaim(fakeImage, prover);
        vm.stopPrank();
    }
    
}
