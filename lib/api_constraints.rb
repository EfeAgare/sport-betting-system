class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default] || false
  end

  def matches?(req)
    @default || req.headers["Accept"]&.include?("application/vnd.your_app.v#{@version}")
  end
end
