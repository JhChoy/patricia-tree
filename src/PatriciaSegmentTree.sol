// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {Uint16Pack} from "./libraries/Uint16Pack.sol";

/// @notice Patricia-Segment Tree implementation.
/// @author JChoy (https://github.com/JhChoy/patricia-tree/blob/master/src/PatriciaSegmentTree.sol)
library PatriciaSegmentTreeLib {
    using Uint16Pack for uint256;

    error OutOfRange();
    error WrongOffset();
    error NotExist();

    // bytes32(uint256(keccak256("PatriciaSegmentTree")) - 1)
    uint256 internal constant ROOT = 0x5180cb82e974432c1052ba49aed787b94bb44eef3071ff1a62b3a83da765be79;
    uint256 internal constant MAX_VALUE = 2 ** 232 - 1;
    uint8 internal constant MAX_LENGTH = 64;
    uint8 internal constant MAX_OFFSET = 63;

    struct PatriciaSegmentTree {
        mapping(uint256 data => uint256) children;
    }

    struct Data {
        uint8 length; // @dev 4 < length
        uint256 value; // @dev value <= MAX_VALUE
    }

    struct Node {
        // todo: remove size
        uint16 size;
        Data data;
        uint256 addr; // @dev tree.slot or encoded value
    }

    function _checkRange(uint256 value) private pure {
        if (value > MAX_VALUE) revert OutOfRange();
    }

    function add(PatriciaSegmentTree storage tree, uint256 value) internal {
        _checkRange(value);
        Node memory root = loadRootNode(tree);
        _add(tree, root, Data({length: MAX_LENGTH, value: value}), 0);
    }

    function _add(PatriciaSegmentTree storage tree, Node memory node, Data memory data, uint8 offset) private {
        if (node.size == 0) {
            node.size = 1;
            node.data = data;
            storeNode(tree, node);
            return;
        }
        Data memory parent = findParent(node.data.value, data.value, offset);
        if (node.data.length < parent.length) {
            parent = node.data;
        }
        if (parent.length == node.data.length) {
            if (parent.length == MAX_LENGTH) {
                node.size += 1;
                storeNode(tree, node);
            } else {
                // Increase the size.
                node.size += 1;
                storeNode(tree, node);

                // Get the next hex digit.
                uint8 nextHex = uint8((data.value >> ((MAX_OFFSET - parent.length) << 2)) & 0xf);

                // Increase the count of the child node.
                uint256 encodedData = encodeData(parent);
                tree.children[encodedData] = tree.children[encodedData].add16Unsafe(nextHex, 1);

                // Find the child node.
                Node memory childNode = loadNode(
                    tree,
                    Data({
                        length: parent.length + 1,
                        value: parent.value + (uint256(nextHex) << ((MAX_OFFSET - parent.length) << 2))
                    })
                );
                _add(tree, childNode, data, parent.length + 1);
            }
        } else {
            Node memory parentNode = Node({size: node.size + 1, data: parent, addr: node.addr});
            storeNode(tree, parentNode);
            uint8 incomingHex = uint8((data.value >> ((MAX_OFFSET - parent.length) << 2)) & 0xf);
            uint8 movedHex = uint8((node.data.value >> ((MAX_OFFSET - parent.length) << 2)) & 0xf);
            uint256 encodedData = encodeData(parent);
            tree.children[encodedData] = uint256(0).add16Unsafe(incomingHex, 1).add16Unsafe(movedHex, node.size);
            // Store moved node.
            storeNode(
                tree,
                Node({
                    size: node.size,
                    data: node.data,
                    addr: encodeData(
                        Data({
                            length: parent.length + 1,
                            value: parent.value + (uint256(movedHex) << ((MAX_OFFSET - parent.length) << 2))
                        })
                    )
                })
            );
            // Store incoming node.
            storeNode(
                tree,
                Node({
                    size: 1,
                    data: data,
                    addr: encodeData(
                        Data({
                            length: parent.length + 1,
                            value: parent.value + (uint256(incomingHex) << ((MAX_OFFSET - parent.length) << 2))
                        })
                    )
                })
            );
        }
    }

    function remove(PatriciaSegmentTree storage tree, uint256 value) internal {
        _checkRange(value);
    }

    function update(PatriciaSegmentTree storage tree, uint256 from, uint256 to) internal {
        _checkRange(from);
        _checkRange(to);
    }

    function query(PatriciaSegmentTree storage tree, uint256 value) internal view returns (uint256, uint256, uint256) {
        _checkRange(value);
        Node memory root = loadRootNode(tree);
        return _query(tree, root, value, 0);
    }

    function _query(PatriciaSegmentTree storage tree, Node memory node, uint256 value, uint8 offset)
        private
        view
        returns (uint256 left, uint256 mid, uint256 right)
    {
        if (node.size == 0) return (0, 0, 0);

        if (node.data.length == MAX_LENGTH) {
            if (node.data.value < value) {
                return (node.size, 0, 0);
            } else if (node.data.value > value) {
                return (0, 0, node.size);
            } else {
                return (0, node.size, 0);
            }
        }

        Data memory parent = findParent(node.data.value, value, offset);
        if (node.data.value != parent.value) {
            if (node.data.value > parent.value) {
                return (0, 0, node.size);
            } else {
                return (node.size, 0, 0);
            }
        }

        uint8 hexDigit = uint8((value >> ((MAX_OFFSET - node.data.length) << 2)) & 0xf);

        Node memory childNode = loadNode(
            tree,
            Data({
                length: node.data.length + 1,
                value: node.data.value + (uint256(hexDigit) << ((MAX_OFFSET - node.data.length) << 2))
            })
        );
        (left, mid, right) = _query(tree, childNode, value, node.data.length + 1);

        uint256 encodedData = encodeData(node.data);
        left += tree.children[encodedData].sum16Unsafe(0, hexDigit);
        right += tree.children[encodedData].sum16Unsafe(hexDigit + 1, 16);
    }

    function findParent(uint256 a, uint256 b, uint8 offset) internal pure returns (Data memory parent) {
        if (a == b) return Data({length: MAX_LENGTH, value: a});
        require(offset < MAX_LENGTH);
        // todo: binary search
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

    function _slot(PatriciaSegmentTree storage tree, uint256 addr) private pure returns (bytes32 slot) {
        assembly {
            slot := tree.slot
        }
        slot = keccak256(abi.encodePacked(ROOT, slot, addr));
    }

    function loadRootNode(PatriciaSegmentTree storage tree) internal view returns (Node memory root) {
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

    function loadNode(PatriciaSegmentTree storage tree, Data memory addr) internal view returns (Node memory node) {
        node.addr = encodeData(addr);
        bytes32 slot = _slot(tree, node.addr);
        uint256 data;
        assembly {
            data := sload(slot)
        }
        node.size = uint16(data & 0xffff);
        node.data = decodeData(data >> 16);
    }

    function storeNode(PatriciaSegmentTree storage tree, Node memory node) internal {
        bytes32 slot = _slot(tree, node.addr);
        uint256 data = encodeData(node.data) << 16 | node.size;
        assembly {
            sstore(slot, data)
        }
    }

    function loadChildrenMap(PatriciaSegmentTree storage tree, Data memory data) internal view returns (uint256) {
        return tree.children[encodeData(data)];
    }

    function encodeData(Data memory v) internal pure returns (uint256) {
        return v.value << 8 | v.length;
    }

    function decodeData(uint256 v) internal pure returns (Data memory) {
        return Data(uint8(v & 0xff), v >> 8);
    }
}
