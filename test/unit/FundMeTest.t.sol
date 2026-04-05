// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    address USER = makeAddr("user");
    uint256 constant GAS_PRICE = 1;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testDemo() public view {
        // console.log("Hello World!");
        // console.log("The number is: ", number);

        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        //
        assertEq(fundMe.getVersion(), 4);
        // assertEq(fundMe.s_priceFeed().version(), 4);
    }

    function testIfFundingFails() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdateFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: STARTING_BALANCE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, STARTING_BALANCE);
    }

    // function testGetFunder() public {
    //     fundMe.fund{value: 1e18}();
    //     address funder = fundMe.s_funders(0);
    //     assertEq(funder, address(this));
    //}

    function testAddsFunderToArrayOfFunders() public funded {
        vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testCheapOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.cheapWithdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i <= numberOfFunders; i++) {
            // Start i from 1 for better labeling
            address funderAddress = makeAddr(string.concat("funder", vm.toString(i)));
            hoax(funderAddress, SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            console.log("Funder %s funded with %s ETH", funderAddress, SEND_VALUE);
        }

        uint256 startingOwnerBalance = getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas used for withdrawal: %s", gasUsed);

        //Assert
        uint256 endingOwnerBalance = getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function getOwner() public view returns (address) {
        return fundMe.i_owner();
    }
}
