import Foundation

public class King: Character {
    
    public init() {
        let sb = SwordBehavior()
        super.init(weapon: sb)
    }
    
    public init(w: WeaponBehavior) {
        super.init(weapon: w)
    }
    
}
