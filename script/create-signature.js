/*
    Hash private data entries to create a private key,
    and use that private key to generate a signature.

    This script can be used by the anon to generate
    a private key and address before deploying the
    bounty contract. It can also be used by provers
    to construct the signature once they know the
    information.
*/

var Web3 = require('web3');

var web3 = new Web3();

// Data that is private to the anon
PRIVATE_DATA_LIST = [
    "Giovanni",
    "Giorgio",
    "Germany"
]

// Generate private key and address from the data
PRIVATE_KEY = web3.utils.soliditySha3(
    { type: "string", value: PRIVATE_DATA_LIST[0]},
    { type: "string", value: PRIVATE_DATA_LIST[1]},
    { type: "string", value: PRIVATE_DATA_LIST[2]}
)
ADDRESS = web3.eth.accounts.privateKeyToAccount(
    PRIVATE_KEY
)["address"];


// Define the address that will receive the payout from the bounty
RECEIVER_ADDRESS = "0xEA15ffdA91B29882F0163f7eE753b920024F8822";

// Create the signature, of which the prover must submit v, r, s,
// and RECEIVER_ADDRESS in order to claim funds sent to the receiver.
console.log(`${ADDRESS}'s signature for the payload ${RECEIVER_ADDRESS}`)
console.log(web3.eth.accounts.sign(
    web3.utils.keccak256(RECEIVER_ADDRESS),
    PRIVATE_KEY
));