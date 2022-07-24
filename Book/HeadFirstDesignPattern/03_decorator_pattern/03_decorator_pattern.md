### 학습 목표

- 상속을 남용하는 사례를 보고 객체 작성이라는 형식으로 실행 중에 클래스를 데코레이션하는 방법을 배운다.
- 기존 클래스 코드를 바꾸지 않고도 객체에 새로운 임무를 추가 할 수있다.

### 초대형 커피 전문점, 스타버즈

급성장한 스타버즈의 초기 주문 시스템 클래스는 다음과 같다.

```swift
class Beverage {
let description: String

func getDescription() { }
func cost() { }
}

class HouseBlend: Beverage {
override func cost() { }
}

class HouseBlendWithSteamedMilk: Beverage {
override func cost() { }
}

class DarkRoast: Beverage {
override func cost() { }
}

class DarkRoastWithWhipandMocha: Beverage {
override func cost() { }
}
.
.
.
```

매장에서 판매되는 모든 음료는 Beverage의 서브 클래스이다.

커피를 주문할 때 두유, 모카, 휘핑크림 등의 옵션을 선택할 수 있다.

이때 옵션 조합의 경우의 수 만큼 클래스가 생기게 된다.

한눈에 클래스 관리에 어려움을 겪을거라고 예상 할 수 있다.

### 🌟뇌 단련

위 클래스 구조에서 우유의 가격이 오르거나 옵션에 캐러멜이 새로 추가된다면 어떻게 해야할까?

→ 우유 옵션을 가진 클래스를 모두 찾아가서 가격을 변경해줘야한다. 존재하는 음료의 종류 만큼 캐러멜을 추가한 음료 클래스를 만들어야 한다.

지금까지 배운 디자인 원칙 중 위반 하고 있는 것은 무엇일까?

→ 상속을 과하게 사용하고 있는 것 같다.

<aside>
💡 원칙1. 바뀌는 부분을 찾아서 바뀌지 않는 부분과 분리한다.

</aside>

<aside>
💡 원칙2. 구현보다는 인터페이스에 맞춰서 프로그래밍 한다.

</aside>

<aside>
💡 원칙3. 상속보다는 구성을 활용한다.

</aside>

### 인스턴스 변수와 슈퍼클래스 상속을 이용해서 첨가물 관리를 하면 안될까?

```swift
class Beverage {
let description: String
let milk: Bool
let soy: Bool
let mocha: Bool
let whip: Bool

func getDescription() { }
func cost() { }

func hasMilk() { }
func setMilk() { }
func hasSoy() { }
func setSoy() { }
.
.
.
}

class HouseBlend: Beverage {
override func cost() { }
}

class DarkRoast: Beverage {
override func cost() { }
}

class Decaf: Beverage {
override func cost() { }
}

class Espresso: Beverage {
override func cost() { }
}
.
.
.
```

슈퍼클래스의 cost()는 첨가물의 가격을 계산하고 서브클래스에서 cost() 메소드를 오버라이드 할 때 기능을 확장해서 특정 음료의 가격을 더한다.

### 쓰면서 제대로 공부하기

각 클래스에 들어갈 cost()메소드 (수도)코드를 작성해보자.

```swift
class Beverage {
func cost() {
	// 값이 참인 첨가물들의 가격을 더한다
 }
}

class HouseBlend: Beverage {
override func cost() {
	// HouseBlend의 가격을 더한다.
 }
}

```

위 디자인에 영향을 미칠만한 변경 사항을 적어보자.

할인 쿠폰이나 1+1 이벤트 등을 적용하려면 모든 서브 클래스의 cost()를 수정해야 한다.

첨가물의 재고가 떨어졌을 때 프로그램 동작 중 이용자가 선택을 못하도록 할 수 없다.

## OCP 살펴보기

상속을 사용하게되면 서브클래스의 행동은 컴파일 시점에 결정되어버리지만 구성과 위임으로 객체의 행동을 확장하면 런타임에 동적으로 행동을 변경 할 수 있다!

게다가 코드 관리에도 영향을 미치는데 기존 코드를 건드리지 않고 새로운 코드를 만들어서 기능을 추가 할 수 있다~ **확장에는 열려있고 변경에는 닫혀있어야 한다(OCP)**는 디자인 원칙 등장

## 데코레이터 패턴 살펴보기 & 주문시스템에 데코레이터 패턴 적용하기

데코레이터 패턴의 말 뜻대로 음료를 장식 할 수 있다.

커피 객체를 추가 주문 객체인 모카, 휘핑크림 객체 등으로 차례로 장식한 후 가격 계산 메소드를 호출!

```jsx
Whip {

	cost( )

		Mocha { 

			cost( )

				DarkRoast { 

					cost( ) 

				}

		 }

}
```

여기서 포인트는 데코레이터(Whip, Mocha)등이 장식하고 있는 객체와 같은 형식을 가져야 한다는 것임. cost( ) 메소드를 가져야 하기 때문인듯? 근데 상속을 이용해서 다형성을 구현했네? 인터페이스를 써도 무방하지만 기존 코드를 굳이 바꾸지 않기 위해 그렇다고 함

가격을 구하는 순서는 가장 바깥쪽의 Whip에서 cost()를 호출하는 것으로 시작, 그러면 Whip은 Mocha의 cost()를 호출하고 Mocha는 다시 DarkRoast의 cost()를 호출.

DarkRoast는 커피 가격을 리턴하고 Mocha는 커피 가격을에 모카 가격을 더해서 리턴한다.

Whip은 그 가격을 받아서 휘핑크림 가격을 더해서 최종 가격을 리턴!

1. 데코레이터의 슈퍼클래스 = 데코레이터가 장식하는 객체의 슈퍼클래스
2. 위 내용 덕분에 데코레이터 객체는 자신이 장식하는 객체의 자리에 들어갈 수 있다.
3. 한 객체를 여러 개의 데코레이터로 감쌀 수 있다.
4. 데코레이터는 장식하고있는 객체에게 행동을 위임 하는 것 뿐 아니라 추가 행동을 할 수 있다.

   (키포인트라는데 덕분에 데코레이터에 동적으로 행동을 추가할 수 있어서?)

5. 런타임에 데코레이터를 마음대로 적용 할 수 있다.

## 데코레이터 패턴의 정의

데코레이터 패턴으로 어떤 객체에 추가 요소를 동적으로 더할 수 있다. 상속 보다 훨씬 유연!