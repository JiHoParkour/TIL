import Foundation

public class Character {
    
    var weapon: WeaponBehavior
    
    public init(weapon: WeaponBehavior) {
        self.weapon = weapon
    }
  
    public func setWeapon(w: WeaponBehavior) {
        self.weapon = w
    }
    
    public func fight() {

    }
    
    public func attack() {
        weapon.useWeapon()
    }
}
