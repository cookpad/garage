Platform2.configure do
  ability do
    can :show, Post
    can [:edit, :delete], Post do |post|
      post.user_id == user.id
    end
  end
end
