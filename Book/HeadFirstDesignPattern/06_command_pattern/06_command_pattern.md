### 학습 목표

- 메소드 호출을 캡슐화 할 수 있다.
- 메소드를 캡슐화 하는 것의 이점을 알고 활용 할 줄 안다.

## 만능 IOT 리모컨

7개의 빈 슬롯과 각 슬롯 마다 ON/OFF 버튼이 있는 리모컨에 다양한 홈오토메이션 장비를 제어할 수 있도록 아래 동봉된 클래스를 이용해 API를 작성해보자.

```swift
class Light {
	func on() { }
	func off() { }
}

class OutdoorLight {
	func on() { }
	func off() { }
}

class GarageDoor {
	func up() { }
	func down() { }
	func stop() { }
	func lightOn() { }
	func lightOff() { }
}
.
.
.
```

리모컨의 1번 슬롯에 조명을 연결하고 light.on()을 호출하는 방식은 리모컨에 홈오토메이션 장비를 추가 할 때 마다 리모컨의 코드를 고쳐야 하는 불편함이 있다.

작업 요청(리모컨)과 작업 처리(장비 제어 클래스)를 분리하는 커맨트 패턴을 이용하면 해결 할 수 있다!

커맨트 객체는 특정 객체(조명)에 관한 특정 작업 요청(점등)을 캡슐화 한다. 리모컨의 버튼에 커맨트 객체를 저장해두면 리모컨은 작업만 요청하면 된다. 왜냐하면 저장된 커맨드 객체가 누가 어떤 일을 할지 알고 있기 때문에

## 음식 주문 과정 자세히 살펴보기

객체마을 식당의 음식 주문 과정을 통해 커맨드 패턴을 알아보자

1. 고객이 음식 **주문서**를 작성한다. createOrder()
2. **종업원**은 **주문서**를 받는다. takeOrder()
3. **종업원**은 주문을 처리한다. orderUp()
4. **주문서**는 **주방장**이 어떤 음식을 만들어야 하는지 지시한다. makeBurger(), makeShake()

## 객체마을 식당 등장인물의 역할

**주문서**는 주문 내용을 캡슐화 한다.

누가 어떤 메뉴를 만들어야 하는 지 종업원은 알 필요가 없다.

**종업원**은 주문서를 받고 orderUp()메소드를 호출한다.

주문서를 받아서 주문 들어왔다고 얘기만 하면 된다.

**주방장**은 식사를 준비하는 데 필요한 정보를 가지고 있다.

종업원이 orderUp()을 호출하면 음식을 준비한다.

여기서 종업원과 주방장은 주문서 덕분에 분리되어있음. 서로 직접 얘기 할 필요 없음.

리모컨 슬롯에 식당의 주문서가 들어있다면 리모컨이 orderUp() 호출만 하면 누가 어떻게 했는지는 모르지만 불이 켜지게 할 수 있다.

## 객체마을 식당과 커맨드 패턴

객체 마을 식당의 등장인물들의 역할을 커맨드 패턴에 대입해보자.

1. 고객이 음식 **주문서**를 작성한다. createOrder()

   → 클라이언트는 **커맨트 객체**를 생성한다. createCommandObject()

    ```swift
    //커맨드 객체에는 어떤 리시버가 어떤 행동을 해야하는지 정보가 들어있다.
    public func execute() {
    receiver.actionA()
    receiver.actionB()
    }
    ```

2. **종업원**은 **주문서**를 받는다. takeOrder()

   → **인보커**는 **커맨드 객체**를 받아서 저장한다. setCommand()

3. **종업원**은 주문을 처리한다. orderUp()

   → 클라이언트의 명령을 받아서 **인보커**는 **커맨드 객체**의 메소드를 호출한다. execute()

4. **주문서**는 **주방장**이 어떤 음식을 만들어야 하는지 지시한다. makeBurger(), makeShake()

   → **커맨드 객체**는 **리시버**에 있는 행동 메소드를 호출한다. actionA(), actionB()

## 커맨드 객체 만들기

커맨드 객체는 모두 같은 인터페이스를 구현해야 한다. execute()라는 메소드 하나만 있으면 됨

```swift
protocol Command {
	func execute()
}
```

조명을 켤 때 필요한 **커맨드 클래스**

```swift
class LightOnCommand: Command { // 커맨트 프로토콜 구현
	var light: Light!

	init (light: Light) { // 이 커맨드 객체로 제어할 특정 조명을 전달 받음
		self.light = light	
	}

	func execute() {
		light.on()
	}
}
```

## 커맨드 객체 사용하기

커맨드 객체를 사용할 슬롯이 하나만 있는 리모컨을 구현하자

```swift
class SimpleRemoteControl {
	var slot: Command?
	
	init () { }

	func setCommand(command: Command) {
		slot = command
	}

	func buttonWasPressed() {
		slot?.execute()
	}
	
}
```

리모컨을 사용해보자

```swift
class RemoteControlTest {
	let remote: SimpleRemoteControl = SimpleRemoteControl() //인보커
	let light: Light = Light() //리시버
	let lightOn: LightOnCommand = LightOnCommand(light: light) //커맨드 객체

	remote.setCommand(lightOn)
	remote.buttonWasPressed()
}
```

## 커맨드 패턴의 정의

커맨드 패턴은 요청 내역을 객체로 캡슐화 한다. 서로 다른 요청 내역마다 객체화 돼서 매개변수화 할 수 있다. 덕분에 요청을 큐에 저장하거나 로그로 기록, 작업 취소 등을 할 수 있게됨

커맨드 객체에는 행동과 일을 처리하는 리시버가 캡슐화 되어있어 외부에서는 execute()를 호출하면 요청이 처리 된다는 것만 알 수 있음