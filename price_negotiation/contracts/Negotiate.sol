pragma solidity ^0.4.18;

    /*
    ** Price Negotiation Smart Contract
    *
    * This smart contract allows two parties to 
    * negotiate the price of a sale.
    *
    ** Design Rules:
    *  - Either party can query the current price at any time
    *  - Both parties must accept the current price before any currency is exchanged
    *  - Either party can cancel the negotiation and only gas cost is lost
    *  - The seller pays all gas costs
    *  - The seller can cancel the offer at any time
    *
    ** Flow:
    *  1. Seller starts sale by migrating the contract to the blockchain.
    *  2. Buyer registers to the contract as a buyer - price negotiation begins!
    *  3. Either buyer or seller can suggest a new price.
    *  4. Eventually the buyer and seller both agree on the currentPrice - price negotiation is over!
    *  5. The buyer must then pay up. Amount must match agreed upon price.
    *  6. Seller may then withdraw funds from the contract.
    *
    ** Idea: A natural extension of this would be to allow multiple buyers or infinite buyers. 
    *    Essentially an auction application.
    *
    ** Another random idea: Smart contract for AirBnB that interacts with a smart lock granting access
    *    via a temporary code that is granted to the guest upon payment and start time.
    *
    */

contract Negotiate {
    /**
    * Initialize variables
    */
    /* negotiating parties */
	address public seller;
	address public buyer;

    /* true when party has accepted the current price */
	bool public sellerAccepted = false;
	bool public buyerAccepted = false;

    uint public currentPrice = 0;
    bool private negotiationCompleted = false;
	bool public tradeCompleted = false;
    uint private funds;
    

    /**
    * Logging events
    */
	event NegotiationStartEvent(address seller, address buyer);
	event NewPriceEvent(uint currentPrice, address account);
    event NegotiationOverEvent(uint currentPrice);
	event TradeOverEvent(uint paidPrice);

    /**
    * The contract constructor
    */
    constructor() public {
        seller = msg.sender;
	}

    /**
    * Once the sale is open the contract waits for the buyer to register to the contract.
    */
	function registerAsBuyer() public {
        require(buyer == address(0) && seller != address(0));

        buyer = msg.sender;
        emit NegotiationStartEvent(seller, buyer);
    }

    /**
    * For either party to call whenever they would like to suggest a new price. 
    * This resets the 'Accepted' statuses for both the buyer and the seller.
    */
    function suggestNewPrice(uint price) public {
        require(!negotiationCompleted && (msg.sender == seller || msg.sender == buyer));

        sellerAccepted = false;
        buyerAccepted = false;
        currentPrice = price;
        emit NewPriceEvent(currentPrice, msg.sender);
    }

    /**
    * At any time either party can 'accept' the currentPrice.
    * When both parties have accepted the negotiation is over.
    */
    function acceptCurrentPrice() public {
        require(!negotiationCompleted && (msg.sender == seller || msg.sender == buyer));

        if(msg.sender == seller) {
            sellerAccepted = true;
        }
        else {
            buyerAccepted = true;
        }

        if(sellerAccepted && buyerAccepted) {
            negotiationCompleted = true;
            emit NegotiationOverEvent(currentPrice);
        }
    }

    /**
    * Once the price is settled upon the buyer calls this function to transfer payment to
    * the smart contract that the buyer can then withdraw.
    */
    function sendPayment() public payable {
        require(negotiationCompleted && !tradeCompleted && 
                msg.sender == buyer && msg.value == currentPrice);

        funds = msg.value;
        tradeCompleted = true;
        /* Future improvement: add some mechanism for transferring access to traded object to buyer here */
        emit TradeOverEvent(funds);
    }


    /**
    * The withdraw function, following the withdraw pattern shown and explained here: 
    * http://solidity.readthedocs.io/en/develop/common-patterns.html#withdrawal-from-contracts
    */
    function withdraw() public {
        require(tradeCompleted && msg.sender == seller);

        uint amount = funds;

        funds = 0;
        msg.sender.transfer(amount);
    }
}