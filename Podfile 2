source "https://github.com/CocoaPods/Specs.git"

inhibit_all_warnings!
use_frameworks!
platform :ios, "9.0"

def shared_pods
  pod "Planet"
  pod "Alamofire", "~> 4.2.0"
  pod "AlamofireImage", "~> 3.2.0"
  pod "SimpleKeychain", "~> 0.7.0"
  pod "Locksmith", "~> 3.0.0"
  pod "DateTools", "~> 1.7.0"
  pod "FontAwesomeKit", "~> 2.2.0"
  pod "FBSDKCoreKit", "~> 4.37.0"
  pod "FBSDKShareKit", "~> 4.37.0"
  pod "FBSDKLoginKit", "~> 4.37.0"
  pod "Flurry-iOS-SDK", "~> 7.8.2"
  pod "Fabric", "~> 1.6.11"
  pod "Crashlytics", "~> 3.8.3"
  pod "SVWebViewController", "~> 1.0"
  pod 'FacebookCore','0.5.0'
  pod 'FacebookLogin','0.5.0'
  pod 'FacebookShare','0.5.0'
  pod 'YouTubePlayer'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  
  pod 'HCVimeoVideoExtractor'
  pod 'SwiftyJSON'
  
end

target "iList Ambassador" do
  shared_pods
end

target "iList Ambassador Dev" do
  shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
