// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

library Uint16Pack {
    error OutOfRange();

    uint256 private constant _MAX_UINT16 = type(uint16).max;

    function get16Unsafe(uint256 packed, uint256 index) internal pure returns (uint16 ret) {
        assembly {
            ret := and(shr(shl(4, index), packed), 0xffff)
        }
    }

    function get16(uint256 packed, uint256 index) internal pure returns (uint16) {
        if (index > 15) revert OutOfRange();
        return get16Unsafe(packed, index);
    }

    function add16Unsafe(uint256 packed, uint256 index, uint16 value) internal pure returns (uint256 ret) {
        assembly {
            ret := add(packed, shl(shl(4, index), and(value, 0xffff)))
        }
    }

    function add16(uint256 packed, uint256 index, uint16 value) internal pure returns (uint256 ret) {
        if (index > 15) revert OutOfRange();
        uint16 current = get16Unsafe(packed, index);
        current += value;
        ret = update16Unsafe(packed, index, current);
    }

    function sub16Unsafe(uint256 packed, uint256 index, uint16 value) internal pure returns (uint256 ret) {
        assembly {
            ret := sub(packed, shl(shl(4, index), and(value, 0xffff)))
        }
    }

    function sub16(uint256 packed, uint256 index, uint16 value) internal pure returns (uint256 ret) {
        if (index > 15) revert OutOfRange();
        uint16 current = get16Unsafe(packed, index);
        current -= value;
        ret = update16Unsafe(packed, index, current);
    }

    function update16Unsafe(uint256 packed, uint256 index, uint16 value) internal pure returns (uint256 ret) {
        assembly {
            index := shl(4, index)
            packed := sub(packed, and(packed, shl(index, 0xffff)))
            ret := add(packed, shl(index, and(value, 0xffff)))
        }
    }

    function update16(uint256 packed, uint256 index, uint16 value) internal pure returns (uint256) {
        if (index > 15) revert OutOfRange();
        return update16Unsafe(packed, index, value);
    }

    function sum16(uint256 packed) internal pure returns (uint256 ret) {
        unchecked {
            ret = _MAX_UINT16 & packed;
            for (uint256 i = 0; i < 15; ++i) {
                packed = packed >> 16;
                ret += _MAX_UINT16 & packed;
            }
        }
    }

    function sum16(uint256 packed, uint256 from, uint256 to) internal pure returns (uint256) {
        if (from > 15 || to > 16 || from > to) revert OutOfRange();
        return sum16Unsafe(packed, from, to);
    }

    function sum16Unsafe(uint256 packed, uint256 from, uint256 to) internal pure returns (uint256 ret) {
        unchecked {
            packed = packed >> (from << 4);
            for (uint256 i = from; i < to; ++i) {
                ret += _MAX_UINT16 & packed;
                packed = packed >> 16;
            }
        }
    }
}
