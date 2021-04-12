# Tokens Ratio Manager

This contract provides a function to keep a balanced ratio between two of your tokens using the uniswap app.

The idea came from a slayer on telegram who explained his strategy : try to keep a 80/20 ratio between his eth and his stablecoin.

So I thought about a simple contract which could apply almost automatically this strategy.

## How does it work ?

Suppose you have a cron job which verify the current gas price (with tools like [gas.watch](https://ethgas.watch)). When the gas price is at its bottom you could call the `sync` function sending the current market price of the eth.

The function will verify your balance is still on the repartition (minus an allowed variation to avoid swap of small amount)

## Remarks

This contract has not been audited. It should globally work, but maybe there are flaws. Use at your own risk.

## constructor

Create the contract with the following parameters :

* `address _t1` : contract address of the token 1
* `address _t2` : contract address of the token 2
* `address _router` : contract address of the uniswap router API (v2)
* `uint8 _r` : the balanced ratio between the 2 tokens. Aan integer between 1 and 99 (%)

## sync

To get a sync balanced wallet, you call the function `sync` with the following parameter :

* `uint256 _currentPrice` : the current market price.

With the current market price, the function will compute how much ETH (token 1) you have globally.  
Then it will apply the defined ratio to find how much USD you should have (20% of total ETH amount).  
If you have less, you should swap some ETH.  
If you have more, you should swap some USD.
The function use less than 45000 gas __but__ you need to add the price cost of the uniswap function `swapExactTokensForTokens`

## withdraw

Empty the contract and get back all your liquidity.

* `uint256 _percent` : how much get from the stack (from 2% to 100%, with 100% => empty the wallet).

## transferToken

If any other tokens are in the contract, send them to the owner wallet.

* `address _token` : the address of the ERC20 token contract.
