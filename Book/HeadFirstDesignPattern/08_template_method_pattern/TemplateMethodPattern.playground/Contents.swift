import UIKit

protocol CaffeineBeverage {
    func brew()
    func addCondiments()
}

extension CaffeineBeverage {
    func prepareRecipe() {
        boilWater()
        brew()
        pourInCup()
        addCondiments()
    }
    func boilWater() {
        print("물 끓이는 중")
    }
    func pourInCup() {
        print("컵에 따르는 중")
    }
}

class Coffee: CaffeineBeverage {
    func brew() {
        print("필터로 커피 우려내는 중")
    }
    
    func addCondiments() {
        print("설탕과 우유를 추가하는 중")
    }
}

class Tea: CaffeineBeverage {
    func brew() {
        print("찻잎을 우려내는 중")
    }
    
    func addCondiments() {
        print("레몬을 추가하는 중")
    }
}

var coffee: Coffee = Coffee()
var tea: Tea = Tea()

coffee.prepareRecipe()

tea.prepareRecipe()


///템플릿 메소드로 정렬하는 법
class Person: Comparable {
    static func < (lhs: Person, rhs: Person) -> Bool {
        return lhs.weight < rhs.weight
    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.weight == rhs.weight && lhs.name == rhs.name
    }
    
    var name: String
    var weight: Int
    
    init(name: String, weight: Int) {
        self.name = name
        self.weight = weight
    }
}

var cheolsoo = Person(name: "cheolsoo", weight: 76)
var younghee = Person(name: "younghee", weight: 48)
var hooni = Person(name: "hooni", weight: 108)

var personList: [Person] = [cheolsoo, younghee, hooni]


personList.forEach {
    print($0.name)
}

/// sort()는 내부적으로 템플릿 메소드가 있고 그 안에 정렬 알고리즘이 들어있다.
/// 그러나 정렬 알고리즘이 온전히 동작하려면 대소관계를 리턴하는 메소드가 필요하다.
/// ArrayList의 서브클래스를 만들지 않고도 sort()를 모든 배열에서 쓸 수 있도록 하기 위해 정적메소드로 구현되어있음
/// Person을 배열의 ArrayList의 서브클래스로 만드는 대신 comparable 프로토콜을 따르도록 함으로써 정렬 알고리즘이 온전히 동작 할 수 있도록 완성 할 수 있음
personList.sort(by: >)

personList.forEach {
    print($0.name)
}
