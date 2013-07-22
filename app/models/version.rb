class Version
  attr_accessible :children
  serialize :children, Hash
end
