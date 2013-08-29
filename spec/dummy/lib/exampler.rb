class Exampler
  attr_reader :controller

  def initialize(controller)
    @controller = controller
  end

  def examples_for(klass)
    case klass
    when "user"
      [controller.main_app.users_path, current_user]
    when "post"
      [controller.main_app.posts_path, Post.first]
    else
      []
    end
  end

  private
  def current_user
    controller._current_user
  end
end
