// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "./IConnaitre.sol";

contract Connaitre is IConnaitre {

    error AuthError();
    error NotImplementedError();

    address public owner;
    uint256 immutable public escrowAmount;


    // Bounty creator creates the bounty contract and
    // stores their hash(hash(desired ata)) as imageImage_.
    constructor(address tokenAddress_, address owner_, uint256 escrowAmount_, bytes memory imageImage_) {
        escrowAmount = escrowAmount_;
    }

    // Modifier to guarantee owner is invoking function
    modifier isOwner() {
        if (msg.sender != owner) {
            revert AuthError();
        }
        _;
    }

    // Owner takes funds out of the protocol after a delay.
    // A convenience method that isn't necessary, since
    // the contract owner should 
    // function defund(address receiver_) external isOwner {
    //     revert NotImplementedError();
    // }

    // Escrows an amount in funding so that prover_
    // is the only address that can claim the 
    // bounty over the next window of blocks.
    // Note: requires users to approve spending separately
    function reserveWindow(address prover_) external {

    }

    // Submits a proof. If the proof is valid, transfer
    // funds to the receiver_. The `image_` input must
    // be equal to hash(desired data) of the knowledge that the prover
    // wanted to have proven. Also returns the escrow amount.
    function proveKnowledgeAndClaim(bytes calldata image_, address receiver_) external {

    }
}