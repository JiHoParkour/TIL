#2장 타입 선택

대다수 객체지향 프로그래밍 언어에서 객체의 청사진으로 참조 타입인 클래스를 생성함

스위프트는 다른 객체지향 언어와 달리 구조체에 클래스와 동일한 기능이 많고 값 타입이다.

애플은 구조체를 사용할 것을 권장하는데 그 이유를 알아보고 여러 타입의 장단점을 알아보자.

스위프트는 타입을 이름 있는 타입과 복합 타입으로 분류함

이름 있는 타입은 클래스, 구조체, 열거형, 프로토콜 뿐 아니라 스위프트 표준 라이브러리에 배열, 셋, 딕셔너리 등도 포함되는구나

다른 언어의 원시 타입을 스위프트에서는 구조체를 사용해 구현해 놓았기 때문에 확장을 사용해 타입의 행위를 확장 할 수 있다. 이는 이런 이름 있는 타입을 확장 하는 능력은 프로토콜 지향 언어가 갖는 특징. 그래서 String을 extension해서 쓸 수 있었구나

복합 타입은 함수(클로저, 함수, 메소드)와 튜플이 있다. 함수와 메소드차이가 뭐지? 우선 함수는 여러 문장들이 하나의 기능을 하도록 구성 한 것인데 이게 클래스 내부에 정의되면 메소드라고 불림

튜플 타입은 예전에 본 적 있는데 (prop1, prop2, …) 같은 형식이었음

typealias는 복합 타입에 별칭을 부여해 별칭으로 호출 할 수 있도록 해주는구나. 이름 있는 타입은 안되나보다.

타입은 다시 두가지 범주로 나뉨. 참조 타입과 값 타입. 클래스는 참조 타입이기 때문에 변수에 인스턴스를 할당하면 스택 영역에는 인스턴스가 참조하고 있는 메모리의 주소가 할당되고 실제 데이터는 힙 영역에 할당됨. 변수를 복사하면 같은 가리키는 주소가 복사되기 때문에 원본과 복사본이 같은 인스턴스를 공유하게 됨. 구조체는 값 타입이기 때문에 변수에 인스턴스를 할당 하면 스택 영역에 값이 할당됨. 변수를 복사하면 원본에 영향을 주지 않는 복사본이 생성됨

클래스 외 구조체, 열거형, 튜플 등이 값타입에 속함

즉 스위프트에서 모든 타입은 이름 있는 타입 / 복합 타입 중 하나 이면서 프로토콜을 제외하고는 참조 타입 / 값 타입 중 하나임.(프로토콜은 인스턴스 생성 불가하니까)

## 클래스

클래스는 객체의 프로퍼티와 메소드, 생성자를 단일 타입으로 캡슐화 해주는 일종의 구성체구나

클래스는 이름 있는 타입이면서 참조 타입이기도 하다.

## 구조체

애플이 값 타입을 선호하라고 하는데 실제로 스위프트 표준 라이브러리를 보면 구조체를 사용해서 타입 대부분을 구현함. 이게 가능한 건 구조체가 클래스와 유사한 점이 많기 때문

따라서 구조체 역시 인스턴스의 프로퍼티와 메소드, 생성자를 단일 타입으로 캡슐화 해주는 일종의 구성체라고 정의할 수 있음

구조체는 클래스와 다르게 생성자를 정의하지 않으면 기본 생성자를 제공한다.

구조체는 값 타입이기 때문에 인스턴스 내부 메소드에서 구조체 프로퍼티 값을 변경하려면 mutating키워드를 사용해야함

클래스와 차이점은 값 타입이라는 것

## 접근 제어

접근 제어는 내부 코드를 외부의 접근으로 부터 제한한다.

접근제어자 키워드는 외부에서 내부 프로퍼티나 메소드 그리고 생성자에 접근 할 수 있는 단계를 부여 함

다섯 가지의 단계가 있다.

Open : 외부 모듈에서 접근 가능하며 상속이나 오버라이딩 또한 가능

Public : 외부 모듈에서 접근 가능

Internal(default) : 모듈 내부 어디서든 접근 가능

Fileprivate : 해당 파일 내부에서만 접근 가능

