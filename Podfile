platform :ios, '10.0'
use_frameworks!

target 'Bais' do
  swift_version = "3.0"

  # developer tools
  pod 'Fabric'
  pod 'Crashlytics'

  # firebase pods
  pod 'Firebase'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Storage'
  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'
  
  # layout
  #pod 'Hero', '>= 0.1.3'
  pod 'pop'
  pod 'DGActivityIndicatorView'
	pod 'AsyncDisplayKit', '>= 2.1'
  pod 'ESTabBarController-swift', :git => 'https://github.com/jonybur/ESTabBarController.git'

  # facebook
  pod 'FBSDKCoreKit', '>= 4.15.1'
  pod 'FBSDKLoginKit', '>= 4.15.1'
  pod 'FBSDKShareKit', '>= 4.15.1'

  # web requests
  pod 'Alamofire', '>= 4.0.0'
  pod 'SwiftyJSON', '>= 3.1.4'
  pod 'PromiseKit', '~> 4.0'

  # utilities
  pod 'CountryPicker', '>= 1.3'

  # chat
  pod 'NMessenger', :git => 'https://github.com/jonybur/nmessenger.git', :branch => 'asdk-2.1'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'GeoFire' then
      target.build_configurations.each do |config|
        config.build_settings['FRAMEWORK_SEARCH_PATHS'] = "#{config.build_settings['FRAMEWORK_SEARCH_PATHS']} ${PODS_ROOT}/FirebaseDatabase/Frameworks/ $PODS_CONFIGURATION_BUILD_DIR/GoogleToolboxForMac"
        config.build_settings['OTHER_LDFLAGS'] = "#{config.build_settings['OTHER_LDFLAGS']} -framework FirebaseDatabase"
      end
    end
  end
end