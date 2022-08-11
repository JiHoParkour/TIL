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