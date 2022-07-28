import UIKit

/**Enum**/
/// 연산 프로퍼티
print("\(Member.randomCase())")

/// 연관 값
var yonex = BadmintonRacketFormat.Yonex(weight: 81, price: 159000)

switch yonex {
case .Yonex(let weight, let price):
    print("\(weight)g - \(price)원")
case .Victon(let weight, let price):
    print("\(weight)g - \(price)원")
case .Jubong(let weight, let price):
    print("\(weight)g - \(price)원")
case .Natto(let weight, let price):
    print("\(weight)g - \(price)원")
case .Daiso(let weight, let price):
    print("\(weight)g - \(price)원")
}

/// 연관 값 + 연산 프로퍼티
var daiso = BadmintonRacketFormat.Daiso(weight: 106, price: 2500)
print("\(daiso.weight)g - \(daiso.price)원")

/// 연관 값 + 메소드
var victon = BadmintonRacketFormat.Victon(weight: 86, price: 219000)
var totalWeight = daiso.weightTogether(otherRacket: victon)
print("total wight \(totalWeight)g")


/**Tuptle**/
/// 이름 없는 튜플
let myProtein = ("choco", 23)
let (flavor, content) = myProtein
print("\(flavor) \(content)")
                 
/// 이름 있는 튜플
let myProtein2 = (flavor: "choco", content: 23)
print("\(myProtein2.flavor) \(myProtein2.content)")
                 
/// 함수에서 여러 값 반환 할 때 튜플로 반환하기
func calculateTip(billAmount: Double, tipPercent: Double)
-> (tipAmount: Double, totalAmount: Double) {
    let tip = billAmount * (tipPercent/100)
    let total = billAmount + tip
    return (tipAmount: tip, totalAmount: total) //튜플로 반환
}

var tip = calculateTip(billAmount: 10000.0, tipPercent: 10)
print("\(tip.tipAmount) \(tip.totalAmount)") //튜플 내부 정보 접근

/// 튜플에 별칭을 부여해서 타입으로 만들기
typealias AliasTuple = (tipAmount: Double, total: Double) //별칭 부여

let myTuple: AliasTuple = (1000.0, 11000.0)
print("\(myTuple.tipAmount)")

