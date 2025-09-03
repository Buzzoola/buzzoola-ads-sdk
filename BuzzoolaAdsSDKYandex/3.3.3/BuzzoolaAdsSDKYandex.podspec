#
#  Be sure to run `pod spec lint BuzzoolaAdsSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name             = 'BuzzoolaAdsSDKYandex'
  s.version          = '3.3.3'
  s.summary          = 'Mobile SDK for Ads'
  s.swift_version    = '5.0'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://gitlab.services.mts.ru/mts-ads/sdk/mts-ads-sdk-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'eskorotaeva' => 'ekorotaeva@mts.ru' }
  s.source           = { :git => 'https://github.com/Buzzoola/buzzoola-ads-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.static_framework = true
  s.requires_arc = true

  s.source_files = 'Source/**/*.swift'
  s.dependency 'YandexMobileAds', '~> 7.15'
  s.dependency 'BuzzoolaAdsSDK', '3.3.3'

end
