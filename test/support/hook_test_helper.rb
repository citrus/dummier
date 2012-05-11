module HookTestHelper

  extend self

  def register(hook)
    hooks << hook
  end

  def hooks
    @hooks ||= []
  end

  def reset!
    @hooks = []
  end

end
