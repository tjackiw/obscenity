module Obscenity
  class Error < RuntimeError; end

  class UnknownContent     < Error; end
  class UnknownContentFile < Error; end
  class EmptyContentList  < Error; end
end
