require_relative 'lib/binary_search_tree'

def print_all_ways(tree)
  puts "Level order: #{tree.level_order}"
  puts "In order: #{tree.inorder}"
  puts "Pre order: #{tree.preorder}"
  puts "Post order: #{tree.postorder}"
end

tree = Tree.new((Array.new(15) { rand(100..200) }))
raise "Tree was not initialised balanced" unless tree.balanced?

print_all_ways(tree)

100.times do
  tree.insert(rand(1..100))
end

raise "Tree is still balanced after adding 100 random numbers" if tree.balanced?
tree.rebalance
raise "Tree did not rebalance" unless tree.balanced?

print_all_ways(tree)
