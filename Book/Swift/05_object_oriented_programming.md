# 5. 객체지향 프로그래밍

객체지향 프로그래밍은 프로그래밍을 특성과 행동을 가진 객체들의 상호작용으로 바라보는 관점의 프로그래밍 패러다임이라고 알고 있음

스위프트는 프로토콜지향언어인데 왜 객체지향 프로그래밍을 설명해주지?

프로토콜 지향 프로그래밍으로 해결하려고 했던 문제와 프로토콜 지향 프로그래밍을 이해하는데 도움을 줄 것임

이번 장에서 다룰 내용은 다음과 같음

- 스위트를 객체지향 프로그래밍 언어로 사용하는 방법
- 객체지향 방식을 사용해 API를 개발하는 방법
- 객체지향 설계 방식의 장점
- 객체지향 프로그래밍의 문제점

### 객체지향 프로그래밍

객체지향 언어 이전의 절차적 언어가 프로그래밍을 처리해야할 순차적인 명령으로 봤다면 객체지향 언어는 프로그래밍을 속성(프로퍼티)과 행위(메소드)를 가진 객체의 상호작용으로 바라봄

객체는 현실 또는 가상의 물체(타입)이 될 수 있다.

예를 들면 생수는 속성(제조사, 제조일, 유통기한, 취수원, 용량, 영양성분, 온도)과 행위(마시기, 온도변화)를 갖는 객체로 모델링 할 수 있다.

생수를 보관(상호작용)하는 냉장고 역시 속성(제조사, 용량, 온도, 소비전력, 남은 용량)과 행위(추가하기, 꺼내기)를 갖는 객체로 모델링 할 수 있다.

객체를 생성하기 위해서는 객체의 속성과 행위를 알리는 청사진이 필요한데 그게 클래스!

클래스는 객체의 속성과 행위를 단일 타입으로 캡슐화 한다.

클래스의 이니셜라이저는 인스턴스(객체)를 생성하고 프로퍼티 값을 초기화하는데 사용됨

또한 클래스는 참조타입이며 슈퍼클래스와 서브클래스를 가질 수 있음

세 가지 이동 타입을 갖는 게임을 만드는 상황을 통해 객체지향 프로그래밍의 문제점을 알아보자