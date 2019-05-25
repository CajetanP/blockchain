pragma solidity >=0.5.0 <0.7.0;

contract Coin {
    // The keyword "public" makes variables readable from outside
    address public minter;
    mapping (address => uint) public balances;

    // Events allow light clients to efficiently react to changes
    event Sent(address from, address to, uint amount);

    // Constructor, run only when the contract is created
    constructor() public {
        minter = msg.sender;
    }

    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        require(amount < 1e60);
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}
