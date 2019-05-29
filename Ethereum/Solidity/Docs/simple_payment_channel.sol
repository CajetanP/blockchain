pragma solidity >= 0.4.24 < 0.7.0;

contract SimplePaymentChannel {
    address payable public sender;
    address payable public recipient;

    uint256 public expiration;

    constructor (address payable _recipient, uint256 duration) public payable {
        sender = msg.sender;
        recipient = _recipient;
        expiration = now + duration;
    }

    function isValidSignature(uint256 amount, bytes memory signature) internal view returns (bool) {
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));
        // check that the signature is from the sender
        return recoverSigner(message, signature) == sender;
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    // prefix hash to mimic the behaviour of eth_sign
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum signed message:\n32", hash));
    }
}
