# Connaître: A Framework for Anon Identity Bounties

## Intro
Bug bounties are a mechanism through which projects can align incentives with security researchers to discover bugs in their software. This is good for the project, because they only need to pay out if their software is buggy. And it's good for talented security researchers, because they have an opportunity to be paid meritocratically for their research. This model works best for projects who already have great security, but wish to pay out in the off chance that there's an issue.

There also exist anonymous developers who wish to remain anonymous. These devs, like the aforementioned bug bounty projects, likely have a good anonymous setup, but they would like to get guarantees that they are anonymous. Or perhaps they don't know if someone knows their identity. In either of these cases, they may want to offer a bounty for someone to prove that they know who the person is. This project provides a way for anons to run such a bounty.

## Bounty constraints
1. The security researcher doesn't trust the anonymous account running the bounty. The researcher must have a guarantee that the account will pay up if the researcher knows the anon's personal info.
2. The anon does not want their personal info to be leaked. Therefore, this bounty program must run in a way where the security researcher need not publicize the anon's information to the world.

The way to address these constraints is to codify the rules of the anon bounty into a smart contract, of course!

## High-level workflow
* The anon deploys the contract `AnonBounty.sol` and sends some amount of ERC20 token to it.
* The security researcher submits their proof 

## Contract overview
## `Connaitre.sol`
This contract should be deployed by the anon in order to provide a bounty. It is the anon's job to separately fund the contract with an ERC20 transfer. There are two ways to get funds out of the contract: (1) by the contract owner via `defund()`, or (2) via anyone with `proveKnowledge()`. 

```solidity
interface IAnonBounty {
    
    // Bounty creator creates the bounty contract and
    // stores their hash(hash(desired ata)) as imageImage_.
    function constructor(address tokenAddress_, address owner_, bytes imageImage_);

    // Modifier to guarantee owner is invoking function
    modifier isOwner();

    // Owner takes funds out of the protocol after a delay.
    // A convenience method that isn't necessary, since
    // the contract owner should 
    function defund(address receiver_) isOwner;

    // Escrows an amount in funding so that prover_
    // is the only address that can claim the 
    // bounty over the next window of blocks.
    function reserveWindow(address prover_) payable;

    // Submits a proof. If the proof is valid, transfer
    // funds to the receiver_. The `image_` input must
    // be equal to hash(desired data) of the knowledge that the prover
    // wanted to have proven. Also returns the escrow amount.
    function proveKnowledgeAndClaim(bytes image_, address receiver_);
}
```

## `BountyHunter.sol`


```solidity
// The contract to be implemented by the bounty solver
interface IBountyHunter {
    // Create a guarded 
    constructor(address owner_, address bountyAddress_);

    // Modifier to guarantee owner is invoking function
    modifier isOwner();

    // Function that 
    function proveKnowledge(bytes image_) isOwner;
}
```


This repo 


1. 