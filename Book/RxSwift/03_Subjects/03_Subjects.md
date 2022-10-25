# 3장 Subjects

앞 장에서 옵저버블이 무엇인지, 어떻게 만드는지, 어떻게 구독하는지 그리고 다 사용하고 어떻게 폐기하는지 배웠다. 옵저버블은 RxSwift의 근간이지만 본질적으로 값을 읽기만 할 수 있다. 다시 말해 옵저버블을 구독한 후 옵저버블이 생성하는 새로운 이벤트를 감지할 수 밖에 없다는 뜻이다.

앱을 개발할때 일반적으로 필요한건 실행 중에 새로운 값을 수동으로 옵저버블에 추가해서 구독자에게 방출하는 것임. 즉, 옵저버블과 옵저버의 두 가지 역할을 할 수 있어야 하는데 바로 subject가 할 수 있다. 옵저버의 역할 덕분에 새로운 값을 받을 수 있다.

이번 장에서 RxSwift의 각기 다른 형태의 Subject를 알아보고 동작원리와 상황에 맞는 subject사용 예시를 볼것임. subject의 래퍼인 relay또한 알아보겠음

&nbsp;

[TOC]
&nbsp;

## 1. 시작하기

```swift
let subject = PublishSubject<String>()
```

위와 같이 PublishSubject를 생성할 수 있는데 신문 발행자(publisher)처럼 정보를 받아서 구독자에게 발행할 것임. String 형식이기때문에 문자열을 받아서 발행 할 수 있다. 초기화되면 발행할 문자열을 받을 준비가 된다.

```swift
subject.on(.next("Is anyone listening?"))
```

위 코드는 subject에 새 문자열을 더한다. 옵저버가 없기때문에 아무것도 출력되지않는다. subject를 구독해보자.

```swift
let subscriptionOne = subject
  .subscribe(onNext: { string in
    print(string)
  })
```

지난 장에서 배운것처럼 subject에 대한 구독을 생성해서 next이벤트에 값을 출력한다. 그러나 여전히 console에는 아무것도 출력되지않는다. 왜냐하면 PublishSubject는 현재 구독자에게만 이벤트를 발행하기 때문이다. 그래서 이벤트가 발행되었던 시점에 구독을하지 않고 있었다면 구독 시점에 아무것도 얻을 수 없다.

```swift
subject.on(.next("1"))
subject.onNext("2")
/* primt
1
2
*/
```

이제 구독을 했으니 이벤트를 발행해보자. String 타입 subject이기때문에 문자열만 더할 수 있다. 더한 문자열은 이제 이벤트를 방출할것임. 구독자가 없으면 이벤트 발행자체가 안되는것 같다.

subscribe 연산자와 비슷하게 on(.next(_:))는 subject에 새로운 next이벤트를 더하고 매개변수로 값을 전달하는 한다. 그리고 onNext()로 간편하게 쓸 수 있다.

&nbsp;

&nbsp;

## 2. What are subjects?

subject는 옵저버블이자 옵저버이다. 바로 위에서 subject에 next이벤트를 전달하고 각 이벤트가 구독자에게 떻게 방출되는지 살펴보았다.

다음은 네 가지의 서브젝트이다.

- PublishSubject : 빈 값으로 생성되고 구독자에게 새 요소만을 발행한다.
- BehaviorSubject : 초기 값을 갖고 생성되고 그 값을 발행하거나 새 구독자에게는 최신 요소를 발행한다.
- ReplaySubject : 버퍼 사이즈를 갖고 생성되고 사이즈만큼 요소를 유지한다. 그리고 새 구독자에게 그것을 발행한다.
- AsyncSubject : 오직 시퀀스의 마지막 next이벤트를 subject가 completed이벤트를 전달 받았을 때 발행한다. 드물게 쓰여서 다루지 않을것. 구색맞추기 위해 알아봄

