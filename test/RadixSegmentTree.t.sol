// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../src/RadixSegmentTree.sol";
import "./Wrapper.sol";

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
}
