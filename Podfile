# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'PlatziTweets' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PlatziTweets
  pod 'NotificationBannerSwift', '~> 3.0.0'
  pod 'KeychainSwift'
  pod 'SVProgressHUD'
  pod 'Simple-Networking', '~> 0.3.2'
  pod 'Kingfisher', '~> 5.0'
  pod 'Firebase/Storage'
  pod 'Firebase/Analytics'
  pod 'FirebaseCrashlytics'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
        end
    end
end
