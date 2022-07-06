import UIKit



protocol FlyBehavior {
    func fly()
}

class FlyWithWings: FlyBehavior {
    func fly() {
        print("날개를 펄럭이며 오리가 날았다.")
    }
}

class FlyNoWay: FlyBehavior {
    func fly() {
        print("나는 날 수가 없어요. 날개가 없거든요.")
    }
}

protocol QuackBehavior {
    func quack()
}

class Quack: QuackBehavior {
    func quack() {
        print("꽉")
    }
}

class MuteQuack: QuackBehavior {
    func quack() {
        print("...")
    }
}
class Squeak: QuackBehavior {
    func quack() {
        print("삐익")
    }
}


class Duck {
    var flyBehavior: FlyBehavior
    var quackBehavior: QuackBehavior
    
    init(flyBehavior: FlyBehavior, quackBehavior: QuackBehavior) {
        self.flyBehavior = flyBehavior
        self.quackBehavior = quackBehavior
    }
    
    func setFlyBehavior(fb: FlyBehavior) {
        self.flyBehavior = fb
    }
    
    func setQuackBehavior(qb: QuackBehavior) {
        self.quackBehavior = qb
    }
    
    func performFly() {
        flyBehavior.fly()
    }
    
    func performQuack() {
        quackBehavior.quack()
    }
    
    func swim() {
        print("나는 오리 나는 물에 뜬다.")
    }
}


class MallardDuck: Duck {
    
    init() {
        let flyBehavior = FlyWithWings()
        let quackBehavior = Quack()

        super.init(flyBehavior: flyBehavior, quackBehavior: quackBehavior)
    }
    
}

class ModelDuck: Duck {
    init() {
        let flyBehavior = FlyNoWay()
        let quackBehavior = Quack()

        super.init(flyBehavior: flyBehavior, quackBehavior: quackBehavior)
    }
}

class FlyRocketPowered: FlyBehavior {
    func fly() {
        print("로켓을 타고 날아요")
    }
}

let mallard = MallardDuck()

mallard.performQuack()
mallard.performFly()

let model = ModelDuck()

model.performFly()

model.setFlyBehavior(fb: FlyRocketPowered())

model.performFly()

//오리 호출기 구현하기
class DuckSoundMaker {
    var quackBehavior: QuackBehavior
    
    init(quackBehavior: QuackBehavior) {
        self.quackBehavior = quackBehavior
    }
    
    func setQuackBehavior(qb: QuackBehavior) {
        self.quackBehavior = qb
    }
    
    func performQuack() {
        quackBehavior.quack()
    }
}

let duckSoundMaker = DuckSoundMaker(quackBehavior: Quack())

duckSoundMaker.performQuack()


