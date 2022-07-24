import UIKit

/// 슈퍼클래스 Beverage 클래스
protocol Beverage {
    
    var description: String { get }
    
    func getDescription() -> String
    
    func cost() -> Double
}
/// 기본구현
extension Beverage {
    var description: String {
        return "제목 없음"
    }
    
    func getDescription() -> String {
        return description
    }
}

/// 첨가물 클래스
protocol CondimentDecorator: Beverage {
    var beverage: Beverage { get }
    func getDescription() -> String
}
/// Beverage 클래스의 구상 클래스
class Espresso: Beverage {
    var description: String
    
    init () {
        self.description = "에스프레소"
    }

    
    func cost() -> Double {
        return 1.99
    }
}

class HouseBlend: Beverage {
    var description: String
    
    init () {
        self.description = "하우스 블렌드 커피"
    }

    
    func cost() -> Double {
        return 0.89
    }
}

class DarkRoast: Beverage {
    var description: String
    
    init () {
        self.description = "다크로스트 커피"
    }

    
    func cost() -> Double {
        return 0.99
    }
}

class Decaf: Beverage {
    var description: String
    
    init () {
        self.description = "디카페인 커피"
    }

    
    func cost() -> Double {
        return 1.99
    }
}

/// 첨가물 클래스의 구상 클래스
class Mocha: CondimentDecorator {
    
    var beverage: Beverage
    
    var description: String
    
    init(beverage: Beverage) {
        self.beverage = beverage
        self.description = "모카"
    }
    
    func cost() -> Double {
        return beverage.cost() + 0.20
    }
    
    func getDescription() -> String {
        return beverage.getDescription() + ", \(self.description)"
    }
   
    
}

class Soy: CondimentDecorator {
    
    var beverage: Beverage
    
    var description: String
    
    init(beverage: Beverage) {
        self.beverage = beverage
        self.description = "두유"
    }
    
    func cost() -> Double {
        return beverage.cost() + 0.15
    }
    
    func getDescription() -> String {
        return beverage.getDescription() + ", \(self.description)"
    }
    
}

class Whip: CondimentDecorator {
    
    var beverage: Beverage
    
    var description: String
    
    init(beverage: Beverage) {
        self.beverage = beverage
        self.description = "휘핑크림"
    }
    
    func cost() -> Double {
        return beverage.cost() + 0.10
    }
    
    func getDescription() -> String {
        return beverage.getDescription() + ", \(self.description)"
    }
   
    
}

class Milk: CondimentDecorator {
    
    var beverage: Beverage
    
    var description: String
    
    init(beverage: Beverage) {
        self.beverage = beverage
        self.description = "우유"
    }
    
    func cost() -> Double {
        return beverage.cost() + 0.10
    }
    
    func getDescription() -> String {
        return beverage.getDescription() + ", \(self.description)"
    }
   
    
}

let beverage = Espresso()
print("\(beverage.getDescription()) $\(beverage.cost())")

var beverage2: Beverage = DarkRoast()
beverage2 = Mocha(beverage: beverage2)
beverage2 = Mocha(beverage: beverage2)
beverage2 = Whip(beverage: beverage2)
print("\(beverage2.getDescription()) $\(beverage2.cost())")

var beverage3: Beverage = HouseBlend()
beverage3 = Soy(beverage: beverage3)
beverage3 = Mocha(beverage: beverage3)
beverage3 = Whip(beverage: beverage3)
print("\(beverage3.getDescription()) $\(beverage3.cost())")

