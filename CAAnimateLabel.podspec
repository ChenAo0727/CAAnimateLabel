

Pod::Spec.new do |s|


  s.name         = "CAAnimateLabel"
  s.version      = "1.1.0"
  s.summary      = "A label can animate and quick custom animation"

  s.homepage     = "https://github.com/ChenAo0727/CAAnimateLabel"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = "chenao"
  s.social_media_url   = "https://ChenAo0727.github.io"


  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'

  s.source       = { :git => "https://github.com/ChenAo0727/CAAnimateLabel.git", :tag => s.version }

  s.source_files  = "CAAnimateLabel/**/*.{h,m}"
  s.public_header_files = "CAAnimateLabel/**/*.h"

  # s.resource  = "icon.png"
   s.resources = "Resources/*.gif"

   s.frameworks = "CoreText"
   s.requires_arc = true
end
