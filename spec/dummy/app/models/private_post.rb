class PrivatePost
  # Virtual class to use for private post actions with Permissions

  def self.effective_permissions(other, target)
    Garage::Permissions.new(other) do |perms|
      perms.permits! :read, :write if target[:user] == other
    end
  end
end
