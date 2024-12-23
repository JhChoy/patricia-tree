// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.24;

import "../../src/libraries/Uint16Pack.sol";

contract Uint16PackWrapper {
    using Uint16Pack for uint256;

    function get16Unsafe(uint256 packed, uint256 index) external pure returns (uint16) {
        return packed.get16Unsafe(index);
    }

    function get16(uint256 packed, uint256 index) external pure returns (uint16) {
        return packed.get16(index);
    }

    function add16Unsafe(uint256 packed, uint256 index, uint16 value) external pure returns (uint256) {
        return packed.add16Unsafe(index, value);
    }

    function add16(uint256 packed, uint256 index, uint16 value) external pure returns (uint256) {
        return packed.add16(index, value);
    }

    function sub16Unsafe(uint256 packed, uint256 index, uint16 value) external pure returns (uint256) {
        return packed.sub16Unsafe(index, value);
    }

    function sub16(uint256 packed, uint256 index, uint16 value) external pure returns (uint256) {
        return packed.sub16(index, value);
    }

    function update16Unsafe(uint256 packed, uint256 index, uint16 value) external pure returns (uint256) {
        return packed.update16Unsafe(index, value);
    }

    function update16(uint256 packed, uint256 index, uint16 value) external pure returns (uint256) {
        return packed.update16(index, value);
    }

    function sum16(uint256 packed) external pure returns (uint256) {
        return packed.sum16();
    }

    function sum16(uint256 packed, uint256 from, uint256 to) external pure returns (uint256) {
        return packed.sum16(from, to);
    }

    function sum16Unsafe(uint256 packed, uint256 from, uint256 to) external pure returns (uint256) {
        return packed.sum16Unsafe(from, to);
    }
}