Private : 정의된 범위 내에서만 접근 가능

접근제어 시 제한 사항이 있는데 상위 요소보다 하위 요소가 더 높은 접근 수준을 가질 수 없다는 것.

ex) 메소드에서 인자나 반환 타입의 접근 단계가 private인 경우 외부코드가 private에 접근 할 수 없기 때문에 해당 메소드는 public으로 설정 할 수 없음

클래스의 접근 단계가 private인 경우 메소드나 프로퍼티의 접근 단계를 public으로 설정 할 수 없음

## 열거형

대부분 언어에서는 요소라 불리는 이름 있는 값으로 구성된 데이터 타입에 지나지 않지만

스위프트 열거형은 기능 면에서 클래스와 구조체에 가까운 속성을 지니고 있다.

열거형을 클래스나 구조체처럼 사용 할 수 있다는 말인지? 그래서 이점이 뭔지 알아보자

일반적인 사용 예

```swift
enum Devices {
	case Ipod
	case Iphone
	case Ipad
}
```

1. 각 값에 원시 값(raw values)을 부여 할 수 있다.

```swift
enum Devices {
	case IPod = "iPod"
	case IPhone = "iPhone"
	case IPad = "iPad"
}

Devices.IPod.rawValue // "iPod"
```

1. 케이스값 옆에 연관 값(associated values)를 저장 할 수 있다. 케이스 타입에 정보를 추가 저장 할 수 있게 됨

```swift
enum Devices {
	case Ipod(model: Int, year: Int, memory: Int)
	case Iphone(model: String, memory: Int)
	case Ipad(model: String, memory: Int)
}

//연관 값 저장하기
var myPhone = Devices.IPhone(model: "iPhone13pro", memory: 256)
var myTablet = Devices.IPad(model: "air", memory: 1024)

switch myPhone {
	case .IPod(let model, let year, let memory):
		print("iPod: \(model) \(memory)") //연관 값 가져오기
	case .IPhone(let model, let memory):
		print("iPhone: \(model) \(memory)") // "iPhone: iPhone13pro 256"
	case .IPad(let mode, let memory):
		print("iPad: \(model) \(memory)")
}
```

1. 클래스나 구조체처럼 연산 프로퍼티나 생성자 또는 메소드를 가질 수 있다.

```swift
Playground에 작성
```

연산 프로퍼티를 사용 하면 번거로운 연관 값 검색을 닷 문법으로 쉽게 할 수 있다.

메소드를 추가해서 다른 인스턴스와의 상호작용도 처리할 수 있다.

스위프트의 열거형은 다른 언어의 열거형 보다 강력하지만 클래스와 구조체를 완전히 대체할 순 없다. 열거형은 여전히 이름 있는 값을 갖은 유한한 셋으로 구성된 데이터 타입이라는 한계가 있기 때문에

열거형도 구조체처럼 이름 있는 타입이고 값 타입이다.

## 튜플

튜플이 저평가된 타입 중 하나라는데 왜일까?

튜플은 유한하며, 쉼표로 구분하는 순서 있는 요소의 목록이다. (valueA, valueB, valueC)?

튜플의 사용 예를 보자

```swift
// 이름 없는 튜플
let myProtein = ("choco", 23) // 튜플 생성
let (flavor, content) = myProtein // 패턴 매칭
print("\(flavor) \(content)")  // 튜플 내부 정보 접근
```

튜플로 묶을때 각각 값에 flavor, content라는 이름을 부여 해서 내부 정보 접근 할 때 이 이름을 쓸 수 있음

```swift
//이름 있는 튜플 (패턴 매칭 필요 없이 쉽게 값을 가져올 수 있음)
let myProtein2 = (flavor: "choco", content: 23)
print("\(myProtein2.flavor) \(myProtein2.content)")
```

함수에서 여러 값을 반환 하는 경우 튜플을 반환 타입으로 사용 할 수 있다.

