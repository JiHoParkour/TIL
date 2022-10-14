# 2. Observables

앞서 RxSwift의 기본 개념을 배웠다. observable을 이용해서 점프업 해보자.

이번 장에서는 observable을 생성, 구독 해볼 것임. 일부 옵저버블은 사용이 모호해보일 수도 있지만 옵저버블의 유형에 대한 중요한 스킬 얻을 수 있을것이다.

## 1. 옵저버블?

옵저버블은 rx의 심장이다. 어떻게 만들고 사용하는지 알아볼것임

### observable, observable sequence, sequence

observable, observable sequence, sequence는 Rx에서 동일한 의미이다. 때로는 stream이라고도 하는데 이건 다른 플랫폼의 Rx에서 온거고 RxSwift에서는 sequece로 통용된다.

Observable은 단지 특별한 힘을가진 시퀀스이다. 세 가지 중 가장 중요한 한가지는 비동기다. 옵저버블은 시간이 흐르면 이벤트를 방출한다. 이벤트는 숫자나 커스텀 인스턴스 같은 값 혹은 탭 같은 제스처를 갖는다.

### marble diagram

이것을 개념화하는 가장 좋은 방법은 마블 다이어그램이다. 마블 다이어그램은 타임라인에 값을 표시하는것임

왼쪽에서 오른쪽으로 지나는 화사표는 시간의 흐름이다. 1번 요소가 방출되고, 얼마간의 시간이 흐른 뒤 2버노가 3번 요소가 차례로 방출되고 있는 옵저버블을 나타내는 마블 다이어그램이다.

얼마나 오래? 라고 생각했다면 옵저버블의 생애주기를 알아볼 차례다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/c1161239a67d91b694c2ef4cf9f746b75a8ac5f29e8c540207b89f5792944988/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/c1161239a67d91b694c2ef4cf9f746b75a8ac5f29e8c540207b89f5792944988/original.png)

## 2. 옵저버블의 생애주기(LifeCycle of an observable)

첫번재 다이어그램의 세로 작대기는 옵저버블이 완료되어 종료되었음을 나타낸다.

두번째 다이어그램 X 표시는 옵저버블이 오류이벤트가 발생되고 종료되었음을 나타낸다.

둘 다 종료 후에는 아무것도 방출 할 수 없다는것을 유의해야한다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/110965d6b04dbdaf604408dba4f164f3b0b3e6341a469a8bdb88bcd45159b553/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/110965d6b04dbdaf604408dba4f164f3b0b3e6341a469a8bdb88bcd45159b553/original.png)

