# MyLearningsiOS

SwiftUI
- sheet presentation
    screen size adjusting -> .presentationDetents([.height(300), .medium])
- UIRepresentable to create UIkit views in SwiftUI
      - for creating gesture recognition create a coordinator class inside the UIRepresentable.(refer twitter animation swiftui)

  Animation in UIKit
      - UIView.animate(withDuration: <#T##TimeInterval#>, animations: <#T##() -> Void#>)

  Select views based on tags
      - first assign views/buttons with tags in storyboard
      - next create those things in code
          for example: - set of buttons with tags
                          if let button = view.viewWithTag(i) as? UIButton{
                                button.configuration?.image = nil
                            }
    
