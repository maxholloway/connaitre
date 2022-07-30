var Web3 = require('web3');

var web3 = new Web3();

PRIVATE_KEY = "0x0f3e9092d5d3b7cab3b5e959ee65a6ac066f9175f38b669d598b80a30e3ba79c";
ADDRESS = web3.eth.accounts.privateKeyToAccount(
    "0x0f3e9092d5d3b7cab3b5e959ee65a6ac066f9175f38b669d598b80a30e3ba79c"
)["address"];

// console.log(PRIVATE_KEY, ADDRESS);

RECEIVER_ADDRESS = "0xEA15ffdA91B29882F0163f7eE753b920024F8822";

console.log(web3.eth.accounts.sign(
    web3.utils.keccak256(RECEIVER_ADDRESS),
    PRIVATE_KEY
));