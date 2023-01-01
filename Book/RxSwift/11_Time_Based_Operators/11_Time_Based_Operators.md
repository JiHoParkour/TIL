# 11장 Time Based Operators

타이밍은 모든것임. 반응형 프로그램 뒤의 핵심 아이디어는 시간이 흐름에 따라 비동기 데이터를 모델링하는 것이다. 이런 측면에서, RxSwift는 시간이 흐름에 따라 시퀀스가 반응하고 이벤트를 변환하는 방식과 시간을 처리할 수 있는 다양한 연산자를 제공한다. 이번 장 전체에서 보다싶이, 시퀀스의 시간의 차원을 관리하는건 쉽고 직관적이다.

&nbsp;

[TOC]

&nbsp;

## 1. Buffering operators

첫번째 시간 기반 연산자 그룹은 버퍼링을 다룬다. 버퍼링 연산자는 지난 요소들을 새로운 구독에 재방출 할 뿐아니라 저장하고 갖고있다가 폭발적으로?(한번에?) 전달한다. 어떻게, 언제 과거와 새로운 요소들이 전달될지 컨트롤 할 수 있게 해준다.

&nbsp;

### Replaying past elements

####replay()

시퀀스가 아이템을 방출 할 때, 미래의 구독자가 과거의 몇 개 혹은 모든 아이템들을 받게 할 필요가 있을것임. 이게 바로 replay와 replayAll 연산자의 목적임.

```swift
/// 1...
let elementsPerSecond = 1
let maxElements = 10
let replayedElements = 1
let replayDelay: TimeInterval = 3

let sourceObservable = Observable<Int>.create { observer in
  var value = 1

    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
        if value <= maxElements {
          observer.onNext(value)
          value += 1
        }
    })

    return Disposables.create{
        timer.invalidate()
    }
}
.replay(replayedElements) /// 2...

/// 3...
_ = sourceObservable.subscribe({ element in
    print(element)
})

/// 4...
DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) {
  _ = sourceObservable.subscribe({ element in
      print(element)
  })
}

_ = sourceObservable.connect() /// 5...

/// 6...
/* print
next(1)
next(2)
next(3)
next(3)
next(4)
next(4)
next(5)
next(5)
...
*/
```

/// 1... 몇개씩 최대 몇개의 이벤트를 몇 초 간격으로 발생하고 몇 개 의 요소를 리플레이 할지 결정 할 변수

/// 2... replay를 이용해 소스 옵저버블에서 방출된 마지막 요소를 개수 만큼 기록하는 새 시퀀스를 생성함. 새로운 구독을 할 때 마다 (있다면) 즉시 버퍼된 요소를 받게된다. 그리고 일반 옵저버 처럼 새 요소를 계속 수신한다.

/// 3... 소스 옵저버블 즉시 구독

/// 4... 소스 옵저버블 3초 뒤 구독

/// 5... replay 연산자는 connectable observable을 생성하기 때문에, 아이템 수신을 시작하려면 기본 소스에 연결해야 한다. 잊으면 구독자는 아무것도 받을 수 없다.

/// 6... 3초 뒤 두 번째 구독이 버퍼되어있던 마지막 한 개의 요소 3과 함께 4를 동시에 수신 한 뒤 새 요소를 수신하는 것을 확인 할 수 있다.

&nbsp;

주의: 커넥터블 옵저버블은 옵저버블의 특별한 클래스임. 구독자의 수와 상관 없이, connect() 메소드 호출 전까지는 아이템 방출을 하지 않을 것임

&nbsp;

&nbsp;

### Unlimited replay

####replayAll()

두 번째 replay 연산자는 replayAll() 이다. 주의깊게 써야 함. 버퍼된 요소의 전체 개수가 합리적으로 유지될 것임을 아는 경우에만 사용해야 함. 예를 들어 HTTP 요청 컨텍스트에서 replayAll()을 사용하는게 적절함. 쿼리에서 반환된 데이터를 유지하는 것의 메모리 영향을 대략적으로 안다. 반면에 종료되지 않거나 많은 데이터를 생성하는 시퀀스에 쓰면 메모리가 금방 가득 찰것임. OS에서 앱을 강제 종료 할 수도 있음

&nbsp;

### Controlled buffering

####buffer(timeSpan:count:scheduler:)

리플레이 가능한 시퀀스를 맛봤으니 통제된 버퍼링을 심화 학습하자.  Buffer(timeSpan:count:scheduler:)를 처음 볼것임. 마찬가지로 몇 가지 상수로 시작하자.

