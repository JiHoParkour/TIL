## Closure

클로저란 코드에서 전달되거나 사용되는 독립적인 기능 블럭임. 블럭? 클로저는 C나 Objective-C의 블럭, 혹은 java의 람다와 비슷하다.

클로저는 이름이 있는 전역함수와 중첩함수 그리고 이름이 없는 익명 함수를 포함하지만 일반적으로 익명 함수를 뜻한다.

따라서 클로저는 { } 블럭 형태의 이름이 없는 함수(익명함수) 라고 할 수 있겠다.

&nbsp;

클로저는 "클로저는 내부 함수와 내부 함수에 영향을 미치는 주변 환경을 모두 포함한 객체"로서 자신이 정의된 맥락으로부터 상수나 변수의 참조를 저장하거나 캡처 할 수 있다.

closure내부에서 변수 x에 대한 참조를 "캡처" 즉 참조할 수 있음을 의미

클로저는 값타입/참조타입에 관계 없이 참조 캡처를 하는것에 유의. 다시 말해 x가 Int(값 타입)일지라도 복사본이 아닌 원본의 주소값을 참조하게 된다.

```swift
func someMethod(closure: ()->()) {
  closure()
}

var x: Int = 100

someMethod {
    x = 200
}

print(x) /// 클로저 내부에서 x의 원본 주소를 참조하고 원본의 값을 변경 했기 때문에 200을 출력
```

이는 클로저가 상수나 변수를 "closing over"(동봉하다, 애워싸다) 하는것으로 알려져 있다. 음.. 상수나 변수를 외부로부터 격리한다는 의미인듯?

Swift가 캡처링(참조)의 모든 메모리 관리를 대신 해준다. 클로저 또한 참조 타입으로서 클로저를 호출하면 클로저의 참조를 카운트하게되고 클로저 내부에서 사용하는 참조 또한 카운트해야 하는데 이런 작업들을 Swift ARC(Auto Reference Counting)가 대신 해준다는 의미이다.

&nbsp;

전역 함수와 중첩 함수는 클로저의 특별한 경우이다. 그래서 클로저는 일반적으로 익명 함수를 칭한다.

클로저는 아래 셋 중 하나의 형태를 취한다.

* "전역 함수"는 이름이 있으며 값을 캡처하지 않는 클로저이다.
* "중첩 함수"는 이름이 있으며 애워싸는 함수에서 값을 캡처할 수 있는 클로저이다.
* 클로저 표현식은 주변 문맥으로부터 값을 캡처 할 수 있는 경량 문법의 "이름이 없는 클로저(익명 함수)"이다.

&nbsp;

### Capturing Values

클로저는 자신이 정의된 주위 문맥으로부터 상수나 변수를 캡처할 수 있다. 덕분에 클로저는 상수나 변수가 정의 되었던 원래 환경이 더이상 존재하지 않더라도 상수나 변수를 클로저 내부에서 참조하거나 수정 할 수 있다.

&nbsp;

스위프트에서 값을 캡처할 수 있는 가장 간단한 형태의 클로저는 다른 함수의 바디 안에 정의된 중첩 함수이다.

중첩 함수는 외부 함수의 어떤 인자도 캡처 할 수 있고 또한 외부 함수 안에 정의된 상수나 변수 또한 캡처 할 수 있다.

incrementer라는 중첩 함수를 포함하는 makeIncrementer라는 예시 함수를 통해 알아보자.

```swift
func makeIncrementer(forIncrement amount: Int) -> () -> Int {
    var runningTotal = 0
    func incrementer() -> Int {
        runningTotal += amount
        return runningTotal
    }
    return incrementer
}
```

incrementer 중첩 함수는 주변 문맥으로부터 runningTotal과 amount 두 값을 캡처한다. 값들을 캡처링 한 후에, incrementer는 makeIncrementer가 호출 될 때마다 amount 값 만큼 runningTotal을 증가시키는 클로저로서 리턴된다.

makeIncrementer의 리턴 타입은 ()->Int인데 이는 함수를 리턴함을 의미한다. makeIncrementer는 호출 될 때마다 매개변수가 없고 Int 값을 반환하는 함수를 리턴한다.

&nbsp;

makeIncrementer 함수는 incrementer에서 리턴될 현재 running total을 저장하기 위해 runningTotal이라는 정수형 변수를 정의한다. 초기값은 0이다.

또한 인자 이름이 forIncrement이고 매개변수 이름은 amount인 하나의 정수형 매개변수가 있다. 인자 값은 반환되는 incrementer 함수가 호출 될 때마다 runningTotal이 얼마나 증가되야 하는지 특정하기 위해 매개변수로 전달된다. makeIncrementer 함수는 incrementer 라 불리는 중첩 함수를 정의하고 이 함수가 실제 증가를 수행한다. 이 함수는 runningTotal에 amount를 더하고 결과를 리턴한다.

