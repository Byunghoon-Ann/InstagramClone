import UIKit
final class DirtyWordCenter {
    
    static let shread  = DirtyWordCenter()
    private init() { }
    
    func searchDirtyWord(_ comment: String) -> Bool {
        let contents = comment.components(separatedBy: " ")
        for i in contents {
            if  engBadWords.contains(i) == true || krBadWords.contains(i) == true {
                return false
            }
        }
        return true
    }
    
   
}
