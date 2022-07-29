# Connaître: A Framework for Anon Identity Bounties

<a href="https://en.wikipedia.org/wiki/On_the_Internet,_nobody_knows_you%27re_a_dog">
    <img src="./assets/dog.jpg" alt="drawing" width=400; style="display: block; margin-left: auto;
  margin-right: auto;"/>
</a>

## Intro
Bug bounties are cool because companies can tap into a global talent pool to discover problems. Wouldn't it be *also* be cool if there were a way for anons to tap into a global talent pool of internet snoopers to see if anyone can discover their secret identity?

## Bounty constraints
1. The security researcher doesn't trust the anonymous account running the bounty. The researcher must have a guarantee that the account will pay up if the researcher knows the anon's personal info.
2. The anon does not want their personal info to be leaked. Therefore, this bounty program must run in a way where the security researcher need not publicize the anon's information to the world.

The way to address these constraints is to codify the rules of the anon bounty into a smart contract, of course!

## High-level workflow
1. The anon deploys the contract `Connaitre.sol` and sends some amount of ERC20 token to it to be used as a bounty.
2. The security researcher (i.e. prover) reserves some number of blocks over which they will be the only address allowed to submit a proof of knowledge. To buy this opportunity, they must put ERC20 into escrow on `Connaitre.sol`. Thus, their workflow is to approve ERC20 token for `Connaitre.sol` and then invoke `reserveWindow()`.
3. After some number of blocks passes, but while the window for depositing is still open, the prover submits their proof of knowledge via the `proveKnowledgeAndClaim()` function.

## Mempool considerations
A skeptical reader may wonder, "why make a reserve window instead of having provers submit their proof at once?". The answer is simple: that would be directly front-runnable. An adversarial miner would be able to replace the `tx.origin` with their own, or other mempool-snoopers would be willing to outbid the prover. However, when we introduce an interval where only the escrow depositor is willing to deposit, it is no longer feasible for mempool snoopers to replace the prover's transactions. If someone replaces the prover's `reserveWindow()` call, then the prover has no incentive to call `proveKnowledgeAndClaim()` (since it would revert), and thus the one who invoked `reserveWindow()` would be out their escrow dollars. If someone replaces the prover's `proveKnowledgeAndClaim()` call, then it will revert since only the prover can call that function during the reserved window.

Unfortunately there is still the possibility that the anon running the bounty program might themselves front-run a prover's attempts. For instance, if the anon sees that a prover was willing to put an escrow down in an effort to claim the bounty, this may be enough information for the anon to learn that their identity has been compromised, at which point they might try to invoke `reserveWindow()` in front of the prover. The prover can make this difficult by deploying a contract of their own to invoke `reserveWindow()`, but that is still not fool-proof from a motivated mem-pool snooping anon.

## Contributing
Feel free to contact me on twitter at [@max_holloway](https://twitter.com/max_holloway) or raise an issue here if you think you can help out!

## Donation
If you like this work, don't buy me a coffee. Instead, do me a favor and donate to a [high impact charity](https://www.givewell.org/about/donate/cryptocurrency). 🙏

## Disclosure
This content is provided as-is. This was put together in an afternoon and is not meant to be used in production unless further tested. Tbh this was mostly meant as a fun way for me to learn how to use foundry.
