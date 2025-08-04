# Fix for Rails 8.0 ActionMailer API change for tapioca compatibility
# Rails 8.0 changed preview_path= to preview_paths=
# This initializer provides backward compatibility for tools that expect the old API

if Rails.version.start_with?('8.')
  class ActionMailer::Base
    def self.preview_path=(path)
      self.preview_paths = [path] if path
    end
  end
end