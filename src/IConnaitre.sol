// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IConnaitre {
    
    // Bounty creator creates the bounty contract and
    // stores their hash(hash(desired ata)) as imageImage_.
    // constructor(address owner_, address tokenAddress_, uint256 bountySize_, uint256 escrowAmount_, uint256 escrowBlocks_, bytes32 imageImage_);

    // Modifier to guarantee owner is invoking function
    // modifier isOwner();

    // Owner takes funds out of the protocol after a delay.
    // A convenience method that isn't necessary, since
    // the contract owner should 
    // function defund(address receiver_) external;

    // Escrows an amount in funding so that prover_
    // is the only address that can claim the 
    // bounty over the next window of blocks.
    function reserveWindow(address prover_) external;

    // Submits a proof. If the proof is valid, transfer
    // funds to the receiver_. The `image_` input must
    // be equal to hash(desired data) of the knowledge that the prover
    // wanted to have proven. Also returns the escrow amount.
    function proveKnowledgeAndClaim(bytes32 image_, address receiver_) external;
}