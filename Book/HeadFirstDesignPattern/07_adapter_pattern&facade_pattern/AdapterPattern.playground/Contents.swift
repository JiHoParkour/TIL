import UIKit

protocol Duck {
    func quack()
    func fly()
}

class MallardDuck: Duck {
    func quack() {
        print("오리 꽥꽥")
    }
    
    func fly() {
        print("푸드덕푸드덕")
    }
}


protocol Turkey {
    func gobble()
    func fly()
}



class WildTurkey: Turkey {
    func gobble() {
        print("칠면조 골골")
    }
    
    func fly() {
        print("날개가 아파서 나는둥 마는둥")
    }
    
}

/// 칠면조 객체를 오리 객체 대신 쓸 수 있게 변환해주는 어댑터 클래스
class TurkeyAdapter: Duck {
    
    var turkey: Turkey
    
    init(turkey: Turkey) {
        self.turkey = turkey
    }
    
    func quack() {
        turkey.gobble()
    }
    
    func fly() {
        for _ in 0..<5 {
            turkey.fly()
        }
    }

}

func testDuck(duck: Duck) {
    duck.quack()
    duck.fly()
}

var duck = MallardDuck()
var turkey = WildTurkey()
var turkeyAdapter = TurkeyAdapter(turkey: turkey)

print("오리가 왈")
duck.quack()
duck.fly()

print("칠면조 왈")
turkey.gobble()
turkey.fly()

print("칠면조 어댑터 왈")
turkeyAdapter.quack()
turkeyAdapter.fly()


/// 반대로 오리 객체를 칠면조객체 대신 쓸 수 있게 해주는 어댑터
class DuckAdapter: Turkey {
    
    var duck: Duck
    
    init(duck: Duck) {
        self.duck = duck
    }
    
    func gobble() {
        duck.quack()
    }
    
}

extension Turkey {
    func fly() {
        print("무거워서 나는둥 마는둥")
    }
}

var duckAdapter = DuckAdapter(duck: duck)

print("오리 어댑터 왈")
duckAdapter.gobble()
duckAdapter.fly()





/// 클래스 어댑터 맛보기 - 객체 어댑터처럼 구성을 사용하지 않고 다중 상속을 사용해야하지만 스위프트니까 프로토콜 다중 채택과 프로토콜 확장으로 비슷하게 구현
protocol Target {
    func request()
}

class ConcreteTarget: Target {
    
}

extension Target {
    func request() {
        print("target request")
    }
}
protocol Adaptee {
    func specificRequest()
}

class ConcreteAdaptee: Adaptee {
    
}

extension Adaptee {
    func specificRequest() {
        print("adapted request")
    }
}

class Adapter: Target, Adaptee {
    func request() {
        specificRequest()
    }
}

var target = ConcreteTarget()
var adaptee = ConcreteAdaptee()

print("target 왈")
target.request()

print("adaptee 왈")
adaptee.specificRequest()

var adapter = Adapter()
print("adapter 왈")
adapter.request()
adapter.specificRequest()