![https://assets.alexandria.raywenderlich.com/books/rxs/images/13887a1c8922fcc3bb2914d01aa5ed5ff38157ee44aed97ea89fd15389a648fd/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/13887a1c8922fcc3bb2914d01aa5ed5ff38157ee44aed97ea89fd15389a648fd/original.png)

요약하자면

- 옵저버블은 요소를 포함하고있는 next이벤트를 방출한다.
- 옵저버블은 error나 complete 종료 이벤트가 발생하기 전까지 next이벤트를 방출한다.
- 옵저버블은 종료된 이후에 이벤트를 방출 할 수 없다.

### next, completed, error

이벤트는 열거형으로 나타내는데 실제 코드를 보자

```swift
public enum Event<Element> {
    /// Next element is produced.
    case next(Element)

    /// Sequence terminated with an error.
    case error(Swift.Error)

    /// Sequence completed successfully.
    case completed
}
```

위와 같이 next 이벤트는 Element(요소)를 포함하고 있고 error 이벤트는 Swift.Error를 포함하고있다. 그리고 completed 이벤트는 이벤트를 멈추는 값이 없는 이벤트다.

옵저버블이 무엇이고 무엇을 하는지 알았으니 만들어보자

## 3. 옵저버블 만들기(Creating observables)

### just, of, from, range

```swift
let one = 1
let two = 2
let three = 3

let observable = Observable<Int>.just(one) /// 1...
let observable2 = Observable.of(one, two, three) /// 2...
let observable3 = Observable.of([one, two, three]) /// 3...
let observable4 = Observable.from([one, two, three]) /// 4...
let observable5 = Observable<Int>.range(start: 1, count: 10) /// 5...
```

/// 1… just : Int 타입 요소 한 개짜리 옵저버블 시퀀스 생성

/// 2… of : Int 타입 요소 여러개의 옵저버블 시퀀스 생성. 요소의 타입이 Array[Int]가 아님에 유의

/// 3… of : Array[Int] 타입 요소의 옵저버블 시퀀스 생성

/// 4… from : Array[Int]로부터 Int 타입 요소 여러개의 옵저버블 시퀀스 생성. 요소의 타입이 Array[Int]가 아님에 유의

/// 5… range : 특정 범위의 옵저버블 시퀀스 생성

Rx에서는 메소드를 operator라고 부른다. just, of, from, range 등은 모두 연산자임

이제 옵저버블을 구독해보자

## 4. 옵저버블 구독하기(Subscribing to observables)

옵저버블을 구독하는건 구독자에게 알림을 보낸다는 면에서 NotificationCenter와 비슷하다.

```swift
let observer = NotificationCenter.default.addObserver(
  forName: UIResponder.keyboardDidChangeFrameNotification,
  object: nil,
  queue: nil) { notification in
  // Handle receiving notification
}
```

RxSwift의 subscribe는 addObserver와 같다.

하지만 RxSwift는 Notification.dafault(싱글톤 인스턴스) 대신 여러 옵저버블 시퀀스를 이용한다.

가장 중요한 차이는 옵저버블은 구독이 발생하기 전까지 이벤트 방출 등 어떤 동작도 하지 않는다는 점!

앞서 observable과 sequence, 그리고 observable sequence는 같은 의미로 통용된다고 했다.

스위프트 표준 라이브러리의 Sequence는 요소에 순차 반복 접근이 가능한데 Iterator protocol을 준수하는 Iterator(반복자객체)를 갖고있기 때문

그래서 obvservable 구독은 스위프트 표준 라이브러리 Iterator의 next()를 호출하는것과 같다. 순차적인 처리를 한다는 뜻

```swift
let sequence = 0..<3

var iterator = sequence.makeIterator()

while let n = iterator.next() {
  print(n)
}

/* Prints:
 0
 1
 2
 */
```

### subscribe

옵저버블 구독은 훨씬 간단하다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/b440ce9ec15bd060eb0e31a1c52907b5f11eff19dba9457ece340c1cbd81075e/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/b440ce9ec15bd060eb0e31a1c52907b5f11eff19dba9457ece340c1cbd81075e/original.png)

subscribe메소드는 Event<Int>를 받는 리턴값이 없는 탈출 클로저를 매개변수로 받는다. 그리고 Disposable을 리턴하는데 다음 장에서 알아보자.

```swift
let one = 1
let two = 2
let three = 3

let observable = Observable.of(one, two, three)

observable.subscribe { event in /// 1...
  print(event) 
}
/* print
next(1)
next(2)
next(3)
completed
*/

observable.subscribe { event in /// 2...
  if let element = event.element {
    print(element)
  }
}
/* print
1
2
3
*/

observable.subscribe( /// 3...
onNext: { element in
  print(element)
}
//,onCompleted: {
//	print("Completed")
//}
)
```

///1… Event는 값을 전달하는 Next, 성공적으로 종료하는 Complete, 에러와 함꼐 종료하는 Error 세 가지가 있는데 그 중 next 이벤트가 세 번 방출되고 complete로 옵저버블 시퀀스가 종료되었다.

///2… 우리가 필요한건 주로 next 이벤트가 전달하는 값인데 그 값에 접근 하는 방법 이벤트 형식이 세 개 이기 때문에 옵셔널인것에 유의

