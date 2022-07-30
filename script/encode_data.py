#!/usr/bin/env python3

"""
Script to be run by the anon in order to generate the
data that's needed to deploy a contract.
"""

from hexbytes import HexBytes
import web3
import eth_account
from web3.auto import w3

def get_private_data():
    private_data = [
        "Giovanni",
        "Giorgio",
        "Germany",
    ]
    
    return [str(datum) for datum in private_data] # require everything to be represented as a string

def get_eth_account():
    private_data = get_private_data()

    # Use the data as a seed to generate a new ethereum account
    private_key = web3.Web3.solidityKeccak(["string" for _ in private_data], private_data)
    public_address = eth_account.Account.from_key(private_key).address

    return private_key, public_address

def encode_message(msg):
    return 

def sign_message(private_key, message):
    # Message must be an address-like object
    message = "hello"
    signed_message = w3.eth.account.sign_message(
        eth_account.messages.encode_defunct(text=message), 
        private_key=private_key
    )
    print(signed_message)
    print()
    print("v", signed_message.v)
    print("r", HexBytes(signed_message.r).__repr__())
    print("s", HexBytes(signed_message.s).__repr__())

def main():
    priv_key, address = get_eth_account()
    print(f"anon info address: {address}")
    print(f"priv key: {priv_key.__repr__()}")
    # sign_message(
    #     priv_key, 
    #     "0xEA15ffdA91B29882F0163f7eE753b920024F8822"
    # )

if __name__ == "__main__":
    main()