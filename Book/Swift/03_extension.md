# 3. 확장

표준 라이브러리에는 없는 기능을 가진 커스텀 라이브러리는 매우 유용하다.

기존의 객체지향 프로그래밍 언어에서는 전역함수나 기능을 추가하고자 하는 클래스를 서브클래싱해서 추가 기능을 정의 할 수 있었음

스위프트에서는 확장을 통해 기능을 추가 할 수 있다. 프로토콜 또한 확장이 가능하며 프로토콜을 채용한 타입에 기능을 추가 할 수 있게 됨

확장은 이미 존재하는 타입에 아래와 같은 아이템을 추가 할 수 있음

- 연산 프로퍼티 ❗저장 프로퍼티는 추가 할 수 없다.
- 인스턴스 메소드, 타입메소드
- 간편 생성자
- 서브스크립트

확장은 기존 방식과 비교하면 왜 유용한지 명확하게 알 수 있다.

1. 서브클래스에 기능을 추가하는 것은 원본 클래스에 기능을 추가하는 것이 아니기 때문에 원본 클래스의 인스턴스를 새로운 서브클래스의 인스턴스로 일일이 바꿔줘야 하는 점
2. 서브클래싱은 참조타입인 클래스만 가능하기 때문에 대부분의 표준 라이브러리가 값 타입으로 구현된 스위프트에서는 기능을 추가 할 수 없다는 점

확장은 원하는 타입에 직접 기능을 추가하기 때문에 인스턴스를 수정 하지 않아도 자동으로 새 기능을 받게 되고 참조 타입 뿐만 아니라 값 타입도 확장할 수 있음

## 확장 정의

일반적으로 커스텁 타입에 기능을 추가하기보다는 타입 자체에 기능을 추가하는 게 낫다. 모든 추가 기능이 함께 있는 편이 관리하기 용이함

프레임워크에 기능을 추가하는 경우에도 프레임워크 자체 소스 코드를 변경하기보다는 확장을 사용해서 기능을 추가하면 좋다. 프레임워크가 업데이트되어도 확장은 유효하기 때문에

```swift
/// 스위프트 표준라이브러리 확장의 예
extension String {
	func getFirstChar() -> Charactrer? {
		guard characters.count > 0 else {
			return nil
		}
		return self[startIndex]
	}
}

/// 확장의 사용 예
var myString = "This is jiho"
print(myString.getFirstChar()) // T
```

## 프로토콜 확장

프로토콜 확장은 특정 프로토콜을 따르는 모든 타입에 공통 기능을 추가하기 위해 사용됨

프로토콜 확장이 없다면 서브클래싱을 할 수 없는 값 타입은 개별적으로 기능 추가를 해야만함

```swift
protocol protocolA {
}

protocol procotolB: protocolA, protocolNeed {
}

protocol protocolC: protocolA {
}

protocol protocolNeed {
}

extension protocolA where Self: protocolNeed {
	func someMethod() {
	///
	}
}
```



위 코드는 protocolA를 따르는 모든 타입에 someMethod() 를 추가해서 확장한다.

프로토콜을 확장할 땐 추가 하는 기능이 해당 프로토콜을 따르는 모든 타입에서 예상대로 작동하도록 주의를 기울여야 한다. 여러 곳에서 채택하고 있을 것임으로

그래서 extension 뒤에 where 절로 확장에 제약을 추가할 수 있다.

protocolB와 protocolC모두 protocolA를 따르기 때문에 someMethod()가 추가되어야 하지만 where제약때문에 protocolNeed를 따르는 protocolB만 someMethod()를 전달 받을 수 있다.

프로토콜 확장은 그룹 타입에 기능 추가할 때 사용해야 함. 단일 타입에 추가할 땐 프로토콜 확장보다는 단일 타입을 확장하는 것을 고려하자. 당연한말?

## 문장 유효성

문장의 유효성을 검사할 때 유용한 정규식(regex)을 사용하는 구조체를 프로토콜을 이용해서 구현할 것임

한 번은 프로토콜 확장을 사용하지 않고, 다른 한 번은 프로토콜 확장을 사용해서 구현함으로써 프로토콜 확장이 어떤 이점이 있는지 보자

