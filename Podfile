platform :ios, '17.0'

target '1 Ice Maker Lab' do
  use_frameworks!

  # Pods for 1 Ice Maker Lab
  # Adjust is linked via local SPM: Packages/ios_sdk
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end
