platform :ios, '10.0'
use_frameworks!

target 'Bais' do
  swift_version = "3.0"

  pod 'pop'
  pod 'DGActivityIndicatorView'
  pod 'JSQSystemSoundPlayer'
  
  pod 'Firebase'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'

  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'

	pod 'AsyncDisplayKit', '>= 2.0'
  pod 'FBSDKCoreKit', '>= 4.15.1'
  pod 'FBSDKLoginKit', '>= 4.15.1'
  pod 'FBSDKShareKit', '>= 4.15.1'
  pod 'Alamofire', '>= 4.0.0'
  pod 'SwiftyJSON', '>= 3.1.4'

  # take out AwaitKit, ESTabBarController
  pod 'AwaitKit', '>= 2.0.0'
  
  pod 'JSQMessagesViewController', :git => 'https://github.com/jessesquires/JSQMessagesViewController.git',
    :branch => 'develop'
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