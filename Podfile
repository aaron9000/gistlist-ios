platform :ios, '8.0'
inhibit_all_warnings!

def app_pods
	pod 'CocoaLumberjack'
	pod 'ObjectiveSugar'
	pod 'SSKeychain'
	pod 'CrittercismSDK'
	pod 'Mixpanel'
	pod 'OctoKit', :podspec => 'Octokit.podspec.json'
	pod 'SDWebImage', '~> 3.7'
	pod 'iRate', '~> 1.11'
	pod 'SVProgressHUD', '~> 1.1'
	pod 'ISO8601DateFormatter', '~> 0.7'
	pod 'WTAHelpers/WTAFrameHelpers', :git => 'git@github.com:willowtreeapps/WTAHelpers.git'
	pod 'VBFPopFlatButton', :podspec => 'VBFPopFlatButton.podspec.json'
end

def testing_pods
	use_frameworks!
    pod 'Quick', '~> 0.9'
    pod 'Nimble', '~> 4.0.0'
    pod 'OCMock'
end

target 'gistlistTests' do
	app_pods
    testing_pods
end

target "gistlist" do
	app_pods
end