&nbsp;

```swift
func incrementer() -> Int {
    runningTotal += amount
    return runningTotal
}
```

중첩함수 incrementer만 떼어놓고 보면 이상해 보일 수 있다. 매개 변수가 없는데도 불구하고 runningTotal과 amount를 함수 바디 안에서 참조하고 있기 때문이다. incrementer는 주변 함수로부터 runningTotal과 amount의 참조를 캡처링하고 자신의 함수 바디에서 사용한다. 참조를 캡처링하는건 makeIncrementer의 호출이 끝났을 때 runningTotal과 amount가 사라지지 않음을 보장하고 또한 다음에 incrementer 함수가 호출 됐을 때 runningTotal이 이용 가능함을 보장한다.

&nbsp;

주의: 최적화로서, Swift는 만약 값이 클로저에 의해 변경되지 않거나 클로저가 생성된 후 변경되지 않으면 값의 복사본을 캡처하고 저장한다.

Swift는 또한 값이 더이상 필요 없을 때 그것의 폐기와 관련한 모든 메모리 관리를 해준다.

클로저는 참조 타입/값 타입에 상관없이 값들을 참조하는걸로 알고 있었는데 최적화를 위해 Cow같이 내부적으로 뭔가 구현되어있나보다.

&nbsp;

makeIncrementer 용례를 보자.

```swift
let incrementByTen = makeIncrementer(forIncrement: 10)
```

호출될 때마다 runningTotal 변수에 10을 더하는 incrementer 함수를 참조하기위해 makeIncrementer를 상수 incrementByTen를 선언함

incrementByTen를 여러번 호출하면 다음과 같다.

```swift
incrementByTen()
// returns a value of 10
incrementByTen()
// returns a value of 20
incrementByTen()
// returns a value of 30
```

&nbsp;

만약 두번째 incrementer를 정의하면, 새로운 별도의 runningTotal 변수에 대한 고유한 참조를 갖게 될 것임

다시 incrementByTen의 runningTotal 변수를 증가시키기위해 incrementByTen를 호출해도 incrementBySeven에 의해 캡처된 변수에는 영향을 미치지 않는다.

```swift
let incrementBySeven = makeIncrementer(forIncrement: 7)
incrementBySeven()
// returns a value of 7

incrementByTen()
// returns a value of 40
```

주의: 만약 클래스 인스턴스의 프로퍼티로 클로저를 할당하고 클로저가 인스턴스나 인스턴스의 멤버 변수를 참조함으로써 인스턴스를 캡처하면 클로저와 인스턴스 사이에 강한 순환 참조를 만들게 된다. Swift는 이 강한 순환 참조를 막기위해 capture lists를 사용한다. 클로저 또한 참조 타입이기 때문에 ARC가 적용된다. 두 참조 타입 간에 서로 강한 참조를 하게되면 참조 카운팅이 계속 남아서 메모리에서 해제되지 않는 메모리 누수가 발생 할 수 있음

&nbsp;

### Closures Are Reference Type

위 예에서, incrementBySeven와 incrementByTen는 상수였지만 이 상수가 참조하는 클로저는 여전히 캡처한 runningTotal 변수를 증가시킬 수 있었다. 이는 함수와 클로저가 참조 타입이기 때문이다.

&nbsp;

함수나 클로저를 상수나 변수에 할당할 때 마다, 실제로는 상수나 변수는 함수나 클로저를 참조하게 된다. 이는 만약 클로저를 두 개의 다른 상수나 변수에 할당하면 두 상수나 변수 모두 같은 클로저를 참조함을 의미한다.

```swift
let alsoIncrementByTen = incrementByTen
alsoIncrementByTen()
// returns a value of 50

incrementByTen()
// returns a value of 60
```

&nbsp;

위 예는 alsoIncrementByTen를 호출하는 것과 incrementByTen를 호출하는 것이 동일함을 보여준다. 왜냐면 두 개 모두 같은 클로저를 참조하고, 같은 runningTotal을 증가시키고 리턴하기 때문에.

&nbsp;

### Escaping Closure

함수가 리턴 된 이후에 클로저가 함수의 인자로 전달되어 호출될 때 클로저는 함수를 escape(탈출)한다고 한다. 

클로저를 매개변수로 취하는 함수를 선언할 때 클로저가 탈출할 수 있음을 나타내기 위해 매개변수의 타입 앞에 @escaping을 붙일 수 있다.

&nbsp;