RxSwift는 Replay라는것도 제공한다. PublishRelay와 BehaviorRelay 두 가지가 있는데 각각의 subject를 래핑한다. 그래서 relay는 오직 next이벤트만을 받아서 방출하는 subject이다. completed와 error는 추가할 수 없기 때문에 종료가 없는 시퀀스에 유용하다.

ReRelay는 RxCocoa가 의존하는 별개의 모듈이라는것을 알아두자. 그래서 RxCocoa를 import해야 사용 할 수 있다.

이제 subject와 relay가 어떻게 동작하는지 자세히 알아보자

&nbsp;

&nbsp;

## 3. Working with publish subjects

### PublishSubject

PublishSubject는 구독자가 구독 시점 뒤에 부터 구독취소되거나 completed나 error이벤트로 종료될때까지 새 이벤트를 감지하도록 하는 데 유용하다.

아래 다이어그램에서 첫번째 줄은 PublishSubject, 두 세번째 줄은 구독자를 의미한다.

위방향 화살표는 구독, 아래방향 화살표는 이벤트 발행을 나타낸다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/0543a50a9da3fee1099ebaf4bc64cbf4c17a6df049058024944a3649ef498dc3/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/0543a50a9da3fee1099ebaf4bc64cbf4c17a6df049058024944a3649ef498dc3/original.png)

첫 번째 구독자는 1 이벤트 다음에 구독했기 때문에 1은 받지 못하고 2와 3을 받는다.

두 번째 구독자는 2 이벤트가 추가된 후 구독했기 때문에 3만 받는다.

주의해야 할 점은 subject가 종료된 후에 구독하는 새 구독자에게는 종료 이벤트가 재발행 된다는 것

그래서 종료 시점 뿐아니라 이미 종료된걸 구독하는 시점을 위해 종료 이벤트를 다루는 코드를 추가하는게 좋다.

미묘한 버그의 원인이 될 수도 있으니 조심하자.

publish subject는 온라인 경매 앱 같은 시간에 민감한 데이터를 처리할 때 사용하자. 10시 1분에 경매 참가한 사용자에게 9시 59분에 1분 남았다고 알리는건 이치에 맞지 않기 때문에.

그리고 새 구독자에게 이전의 값을 재발행하지 않기 때문에 유저가 어떤걸 탭하거나 노티가 도착하는 이벤트를 다룰 때 좋다.

&nbsp;

&nbsp;

## 4. Working with behavior subjects

### BehaviorSubject

BehaviorSubject는 PublishSubject와 비슷하지만 새 구독자에게 마지막 next이벤트를 재발행 한다는 점이 다르다. 아래 다이어그램에서 첫 번째 구독자는 1 이벤트 이후 구독을 했지만 구독하자마자 1번 이벤트를 받는다. 그리고 이어서 2 와 3을 받는다.

두 번째 구독자 역시 2 이벤트 이후 구독했지만 구독하자마자 2 이벤트를 받고 이어서 3을 받는다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/e12faaf78dabff3f1d0835cb4472ec0038e5bbdc3d706e21f91927c129ddc6cf/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/e12faaf78dabff3f1d0835cb4472ec0038e5bbdc3d706e21f91927c129ddc6cf/original.png)

BehaviorSubject는 최신 데이터로 뷰를 미리 채우고 싶을 때 유용하다. 예를 들면 유저 프로필 화면의 컨트롤을 behavior subject에 묶어서 앱이 갱신 데이터를 불러오는 동안 최신 값을 미리 생성해서 보여줄 수 있다.

또한 새 구독자에게 마지막 값을 재발행하기 때문에 “로딩 중” 혹은 “현재 시간 9:41” 등과 같은 상태를 모델링하는데 좋다.

만약 검색화면에서 최근 검색 5개 키워드 처럼 가장 마지막 값보다 더 많이 발행하고 싶다면 ReplaySubject가 좋은 선택이다.

&nbsp;

&nbsp;

## 5. Workimg with replay subjects

### BehaviorSubject

ReplaySubject는 캐시나 버퍼에 마지막에 방출했던 요소들을 특정 사이즈 만큼 저장한다. 그리고는 새 구독자에게 버퍼를 재발행한다.

