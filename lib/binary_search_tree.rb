require 'set'

class Node
  include Comparable

  attr_accessor :data, :left, :right

  def initialize(data)
    @data = data
    @left = nil
    @right = nil
  end

  def <=>(other)
    @data <=> other.data
  end
end

class Queue
  def initialize(array = [])
    @queue = array
  end

  def enqueue(element)
    @queue << element
  end

  def dequeue
    @queue.shift
  end

  def empty?
    @queue.empty?
  end

  def size
    @queue.length
  end
end

class Tree
  attr_reader :root

  def initialize(array = [])
    array = sort_and_remove_duplicates(array)
    @root = build_tree(array)
  end

  def insert(value)
    nodeToInsert = Node.new(value)

    if @root.nil?
      return @root = nodeToInsert
    end

    current = @root

    while current.data != value
      if nodeToInsert < current
        if current.left.nil?
          current.left = nodeToInsert
        end
        current = current.left
      else
        if current.right.nil?
          current.right = nodeToInsert
        end
        current = current.right
      end
    end
  end

  def delete(value, root = @root)
    current = root
    parent = nil
    direction = nil

    while !current.nil? && current.data != value
      parent = current

      if value < current.data
        current = current.left
        direction = :left=
      else
        current = current.right
        direction = :right=
      end
    end

    return if current.nil?

    if current.left.nil? && current.right.nil?
      if parent
        parent.send(direction, nil)
      else
        @root = nil
      end
    elsif !current.left.nil? && !current.right.nil?
      replacement = find_smallest(current.right, current)
      replacement.left = current.left
      replacement.right = current.right
      if parent.nil?
        @root = replacement
      else
        parent.send(direction, replacement)
      end
    elsif !current.left.nil?
      parent.send(direction, current.left)
    elsif !current.right.nil?
      parent.send(direction, current.right)
    else
      raise StandardError, "Branch should not have been reached"
    end

    current
  end

  def find(value)
    current = @root
    while !current.nil? && current.data != value
      if value < current.data
        current = current.left
      else
        current = current.right
      end
    end
    current
  end

  def level_order
    return if @root.nil?
    queue = Queue.new([@root])
    elements = []

    while !queue.empty?
      current = queue.dequeue
      yield(current.data) if block_given?
      elements << current.data

      queue.enqueue(current.left) if current.left
      queue.enqueue(current.right) if current.right
    end
    elements
  end

  def inorder(root = @root, traversed = [], &block)
    return if root.nil?

    inorder(root.left, traversed, &block)

    yield(root.data) if block_given?
    traversed << root.data

    inorder(root.right, traversed, &block)

    traversed
  end

  def preorder(root = @root, traversed = [], &block)
    return if root.nil?

    yield(root.data) if block_given?
    traversed << root.data

    preorder(root.left, traversed, &block)
    preorder(root.right, traversed, &block)

    traversed
  end

  def postorder(root = @root, traversed = [], &block)
    return if root.nil?

    postorder(root.left, traversed, &block)
    postorder(root.right, traversed, &block)

    yield(root.data) if block_given?
    traversed << root.data

    traversed
  end

  def height(root = @root)
    return 0 if root.nil? || (root.left.nil? && root.right.nil?)

    [height(root.left), height(root.right)].max + 1
  end

  def depth(node)
    height - height(node)
  end

  def balanced?(root = @root)
    return true if root.nil?

    balanced?(root.left) && balanced?(root.right) &&
    (height(root.left) - height(root.right)).abs <= 1
  end

  def rebalance
    @root = build_tree(inorder)
  end

  private

  # @param [Array] array that is sorted and has duplicates removed
  # @return a balanced binary search tree
  def build_tree(array)
    return nil if array.length <= 0

    mid = (array.length - 1) / 2

    root = Node.new(array[mid])
    root.left = build_tree(array[0...mid])
    root.right = build_tree(array[mid + 1..])

    root
  end

  def sort_and_remove_duplicates(array)
    array.to_set.to_a.sort
  end

  def find_smallest(smallest, parent)
    while !smallest.left.nil?
      parent = smallest
      smallest = smallest.left
    end
    delete(smallest.data, parent)
  end
end
