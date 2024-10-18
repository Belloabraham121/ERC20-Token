// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "./interface/ERC20.sol";
import {ECDSA} from "./lib/ECDSA.sol";
import {MessageHashUtils} from "./lib/MessageHashUtils.sol";

contract ERC20Token is ERC20 {
    using ECDSA for bytes32;

    address public owner;
    address[] public whitelist;
    mapping(address => bool) public claimed;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(string memory name, string memory symbol, address[] memory _whitelist) ERC20(name, symbol) {
        owner = msg.sender;
        whitelist = _whitelist;
    }

    function isWhitelisted(address account) public view returns (bool) {
        for (uint i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == account) {
                return true;
            }
        }
        return false;
    }

    function claimTokens(bytes32 messageHash, bytes memory signature) public {
        require(isWhitelisted(msg.sender), "Address not whitelisted");
        require(!claimed[msg.sender], "Tokens already claimed");

        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        address signer = ECDSA.recover(ethSignedMessageHash, signature);

        require(signer == msg.sender, "Invalid signature");

        claimed[msg.sender] = true;
        _mint(msg.sender, 100 * 10**decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Cannot mint to the zero address");
        _mint(to, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }
}