Platform2.configure do
  ability do
    can :list, Post
    can :show, Post
    can [:edit, :delete], Post do |post|
      post.user_id == user.id
    end
  end
end

require 'exampler'
Platform2::Docs.config do |c|
  c.exampler = lambda {|controller, klass| Exampler.new(controller).examples_for(klass) }
end
