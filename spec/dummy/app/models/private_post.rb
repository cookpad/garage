class PrivatePost
  # Virtual class to use for private post actions with Permissions

  def self.build_permissions(perms, other, target)
    perms.permits! :read, :write if target[:user] == other
  end
end
