// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../src/RadixSegmentTree.sol";
import "./RadixSegmentTreeWrapper.sol";

import "forge-std/Test.sol";

contract RadixSegmentTreeTest is Test {
    RadixSegmentTreeWrapper public wrapper;

    function setUp() public {
        wrapper = new RadixSegmentTreeWrapper();
    }

    function testAdd1() public {
        uint256 left;
        uint256 mid;
        uint256 right;
        (left, mid, right) = wrapper.query(0);
        assertEq(left, 0);
        assertEq(mid, 0);
        assertEq(right, 0);
        wrapper.add(0xbad124beef911);
        (left, mid, right) = wrapper.query(0xbad124beef911);
        assertEq(left, 0);
        assertEq(mid, 1);
        assertEq(right, 0);
        (left, mid, right) = wrapper.query(0xbad124beef910);
        assertEq(left, 0);
        assertEq(mid, 0);
        assertEq(right, 1);
        (left, mid, right) = wrapper.query(0xbad124beef912);
        assertEq(left, 1);
        assertEq(mid, 0);
        assertEq(right, 0);
    }

    function testAdd2() public {
        wrapper.add(0xdeadbeef);
        wrapper.add(0xdeadbee3);
        wrapper.add(0xceadbeef);
        wrapper.add(0x1eadbeef);
        wrapper.add(0xdeadbeef);

        uint256 left;
        uint256 mid;
        uint256 right;
        (left, mid, right) = wrapper.query(0);
        assertEq(left, 0);
        assertEq(mid, 5);
        assertEq(right, 0);
        (left, mid, right) = wrapper.query(0xdeadbeef);
        assertEq(left, 3);
        assertEq(mid, 2);
        assertEq(right, 0);
        (left, mid, right) = wrapper.query(0xdeadbee3);
        assertEq(left, 2);
        assertEq(mid, 1);
        assertEq(right, 2);
        (left, mid, right) = wrapper.query(0xceadbeef);
        assertEq(left, 1);
        assertEq(mid, 1);
        assertEq(right, 3);
        (left, mid, right) = wrapper.query(0x1eadbeef);
        assertEq(left, 0);
        assertEq(mid, 1);
        assertEq(right, 4);
        (left, mid, right) = wrapper.query(0xdead0000);
        assertEq(left, 2);
        assertEq(mid, 0);
        assertEq(right, 3);
    }

    function testAddFuzz(uint232[] calldata values) public {
        for (uint256 i = 0; i < values.length; ++i) {
            wrapper.add(values[i]);
        }
    }

    function testFindBranch() public {
        uint256 branch;
        uint8 length;
        (branch, length) = wrapper.findBranch(0x1, 0x2, 0);
        assertEq(branch, 0);
        assertEq(length, 63);
        (branch, length) = wrapper.findBranch(0x1234abc, 0x1234bbb, 0);
        assertEq(branch, 0x1234000);
        assertEq(length, 61);
        (branch, length) = wrapper.findBranch(0x1234abc, 0x1234bbb, 61);
        assertEq(branch, 0x1234000);
        assertEq(length, 61);
        vm.expectRevert(abi.encodeWithSelector(RadixSegmentTreeLib.WrongOffset.selector));
        (branch, length) = wrapper.findBranch(0x1234abc, 0x1234bbb, 62);
    }

    function testFindBranchFuzz1(uint232 a, uint232 b) public view {
        vm.assume(a != b);
        wrapper.findBranch(a, b, 0);
    }

    function testFindBranchFuzz2(uint256 a, uint8 p) public view {
        uint256 b = a ^ (1 << p);
        uint8 expectedLength = 63 - p / 4;
        uint256 expectedBranch;
        expectedBranch = expectedLength == 0 ? 0 : a & ~((1 << ((64 - expectedLength) * 4)) - 1);
        uint256 branch;
        uint8 length;
        for (uint8 i = 0; i < expectedLength + 1; ++i) {
            console.logBytes32(bytes32(a));
            console.logBytes32(bytes32(b));
            (branch, length) = wrapper.findBranch(a, b, i);
            assertEq(bytes32(branch), bytes32(expectedBranch));
            assertEq(length, expectedLength);
        }
    }
}