```swift
protocol TextValidation {
	var regExMatchingString: String {get}
	var regExFindMatchingString: String {get}
	var validationMessage: String {get}
	func validateString(str: String) -> Bool
	func getMatchingString(str: String) -> String?
}

/// 프로토콜 확장을 사용하지 않고 채택만 하는 경우
class AlphabeticValidation: TextValidation {
	static let sharedInstance = AlphabeticValidation()
	private init(){}
	let regExFindMatchString = "^[a-zA-Z]{0,10}"
	let validationMessage = "Can only contain Alpha characters"
	var regExMatchingString: String {
		get {
			return regExFindMatchString + "$"
		}
	}
	func validationString(str: String) -> Bool {
		//...중복 코드
	}
	func getMatchingString(str: String) -> String? {
		//...중복 코드
	}
}
class NumericValidation: TextValidation {
	static let sharedInstance = NumericValidation()
	private init(){}
	let regExFindMatchString = "^[0-9]{0,10}"
	let validationMessage = "Can only contain Numeric characters"
	var regExMatchingString: String {
		get {
			return regExFindMatchString + "$"
		}
	}
	func validationString(str: String) -> Bool {
		//...중복 코드
	}
	func getMatchingString(str: String) -> String? {
		//...중복 코드
	}
}
```

프로토콜 확장을 사용하지 않고 유효성 타입마다 채택하면 코드가 중복된다. 그렇다고 중복 코드를 정의하는 슈퍼 클래스를 만들어서 클래스 계층을 생성하는것 외에는 대안이 없다.

프로토콜 확장을 사용해서 중복 코드를 줄일 수 있다.

```swift
protocol TextValidation {
	var regExMatchingString: String {get}
	var validationMessage: String {get}
}

/// 프로토콜 확장
extension TextValidation {
	var regExMatchingString: String {
		get {
			return regExFindMatchString + "$"
		}
	}
	func validationString(str: String) -> Bool {
		//...중복 코드
	}
	func getMatchingString(str: String) -> String? {
		//...중복 코드
	}
}

class AlphabeticValidation: TextValidation {
	static let sharedInstance = AlphabeticValidation()
	private init(){}
	let regExFindMatchString = "^[a-zA-Z]{0,10}"
	let validationMessage = "Can only contain Alpha characters"
}
class NumericValidation: TextValidation {
	static let sharedInstance = NumericValidation()
	private init(){}
	let regExFindMatchString = "^[0-9]{0,10}"
	let validationMessage = "Can only contain Numeric characters"
}
```

프로토콜 확장으로 TextValidation  프로토콜을 채택하는 모든 타입에 중복되는 기능을 추가했다.

덕분에 싱글톤 패턴 구현부를 제외하면 각 유효성 검사 타입들의 중복 코드가 없어졌다.

## 스위프트 표준 라이브러리 확장

스위프트 표준 라이브러리는 대부분 구조체와 프로토콜로 이루어져 있다고 언급했다. 그렇다면 프로토콜 확장을 이용해서 스위프트 표준 라이브러리에 직접 기능을 추가할 수 있다는 말과 같다.

```swift
extension Int {
	func factorial() -> Int {
		var answer = 1
		
		for x in (1...self).reversed() {
			answer *= x
		}
		return answer
	}
}

print(5.factorial()) // 120(5*4*3*2*1)
```

factorial이라는 전역 함수를 생성하는 대신 Interger 타입 자체에 factorial함수를 추가했다.

## Equatable 프로토콜 따르기

확장을 통해 커스텀 타입이 Equatable프로토콜을 따르게 할 수 있다.

Equtable프로토콜을 채택하면  ==나 !=연산자를 이용해 인스턴스를 쉽게 비교 할 수 있음

```swift
struct Person {
	let name: String
	let height: Double
	let weight: Double
}

extension Person: Equatable {
	static func ==(lhs: Person, rhs: Person) -> Bool {
		return lhs.name == rhs.name &&
		lhs.height == rhs.height &&
		lhs.weight == rhs.weight
	}
}

var jiho = Person(name: "Jiho", height: 173.0, weight: 79.1)
var hulk = Person(name: "Hulk", height: 226.4, weight: 521.3)
print(jiho == hulk) // false
```

Person타입에 직접 Equatable을 채택하지 않고 확장을 통해 채택하는 이유는 Equatable 프로토콜의 구현 코드가 해당 확장에 고립되어있어 코드를 읽고 유지하기 수월해서~

## 요약

과거 스위프트에선 구조체, 클래스, 열거형만 확장을 사용할 수 있었지만 스위프트2부터 프로토콜을 확장 할 수 있게 됨

그만큼 프로토콜지향 프로그래밍에 프로토콜 확장은 중요하니 적절하게 잘 써야 함