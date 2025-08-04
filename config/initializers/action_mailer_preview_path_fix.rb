# Fix for Rails 8.0 ActionMailer API change for tapioca compatibility
# Rails 8.0 changed preview_path= to preview_paths=
# This initializer provides backward compatibility for tools that expect the old API

# Define the method immediately when ActionMailer::Base is loaded
ActionMailer::Base.class_eval do
  def self.preview_path=(path)
    self.preview_paths = [path] if path
  end
end if defined?(ActionMailer::Base)