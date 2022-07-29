// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "./IConnaitre.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Connaitre is IConnaitre {

    error AuthError();
    error NotImplementedError();
    error NoInterruptingReservationError();
    error NotInWindowError();
    error InvalidProverError();
    error InvalidProofError();
    error ContactNotFundedError();

    address immutable public OWNER;
    IERC20 immutable public BOUNTY_TOKEN;
    uint256 immutable public BOUNTY_SIZE; // number of BOUNTY_TOKEN to be transferred

    uint256 immutable public ESCROW_AMOUNT; // amount needed to do an escrow
    uint256 immutable public ESCROW_BLOCKS; // number of blocks over which escrow is valid

    bytes32 immutable public IMAGE_IMAGE;

    uint256 internal blockLastReservation;
    address internal callerLastReservation;

    event Data(uint256 data);

    // Bounty creator creates the bounty contract and
    // stores their hash(hash(desired ata)) as imageImage_.
    constructor(address owner_, address tokenAddress_, uint256 bountySize_, uint256 escrowAmount_, uint256 escrowBlocks_, bytes32 imageImage_) {
        // Set state variables
        OWNER = owner_;
        BOUNTY_TOKEN = IERC20(tokenAddress_);
        BOUNTY_SIZE = bountySize_;
        
        ESCROW_AMOUNT = escrowAmount_;
        ESCROW_BLOCKS = escrowBlocks_;
        
        IMAGE_IMAGE = imageImage_;
    }

    // // Modifier to guarantee OWNER is invoking function
    // modifier isOwner() {
    //     if (msg.sender != OWNER) {
    //         revert AuthError();
    //     }
    //     _;
    // }

    // Owner takes funds out of the protocol after a delay.
    // A convenience method that isn't necessary, since
    // the contract OWNER should 
    // function defund(address receiver_) external isOwner {
    //     revert NotImplementedError();
    // }

    modifier isNotRevervedWindow() {
        // Make sure we're not already in a reserved window
        if (_inReservedWindow()) {
            revert NoInterruptingReservationError();
        }
        _;
    }

    // Escrows an amount in funding so that prover_
    // is the only address that can claim the 
    // bounty over the next window of blocks.
    // Note: requires users to approve spending separately
    function reserveWindow(address prover_) isNotRevervedWindow external {
        // Transfer the tokens to this address; if transfer fails, reject escrow
        require(
            BOUNTY_TOKEN.transferFrom(msg.sender, address(this), ESCROW_AMOUNT),
            "Failed to transfer escrow."
        );

        // Reserve the window for the prover_
        blockLastReservation = block.number;
        callerLastReservation = prover_;
    }

    modifier contractIsFunded() {
        if (BOUNTY_TOKEN.balanceOf(address(this)) < BOUNTY_SIZE + ESCROW_AMOUNT) {
            revert ContactNotFundedError();
        }
        _;
    }

    modifier validProver() {
        if (!_inReservedWindow()) {
            revert NotInWindowError();
        }

        if (msg.sender != callerLastReservation) {
            revert InvalidProverError();
        }

        _;
    }

    // Submits a proof. If the proof is valid, transfer
    // funds to the receiver_. The `image_` input must
    // be equal to hash(desired data) of the knowledge that the prover
    // wanted to have proven. Also returns the escrow amount.
    function proveKnowledgeAndClaim(bytes32 image_, address receiver_) validProver contractIsFunded external {
        // Verify that hash(image_) == IMAGE_IMAGE
        if (keccak256(abi.encodePacked(image_)) != IMAGE_IMAGE) {
            revert InvalidProofError();
        }

        // Transfer both the escrow and the original amount back to the recipient
        BOUNTY_TOKEN.transfer(
            receiver_, // Note: potentially replace this with either `msg.sender` or `callerLastReservation`
            BOUNTY_SIZE + ESCROW_AMOUNT
        );
    }

    // Function to determine if the current reserve window is valid
    function _inReservedWindow() internal view returns (bool){
        if (
                (blockLastReservation > 0)
                && (blockLastReservation + ESCROW_BLOCKS >= block.number)
                && (blockLastReservation                 <= block.number) // Note: is it ever possible for this condition to be false?
            ) {
            return true;
        }

        return false;
    }
}