아래 버퍼 사이즈 2의 ReplaySubject의  다이어그램을 보자.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/6e3ef96bc5e166271bb9f5bd3912fb9871b0c1196efe854f9437417643bf1e4e/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/6e3ef96bc5e166271bb9f5bd3912fb9871b0c1196efe854f9437417643bf1e4e/original.png)

첫 번째 구독자는 이미 구독 중 이기 때문에 1 이벤트와 2 이벤트를 발행될 때 받는다.

두 번째 구독자는 2 이벤트 이후 구독했지만 마지막 이벤트 두 개인 1이벤트와 2이벤트를 받는다.

ReplaySubject를 사용할땐 버퍼가 메모리에 저장된다는걸 명심하자. 이미지 같은 replay subject버퍼에 저장하면 큰 메모리 용량을 차지하게 된다. 또한 배열 타입의 ReplaySubject 사용도 조심해야 한다.

새 구독을 할 때 에러 이벤트가 발생했던 경우 에러이벤트를 포함한 버퍼 사이즈 만큼 요소를 받지만 subject가 명시적으로 폐기 된 후에는 버퍼 사이즈와 상관없이 이미 폐기 되었다는 에러이벤트만 수신한다. 하지만 대부분 명시적으로 폐기하는 것 보다는 dispose bag을 이용할것이기 때문에 알고만 있자.

publish, behavior, replay 세 가지 서브젝트로 원하는 대부분을 구현 할 수 있지만 구식으로 돌아가서 옵저버블 타입의 현재 값만 간단히 알고싶을때는 Relay가 제격이다.

&nbsp;

&nbsp;

## 6. Working with relays

### ReplaySubject

앞에서 relay는 subject를 래핑한다고 배웠다. 다른 서브젝트나 옵저버블과는 달리 accept(*:)를 사용해서 relay에 값을 추가 할 수 있다. 다시 말하면 onNext(*:)를 사용하지 않는다. 왜냐하면 relay는 값만 ‘수락(accept)’을 수 있어서 error나 completed 이벤트는 추가 할 수 없기 때문

PublishRelay는 PublishSubject를, BehaviorRelay는 BehaviorSubject를 래핑한다. 릴레이와 랩핑된 서브젝트를 구별하는 것은 릴레이는 종료되지않는것을 보장한다는 점이다. error나 completed이벤트를 발행 할 수 없기 때문

BehaviorRelay는 BehaviorSubject처럼 초기값과 함께 생성되고 새 구독이 일어날 때 초기값이나 마지막 값을 재발행 할것임. BehaviorRelay의 특별한 힘은 현재 값을 언제든지 요청 할 수 있다는것. 이런 특성은 명령형 세계와 반응형 세계를 잇는 유용한 방법이다. 값이 존재 한다는것과 시퀀스가 종료되지 않는것이 보장되기 때문?

```swift
let relay = BehaviorRelay(value: "Initial value")
let disposeBag = DisposeBag()

  // 2
relay.accept("New initial value")

  relay
	.subscribe {
      print(label: "1)", event: $0)
    }
    .disposed(by: disposeBag)

  relay.accept("1")

print(relay.value)

/* print
1) New initial value
1) 1
1
*/
```

위와 같이 relay.value를 이용해서 현재 값에 직접 접근 할 수 있다는걸 기억하자. 이 경우 가장 최근 방출된 값이 1이기 때문에 1이 콘솔에 출력된다.

이런 기능은 명령형 세계와 반응형 세계를 잇는데 도움이 된다. 곧 살펴볼 것임

BehaviorRelay는 다양하게 쓰일 수 있다. 다른 subject처럼 구독을 통해서 next 이벤트가 발행 될 때 마다 반응 할 수 있다. 그리고 업데이트 수신을 구독하지 않고 현재 값만 확인하는 일회성 요구사항을 만족 시킬 수 있다. 로그인 세션 만료 확인 등에 사용 가능하다.