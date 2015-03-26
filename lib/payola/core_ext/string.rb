class String
  def constantize
    names = split('::')
    names.shift if names.empty? || names.first.empty?

    constant = Object
    names.each do |name|
      constant = if constant.const_defined?(name)
                   constant.const_get(name)
                 else
                   constant.const_missing(name)
                 end
    end
    constant
  end
end
