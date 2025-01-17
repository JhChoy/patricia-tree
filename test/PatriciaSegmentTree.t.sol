// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../src/PatriciaSegmentTree.sol";
import "./PatriciaSegmentTreeWrapper.sol";

import "forge-std/Test.sol";

contract PatriciaSegmentTreeTest is Test {
    PatriciaSegmentTreeWrapper public wrapper;

    function setUp() public {
        wrapper = new PatriciaSegmentTreeWrapper();
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
        assertEq32(wrapper.loadRootNode(), 0xbad124beef911_40);
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
        assertEq32(wrapper.loadRootNode(), 0xdeadbeef_40);
        wrapper.add(0xdeadbee3);
        assertEq32(wrapper.loadRootNode(), 0xdeadbee0_3f);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbeef)), 0xdeadbeef_40);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbee3)), 0xdeadbee3_40);
        assertEq32(
            wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x3f, 0xdeadbee0)),
            0x0001000000000000000000000000000000000000000000000001000000000000
        );
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbeef)), 0);
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbee3)), 0);
        wrapper.add(0xceadbeef);
        assertEq32(wrapper.loadRootNode(), 0x38);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x39, 0xc0000000)), 0xceadbeef40);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x39, 0xd0000000)), 0xdeadbee03f);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbeef)), 0xdeadbeef_40);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbee3)), 0xdeadbee3_40);
        assertEq32(
            wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x38, 0)),
            0x0000000000020001000000000000000000000000000000000000000000000000
        );
        assertEq32(
            wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x3f, 0xdeadbee0)),
            0x0001000000000000000000000000000000000000000000000001000000000000
        );
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0xceadbeef)), 0);
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbeef)), 0);
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbee3)), 0);
        wrapper.add(0x1eadbeef);
        assertEq32(wrapper.loadRootNode(), 0x38);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x39, 0x10000000)), 0x1eadbeef40);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x39, 0xc0000000)), 0xceadbeef40);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x39, 0xd0000000)), 0xdeadbee03f);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbeef)), 0xdeadbeef_40);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbee3)), 0xdeadbee3_40);
        assertEq32(
            wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x38, 0)),
            0x0000000000020001000000000000000000000000000000000000000000010000
        );
        assertEq32(
            wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x3f, 0xdeadbee0)),
            0x0001000000000000000000000000000000000000000000000001000000000000
        );
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0x1eadbeef)), 0);
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0xceadbeef)), 0);
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbeef)), 0);
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbee3)), 0);
        wrapper.add(0xdeadbeef);
        assertEq32(wrapper.loadRootNode(), 0x38);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x39, 0x10000000)), 0x1eadbeef40);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x39, 0xc0000000)), 0xceadbeef40);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x39, 0xd0000000)), 0xdeadbee03f);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbeef)), 0xdeadbeef_40);
        assertEq32(wrapper.loadNode(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbee3)), 0xdeadbee3_40);
        assertEq32(
            wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x38, 0)),
            0x0000000000030001000000000000000000000000000000000000000000010000
        );
        assertEq32(
            wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x3f, 0xdeadbee0)),
            0x0002000000000000000000000000000000000000000000000001000000000000
        );
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0x1eadbeef)), 0);
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0xceadbeef)), 0);
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbeef)), 0);
        assertEq32(wrapper.loadChildrenMap(PatriciaSegmentTreeLib.Data(0x40, 0xdeadbee3)), 0);

        uint256 left;
        uint256 mid;
        uint256 right;
        (left, mid, right) = wrapper.query(0);
        assertEq(left, 0);
        assertEq(mid, 0);
        assertEq(right, 5);
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

    function testAddFuzz(uint248[] calldata values) public {
        for (uint256 i = 0; i < values.length; ++i) {
            wrapper.add(values[i]);
        }
    }

    function testCommonPrefix() public {
        PatriciaSegmentTreeLib.Data memory prefix;
        prefix = wrapper.commonPrefix(0x1, 0x2, 0);
        assertEq32(prefix.value, 0);
        assertEq(prefix.length, 63);
        prefix = wrapper.commonPrefix(0x1234abc, 0x1234bbb, 0);
        assertEq32(prefix.value, 0x1234000);
        assertEq(prefix.length, 61);
        prefix = wrapper.commonPrefix(0x1234abc, 0x1234bbb, 61);
        assertEq32(prefix.value, 0x1234000);
        assertEq(prefix.length, 61);
        vm.expectRevert(abi.encodeWithSelector(PatriciaSegmentTreeLib.WrongOffset.selector));
        prefix = wrapper.commonPrefix(0x1234abc, 0x1234bbb, 62);

        prefix = wrapper.commonPrefix(0x1234abc, 0x1234abc, 0);
        assertEq32(prefix.value, 0x1234abc);
        assertEq(prefix.length, 64);
    }

    function testCommonPrefixFuzz1(uint248 a, uint248 b) public view {
        wrapper.commonPrefix(a, b, 0);
    }

    function testCommonPrefixFuzz2(uint256 a, uint8 p) public view {
        uint256 b = a ^ (1 << p);
        uint8 expectedLength = 63 - p / 4;
        uint256 expectedPrefix;
        expectedPrefix = expectedLength == 0 ? 0 : a & ~((1 << ((64 - expectedLength) * 4)) - 1);
        PatriciaSegmentTreeLib.Data memory prefix;
        for (uint8 i = 0; i < expectedLength + 1; ++i) {
            prefix = wrapper.commonPrefix(a, b, i);
            assertEq32(prefix.value, expectedPrefix);
            assertEq(prefix.length, expectedLength);
        }
    }

    function assertEq32(uint256 a, uint256 b) public pure {
        assertEq32(bytes32(a), bytes32(b));
    }
}
