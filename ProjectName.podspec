Pod::Spec.new do |spec|
	spec.name = "<#ProjectName#>"
	spec.version = "<#1.0.0#>"
	spec.summary = "<#YOUR DESCRIPTION#>"
	spec.homepage = "<#YOUR HOMEPAGE#>"
	spec.license = {type: '<#YOUR LICENSE TYPE#>', file: '<#PATH TO YOUR LICENSE FILE#>'}
	spec.authors = {"<#YOUR NAME#>" => '<#YOUR EMAIL#>'}
	spec.social_media_url = "<#YOUR SOCIAL MEDIA URL#>"

	spec.requires_arc = true
	spec.source = {git: "<#GIT URL#>", <#BRANCH, TAG OR OTHER VERSION POINTER#>}
	spec.source_files = "Sources/<#ProjectName#>/*.swift"

	spec.ios.deployment_target = '8.0'
	spec.osx.deployment_target = '10.9'
	spec.tvos.deployment_target = '9.0'
	spec.watchos.deployment_target = '2.0'

#	spec.dependency "Example", "~> 1.4.0"
end
