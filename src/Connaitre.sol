// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "./IConnaitre.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Connaitre {

    error InvalidSignError();
    error ContractNotFundedError();

    event SignerAddress(address);
    event ReceiverHash(bytes32);

    address immutable public ANON_INFO_ADDRESS; // ethereum address associated with public key associated with private key associated with anon's private data
    IERC20 immutable public BOUNTY_TOKEN; // ERC20 token to be used for the bounty
    uint256 immutable public BOUNTY_SIZE; // number of BOUNTY_TOKEN to be transferred

    constructor(address anonInfoAddress_, address tokenAddress_, uint256 bountySize_) {
        ANON_INFO_ADDRESS = anonInfoAddress_;
        BOUNTY_TOKEN = IERC20(tokenAddress_);
        BOUNTY_SIZE = bountySize_;
    }

    modifier contractIsFunded() {
        if (BOUNTY_TOKEN.balanceOf(address(this)) < BOUNTY_SIZE) {
            revert ContractNotFundedError();
        }
        _;
    }

    // Submits a proof. If the proof is valid, transfer
    // funds to the receiver_.
    function proveKnowledgeAndClaim(
        address receiver_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) 
    external contractIsFunded {
        // 1. Verify that signer of the data is the ANON_INFO_ADDRESS owner
        address signer = _getSigner(
            receiver_,
            v_,
            r_,
            s_
        );

        if (signer != ANON_INFO_ADDRESS) {
            revert InvalidSignError();
        }

        // Transfer both the bounty amount back to the recipient
        BOUNTY_TOKEN.transfer(
            receiver_, // Note: potentially replace this with either `msg.sender` or `callerLastReservation`
            BOUNTY_SIZE
        );
    }

    // Here, the receiver_ is the payload of our message to be signed.
    // To pass it into the signature scheme, it must first be hashed,
    // and then it must be made to fit EIP-191 signed message format,
    // then hashed again. Finally, once this ultimate payload is combined 
    // with v, r, and s, we can derive the public address of the signer
    // via ecrecover().
    function _getSigner(
        address receiver_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    )
    pure internal 
    returns (address){
        bytes32 hashedMessage = keccak256(abi.encodePacked(receiver_));
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, hashedMessage));

        return ecrecover(prefixedHashMessage, v_, r_, s_);
    }
}