

Pod::Spec.new do |spec|


  spec.name         = "CWTool"
  spec.version      = "0.0.1"
  spec.summary      = "CW工具库"


  spec.homepage     = "https://github.com/CWKJTeam/CWSDK"

  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  spec.author             = { "xiaojiabao" => "xiaojiabao@bianfeng.com" }
  # spec.social_media_url   = "https://twitter.com/xiaojiabao"

  spec.ios.deployment_target = '10.0'
 # spec.platform     = :ios, "10.0"

  spec.source       = { :git => "https://github.com/CWKJTeam/CWSDK.git", :tag => "#{spec.version}" }


  spec.source_files  = "ios-template/Tool/**/*.{h,m}"

  # spec.frameworks = "SomeFramework", "AnotherFramework"
  # spec.libraries = "iconv", "xml2"
  spec.dependency 'SDWebImage', '~> 5.12.1'
  spec.dependency 'MBProgressHUD', '0.9.1'
  #spec.dependency 'CocoaHTTPServer', '~> 2.3'
  spec.dependency 'AFNetworking', '~> 3.1.0'


end