클로저가 탈출 할 수 있는 방법 중 하나는 함수 외부에 선언된 변수에 저장되는 것이다. 예를 들어, 비동기 작업을 시작하는 많은 함수는 completion handler로서 클로저 인자를 취한다. 함수는 작업을 시작한 뒤 반환하지만 클로저는 작업이 완료될 때 까지 호출되지 않는다. 이 때 클로저는 나중에 호출되기 위해 탈출할 필요가 있다. 

```swift
var completionHandlers: [() -> Void] = []
func someFunctionWithEscapingClosure(completionHandler: @escaping () -> Void) {
    completionHandlers.append(completionHandler)
}
```

위 예에서 someFunctionWithEscapingClosure는 인자로 클로저를 취하고 클로저를 함수 밖에서 선언된 리스트에 추가한다. 만약 이 함수의 매개변수에 @escaping을 표시하지 않으면 컴파일 에러가 발생할 것임

&nbsp;

self를 참조하는 탈출 클로저는 self가 클래스의 인스턴스를 참조하는지 특별한 고려가 필요하다. 탈출 클로저에서 self를 캡처링 하는 건 우연히 강한 순환 참조를 만들어내기 쉽다. 클로저와 클래스 모두 참조타입이기 때문에.

&nbsp;

일반적으로, 클로저는 클로저 바디안에서 변수를 사용함으로써 변수를 캡처한다. 하지만 self가 클래스의 인스턴스를 참조하는 경우 명시적이어야 한다. 만약 self를 캡처하고 싶으면 사용할 때 명시적으로 self를 작성하거나 클로저의 캡처리스트에 self를 작성하자. self를 명시적으로 작성하는건 의도를 표현하게 한다. 그리고 순환 참조가 없음을 확인하도록 상기시켜준다. 예를 들어, 아래 코드에서 someFunctionWithEscapingClosure에 전달되는 클로저는 self를 명시적으로 참조한다. 대조적으로, someFunctionWithNonescapingClosure에 전달되는 클로저는 nonescaping 클로저인데 self를 암묵적으로 참조할 수 있음을 의미한다. someFunctionWithEscapingClosure는 함수가 리턴된 이후에 completionHandlers.first?()를 통해 호출된다.

```swift
func someFunctionWithNonescapingClosure(closure: () -> Void) {
    closure()
}

class SomeClass {
    var x = 10
    func doSomething() {
        someFunctionWithEscapingClosure { self.x = 100 }
        someFunctionWithNonescapingClosure { x = 200 }
    }
}

let instance = SomeClass()
instance.doSomething()
print(instance.x)
// Prints "200"

completionHandlers.first?()
print(instance.x)
// Prints "100"
```

&nbsp;

위 코드처럼 self를 명시할 수도 있고 캡처리스트에 포함해서 self를 암묵적으로 참조 할 수도 있다.

```swift
class SomeOtherClass {
    var x = 10
    func doSomething() {
        someFunctionWithEscapingClosure { [self] in x = 100 }
        someFunctionWithNonescapingClosure { x = 200 }
    }
}
```

&nbsp;

만약 self가 structure나 enumeration의 인스턴스이면, self를 항상 암묵적으로 참조할 수 있다. 그런데, escaping 클로저는 self가 structure나 enumeration의 인스턴스이면 self에 mutable(변할 수 있는)한 참조를 캡처 할 수 없다. 이는 구조체나 이넘이 공유된 가변성을 허용하지 않기 때문? 기본적으로 구조체나 이넘은 값타입이기 때문에 immutable(불변한)한 것과 관련이 있는것 같다. struct는 값타입이라서 mutating 키워드를 이용해서 내부 값을 바꾸면 변경된 값과 함께 새로운 인스턴스를 만들어서 기존 인스턴스에 재할당하는 작업을 한다.

someFunctionWithEscapingClosure에서 self.x = 100으로 값을 변경하면 SomeStruct의 새로운 인스턴스가 생성될 것인데 문제는 mutating doSomething()이 동작하는 시점과 탈출클로저 someFunctionWithEscapingClosure이 실행되는 시점(불특정한 미래)의 간극인듯? 간극 때문에 그사이 어떤 변경이 있었다면 원치 않는 동작이 발생 할 수 있음. 그래서 아래 나오는 탈출클로저는 self가 구조체일 때 self에 mutable(변할 수 있는)한 참조를 캡처 할 수 없다는 원칙이 생긴 것 같다.

```swift
struct SomeStruct {
    var x = 10
    mutating func doSomething() {
        someFunctionWithNonescapingClosure { x = 200 }  // Ok
        someFunctionWithEscapingClosure { x = 100 }     // Error
    }
}
```

someFunctionWithEscapingClosure 함수가 컴파일 에러가 나는 이유는 mutating method 내에 있어서 self가 mutable하기 때문이다. 탈출 클로저는 self가 구조체일때 self에 변할 수 있는 참조를 캡처 할 수 없다는 원칙을  위반하는 것임.
