// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC20Token.sol";
import "../src/lib/MessageHashUtils.sol";

contract ERC20TokenTest is Test {
    ERC20Token public token;
    address public owner;
    address[] public whitelist;

    function setUp() public {
        owner = address(this);
        whitelist = new address[](3);
        whitelist[0] = address(0x1);
        whitelist[1] = address(0x2);
        whitelist[2] = address(0x3);

        token = new ERC20Token("Test Token", "TST", whitelist);
    }

    function testIsWhitelisted() public view {
        assertTrue(token.isWhitelisted(address(0x1)));
        assertTrue(token.isWhitelisted(address(0x2)));
        assertTrue(token.isWhitelisted(address(0x3)));
        assertFalse(token.isWhitelisted(address(0x4)));
    }

    function testClaimTokens() public {
        address whitelistedUser = address(0x1);
        bytes32 messageHash = keccak256(abi.encodePacked(whitelistedUser));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(whitelistedUser);
        token.claimTokens(messageHash, signature);

        assertEq(token.balanceOf(whitelistedUser), 100 * 10**token.decimals());
        assertTrue(token.claimed(whitelistedUser));
    }

    function testCannotClaimTwice() public {
        address whitelistedUser = address(0x1);
        bytes32 messageHash = keccak256(abi.encodePacked(whitelistedUser));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(whitelistedUser);
        token.claimTokens(messageHash, signature);

        vm.expectRevert("Tokens already claimed");
        vm.prank(whitelistedUser);
        token.claimTokens(messageHash, signature);
    }

    function testCannotClaimIfNotWhitelisted() public {
        address nonWhitelistedUser = address(0x4);
        bytes32 messageHash = keccak256(abi.encodePacked(nonWhitelistedUser));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.expectRevert("Address not whitelisted");
        vm.prank(nonWhitelistedUser);
        token.claimTokens(messageHash, signature);
    }



}