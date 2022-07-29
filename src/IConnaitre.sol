// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IConnaitre {
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