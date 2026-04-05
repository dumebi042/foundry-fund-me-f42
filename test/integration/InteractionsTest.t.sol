// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe public fundMe;
    DeployFundMe deployFundMe;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

  address USER = makeAddr("user");

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteraction() public {
        FundFundMe fundFundMe = new FundFundMe();
        //vm.deal(USER, STARTING_BALANCE); // ← Give the contract itself ETH, STARTING_BALANCE);

        // vm.deal(USER, SEND_VALUE);
        // fundFundMe.fundFundMe((address(fundMe)));
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        //fundFundMe.fundFundMe(payable(address(fundMe)));

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe((address(fundMe)));

        assertEq(address(fundMe).balance, 0);
    }
}
