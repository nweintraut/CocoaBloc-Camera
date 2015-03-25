Pod::Spec.new do |s|
  s.name             = "CocoaBloc-Camera"
  s.version          = "0.1.0"
  s.summary          = "StageBloc's iOS camera components"
  s.description      = "An iOS UI framework for StageBloc photo/video composition"
  s.homepage         = "https://github.com/stagebloc/CocoaBloc-Camera"

  s.license          = 'MIT'
  s.authors = {   'John Heaton'   => 'pikachu@stagebloc.com',
                  'Mark Glagola'  => 'mark@stagebloc.com',
                  'David Warner'  => 'spiderman@stagebloc.com',
                  'Josh Holat'    => 'bumblebee@stagebloc.com' }
  s.source  = { :git => "https://github.com/stagebloc/CocoaBloc-Camera.git" }
  s.social_media_url = 'https://twitter.com/stagebloc'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CocoaBloc-Camera' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
