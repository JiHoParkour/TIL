import Foundation

public class Troll: Character {

    public init() {
        
        let knifeBehavior = KnifeBehavior()

        super.init(weapon: knifeBehavior)
    }

}

