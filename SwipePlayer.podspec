Pod::Spec.new do |s|

  s.name         = "GraphQLClient"
  s.version      = "1.0.0"
  s.summary      = "This framework provide to connect a server supporting GraphQL and fetch data formated JSON."

  s.homepage     = "https://serkanhocam.com/"
  s.license      = "Serkan Kayaduman"
  s.author       = { "Serkan Kayaduman"=>"serkankayaduman@hotmail.com"}
  s.platform     = :ios
  s.swift_version = "5.0"
  s.ios.deployment_target = "16.2"
  s.source       = { :git => "https://github.com/SerkanHocam/GraphQL_Client.git", :tag => s.version }
  s.source_files = "GraphQLClient/GraphQLClient/GraphQL.swift"
  s.frameworks   = "UIKit"
end