///3… 옵셔널 바인딩 없이 각 이벤트의 값을 다루는 방법. 원하는 이벤트만 처리 할 수 있다.

### empty, never

```swift
let observable = Observable<Void>.empty() /// 4...

observable.subscribe(
  onNext: { element in
    print(element)
  },
  onCompleted: {
    print("Completed")
  }
)

let observable = Observable<Void>.never() /// 5...
  observable.subscribe(
    onNext: { element in
      print(element)
    },
    onCompleted: {
      print("Completed")
    }
  )
```

/// 4… 0개의 요소를 방출하는 observable. 방출 요소가 없어서 타입추론이 안되기때문에 Void 사용.

next이벤트 방출 없이 즉시 complreted 이벤트가 방출될것임

즉시 종료되거나 의도적으로 값이 없는 옵저버블을 반환하려는 경우에 유용하다는데.. 와닿지 않음

/// 5… empty와 반대로 이벤트를 방출하지도 않고 종료도 되지 않는 옵저버블 Infinite duration을 나타내는데 이용된다는데 무한로딩을 얘기하는건가? 이것도 와닿지 않는다

never()을 제외하고는 자동으로 completed 이벤트와 함께 종료되는 옵저버블을 살펴보았다.

그리고 옵저버블을 만들고 구독하는데 집중할 수 있었다. 하지만 옵저버블을 구독하는것의 중요한 점이 가려져있는데 바로 이번 장 중간에 등장했던 Disposable과 관련이 있다.

## 5. 폐기 및 종료(Disposing and terminating)

옵저버블은 구독전엔 아무 동작도 하지 않는다. 구독은 옵저버블이 completed나 error 이벤트와 함께 종료될 때까지 이벤트를 방출하도록 한다.

그런데 구독을 취소함으로써 수동으로 종료할 수도 있다.

앞서 subscribe는 disposable을 리턴한다고 했다. 이 disposable의 dispose()를 호출하면 구독을 취소할 수 있다.

```swift
let observable = Observable.of("A", "B", "C")

let subscription = observable.subscribe { event in
   print(event)
}

subscription.dispose()
```

각각의 구독을 개별관리하는건 어렵기때문에 RxSwift에서 disposable을 담을 DisposeBag을 제공한다.

disposeBag이 메모리에서 해제되기 직전에 담겨있는 disposable들의 dispose()메소드를 호출하게됨

```swift
let disposeBag = DisposeBag() /// 1...

Observable.of("A", "B", "C") /// 2...
    .subscribe { /// 3...
       print($0)
    }
    .disposed(by: disposeBag) /// 4...
```

///1… dispose bag 생성

///2… observable 생성

///3… observable 구독 및 이벤트 핸들링

///4… subscribe에서 리턴된 disposable을 dispose bag에 담기

위 패턴은 가장 자주 쓰게 될 패턴임

왜 disposable을 신경써야 할까?

dispoable을 dispose bag에 담지 않거나 직접 dispose() 호출을 해서 구독 취소를 하지 않으면 메모리누수가 발생할 수도 있음! 구독이 메모리에서 해제되지 않는가보다. 컴파일러가 경고할것임

### create

create 연산자를 이용하면 옵저버블이 방출할 이벤트를 특정할 수 있다.

create 연산자는 subscribe를 매개변수로 받는다. 그리고 observable에 subscibe를 호출하는 구현을 제공하는 역할을 한다.

즉, 구독하는곳에 방출될 모든 이벤트를 정의한다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/fc9b2037734c93600f64c42c2c55dc6cb3cc808fbb22345959fae13a06935ad1/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/fc9b2037734c93600f64c42c2c55dc6cb3cc808fbb22345959fae13a06935ad1/original.png)

create연산자의 매개변수 subscribe는 Disposable 리턴하고 AnyObserver를 받는 탈출 클로저이며 Disposable을 리턴한다.

