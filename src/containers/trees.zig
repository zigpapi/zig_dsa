//! This namespace is for tree datastructures
//! ranging from Binary tree, AVL, General Tree etc.
//! it also a working progress.

const std = @import("std");
const Allocator = std.mem.Allocator;
const heap = std.heap;

/// Generic Binary Serach Tree Data structure
/// moving foward it will be referred to as BST
pub fn BinarySearchTree(comptime T: type) type {
    return struct {
        /// root node of the BST
        root: ?*Node = null,
        allocator: Allocator,

        const Self = @This();

        /// Node struct type
        const Node = struct {
            /// left child node init to null
            left: ?*Node = null,
            /// right child node init to null
            right: ?*Node = null,
            /// the data for this node of type T
            data: T,
        };

        /// init() initiliazes BST with an allocator.
        pub fn init(allocator: Allocator, root_node: ?*Node) Self {
            if (root_node) |root| {
                return Self{ .allocator = allocator, .root = root };
            }
            return Self{ .allocator = allocator };
        }
        /// createNode() creates a new Node struct and returns an error union set
        /// either anyerror!*Node
        pub fn createNode(self: *Self, data_value: T) !*Node {
            const new_node = try self.allocator.create(Node);
            new_node.* = Node{ .data = data_value };
            return new_node;
        }

        pub fn insertNode(self: *Self, data: T) !bool {
            const new_node = try self.createNode(data);
            if (self.root == null) {
                self.root = new_node;
                return true;
            }

            var current = self.root;

            while (current) |curr_node| {
                if (data < curr_node.data) {
                    if (curr_node.left == null) {
                        curr_node.left = new_node;
                        return true;
                    } else {
                        current = curr_node.left;
                    }
                } else if (data > curr_node.data) {
                    if (curr_node.right == null) {
                        curr_node.right = new_node;
                        return true;
                    } else {
                        current = curr_node.right;
                    }
                } else {
                    // Value already exists; no duplicates allowed
                    self.allocator.destroy(new_node);
                    return false;
                }
            }
            return false;
        }
    };
}
test "init() no root node" {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const BST = BinarySearchTree(u8);
    const tree = BST.init(allocator, null);
    try std.testing.expectEqual(null, tree.root);
    _ = try std.io.getStdErr().write("this passed\n");
}

test "init() with root node" {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const BST = BinarySearchTree(u8);
    var tree = BST.init(allocator, null);

    const new_node = try tree.createNode(5);
    tree.root = new_node;
    try std.testing.expectEqual(new_node, tree.root.?);
    _ = try std.io.getStdErr().write("this passed\n");
}

test "createNode()" {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const BST = BinarySearchTree(u8);
    var tree = BST.init(allocator, null);

    const new_node = try tree.createNode(5);

    // Check that the node's fields are initialized correctly
    try std.testing.expectEqual(new_node.data, 5);
    try std.testing.expectEqual(new_node.left, null);
    try std.testing.expectEqual(new_node.right, null);
}

test "insertNode()" {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const BST = BinarySearchTree(u8);
    var tree = BST.init(allocator, null);

    const isInserted = try tree.insertNode(5);
    const isInsertedFalse = try tree.insertNode(5);
    const tests = try tree.insertNode(7);
    _ = tests;

    try std.testing.expectEqual(true, isInserted);
    try std.testing.expectEqual(false, isInsertedFalse);
    try std.testing.expectEqual(tree.root.?.right.?.data, 7);
}
