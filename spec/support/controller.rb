class Controller
  class << self
    def before_actions
      @before_actions ||= []
    end

    def before_action(*args)
      self.before_actions << args
    end
  end

  attr_accessor :request

  def initialize(request)
    self.request = request
    self.class.before_actions.each do |name, *|
      send name
    end
  end
end
