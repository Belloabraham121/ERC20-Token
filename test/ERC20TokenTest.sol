// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ERC20Token.sol";
import "../src/lib/MessageHashUtils.sol";

contract ERC20TokenTest is Test {
    ERC20Token public token;
    address[] public whitelist;
    address public owner;

    function setUp() public {
        owner = address(this);

        whitelist[0] = address(0x1);
        whitelist[1] = address(0x2);
        whitelist[2] = address(0x3);

        token = new ERC20Token("Test Token", "TEST", whitelist);
    }

    function testMintAndClaimTokens() public {
        address whitelistedUser = whitelist[0];
        
        // Mint tokens to the contract
        uint256 mintAmount = 1000 * 10**token.decimals();
        token.mint(address(token), mintAmount);

        
        // Verify the tokens were minted to the contract
        assertEq(token.balanceOf(address(token)), mintAmount, "Contract balance should match minted amount");

        vm.startPrank(whitelistedUser);

        bytes32 messageHash = keccak256(abi.encodePacked(whitelistedUser, "Claim tokens"));
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        uint256 initialBalance = token.balanceOf(whitelistedUser);
        token.claimTokens(messageHash, signature);
        uint256 finalBalance = token.balanceOf(whitelistedUser);

        // Verify the user received the claimed tokens
        assertEq(finalBalance, initialBalance + 100 * 10**token.decimals(), "User should receive 100 tokens");

        // Verify the contract's balance decreased
        assertEq(token.balanceOf(address(token)), mintAmount - 100 * 10**token.decimals(), "Contract balance should decrease by 100 tokens");

        vm.stopPrank();
    }

  

    function testDoubleClaim() public {
        address whitelistedUser = whitelist[0];
        
        // Mint tokens to the contract
        uint256 mintAmount = 1000 * 10**token.decimals();
        token.mint(address(token), mintAmount);

        vm.startPrank(whitelistedUser);

        bytes32 messageHash = keccak256(abi.encodePacked(whitelistedUser, "Claim tokens"));
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        token.claimTokens(messageHash, signature);

        vm.expectRevert("Tokens already claimed");
        token.claimTokens(messageHash, signature);

        vm.stopPrank();
    }


    function testNonWhitelistedClaim() public {
        address nonWhitelistedUser = address(0x4);
        vm.startPrank(nonWhitelistedUser);

        bytes32 messageHash = keccak256(abi.encodePacked(nonWhitelistedUser, "Claim tokens"));
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, ethSignedMessageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.expectRevert("Address not whitelisted");
        token.claimTokens(messageHash, signature);

        vm.stopPrank();
    }
}