```swift
func calculateTip(billAmount: Double, tipPercent: Double) 
-> (tipAmount: Double, totalAmount: Double) {
	let tip = billAmount * (tipPercent/100)
	let total = billAmount + tip
	return (tipAmount: tip, totalAmount: total) //튜플로 반환
}

var tip = calculateTip(billAmount: 97000.0, tipPercent: 10)
print("\(tip.tipAmount) \(tip.totalAmount)") //튜플 내부 정보 접근
```

위와 같이 튜플은 임의의 컬렉션 값을 전달 할 때 유용함

튜플을 값 타입이며 이름이 있기도, 없기도 한 복합 타입이기도 하다

```swift
typealias AliasTuple = (tipAmount: Double, total: Double) //별칭 부여

let myTuple: AliasTuple = (93000.0, 100200.0)
```

## 프로토콜

프로토콜은 실제로 인스턴스를 생성 할 수 없다. 구현 요구 사항을 정의 해 놓은 약속임

하지만 프로토콜은 타입으로 사용 할 수 있음. 변수, 상수, 튜플, 컬렉션 등의 타입을 정의 하는 경우 해당 타입에 프로토콜을 사용 할 수 있다.

프로토콜은 인스턴스를 생성 할 수 없으므로 값 타입도 참조 타입도 아니다.

두 타입의 차이를 알아보자.

## 값 타입과 참조 타입

값 타입(구조체, 열거형, 튜플)과 참조 타입(클래스)의 몇 가지 차이 점 중 주된 차이점은 인스턴스가 전달되는 방식이다.

값 타입 인스턴스를 전달 하는 경우 원본의 복사본을 전달함. 그래서 한 인스턴스가 변경 되더라도 다른 인스턴스에는 영향을 끼치지 않는다.

참조 타입 인스턴스를 전달하는 경우 원본 인스턴스의 참조를 전달함. 두 참조가 같은 인스턴스를 가리키고 있기 때문에 한 **참조가 변경**되면 다른 참조에 영향을 끼친다.

참조란 메모리에 접근 할 수 있는 주소 같은거라고 알고 있었는데 인스턴스가 아니라 참조가 변경된다고 하네 계속 읽어보자

두 타입의 차이점을 알고 각각의 장점과 사용 시 주의 사항을 알아보자

```swift
/// 참조타입과 값타입의 차이
class ReferenceType {
    var name: String
    var assignment: String
    var grade: Int
    
    init(name: String, assignment: String, grade: Int) {
        self.name = name
        self.assignment = assignment
        self.grade = grade
    }
}

struct ValueType {
    var name: String
    var assignment: String
    var grade: Int
}

var ref = ReferenceType(name: "Jiho", assignment: "Coding Test", grade: 90)
var val = ValueType(name: "Jiho", assignment: "Coding Test", grade: 90)

func extraCreditReferenceType(ref: ReferenceType, extraCredit: Int) {
    let ref2 = ref //원본의 참조 전달 
    ref2.grade += extraCredit
}

func extraCreditValueType(val: ValueType, extraCredit: Int) {
    var val2 = val //원본의 복사본 전달
    val2.grade += extraCredit
}

extraCreditReferenceType(ref: ref, extraCredit: 5)
print("Reference: \(ref.name) - \(ref.grade)") //Reference: Jiho - 95

extraCreditValueType(val: val, extraCredit: 5)
print("Value: \(val.name) - \(val.grade)") //Value: Jiho - 90
```

값 타입 인스턴스는 원본의 복사본이 전달돼서 예기치 못한 참조로부터 값이 변경되는 일을 방지 할 수 있겠구나

참조 타입을 사용하면서 마주칠 수 있는 문제상황을 보자

```swift
/// 참조타입을 사용할 때 마주칠 수 있는 문제 상황
func getGradeForAssignment(assignment: ReferenceType) {
    let num = Int(arc4random_uniform(20) + 80)
    assignment.grade = num
    print("Grade for \(assignment.name) is \(num)")
}

var csGrades = [ReferenceType]()
var students = ["Jiho", "Hojin", "Dew", "Nuri"]
var csAssignment = ReferenceType(name: "", assignment: "CsAssignment", grade: 0)

for student in students {
    csAssignment.name = student
    getGradeForAssignment(assignment: csAssignment)
    csGrades.append(csAssignment) //배열에 원본의 참조를 전달
	//Grade for Jiho is 80
	//Grade for Hojin is 99
	//Grade for Dew is 82
	//Grade for Nuri is 96
}

for assignment in csGrades {
    print("\(assignment.name): grade \(assignment.grade)")
	//Nuri: grade 96
	//Nuri: grade 96
	//Nuri: grade 96
	//Nuri: grade 96
}
```

