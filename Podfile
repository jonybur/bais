platform :ios, '10.0'
use_frameworks!

target 'Bais' do
  swift_version = "3.0"

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
	pod 'AsyncDisplayKit', '>= 2.0'

  # facebook
  pod 'FBSDKCoreKit', '>= 4.15.1'
  pod 'FBSDKLoginKit', '>= 4.15.1'
  pod 'FBSDKShareKit', '>= 4.15.1'

  # web requests
  pod 'Alamofire', '>= 4.0.0'
  pod 'SwiftyJSON', '>= 3.1.4'

  # chat
  #pod 'NMessenger'
  pod 'JSQMessagesViewController', :git => 'https://github.com/jessesquires/JSQMessagesViewController.git', :branch => 'develop'
  
  # to deprecate
  pod 'AwaitKit', '>= 2.0.0'
  pod 'ESTabBarController-swift',
    :git => 'https://github.com/jonybur/ESTabBarController.git'

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