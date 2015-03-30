Pod::Spec.new do |s|
  s.name             = "CocoaBloc-Camera"
  s.version          = "0.1.1"
  s.summary          = "StageBloc's iOS camera components"
  s.description      = "An iOS UI framework for StageBloc photo/video composition"
  s.homepage         = "https://github.com/stagebloc/CocoaBloc-Camera"

  s.license          = 'MIT'
  s.authors = {   'John Heaton'   => 'pikachu@stagebloc.com',
                  'Mark Glagola'  => 'mark@stagebloc.com',
                  'David Warner'  => 'spiderman@stagebloc.com',
                  'Josh Holat'    => 'bumblebee@stagebloc.com' }
  s.source  = { :git => "https://github.com/stagebloc/CocoaBloc-Camera.git", :tag => "0.1.1" }
  s.social_media_url = 'https://twitter.com/stagebloc'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.dependency 'pop'
  s.dependency 'ReactiveCocoa'
  s.dependency 'PureLayout'

  s.dependency 'CocoaBloc-UI'

  s.source_files = 'Pod/Classes/**/*'
  s.private_header_files = "Pod/Classes/Misc/*.h"
  s.resource_bundles = {
    'CocoaBloc-Camera' => ['Pod/Assets/*.png']
  }

end
