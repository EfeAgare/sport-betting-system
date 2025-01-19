class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default] || false
  end

  def matches?(req)
    @default || req.headers["Api-Version"]&.to_i == @version
  end
end
