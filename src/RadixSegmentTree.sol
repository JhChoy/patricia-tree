// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

/// @notice Radix-Segment Tree implementation.
/// @author JChoy (https://github.com/JhChoy/radix-segment-tree/blob/master/src/RadixSegmentTree.sol)
library RadixSegmentTreeLib {
    error OutOfRange();
    error WrongOffset();

    // bytes32(uint256(keccak256("RadixSegmentTree")) - 1)
    uint256 internal constant ROOT = 0x93d586536338c237314802209ad99ffc16300a0123983a9edf87427344edd372;
    uint256 internal constant MAX_VALUE = 2 ** 232 - 1;
    uint8 internal constant MAX_LENGTH = 64;
    uint8 internal constant MAX_OFFSET = 63;

    struct RadixSegmentTree {
        mapping(uint256 data => uint256) children;
    }

    struct Data {
        uint8 length; // @dev 4 < length
        uint256 value; // @dev value <= MAX_VALUE
    }

    struct Node {
        uint16 size;
        Data data;
        uint256 addr; // @dev tree.slot or encoded value
    }

    function _checkRange(uint256 value) private pure {
        if (value > MAX_VALUE) revert OutOfRange();
    }

    function add(RadixSegmentTree storage tree, uint256 value) internal {
        _checkRange(value);
    }

    function remove(RadixSegmentTree storage tree, uint256 value) internal {
        _checkRange(value);
    }

    function update(RadixSegmentTree storage tree, uint256 from, uint256 to) internal {
        _checkRange(from);
        _checkRange(to);
    }

    function query(RadixSegmentTree storage tree, uint256 value)
        internal
        view
        returns (uint256 left, uint256 mid, uint256 right)
    {
        _checkRange(value);
    }

    function findParent(uint256 a, uint256 b, uint8 offset) internal pure returns (Data memory parent) {
        if (a == b) return Data({length: MAX_LENGTH, value: a});
        require(offset < MAX_LENGTH);
        assembly {
            // a = 0x132xx...x
            // b = 0x134xx...x
            // c = 0xffxxx...x
            let c := not(xor(a, b))
            // Generate `offset` number of 0x`f`s at the front.
            offset := sub(MAX_LENGTH, offset)
            let lastMask := not(sub(shl(shl(2, offset), 1), 1)) // ~((1 << (offset << 2)) - 1)
            if lt(c, lastMask) {
                mstore(0x00, 0xea08b33a) // `WrongOffset()`.
                revert(0x1c, 0x04)
            }
            for {} true {} {
                offset := sub(offset, 1)
                // Append 0xf to the last mask
                // lastMask + (0xf << (offset << 2))
                let mask := add(lastMask, shl(shl(2, offset), 0xf))
                // If c < mask, then a and b have different hex digits.
                // 0xffffxxx...xx < 0xfffff00...00
                if lt(c, mask) {
                    mstore(add(parent, 0x20), and(a, lastMask))
                    // Find the length of the common prefix.
                    // `offset` cannot be 64, because a != b.
                    mstore(parent, sub(MAX_OFFSET, offset))
                    break
                }
                lastMask := mask
            }
        }
        // Sanity check
        require(parent.value <= a && parent.value <= b);
    }

    function _slot(RadixSegmentTree storage tree, uint256 addr) private pure returns (bytes32 slot) {
        assembly {
            slot := tree.slot
        }
        slot = keccak256(abi.encodePacked(ROOT, slot, addr));
    }

    function loadRootNode(RadixSegmentTree storage tree) internal view returns (Node memory root) {
        // todo: perf
        uint256 data;
        uint256 addr;
        assembly {
            addr := tree.slot
        }
        bytes32 slot = _slot(tree, addr);
        assembly {
            data := sload(slot)
        }
        root.size = uint16(data & 0xffff);
        root.data = decodeData(data >> 16);
        root.addr = addr;
    }

    function loadNode(RadixSegmentTree storage tree, Data memory addr) internal view returns (Node memory node) {
        node.addr = encodeData(addr);
        bytes32 slot = _slot(tree, node.addr);
        uint256 data;
        assembly {
            data := sload(slot)
        }
        node.size = uint16(data & 0xffff);
        node.data = decodeData(data >> 16);
    }

    function storeNode(RadixSegmentTree storage tree, Node memory node) internal {
        bytes32 slot = _slot(tree, node.addr);
        uint256 data = encodeData(node.data) << 16 | node.size;
        assembly {
            sstore(slot, data)
        }
    }

    function loadChildrenMap(RadixSegmentTree storage tree, Data memory data) internal view returns (uint256) {
        return tree.children[encodeData(data)];
    }

    function encodeData(Data memory v) internal pure returns (uint256) {
        return v.value << 8 | v.length;
    }

    function decodeData(uint256 v) internal pure returns (Data memory) {
        return Data(uint8(v & 0xff), v >> 8);
    }
}