```swift
let bufferTimeSpan: RxTimeInterval = .seconds(4)
let bufferMaxCount = 2

let sourceObservable = PublishSubject<String>()

_ = sourceObservable.subscribe({ element in
    print(element)
})

sourceObservable
  .buffer(timeSpan: bufferTimeSpan, count: bufferMaxCount, scheduler: MainScheduler.instance)
  .map(\.count)
  .subscribe({ element in
      print(element)
  })


DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
  sourceObservable.onNext("🐱")
  sourceObservable.onNext("🐱")
  sourceObservable.onNext("🐱")
}

/* print
next(0)

next(🐱)
next(🐱)
next(2)
next(🐱)

next(1)

next(0)
*/
```

* 소스 옵저버블로부터 요소의 배열을 받길 원함

* 각 배열은 최대 bufferMaxCount 개수 만큼의 요소를 보관함

* bufferTimeSpan이 만료되기 전에 bufferMaxCount만큼의 요소를 받으면, 연산자는 버퍼된 요소를 방출하고 타이머를 리셋한다.

* 마지막 방출그룹 이후 bufferTimeSpan의 지연시간이 지나면 버퍼는 배열을 방출한다. bufferTimeSpan동안 받은 요소가 없으면 비어있을 것임.

&nbsp;

버퍼는 허용 용량의 최대치에 도달하면 즉시 요소의 배열을 방출한다. 그리고 특정 시간동안 혹은 다시 최대치에 도달 할 때 까지 기다리다가 시간이 다 지나거나 최대치에 도달하면 새로운 배열을 방출한다.

&nbsp;

###  Windows of buffered observables

####window(timeSpan:count:scheduler:)

buffer와 비슷한 마지막 버퍼링 테크닉은 window(timeSpan:count:scheduler:)이다. 거의 비슷하지만 다른 점은 배열 대신 버퍼된 요소의 옵저버블을 방출하는 것임. 

```swift
let elementsPerSecond = 3
let windowTimeSpan: RxTimeInterval = .seconds(4)
let windowMaxCount = 5
let sourceObservable = PublishSubject<String>()

let timer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(elementsPerSecond), repeats: true, block: { timer in
    sourceObservable.onNext("🐱")
    
})

_ = sourceObservable
  .window(timeSpan: windowTimeSpan, count: windowMaxCount, scheduler: MainScheduler.instance)
  .flatMap { windowedObservable -> Observable<String> in /// 1...
    return windowedObservable
      .concat(Observable.just("last")) /// 2...
  }
  .subscribe(onNext: { value in
    if value != "last" {
        print(value)
    } else {
        print("completed")
    }
  })
/* print
🐱
🐱
🐱
🐱
🐱
completed
🐱
🐱
🐱
🐱
🐱
completed
반복..
*/
```

/// 1... window()는 배열 대신 옵저버블을 방출한다. flatMap을 이용해서 옵저버블을 핸들링한다. 옵저버블이 방출될 때 마다 flatMap()은 새로운 옵저버블을 받아서 concat으로 "last"라는 문자열을 삽입후 리턴

/// 2... last를 이용해서 completed를 출력 할 것임

&nbsp;

위 예시 코드는 4초가 지나거나 최대 5개의 요소를 받았을 때마다 새로운 옵저버블을 방출하고 순환이 다시 시작됨. window() 옵저버블을 방출하기 때문에 flatMap을 사용 할 수 있고 buffer()보다 복잡한 작업이 가능 할 것 같다.

&nbsp;

&nbsp;

## 2. Time-shifting operators

때때로, 시간을 여행할 필요가 있다. RxSwift가 과거 관계의 실수를 고치는데 도움을 줄 수 없는 반면, Time-shifting 연산자는 자가 복제가 가능할 때 까지 잠시동안 멈추게 할 수 있는 능력이 있다.

&nbsp;

시간과 관련된 두 개의 연산자를 들여다보자.

&nbsp;

###Delayed subscriptions

####delayedSubscription(_:scheduler:)

```swift
let elementsPerSecond = 1
let delay: RxTimeInterval = .milliseconds(1500)

let sourceObservable = PublishSubject<Int>()


var current = 1
let timer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(elementsPerSecond), repeats: true, block: { timer in
    sourceObservable.onNext(current)
    current = current + 1
})

_ = sourceObservable
  .delaySubscription(delay, scheduler: MainScheduler.instance)
  .subscribe({ value in
      print(value)
  })
/* print
next(2)
next(3)
next(4)
next(5)
...
*/
```

delayedSubscription(_:scheduler:)는 이름이 의미하는대로, 구독자가 구독으로부터 요소를 받기 시작하는 시간을 지연한다. 위 예시코드에서 1.5초 이후에 요소 2부터 받는 것을 확인할 수 있다.

&nbsp;

###cold observable & hot observable

