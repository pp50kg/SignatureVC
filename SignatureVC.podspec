Pod::Spec.new do |s|
s.name         = "SignatureVC"
s.version      = "1.0"
s.summary      = "A library to generate SignatureVC"
s.homepage     = "https://github.com/pp50kg/SignatureVC"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author       = { "AdamPP" => "adamhsuapple@gmail.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/pp50kg/SignatureVC.git", :tag => s.version }
s.source_files = "SignatureVC/**/*.{h,m}"
s.resource = "SignatureVC/**/*.{xib,json,bundle}"
s.requires_arc = true
s.swift_version = '4.0'
end
