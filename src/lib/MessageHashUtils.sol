// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Signature message hash utilities for producing digests to be used with ECDSA recoveries.
 *
 * @custom:oz-upgrades-unsafe-allow external-library-linking
 */
library MessageHashUtils {
    /**
     * @dev Returns the keccak256 hash of the abi-encoded `messageHash` after prefixing it with
     * `\x19Ethereum Signed Message:\n32`. This is the format signed by `eth_sign`.
     */
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }

    /**
     * @dev Returns the keccak256 hash of the abi-encoded `message` after prefixing it with
     * `\x19Ethereum Signed Message:\n${message.length}`. This is the format signed by `eth_sign`.
     */
    function toEthSignedMessageHash(bytes memory message) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(message.length), message));
    }
}

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
