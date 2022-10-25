# 4장 팩토리 패턴

### 학습 목표

- 인스턴스를 만드는 작업을 모두 공개할 필요 없으며, 오히려 결합 문제가 생길 수 있음을 안다.
- 팩토리 패턴으로 불필요한 의존성 없애고 결합 문제를 해결 할 수 있다.



```swift
protocol Duck { }
class MallardDuck: Duck { }
let duck: Duck = MallardDuck( )
```

인터페이스를 써서 유연한 코드를 짜려고해도 결국은 구상 클래스의 인스턴스를 만들어야 한다. 구상 클래스가 추가되거나 변화가 생겼을 때 수정을 해야 할 일이 생길 수도 있기 때문에 유연한 코드라고 볼 수 없음



```swift
let duck: Duck

if (picnic) {
	duck = MallardDuck()
} else if (hunting) {
	duck = DecoyDuck()
} else if (inBathTub) {
	duck = RubberDuck()
}
```

Duck을 채택하는 구상 클래스가 여러 개라면 위와 같이 코드를 짜야함. 그리고 컴파일 전까지는 어떤 인스턴스를 만들어야 하는지 알 수가 없음

구상 클래스를 많이 사용하면 구상 클래스가 추가될때마다 코드를 고쳐야하므로 문제가 생길 가능성이 높아짐. 이는 변경에 닫혀있는코드가 됨

이를 해결하기 위해선 새로운 구상 형식을 써서 열 수 있게 만들어야함



### 🌟뇌 단련

어떻게 하면 앱에서 구상 클래스의 인스턴스 생성 부분을 전부 찾아내서 앱의 나머지 부분으로 부터 분리(캡슐화)할 수 있을까?

→ 모든 구상 클래스의 인스턴스 생성하는 역할을 하는 클래스를 만들면 관리하기 쉽지 않을까?



### 피자 코드 만들고 피자 추가하기

```swift
func orderPizza(type: String) -> Pizza {
	var pizza: Pizza?

/// 객체 생성하는 부분
/// 피자 메뉴가 변경 될때마다 코드를 계속 고쳐야함
/// 아래 부분은 변경에 닫혀있지 않다.
	if (type.equals("cheese")) {
		pizza = CheesePizza()
	} else if (type.equals("greek")) {
		pizza = GreeekPizza()
	} ~~else if (type.equals("pepperoni")) {
		pizza = PepperoniPizza()
	}~~ else if (type.equals("new")) {
		pizza = NewPizza()
	}

///거의 변하지 않는 부분
	pizza.prepare()
	pizza.bake()
	pizza.cut()
	pizza.box()
	return pizza
}
```



### 객체 생성 부분 캡슐화 하고 객체 생성 팩토리 만들기

```swift
class SimplePizzaFactory {
	func createPizza(type: String) {
		var pizza: Pizza?
		
		if (type.equals("cheese")) {
		pizza = CheesePizza()
	} else if (type.equals("greek")) {
		pizza = GreeekPizza()
	} else if (type.equals("pepperoni")) {
		pizza = PepperoniPizza()
	~~~~} else if (type.equals("new")) {
		pizza = NewPizza()
	}
 
		return pizza
}
```