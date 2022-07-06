import UIKit


let king = King()

king.attack()


let axeBehavior = AxeBehavior()

king.setWeapon(w: axeBehavior)

king.attack()

let bowAndArrowBehavior = BowAndArrowBehavior()
let infestedKing = King(w: bowAndArrowBehavior)

infestedKing.attack()

let troll = Troll()


troll.attack()
