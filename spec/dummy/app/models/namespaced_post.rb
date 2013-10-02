class NamespacedPost
  # Virtual class to use for private post actions with Permissions

  def self.build_permissions(perms, other, target)
    perms.permits! :read, :write
  end
end
