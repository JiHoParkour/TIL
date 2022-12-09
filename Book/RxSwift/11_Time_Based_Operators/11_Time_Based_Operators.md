# 11장 Time Based Operators

타이밍은 모든것임. 반응형 프로그램 뒤의 핵심 아이디어는 시간이 흐름에 따라 비동기 데이터를 모델링하는 것이다. 이런 측면에서, RxSwift는 시간이 흐름에 따라 시퀀스가 반응하고 이벤트를 변환하는 방식과 시간을 처리할 수 있는 다양한 연산자를 제공한다. 이번 장 전체에서 보다싶이, 시퀀스의 시간의 차원을 관리하는건 쉽고 직관적이다.

&nbsp;

## 1. Buffering operators

첫번째 시간 기반 연산자 그룹은 버퍼링을 다룬다. 버퍼링 연산자는 지난 요소들을 새로운 구독에 재방출 할 뿐아니라 저장하고 갖고있다가 폭발적으로?(한번에?) 전달한다. 어떻게, 언제 과거와 새로운 요소들이 전달될지 컨트롤 할 수 있게 해준다.

&nbsp;

### Replaying past elements

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

두 번째 replay 연산자는 replayAll() 이다. 주의깊게 써야 함. 버퍼된 요소의 전체 개수가 합리적으로 유지될 것임을 아는 경우에만 사용해야 함. 예를 들어 HTTP 요청 컨텍스트에서 replayAll()을 사용하는게 적절함. 쿼리에서 반환된 데이터를 유지하는 것의 메모리 영향을 대략적으로 안다. 반면에 종료되지 않거나 많은 데이터를 생성하는 시퀀스에 쓰면 메모리가 금방 가득 찰것임. OS에서 앱을 강제 종료 할 수도 있음

&nbsp;

### Controlled buffering

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

## Time-shifting operators

















