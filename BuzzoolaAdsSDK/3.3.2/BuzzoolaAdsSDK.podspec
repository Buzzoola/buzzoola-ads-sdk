#
#  Be sure to run `pod spec lint BuzzoolaAdsSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name             = 'BuzzoolaAdsSDK'
  s.version          = '3.3.2'
  s.summary          = 'Mobile SDK for Ads'
  s.swift_version    = '5.0'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://gitlab.services.mts.ru/mts-ads/sdk/mts-ads-sdk-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'eskorotaeva' => 'ekorotaeva@mts.ru' }
  s.source           = { :http => 'https://ru-msk-1.store.cloud.mts.ru/monetization.download/repository/ios-sdk/BuzzoolaAdsSDK_3.3.2.zip', :type => 'zip' }

  s.ios.deployment_target = '13.0'
  s.static_framework = true
  s.requires_arc = true

  s.subspec 'BuzzoolaAdsSDK' do |ss|
    ss.vendored_frameworks = 'BuzzoolaAdsSDK/BuzzoolaAdsSDK.xcframework'

    ss.dependency 'SDWebImage', '~> 5.20'
    ss.dependency 'DeviceKit', '~> 5.5'
  end

  s.subspec 'BuzzoolaAdsSDKAnalytics' do |ss|
    ss.vendored_frameworks = 'BuzzoolaAdsSDK/BuzzoolaAdsSDKAnalytics.xcframework'
    ss.dependency 'MTAnalytics', '~> 5.0'
  end

  s.subspec 'BuzzoolaAdsSDKMyTarget' do |ss|
    ss.vendored_frameworks = 'BuzzoolaAdsSDK/BuzzoolaAdsSDKMyTarget.xcframework'
    ss.dependency 'myTargetSDK', '~> 5.29'
  end

end
