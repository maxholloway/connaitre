// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IConnaitre {

    // Submits a proof. If the proof is valid, transfer
    // funds to the receiver_. This function is not
    // vulnerable to generalized frontrunners / PGAs.
    function proveKnowledgeAndClaim(
        address receiver_,  // addres that will receive the bounty
        uint8 v_,           // v, from the ECDSA
        bytes32 r_,         // r, from the ECDSA
        bytes32 s_          // s, from the ECDSA
    ) external;
}