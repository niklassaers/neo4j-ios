Pod::Spec.new do |s|
  s.name         = "Theo"
  s.version      = "4.0.0"
  s.summary      = "Open Source Neo4j library for iOS"

  s.description  = <<-DESC
    Theo is an open-source framework written in Swift that provides an interface for interacting with Neo4j.

    Features:
    - CRUD operations for Nodes and Relationships
    - Transaction statement execution
    - Bolt support
DESC

  s.homepage     = "https://github.com/Swift-Neo4j/neo4j-ios"
  s.license      = { :type => "MIT", :file => "LICENSE" }


  s.authors             = { "Niklas Saers" => "niklas@saers.com",
                            "Cory Wiles" => "corywiles@icloud.com" }

  s.source       = { :git => "https://github.com/Swift-Neo4j/neo4j-ios.git", :tag => "#{s.version}" }

  s.source_files  = "Classes", "Sources/**/*.swift"
  
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  s.tvos.deployment_target = "10.0"
  
  s.dependency 'BoltProtocol', '~> 1.0.0'
  s.dependency 'Result', '~> 3.2.4'
  
end
