

Pod::Spec.new do |spec|



  spec.name         = "EmbddedInVCSDK"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of EmbddedInVCSDK."

  
  spec.description  = "A short description of EmbddedInVCSDK."

  spec.homepage     = "https://github.com/Sowjanyappl/EmbddedInVCSDK.git"

  spec.license      = "MIT"

  spec.author             = { "Sowjanyappl" => "https://github.com/Sowjanyappl/EmbddedInVCSDK.git" }

 


  spec.source       = { :git => "https://github.com/Sowjanyappl/EmbddedInVCSDK.git", :tag => "#{spec.version}" }


 
  

  spec.source_files  = "Classes", "Classes/**/*.{h}"
  spec.exclude_files = "Classes/Exclude"

     spec.dependency "Alamofire"

end
