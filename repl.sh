gem uninstall -aIx github-markup 
rake build
gem install --no-ri --no-rdoc pkg/github-markup*.gem
