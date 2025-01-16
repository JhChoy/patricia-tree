// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

import {Uint16Pack} from "./libraries/Uint16Pack.sol";

/// @notice Patricia-Segment Tree implementation.
/// @author JChoy (https://github.com/JhChoy/patricia-tree/blob/master/src/PatriciaSegmentTree.sol)
library PatriciaSegmentTreeLib {
    using PatriciaSegmentTreeLib for PatriciaSegmentTree;
    using Uint16Pack for uint256;

    error OutOfRange();
    error WrongOffset();
    error NotExist();

    // bytes32(uint256(keccak256("PatriciaSegmentTree")) - 1)
    uint256 internal constant ROOT = 0x5180cb82e974432c1052ba49aed787b94bb44eef3071ff1a62b3a83da765be79;
    uint256 internal constant MAX_VALUE = 2 ** 248 - 1;
    uint8 internal constant MAX_LENGTH = 64;
    uint8 internal constant MAX_OFFSET = 63;

    struct PatriciaSegmentTree {
        mapping(uint256 data => uint256) children;
        uint16 rootSize;
    }

    struct Data {
        uint8 length; // @dev 4 < length
        uint256 value; // @dev value <= MAX_VALUE
    }

    struct Node {
        Data data;
        uint256 addr; // @dev tree.slot or encoded value
    }

    function _checkRange(uint256 value) private pure {
        if (value > MAX_VALUE) revert OutOfRange();
    }

    function add(PatriciaSegmentTree storage tree, uint256 value) internal {
        _checkRange(value);

        Node memory currentNode = tree.loadRootNode();
        uint16 newSize = ++tree.rootSize;

        Data memory data = Data({length: MAX_LENGTH, value: value});
        uint8 offset = 0;

        while (true) {
            // If this is the first value, store it in the root.
            if (newSize == 1) {
                currentNode.data = data;
                tree.storeNode(currentNode);
                return;
            }

            // parent = common prefix
            Data memory parent = findParent(currentNode.data.value, data.value, offset);

            // If the prefix of currentNode is shorter, replace parent.
            if (currentNode.data.length < parent.length) {
                parent = currentNode.data;
            }

            if (parent.length == currentNode.data.length) {
                // If we haven't reached the maximum length (=leaf), we need to go down to the child.
                if (parent.length < MAX_LENGTH) {
                    // Extract nibble
                    uint8 nextHex = uint8((data.value >> ((MAX_OFFSET - parent.length) << 2)) & 0xF);

                    // Increase child count
                    uint256 encodedData = encodeData(parent);
                    uint256 children = tree.children[encodedData].add16Unsafe(nextHex, 1);
                    tree.children[encodedData] = children;

                    // Load child node
                    Node memory childNode = tree.loadNode(
                        Data({
                            length: parent.length + 1,
                            value: parent.value + (uint256(nextHex) << ((MAX_OFFSET - parent.length) << 2))
                        })
                    );

                    currentNode = childNode;
                    offset = parent.length + 1;
                    newSize = uint16(children.get16Unsafe(nextHex));

                    continue;
                } else {
                    return;
                }
            } else {
                // Create new parent node and store it.
                Node memory parentNode = Node({data: parent, addr: currentNode.addr});
                tree.storeNode(parentNode);

                uint8 incomingHex = uint8((data.value >> ((MAX_OFFSET - parent.length) << 2)) & 0xF);
                uint8 movedHex = uint8((currentNode.data.value >> ((MAX_OFFSET - parent.length) << 2)) & 0xF);

                uint256 encodedData = encodeData(parent);
                // Distribute counts to left/right (or branch).
                // incomingHex = new value, movedHex = existing node
                tree.children[encodedData] = uint256(0).add16Unsafe(incomingHex, 1).add16Unsafe(movedHex, newSize - 1);

                // Store moved node.
                {
                    Data memory movedData = Data({
                        length: parent.length + 1,
                        value: parent.value + (uint256(movedHex) << ((MAX_OFFSET - parent.length) << 2))
                    });
                    tree.storeNode(Node({data: currentNode.data, addr: encodeData(movedData)}));
                }

                // Store incoming node.
                {
                    Data memory incomingData = Data({
                        length: parent.length + 1,
                        value: parent.value + (uint256(incomingHex) << ((MAX_OFFSET - parent.length) << 2))
                    });
                    tree.storeNode(Node({data: data, addr: encodeData(incomingData)}));
                }

                return;
            }
        }
    }

    function remove(PatriciaSegmentTree storage tree, uint256 value) internal {
        _checkRange(value);
    }

    function update(PatriciaSegmentTree storage tree, uint256 from, uint256 to) internal {
        _checkRange(from);
        _checkRange(to);
    }

    function query(PatriciaSegmentTree storage tree, uint256 value)
        internal
        view
        returns (uint256 left, uint256 mid, uint256 right)
    {
        _checkRange(value);

        Node memory currentNode = tree.loadRootNode();
        uint16 size = tree.rootSize;
        uint8 offset = 0;

        // Accumulated (left, mid, right) values
        left = 0;
        mid = 0;
        right = 0;

        while (true) {
            if (size == 0) {
                // size = 0 means this value has not been added
                break;
            }

            // Check if this is a leaf node (length == MAX_LENGTH)
            if (currentNode.data.length == MAX_LENGTH) {
                if (currentNode.data.value < value) {
                    // If the current node is smaller than the value, all are left
                    left += size;
                } else if (currentNode.data.value > value) {
                    // If the current node is larger than the value, all are right
                    right += size;
                } else {
                    // If the value matches, all count goes to mid
                    mid += size;
                }
                break;
            }

            // parent = common prefix
            Data memory parent = findParent(currentNode.data.value, value, offset);

            // If the prefix is different, all count goes to left or right
            if (currentNode.data.value != parent.value) {
                if (currentNode.data.value > parent.value) {
                    right += size;
                } else {
                    left += size;
                }
                break;
            }

            // Extract nibble to determine child index
            uint8 hexDigit = uint8((value >> ((MAX_OFFSET - currentNode.data.length) << 2)) & 0xF);
            uint256 childrenMap = tree.loadChildrenMap(currentNode.data);

            // All nibbles less than (hexDigit) are left
            left += childrenMap.sum16Unsafe(0, hexDigit);
            // All nibbles greater than (hexDigit) are right
            right += childrenMap.sum16Unsafe(hexDigit + 1, 16);

            // Count of the child with (hexDigit)
            size = childrenMap.get16Unsafe(hexDigit);

            // Update offset to point to next nibble position after current node
            offset = currentNode.data.length + 1;

            // Move to the child node
            currentNode = tree.loadNode(
                Data({
                    length: currentNode.data.length + 1,
                    value: currentNode.data.value + (uint256(hexDigit) << ((MAX_OFFSET - currentNode.data.length) << 2))
                })
            );
        }
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
        root.data = decodeData(data);
        root.addr = addr;
    }

    function loadNode(PatriciaSegmentTree storage tree, Data memory addr) internal view returns (Node memory node) {
        node.addr = encodeData(addr);
        bytes32 slot = _slot(tree, node.addr);
        uint256 data;
        assembly {
            data := sload(slot)
        }
        node.data = decodeData(data);
    }

    function storeNode(PatriciaSegmentTree storage tree, Node memory node) internal {
        bytes32 slot = _slot(tree, node.addr);
        uint256 data = encodeData(node.data);
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