csGrades배열에 Nuri의 점수밖에 없는 이유는 참조타입인 csAssignment를 하나 생성 후 계속 같은 인스턴스를 업데이트 하면서 덮어 썼기 때문. csGrades 의 모든 참조는 같은 ReferenceType 인스턴스를 가리키고 있음

값 타입을 이용해서 올바르게 동작하도록 바꿀 수 있음

inout 매개변수와 &기호를 이용

inout매개변수는 값 타입의 매개변수를 변경 할 수 있게 해주고 함수 호출이 끝나더라도 변경 사항을 유지해줌

inout이라는 이름처럼 함수의 매개변수로 들어온 인자를 함수 내부에서 변경 후 함수 바깥으로 전달한다.

&기호는 값 타입의 참조를 전달하겠다는 뜻. inout과 함께 쓰이는구나

```swift
/// 참조타입을 사용할 때 마주칠 수 있는 문제 상황을 값타입을 이용해서 해결
/// inout - & 키워드 사용
func getGradeForAssignment(assignment: inout ValueType) {
    let num = Int(arc4random_uniform(20) + 80)
    assignment.grade = num
    print("Grade for \(assignment.name) is \(num)")
}

var csGrades = [ValueType]()
var students = ["Jiho", "Hojin", "Dew", "Nuri"]
var csAssignment = ValueType(name: "", assignment: "CsAssignment", grade: 0)

for student in students {
    csAssignment.name = student
    getGradeForAssignment(assignment: &csAssignment) //inout - &
    csGrades.append(csAssignment) //배열에 원본의 복사본을 전달
	//Grade for Jiho is 97
	//Grade for Hojin is 96
	//Grade for Dew is 86
	//Grade for Nuri is 82
}

for assignment in csGrades {
    print("\(assignment.name): grade \(assignment.grade)")
	//Jiho: grade 97
	//Hojin: grade 96
	//Dew: grade 86
	//Nuri: grade 82
}
```

위와 같이 작동 할 수 있는 이유는 csGrades배열에 csAssignment의 복사본을 추가했기 때문임. 그리고 복사본을 넣기 전에 getGradeForAssignment() 함수에 전달할 때는 값 타입일지라도 인스턴스 참조를 전달함. 덕분에 함수 내부에서 값 타입을 변경하고 함수 바깥으로 변경 사항을 전달 할 수 있었음

이번엔 참조 타입(클래스)로만 가능한 작업을 몇 가지 알아보겠음

## 참조 타입만을 위한 재귀적 데이터 타입

재귀 = 자기 자신을 정의 할 때 자신을 재참조하다

즉, 재귀적 데이터 타입은 (나와)같은 타입의 다른 값을 프로퍼티로 갖는 타입을 말함

리스트나 트리 같은 동적 자료 구조를 정의 할 때 재귀적 데이터 타입 사용한다. 이런 동적 자료 구조는 런타임에 크기가 변동될 수 있음

연결 리스트가 좋은 예. 연결 리스트는 서로 연결 된 노드의 그룹으로 각 노드는 다음 노드의 링크를 갖고 있음

