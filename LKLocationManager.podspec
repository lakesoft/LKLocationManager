Pod::Spec.new do |s|
  s.name         = "LKLocationManager"
  s.version      = "1.1.0"
  s.summary      = "Core Location Library"
  s.description  = <<-DESC
Location Library to get location easily. And Supports reverse Geo cording.
                   DESC
  s.homepage     = "https://github.com/lakesoft/LKLocationManager"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Hiroshi Hashiguchi" => "xcatsan@mac.com" }
  s.source       = { :git => "https://github.com/lakesoft/LKLocationManager.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Classes/*'
  s.resource = "Resources/LKLocationManager-Resources.bundle"

end
