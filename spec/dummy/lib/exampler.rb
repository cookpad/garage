class Exampler
  attr_reader :controller

  def initialize(controller)
    @controller = controller
  end

  def examples_for(klass)
    examples = []
    case klass
    when "User"
    when "Post"
      examples << controller.main_app.posts_path
      examples << current_user.posts.first
    end
    examples
  end

  private
  def current_user
    controller._current_user
  end
end