![https://hudi.blog/static/73d52eeadd7cd6786538357697f9fcae/d35da/01.png](https://hudi.blog/static/73d52eeadd7cd6786538357697f9fcae/d35da/01.png)

참조 타입을 사용해 연결 리스트를 생성하면 아래와 같음

```swift
class LinkedListRefereneType {
	var value: String
	var next: LinkedListReferenceType? //(나와)같은 타입의 다른 값을 프로퍼티로 갖는다
	init(value: String) {
		self.value = value
	}
}
```

만약 값 타입(struct)를 사용해 연결 리스트를 구현하려고 하면 **error: cannot find type 'LinkedListReferenceType' in scope** 에러를 만날것. 스위프트에서 재귀적 값 타입을 불허함

왜냐하면 값타입을 사용하면 next 프로퍼티에 원본이 아닌 복사본이 전달되서 각 노드들의 연결성이 생기지 않기 때문

다음은 참조 타입(클래스)만 할 수 있는 상속을 알아보자
## 참조 타입만을 위한 상속

서브클래스는 슈퍼클래스로부터 메소드, 프로퍼티 등의 특징들을 상속 받는다.

상속을 이용하면 복잡한 클래스 계층을 만들 수 있다. 특징을 상속 받기 때문에 중복 코드를 피할 수 있지만 복잡성 때문에 계층 안의 클래스를 변경할 때 계층 내부의 모든 클래스에 어떤 영향을 미칠지 파악하기 어렵다.

스위프트에서는 복잡한 클래스 계층 구조를 지양하고 프로토콜지향적인 접근법을 사용하는것이 좋음

## 다이내믹 디스패치

```swift
class Parent {
	init() { }
	func someMethod() { //... }
	final someFinalMethod() { //... }
}

class Child: Parent {
	init() { }
	override func someMethod() { //... }
}

let instance: Parent = Child()
instance.someMethod() // Parent의 someMethod()를 호출 할지 Child의 someMethod()를 호출할지?
instance.someFinalMethod() // Parent의 someFinalMethod()를 직접 호출
```

슈퍼클래스에 정의된 기능을 상속하고 오버라이드 한다면 위와 같은 상황에서 언제 적절한 구현체를 선택할까?

호출할 구현체를 선택하는 과정은 런타임에 수행되고 이를 다이내믹 디스패치라고 한다.

이는 런타임에 오버헤드가 발생한다는 의미이며 성능에 민감한 게임 앱 같은 경우 문제가 될 수도 있음

다이내믹 디스패치와 관련된 오버헤드를 줄이는 방법 중 하나는 final키워드를 사용하는 것

클래스나 메소드,함수 정의부 앞에 final을 붙이면 클래스는 서브클래싱을 할 수 없다는 의미, 메소드나 함수는 오버라이드 할 수 없다는 의미이다.

해당 키워드가 붙은 메소드나 함수를 런타임때 간접 호출이 아닌 직접 호출을 하면서 오버헤드를 줄일 수 있음. 오버라이딩이 불가능하기 때문에 Parent의 메소드라고 확신 할 수 있는 듯?

## 스위프트 내장 타입

스위프트 표준 라이브러리에서는 갑 타입인 구조체를 이용해서 표준 데이터 타입과 표준 자료 구조를 정의해놓았음

덕분에 스위프트에서는 Int, Double, String과 같은 타입을 확장 할 수 있다. 배열, 딕셔너리, 셋 과 같은 자료 구조 또한 마찬가지이다. 값 타입 자료구조를 다른 변수에 할당할 때 원본 자료 구조의 복사본을 전달하는데 많은 양의 요소를 갖고 있는 자료 구조라면 성능이 어떨까?

## Copy-on-write

값 타입의 인스턴스는 두 번째 변수에 할당 될 때 해당 인스턴스의 복사본을 전달받는다. 이때 50000개의 요소를 가진 배열이라면 런타임에 50000개의 요소를 모두 복사해야 함. 이는 성능에 영향을 미칠 수 있음

Cow는 이런 문제를 어느 정도 해결할 수 있음. 스위프트에서는 만약 인스턴스를 두 번째 변수에 할당 할 때 자료 구조에 변경이 없다면 복사본을 만들지 않고 참조를 전달함 그러면 50000개의 요소를 복사하는 런타임 오버헤드를 피할 수 있다.

Cow는 스위프트 표준 라이브러리의 특정 타입에만 구현되어있음

## 요약

대부분의 객체지향 프로그래밍언어와 다르게 스위프트는 이름 있는 타입과 복합 타입, 그리고 다시 참조 타입과 값 타입으로 나뉘는 여러 타입 선택권이 있음

애플은 값 타입 사용을 추천함. 아무래도 스위프트는 프로토콜지향언어로써 복잡한 클래스 상속 구조 사용을 지양하기 때문인 것 같다