AnyObserver는 옵저버블 시퀀스에 어떤 값이든 더할 수 있는 제네릭 타입이며 구독자들에게 방출될것임

create연산자를 이용해보자.

```swift
let disposeBag = DisposeBag()

Observable<String>.create { observer in
  observer.onNext("1")

  observer.onCompleted()
//observer.onError(MyError.anError)

  observer.onNext("?") /// 1...
  
  return Disposables.create() /// 2...
  }
  .subscribe(
    onNext: { print($0) },
    onError: { print($0) },
    onCompleted: { print("Completed") },
    onDisposed: { print("Disposed") }
  )
  .disposed(by: disposeBag)
}
```

///1… 두번째 next이벤트의 ? 요소는 구독자에게 방출되지 않을것 왜냐면 이미 completed이벤트 (혹은 error이벤트)와 함께 시퀀스가 종료됐기때문에

///2… observable이 종료되고 무슨 일이 일어날 지 정의하는 disposable을 반환. 여기선 cleanup이 필요없어서 빈 disposable을 반환한다는데 이해안됨

Disposable을 리턴하는게 이상해보여도 subscribe 연산자가 subscription을 나타내는 disposable을 반환해야한다는걸 기억해보자. subscribe가 사용하나보다.

## 6. 옵저버블 팩토리 만들기(Creating observable factories)

구독을 기다리는 옵저버블을 만드는 것 보단, 각 구독자에게 새로운 옵저버블을 뱉는 옵저버블 팩토리를 만들 수 있다.

### deffered

```swift
let disposeBag = DisposeBag()

  var flip = false /// 1...

  let factory: Observable<Int> = Observable.deferred { /// 2...

    flip.toggle() /// 3...

    if flip { /// 4...
      return Observable.of(1, 2, 3)
    } else {
      return Observable.of(4, 5, 6)
    }
  }

for _ in 0...3 { /// 5...
  factory.subscribe(onNext: {
    print($0, terminator: "")
  })
  .disposed(by: disposeBag)

  print()
}

/* print
123
456
123
456
*/
```

///1... 어떤 옵저버블을 반환할지 결정할 Bool 플래그 값

///2… deffered 연산자를 이용해 observable<Int> 팩토리 생성. 위치 상관없이 함수 제일 마지막에 실행되는 swift의 deffer와 비슷하네

///3… 플래그값 뒤집기. factory에 구독이 발생할 때마다 실행될 것임

///4… flip값에 따라 다른 옵저버블 반환

외부에서는 어떤 옵저버블이 반환되는지 알 수 없다.

구독마다 옵저버블을 여러개 만들 필요 없이 특정 조건에 따라 알맞는 옵저버블을 생성할 수 있겠다.

## 7. 특성 사용하기(***\*Using Traits)\****

Traits은 일반 Observable 보다 적은 행동을 갖는 Observable이다. 꼭 써야할 필요는 없다.

일반 Observable이 쓰이는 곳 어디서든 Trait으로 대체 가능하다.

왜 사용하는걸까?

더 명확한 의도를 전달하기 위해서! trait을 사용하면 코드가 더 직관적이다. Observable에게 기대하는 행동이 적어서 배제할 수 있기 때문인가보다.

### Single, Maybe, Completable

Single, Maybe, Completable 세 가지의 trait이 있다.

Single은 success(value)이벤트 혹은 error(error) 이벤트를 방출한다. success(value)이벤트는 next 이벤트와 completed 이벤트의 결합이다. Single은 다운로드 같이 성공해서 값을 산출하거나 실패하는 일회성 처리에 유용하다.

Completable은 completed 이벤트 혹은 error(error)이벤트를 방출한다. 값은 방출하지 않는다. 파일 쓰기같은 성공/실패 처리에 유용하다.

