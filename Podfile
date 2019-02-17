# Uncomment the next line to define a global platform for your project
platform :ios, '12.1'

target 'BattleBombs' do

  use_frameworks!
  
  pod 'Celer', :git => 'https://github.com/celer-network/CelerPod.git'
  pod 'QRCode'
  pod 'CryptoSwift'
  pod 'SwiftKeychainWrapper'
  pod 'web3swift'
  
  target 'BattleBomberMessage' do
    inherit! :search_paths    
  end
  
  target 'BattleBombsTests' do
    inherit! :search_paths
  end

  target 'BattleBombsUITests' do
    inherit! :search_paths
  end

end




post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
