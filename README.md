# Eth_price_negotiation
Ethereum Smart Contract that facilitates negotiating a price between a buyer and a seller and safe transfer of the correct amount of funds once price is agreed upon.

# Setup
- Install Truffle (http://truffleframework.com/)
- Install Ganache (http://truffleframework.com/ganache/)
- Clone this repo to your local machine

# Instructions For Use
Open the Ganache client then run the following commands from the command line within the 'price_negotiation' directory of your cloned copy:
- truffle compile
- Start Ganache
- truffle migrate --reset
- truffle console --network development
- seller = web3.eth.accounts[0] (and same for buyer @accounts[1])
- Negotiate.deployed().then(sale => { NegotiateInstance = sale})
- NegotiateInstance.seller.call() (to show address of seller was defaulted to account[0])
- NegotiateInstance.registerAsBuyer({from: buyer})
- NegotiateInstance.currentPrice() (to show getter functions)
- NegotiateInstance.suggestNewPrice(web3.toWei(#, “ether”), {from: seller})
- NegotiateInstance.currentPrice()
- NegotiateInstance.acceptCurrentPrice({from: seller}) (and buyer)
- NegotiateInstance.sendPayment({from: buyer, value: web3.toWei(#, “ether”)})
- NegotiateInstance.withdraw({from: seller})
