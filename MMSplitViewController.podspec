Pod::Spec.new do |s|
  s.name         = "MMSplitViewController"
  s.version      = "0.0.5"
  s.summary      = "An interactive split interface."
  s.homepage     = "https://matias.ma/"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Matías Martínez" => "soy@matmartinez.net" }
  s.source       = { :git => "https://github.com/matmartinez/MMSplitViewController.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.framework  = 'QuartzCore'
  s.requires_arc = true
  s.source_files = 'Classes/*.{h,m}'
  s.resources = 'Images/*.png'
 end