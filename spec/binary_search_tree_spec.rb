require_relative '../lib/binary_search_tree.rb'

RSpec.describe Tree do
  let(:tree) { described_class.new }
  def expected_tree(root, example = 0)
    Proc.new do
      # expected in example 0:
      #        8
      #     /     \
      #    4      67
      #   / \    / \
      #  1   5  9  324
      #  \   \  \    \
      #  3   7  23  6345
      expect(root.data).to eq(8) unless example == 7
      expect(root.left.data).to eq(4) unless example == 6
      expect(root.right.data).to eq(67) unless example == 5
      expect(root.left.left.data).to eq(1) unless example == 4
      expect(root.left.left.data).to eq(3) if example == 4
      expect(root.left.right.data).to eq(5) unless example == 6
      expect(root.left.data).to eq(5) if example == 6
      expect(root.left.left.right.data).to eq(3) unless example == 4
      expect(root.left.right.right.data).to eq(7) unless example == 6
      expect(root.left.right.data).to eq(7) if example == 6
      expect(root.right.left.data).to eq(9) unless example == 7
      expect(root.data).to eq(9) if example == 7
      expect(root.right.left.right.data).to eq(
        23) unless example == 3 || example == 7
      expect(root.right.left.data).to eq(23) if example == 7
      expect(root.right.right.data).to eq(324) unless example == 5
      expect(root.right.data).to eq(324) if example == 5
      expect(root.right.right.right.data).to eq(6345) unless example == 5
      expect(root.right.right.data).to eq(6345) if example == 5
      expect(root.right.left.right.right.data).to eq(50) if example == 1
      expect(root.right.right.left.data).to eq(206) if example == 2
    end
  end

  describe "#sort_and_remove_duplicates" do

    it "sorts an array and removes duplicates" do
      array = [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]
      expected = [1, 3, 4, 5, 7, 8, 9, 23, 67, 324, 6345]

      expect(tree.send(:sort_and_remove_duplicates, array)).to eq(
        expected
      )
    end
  end

  describe "#build_tree" do
    it "returns the root node of a binary search tree" do
      array = [1, 3, 4, 5, 7, 8, 9, 23, 67, 324, 6345]

      root = tree.send(:build_tree, array)
      aggregate_failures(&expected_tree(root))
    end
  end

  it "builds a binary search tree upon initialisation" do
    array = [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324]
    tree = described_class.new(array)

    aggregate_failures(&expected_tree(tree.root))
  end

  describe "#insert" do
    it "sets inserted value as root when tree is empty" do
      tree.insert(10)
      expect(tree.root.data).to eq(10)
    end

    describe "on existing tree" do
      let(:array) { [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324] }
      let(:tree) { described_class.new(array) }

      it "does not change tree structure when inserting duplicate element" do
        tree.insert(8)
        aggregate_failures(&expected_tree(tree.root))
      end

      describe "inserts non-duplicate element in correct place" do
        it "example 1" do
          tree.insert(50)
          aggregate_failures(&expected_tree(tree.root, 1))
        end

        it "example 2" do
          tree.insert(206)
          aggregate_failures(&expected_tree(tree.root, 2))
        end
      end
    end
  end

  describe "#delete" do
    let(:array) { [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324] }
    let(:tree) { described_class.new(array) }

    it "deletes a leaf node" do
      tree.delete(23)
      aggregate_failures(&expected_tree(tree.root, 3))
    end

    it "deletes a node with 1 child" do
      tree.delete(1)
      aggregate_failures(&expected_tree(tree.root, 4))
    end

    describe "deletes a node with 2 children" do
      it "example 1" do
        tree.delete(67)
        aggregate_failures(&expected_tree(tree.root, 5))
      end

      it "example 2" do
        tree.delete(4)
        aggregate_failures(&expected_tree(tree.root, 6))
      end
    end

    it "deletes the root node" do
      tree.delete(8)
      aggregate_failures(&expected_tree(tree.root, 7))
    end

    it "deletes a singleton node" do
      tree = Tree.new([8])
      tree.delete(8)
      expect(tree.root).to be nil
    end

    it "returns nil when there is no such node to delete" do
      expect(tree.delete(2)).to be nil
    end
  end

  describe "#find" do
    let(:array) { [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324] }
    let(:tree) { described_class.new(array) }

    it "returns the root node when appropriate" do
      expect(tree.find(8).data).to eq(8)
    end

    it "returns a node with the searched for value" do
      expect(tree.find(324).data).to eq(324)
    end

    it "returns nil when element not found" do
      expect(tree.find(11)).to be nil
    end
  end

  describe "#level_order" do
    it "doesn't yield if tree is empty" do
      tree.level_order { raise "Yielded" }
    end

    describe "populated with elements" do
      let(:array) { [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324] }
      let(:tree) { described_class.new(array) }

      it "returns the elements in level order" do
        expected = [8, 4, 67, 1, 5, 9, 324, 3, 7, 23, 6345]
        expect(tree.level_order).to eq(expected)
      end

      it "yields each element to a block" do
        expected = [8, 4, 67, 1, 5, 9, 324, 3, 7, 23, 6345].map {|x| x * 2}
        target = []

        tree.level_order { |value| target << value * 2 }
        expect(target).to eq(expected)
      end
    end
  end

  describe "#inorder" do
    it "doesn't yield if tree is empty" do
      tree.inorder { raise "Yielded" }
    end

    describe "populated with elements" do
      let(:array) { [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324] }
      let(:tree) { described_class.new(array) }

      it "returns the elements in order" do
        expected = [1, 3, 4, 5, 7, 8, 9, 23, 67, 324, 6345]
        expect(tree.inorder).to eq(expected)
      end

      it "yields each element to a block" do
        expected = [1, 3, 4, 5, 7, 8, 9, 23, 67, 324, 6345].map {|x| x * 2}
        target = []

        tree.inorder { |value| target << value * 2 }
        expect(target).to eq(expected)
      end
    end
  end

  describe "#preorder" do
    it "doesn't yield if tree is empty" do
      tree.preorder { raise "Yielded" }
    end

    describe "populated with elements" do
      let(:array) { [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324] }
      let(:tree) { described_class.new(array) }

      it "returns the elements in order" do
        expected = [8, 4, 1, 3, 5, 7, 67, 9, 23, 324, 6345]
        expect(tree.preorder).to eq(expected)
      end

      it "yields each element to a block" do
        expected = [8, 4, 1, 3, 5, 7, 67, 9, 23, 324, 6345].map {|x| x * 2}
        target = []

        tree.preorder { |value| target << value * 2 }
        expect(target).to eq(expected)
      end
    end
  end

  describe "#postorder" do
    it "doesn't yield if tree is empty" do
      tree.postorder { raise "Yielded" }
    end

    describe "populated with elements" do
      let(:array) { [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324] }
      let(:tree) { described_class.new(array) }

      it "returns the elements in order" do
        expected = [3, 1, 7, 5, 4, 23, 9, 6345, 324, 67, 8]
        expect(tree.postorder).to eq(expected)
      end

      it "yields each element to a block" do
        expected = [3, 1, 7, 5, 4, 23, 9, 6345, 324, 67, 8].map {|x| x * 2}
        target = []

        tree.postorder { |value| target << value * 2 }
        expect(target).to eq(expected)
      end
    end
  end

  describe "#height" do
    let(:array) { [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324] }
    let(:tree) { described_class.new(array) }

    it "returns height of tree when given no arguments" do
      expect(tree.height).to eq(3)
    end

    it "returns height of a subtree" do
      expect(tree.height(tree.find(4))).to eq(2)
    end
  end

  describe "#depth" do
    let(:array) { [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324] }
    let(:tree) { described_class.new(array) }

    it "returns depth of root" do
      expect(tree.depth(tree.root)).to eq(0)
    end

    it "returns depth of node" do
      expect(tree.depth(tree.find(4))).to eq(1)
    end

    it "returns depth of leaf" do
      expect(tree.depth(tree.find(3))).to eq(3)
    end
  end

  describe "#balanced?" do
    let(:array) { [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324] }
    let(:tree) { described_class.new(array) }

    it "returns true for balanced tree" do
      expect(tree.balanced?).to be true
    end

    it "returns false for an unbalanced tree" do
      tree.insert(10009)
      tree.insert(10010)
      expect(tree.balanced?).to be false
    end
  end

  describe "rebalance" do
    let(:array) { [1, 7, 4, 23, 8, 9, 4, 3, 5, 7, 9, 67, 6345, 324] }
    let(:tree) { described_class.new(array) }

    it "rebalances an unbalanced tree" do
      tree.insert(10009)
      tree.insert(10010)

      tree.rebalance
      expect(tree.balanced?).to be true
    end
  end
end
