Pod::Spec.new do |s|

  s.name                 = "MGFilterFactory"
  s.version              = "0.0.4"
  s.summary              = "Filters"
  s.homepage             = "https://github.com/mgzf/MGFilterFactory"
  s.license              = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Harly" => "magic_harly@hotmail.com" }
  s.platform             = :ios, "8.0"
  s.source               = { :git => "https://github.com/mgzf/MGFilterFactory", :tag => s.version }
  s.source_files          = "MogoFilterFactoryDemo/FilterFactory/*.{h,m,swift,xib}"
  #s.resources          = "LPPushService/Images/*.png"
  s.dependency             "RxSwift"
                           "RxCocoa"
  s.requires_arc         = true

end