주의: Rx에서 어떤 옵저버블은 "cold"라고 불리는 반면 어떤 옵저버블은 "hot"이라고 불린다. Cold 옵저버블은 구독을 한 뒤에 요소들을 방출하기 시작한다. Hot 옵저버블은 어떤 시점에 보게 되는 영구적인 소스같은 것임(알림을 생각해보자). 구독을 지연시킬 때, 옵저버블이 cold면 차이를 만들 수 없을 것임. hot 옵저버블이면 아마 요소들을 스킵할 것임.

&nbsp;

Hot과 Cold 옵저버블은 머릿속을 어지럽히는 까다로운 주제임. cold 옵저버블은 오직 구독이 됐을 때 이벤트를 생성한다는 것을 기억하자. 그러나 hot 옵저버블은 구독이 되는것과는 상관없이 이벤트를 생성한다.

&nbsp;

###Delayed elements

####delay(_:scheduler:)

다른 종류의 지연은 전체 시퀀스가 시간 이동을 하도록 한다. 구독을 늦추는 대신, 연산자는 소스 옵저버블을 즉시 구독하지만 특정 시간 동안 모든 이벤트를 지연시킨다. 최종 결과는 구체적인 시간 이동임.

```swift
let elementsPerSecond = 1
let delay: RxTimeInterval = .milliseconds(1500)

let sourceObservable = PublishSubject<Int>()


var current = 1
let timer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(elementsPerSecond), repeats: true, block: { timer in
    sourceObservable.onNext(current)
    current = current + 1
})

_ = sourceObservable
  .delay(delay, scheduler: MainScheduler.instance)
  .subscribe({ value in
      print(value)
  })
/* print
next(1)
next(2)
next(3)
next(4)
next(5)
...
*/
```

코드는 비슷하다. delaySubscription을 delay로 대체했다. 하지만 이전에는 구독을 지연했기 때문에 next(1)을 받지 못했다. 반면 delay연산자는 요소들을 시간이동 시키기 때문에 어떤것도 놓치지 않았다. 다시말하면 구독이 즉시 발생했다. 단순히 지연된 아이템들을 확인 할 수 있다.

&nbsp;

&nbsp;

##3. Time operators

모든 앱에서 일반적으로 필요한건 타이머다. iOS와 macOS는 몇개의 타이밍 솔루션이 있다. 역사적으로 Timer는 일을 해냈지만 혼란스러운 소유권 모델을 갖고 있어서 제대로 하기가 까다로웠다. 최근에는, 디스패치 프레임워크가 디스패치 소스를 사용해서 타이머를 제공했다. 그건 비록 래핑을 하지 않으면 여전히 API가 복잡했지만 그래도 Timer보단 나은 솔루션이다.

&nbsp;

RxSwift는 일회용 타이머와 반복 타이머 모두에 간단하고 효과적인 솔루션을 제공한다. 그건 시퀀스와 완벽하게 통합되고 다른 시퀀스에 취소와 결합성 모두를 완벽하게 제공한다.

&nbsp;

###Intervals

####interval(_:scheduler:)

위 예시들에서 interval timer를 만들기 위해서  Timer를 몇 번 사용했다. timer를 RxSwift의 Observable.interval(_:scheduler:) 함수로 대체할 수 있다. 이건 무한한 Int값 옵저버블 시퀀스를 생성하고 지정된 스케쥴러에서 선택한 간격으로 전송한다.

```swift
let sourceObservable = Observable<Int>
  .interval(.milliseconds(Int(1000.0 / Double(elementsPerSecond))), scheduler: MainScheduler.instance)
  .replay(replayedElements)
```

위 replay 예시에서 타이머를 이용하는 대신 interval 함수를 이용해서 소스 옵저버블을 생성 할 수 있다.

&nbsp;

RxSwift에서 interval timer를 만드는건 놀랍도록 쉽다. 뿐만아니라 취소 또한 쉽다. 왜냐면 interval(_:scheduler:)가 옵저버블 시퀀스를 생성하기 때문에 구독을 취소하고 타이머를 멈추기 위해서 간단하게 반환된 disposable을 dispose()할 수 있다.

&nbsp;

구독자가 시퀀스를 관찰하기 시작하고 특정 기간에 첫 번째 값이 방출된다는 것은 주목할 만하다. 또한 타이머도 이 시점 전에는 시작하지 않을 것임. 구독은 타이머를 시작하는 방아쇠임. 구독이 발생 한 후 이벤트가 방출되기 때문에 cold 옵저버블!

&nbsp;

주의: 위 예시에서 알 수 있듯이 interval은 0부터 시작하는 정수값을 방출한다. 만약 다른 값이 필요하면 map()을 이용하면된다. 실제 경우에는 타이머에서 방출된 값은 무시되지만 유용한 인덱스이다.

