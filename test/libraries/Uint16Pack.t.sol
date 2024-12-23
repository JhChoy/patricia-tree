// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "./Uint16PackWrapper.sol";

import "forge-std/Test.sol";

contract Uint16PackTest is Test {
    Uint16PackWrapper public wrapper;

    function setUp() public {
        wrapper = new Uint16PackWrapper();
    }

    function testGet16Unsafe(uint16[16] memory values) public view {
        uint256 packed = _build(values);
        for (uint256 i = 0; i < 16; i++) {
            assertEq(wrapper.get16Unsafe(packed, i), values[i]);
        }
    }

    function testGet16(uint16[16] memory values) public view {
        uint256 packed = _build(values);
        for (uint256 i = 0; i < 16; i++) {
            assertEq(wrapper.get16(packed, i), values[i]);
        }
    }

    function testGet16OutOfRange() public {
        vm.expectRevert(abi.encodeWithSelector(Uint16Pack.OutOfRange.selector));
        wrapper.get16(0x124123, 16);
    }

    function testAdd16Unsafe(uint16[16] memory values, uint256 r) public view {
        uint256 packed = _build(values);
        for (uint256 i = 0; i < 16; i++) {
            uint16 added = type(uint16).max == values[i] ? 0 : uint16(r % (type(uint16).max - values[i]));
            uint256 result = wrapper.add16Unsafe(packed, i, added);
            assertEq(result, packed + (uint256(added) << (i * 16)));
            assertEq(wrapper.get16Unsafe(result, i), values[i] + added);
        }
    }

    function testAdd16(uint16[16] memory values, uint256 r) public view {
        uint256 packed = _build(values);
        for (uint256 i = 0; i < 16; i++) {
            uint16 added = type(uint16).max == values[i] ? 0 : uint16(r % (type(uint16).max - values[i]));
            uint256 result = wrapper.add16(packed, i, added);
            assertEq(result, packed + (uint256(added) << (i * 16)));
            assertEq(wrapper.get16(result, i), values[i] + added);
        }
    }

    function testAdd16OutOfRange() public {
        vm.expectRevert(abi.encodeWithSelector(Uint16Pack.OutOfRange.selector));
        wrapper.add16(0x124123, 16, 0xbedc);

        wrapper.add16(0x124123, 0, 0xbedc);

        vm.expectRevert(stdError.arithmeticError);
        wrapper.add16(0x124123, 0, 0xbedc + 1);
    }

    function testSub16Unsafe(uint16[16] memory values, uint256 r) public view {
        uint256 packed = _build(values);
        for (uint256 i = 0; i < 16; i++) {
            uint16 subbed = values[i] == 0 ? 0 : uint16(r % values[i]);
            uint256 result = wrapper.sub16Unsafe(packed, i, subbed);
            assertEq(result, packed - (uint256(subbed) << (i * 16)));
            assertEq(wrapper.get16Unsafe(result, i), values[i] - subbed);
        }
    }

    function testSub16(uint16[16] memory values, uint256 r) public view {
        uint256 packed = _build(values);
        for (uint256 i = 0; i < 16; i++) {
            uint16 subbed = values[i] == 0 ? 0 : uint16(r % values[i]);
            uint256 result = wrapper.sub16(packed, i, subbed);
            assertEq(result, packed - (uint256(subbed) << (i * 16)));
            assertEq(wrapper.get16(result, i), values[i] - subbed);
        }
    }

    function testSub16OutOfRange() public {
        vm.expectRevert(abi.encodeWithSelector(Uint16Pack.OutOfRange.selector));
        wrapper.sub16(0x124123, 16, 0x4123);

        wrapper.sub16(0x124123, 0, 0x4123);

        vm.expectRevert(stdError.arithmeticError);
        wrapper.sub16(0x124123, 0, 0x4123 + 1);
    }

    function testUpdate16Unsafe(uint16[16] memory values, uint256 r) public view {
        uint256 packed = _build(values);
        for (uint256 i = 0; i < 16; i++) {
            uint16 updated = uint16(r % type(uint16).max);
            uint256 result = wrapper.update16Unsafe(packed, i, updated);
            assertEq(result, packed - (uint256(values[i]) << (i * 16)) + (uint256(updated) << (i * 16)));
            assertEq(wrapper.get16Unsafe(result, i), updated);
        }
    }

    function testUpdate16(uint16[16] memory values, uint256 r) public view {
        uint256 packed = _build(values);
        for (uint256 i = 0; i < 16; i++) {
            uint16 updated = uint16(r % type(uint16).max);
            uint256 result = wrapper.update16(packed, i, updated);
            assertEq(result, packed - (uint256(values[i]) << (i * 16)) + (uint256(updated) << (i * 16)));
            assertEq(wrapper.get16(result, i), updated);
        }
    }

    function testUpdate16OutOfRange() public {
        vm.expectRevert(abi.encodeWithSelector(Uint16Pack.OutOfRange.selector));
        wrapper.update16(0x124123, 16, 0x4123);
    }

    function testSum16(uint16[16] memory values) public view {
        uint256 packed = _build(values);
        assertEq(wrapper.sum16(packed), _sum(values));
    }

    function testSum16Range(uint16[16] memory values, uint8 start, uint8 end) public {
        uint256 packed = _build(values);
        if (start > 15 || end > 16 || start > end) {
            vm.expectRevert(abi.encodeWithSelector(Uint16Pack.OutOfRange.selector));
            wrapper.sum16(packed, start, end);
        } else {
            assertEq(wrapper.sum16(packed, start, end), _sum(values, start, end));
        }
    }

    function testSum16Unsafe(uint16[16] memory values, uint8 start, uint8 end) public view {
        vm.assume(start <= 15 && end <= 16 && start <= end);
        uint256 packed = _build(values);
        uint256 result = wrapper.sum16Unsafe(packed, start, end);
        assertEq(result, _sum(values, start, end));
    }

    function _build(uint16[16] memory values) internal pure returns (uint256 packed) {
        for (uint256 i = 0; i < 16; i++) {
            packed = packed + (uint256(values[i]) << (i * 16));
        }
    }

    function _sum(uint16[16] memory values) internal pure returns (uint256 sum) {
        for (uint256 i = 0; i < 16; i++) {
            sum += values[i];
        }
    }

    function _sum(uint16[16] memory values, uint256 start, uint256 end) internal pure returns (uint256 sum) {
        for (uint256 i = start; i < end; i++) {
            sum += values[i];
        }
    }
}