마지막으로 Maybe는 Single과 Completable의 혼합이다. success(value), completed 이벤트 혹은 error(error) 이벤트를 방출한다. 성공/실패 작업 뿐 아니라 성공 시 값을 방출 할 수도 있는 작업에 유용하다.

다음 장에서 더 자세히 다룰 기회가 있을것임

Single을 사용해서 텍스트파일의 텍스트를 읽어오는 코드를 살펴보자

```swift
let disposeBag = DisposeBag()

enum FileReadError: Error {
  case fileNotFound, unreadable, encodingFailed
}

func loadText(from name: String) -> Single<String> {
  return Single.create { single in

	let disposable = Disposables.create()

	guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
				  single(.error(FileReadError.fileNotFound))
	return disposable
	}

	guard let data = FileManager.default.contents(atPath: path) else {
	  single(.error(FileReadError.unreadable))
	  return disposable
	}

	guard let contents = String(data: data, encoding: .utf8) else {
	  single(.error(FileReadError.encodingFailed))
	  return disposable
	}

	single(.success(contents)) /// 1...
	return disposable
  }
}

loadText(from: "Copyright")
  .subscribe {
    switch $0 { /// 2...
    case .success(let string):
      print(string)
    case .error(let error):
      print(error)
    }
}
.disposed(by: disposeBag)
```

///1… Observable을 create하는 것과 비슷하지만 single을 값을 가진 success이벤트로 방출

///2… 방출된 이벤트가 success 인지 error인지에 따라 값을 산출해서 처리

## 8. 부수 효과 실행하기(Perform side effects)

옵저버블의 이벤트 방출에 영향을 주지 않으면서 부수 작업을 하고 싶을 때 유용한 연산자가 있다.

### do

do 연산자는 부수 효과를 삽입 할 수 있도록 해주는데 방출된 이벤트에는 영향을 주지 않으면서 어떤 작업을 할 수 있음

do는 다음 연산자에게 값을 그대로 전달함. subscribe과는 다르게 onSubscribe 핸들러를 추가로 포함하고 있고 subscribe처럼 원하는 이벤트에 대한 처리만 할 수 있다.

예시를 통해 알아보자

```swift
let disposeBag = DisposeBag()
let observable = Observable<Int>.of(1)

  observable
    .do(
        onNext: {element in /// 1...
            print("side work with \\(element)")
        },
        onSubscribe: {
            print("observable subscribed")
        }
        
    )
    .subscribe(
    onNext: { element in
        print(element)
    },
    onCompleted: {
      print("Completed")
    }
  )
  .disposed(by: disposeBag)
```

///1… subscribe이전에 do를 삽입해서 구독이 됐을 때나 값이 이벤트가 방출됐을 때 이벤트에 영향을 주지 않고 부수 작업을 할 수 있다.

## 9. 디버그 정보 출력하기(Print debug info)

do를 이용해서 부수 작업을 하는게 debug를 하는 방법 중 하나 일 수 있지만 목적에 맞는 더 좋은 방법이 있다.

### debug

debug 연산자는 옵저버블에서 방출되는 모든 이벤트에 대한 정보를 print한다.

몇몇 매개 변수를 전달 할 수 있지만 가장 유용한건 식별자 문자열을 전달해서 같이 print하는 것

복잡한 Rx 체인에서 곳곳에 debug를 삽입할텐데 식별할 문자열이 같이 나오면 아주 도움이 된다.

```swift
let disposeBag = DisposeBag()
let observable = Observable<Int>.of(1)

  observable
    .debug("debug")
    .subscribe(
    onNext: { element in
        print(element)
    },
    onCompleted: {
      print("Completed")
    }
  )
  .disposed(by: disposeBag)

/* print
2022-10-14 18:57:10.735: debug -> subscribed
2022-10-14 18:57:10.742: debug -> Event next(1)
2022-10-14 18:57:10.743: debug -> Event completed
2022-10-14 18:57:10.743: debug -> isDisposed
*/
```