&nbsp;
### One-shot or repeating timers

#### timer(_dueTime:period:scheduler:)

더 강력한 타이머 옵저버블을 원한다면 Observable.timer(_dueTime:period:scheduler:) 연산자가 있다. interval과 비슷하지만 몇 가지 특정이 있다.

* 구독 시점과 첫 번째 방출된 값 사이의 경과 시간으로 "마감 기한"을 지정할 수 있다. 즉, 구독하고 몇 초 후에 값을 받을 지.
* 반복 주기는 선택이다. 만약 특정하지 않으면 타이머 옵저버블은 한 번 방출하고 완료될 것임

얼마나 유용한지 코드로 보자.

```swift
_ = Observable<Int>
  .timer(.seconds(3), scheduler: MainScheduler.instance)
  .flatMap { _ in
    sourceObservable.delay(delay, scheduler: MainScheduler.instance)
  }
  .subscribe(delayedTimeline)

```

타이머를 촉발하는 타이머는 처음이다. 몇 가지 이점이 있는데 다음과 같다.

* 전체 과정의 가독성이 좋다(Rx스럽다).
* 구독이 disposable을 반환하기 때문에, 첫 번째 혹은 두 번째 타이머가 싱글 옵저버블과 함께 트리거되기 전에 언제든 취소할 수 있다.
* flatMap 연산자를 이용해서, 디스패치의 비동기 클로저로 후프?를 뛰어넘을 필요 없이 타이머 시퀀스를 생성 할 수 있다.

어떤 이점이 있는지 설명이 잘 와닿지 않는데, 정리하자면 interval은 특정 주기로 반복할 때, timer는 특정 시간 이후에 (optional-특정 주기로 반복) 트리거 할 때 사용 할 수 있겠다.

&nbsp;

###Timeouts

timeout 이라는 특별한 연산자와 함께 이 시간 기반 연산자 모음을 끝내보자. 이 연산자의 주 목적은 시간 초과(오류) 조건에서 실제 타이머를 의미론적으로 구별하는 것임. 타이머를 이용해서 시간 초과 오류 조건에 대한 처리를 가능하게 해준다는 의미 인듯? 그러므로 지정된 시간 동안 어떤 아이템도 방출되지 않아 시간 초과가 발생하면 RxError.TimeoutError 에러 이벤트를 방출하게 됨. 에러가 잡히지 않으면 시퀀스를 종료함(에러가 잡히지 않는 다는건 소스 시퀀스가 완료 됐다는 건가?)

&nbsp;

다음 장에서 배울 RxCocoa를 이용해서 버튼 탭을 옵저버블 시퀀스로 바꿔보자. 

* 버튼 탭 감지
* 만약 버튼이 5초 안에 눌리면, 콘솔에 뭔가 출력하고 시퀀스 종료
* 만약 버튼이 눌리지 않으면 에러 조건을 출력

#### timeout(_:scheduler:)

```swift
let button = UIButton(type: .system)
let timeOutSecond: RxTimeInterval = .seconds(3)
let _ = button
    .rx.tap
    .map { _ in "•"}
    .timeout(timeOutSecond, scheduler: MainScheduler.instance)
    .subscribe { value in
        print(value)
    }

button.sendActions(for: .touchUpInside)
button.sendActions(for: .touchUpInside)
/*print
next(•)
next(•)
error(Sequence timeout.)
*/
```

만약 버튼을 5초 안에 누르면(그리고 5초안에 뒤이어 누르면), next(•)가 콘솔에 출력된다. 누르기를 멈추고 3초 뒤에 시간초과가 발생하고 error 이벤트가 방출된다.

&nbsp;


####timeout(otehr:scheduler:)
Timeout(_:scheduler:)의 다른 유형은 옵저버블을 취하고 시간초과가 발생하면 에러를 방출하는 대신에 구독을 이 옵저버블로 바꾼다.

&nbsp;

이 유형의 timeout의 많은 사용 사례가 있음. 그 중 하나는 에러 대신에 값을 방출하고 정상적으로 complete하는 것임

&nbsp;

timeout을 아래 와 같이 바꾸면 에러 대신 X요소의 방출과 완료 이벤트를 확인 할 수 있다.

```swift
let button = UIButton(type: .system)
let timeOutSecond: RxTimeInterval = .seconds(3)
let _ = button
    .rx.tap
    .map { _ in "•"}
    .timeout(timeOutSecond, other: Observable.just("X"), scheduler: MainScheduler.instance)
    .subscribe { value in
        print(value)
    }

button.sendActions(for: .touchUpInside)
button.sendActions(for: .touchUpInside)
/*print
next(•)
next(•)
next(X)
completed
*/
```
