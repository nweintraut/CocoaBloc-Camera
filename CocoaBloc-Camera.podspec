pod_version = '0.2.0'

Pod::Spec.new do |s|
    s.name             = "CocoaBloc-Camera"
    s.version          = pod_version
    s.summary          = "StageBloc's iOS camera components"
    s.description      = "An iOS UI framework for StageBloc photo/video composition"
    s.homepage         = "https://github.com/stagebloc/CocoaBloc-Camera"

    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.authors = {   'John Heaton'   => 'pikachu@stagebloc.com',
                    'Mark Glagola'  => 'mark@stagebloc.com',
                    'David Warner'  => 'spiderman@stagebloc.com',
                    'Josh Holat'    => 'bumblebee@stagebloc.com' }
    s.source  = { :git => "https://github.com/stagebloc/CocoaBloc-Camera.git", :tag => pod_version }
    s.social_media_url = 'https://twitter.com/stagebloc'

    s.platform     = :ios, '8.0'
    s.requires_arc = true
    s.module_name = 'CocoaBlocCamera'

    s.dependency 'pop', '~> 1.0'
    s.dependency 'ReactiveCocoa', '~> 2.0'
    s.dependency 'PureLayout', '~> 2.0'

    s.dependency 'CocoaBloc-UI', '~> 0.0.5'

    s.source_files = 'Pod/Classes/**/*'
    s.resources = ['Pod/Assets/*']

end
