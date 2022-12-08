

Pod::Spec.new do |spec|


  spec.name         = "CWSDKTool"
  spec.version      = "0.0.9"
  spec.summary      = "CW工具库"


  spec.homepage     = "https://github.com/CWKJTeam/CWSDK"

  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  spec.author             = { "xiaojiabao" => "xiaojiabao@bianfeng.com" }
  # spec.social_media_url   = "https://twitter.com/xiaojiabao"

  spec.ios.deployment_target = '10.0'
 # spec.platform     = :ios, "10.0"

  spec.source       = { :git => "https://github.com/CWKJTeam/CWSDK.git", :tag => "#{spec.version}" }


  spec.source_files  = "Tool/**/*.{h,m}"

#--------文件分级---------------#
  #spec.subspec 'ClassCategory' do |ss|
  #ss.source_files = 'Tool/ClassCategory/*'
  #ss.dependency 'Tool'  依赖其他文件夹
  #end

  #spec.subspec 'TYDownloadManager' do |ss|
  #ss.source_files = 'Tool/TYDownloadManager/*'
  #end

  #spec.subspec 'WebServer' do |ss|
  #ss.source_files = 'Tool/WebServer/*'
  #end
#--------文件分级---------------#

  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }

  # spec.frameworks = "SomeFramework", "AnotherFramework"
  # spec.libraries = "iconv", "xml2"
  spec.dependency 'SDWebImage', '~> 5.12.1'
  spec.dependency 'MBProgressHUD', '0.9.1'
  spec.dependency 'CocoaHTTPServer', '~> 2.3'
  spec.dependency 'AFNetworking/Reachability', '~> 3.1.0'
  spec.dependency 'AFNetworking/Serialization', '~> 3.1.0'
  spec.dependency 'AFNetworking/Security', '~> 3.1.0'
  spec.dependency 'AFNetworking/NSURLSession', '~> 3.1.0'


end
