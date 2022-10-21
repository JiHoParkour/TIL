# 5. Filtering Operators

새 기술 배우는건 고층 건물 짓는것과 같음. 지금까지 단단한 기반을 다졌다. 다시 말해 지금까진 RxSwift에 대한 기본적인 이해를 확립했다. 이젠 지식을 한 단계씩 레벨업시켜보자.

이번 장에서는 RxSwift의 filtering operator에 대해 배울것임. filtering operator는 방출된 이벤트에 조건부 제한을 적용해서 subscriber가 다루길 원하는 것만 받게 할 수 있다. 스위프트 표준 라이브러리의 filter를 사용해봤다면 쉽게 이해할 수 있을 것임

## Ignoring operators

### ignoreElements

유용한 연산자 중 하나인 ignoreElements로 시작해보자. 아래 다이어그램에 묘사된 것 처럼 모든 next이벤트를 무시할 것이다. 하지만 completed나 error같은 stop이벤트는 허용할 것임

첫 번째 시퀀스는 옵저버블을 두 번째 시퀀스는 구독을 의미하고 가운데 박스는 연산자와 매개변수를 의미한다. 보이다싶이 1,2,3이벤트는 연산자에 가로막혀 구독에서 받지 못하지만 completed이벤트는 구독에 전달되었다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/497ccb36e215ed390f15d626b52a8537e633bb7555b18edce395c49beb42bdac/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/497ccb36e215ed390f15d626b52a8537e633bb7555b18edce395c49beb42bdac/original.png)

예시 코드를 통해 알아보자

```swift
let strikes = PublishSubject<String>()

let disposeBag = DisposeBag()

strikes
    .ignoreElements() /// 1...
    .subscribe { _ in
        print("You're out!")
    }
    .disposed(by: disposeBag)

strikes.onNext("X")
strikes.onNext("X")
strikes.onNext("X")

strikes.onCompleted()
/* print
You're out!
*/
```

///1… ignoreElements 연산자로 인해 next(X) 이벤트는 무시되고 마지막 completed(혹은 error) 이벤트만 수신된다.

### elementAt

만약 3번 째 스트라이크 같은 n번째 요소를 다루고 싶다면 elementAt을 사용할 수 있다. elementAt은 받고싶은 이벤트의 인덱스를 매개변수로 취하고 나머지는 이벤트는 모두 무시한다. 아래 다이어그램에서 확인 할 수 있듯이 ElementAt은 1번 인덱스만 전달하기때문에 2번 째 요소만 연산자를 통과하게 된다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/545a66fcd286681b88a477b45220fb66237bc3578c4b6dc83db4144c85e82024/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/545a66fcd286681b88a477b45220fb66237bc3578c4b6dc83db4144c85e82024/original.png)

예시 코드를 통해 알아보자

```swift
let strikes = PublishSubject<String>()

let disposeBag = DisposeBag()

strikes
    .elementAt(2) /// 1...
    .subscribe(onNext: { _ in
        print("You're out!")
    })
    .disposed(by: disposeBag)

strikes.onNext("X")
strikes.onNext("X")
strikes.onNext("X")

/* print
You're out!(onNext)
You're out!(onCompleted)
*/
```

/// 1... 인덱스 2 이벤트를 제외한 모든 이벤트를 무시하는 연산자를 적용했다. 따라서 3번 째 next이벤트를 수신할 것. 특이하게 곧바로 이어서 You're out! 콘솔에 출력된것을 확인 할 수 있는데 이는 elementAt 연산자가 해당 인덱스의 요소를 방출하자마자 구독이 종료되기 때문이다.

### filter

ignoreElements와 elementAt은 observable에서 방출된 요소를 필터링한다. 만약 그 이상의 필터링을 원하면 filter 연산자를 사용하자. filter 연산자는 술어 클로저를 취해서 방출되는 모든 요소에 그걸 적용하고 조건에 true를 만족하는 요소들만 통과시킨다.

아래 다이어그램을 보자. 필터 조건이 3보다 작은 요소만 통과이기때문에 1과 2만 통과할 것임

![https://assets.alexandria.raywenderlich.com/books/rxs/images/989c715734375e6df0a07a1e915e1537a3e5143649e656d30ccc48de8b1cb5dc/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/989c715734375e6df0a07a1e915e1537a3e5143649e656d30ccc48de8b1cb5dc/original.png)

2의 배수만 통과시키는 예시 코드이다.

```swift
let disposeBag = DisposeBag()

Observable.of(1, 2, 3, 4, 5, 6)
    .filter { $0.isMultiple(of: 2) }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/* print
2
4
6
*/
```

## ***\*Skipping operators\****

### skip

만약 몇개의 요소를 스킵하고싶으면 skip 연산자를 쓰자. skip 연산자는 처음 n개의 요소를 무시한다. n은 skip 연산자에 매개변수로 전달된다. 아래 마블다이어그램은 처음 2개의 요소를 스킵한다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/94cdc75444ac8e1cfa704c50eb89a82f62b0d10d6c8143f94a05cdd05c26e88c/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/94cdc75444ac8e1cfa704c50eb89a82f62b0d10d6c8143f94a05cdd05c26e88c/original.png)

처음 세 개의 요소를 스킵하는 예시 코드이다.

```swift
let disposeBag = DisposeBag()

Observable.of("A", "B", "C", "D", "E", "F")
    .skip(3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/* print
D
E
F
*/
```

### skipWhile

skip의 사촌격인 skipWhile이 있다. filter처럼 어떤 것을 스킵할지 정하는 술부를 포함한다. 하지만 구독하는 동안 계속 적용되는 filter와는 달리, skipWhile은 조건을 만족하는 순간까지 적용되고 그 순간을 포함해서 그 이후 이벤트는 모두 통과시킨다.

skipWhile는 filter와 반대로 조건이 true를 만족시킬 땐 스킵하고 false를 만족시킬 땐 통과시킨다.

아래 다이어그램에서 1은 조건을 만족시키기 때문에 스킵되고 2는 조건을 만족시키지 못하기 때문에 통과된다. 그이후 3부터 또한 통과된다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/988607fbb583f746546547d14d39cf06752417ce9aa076ccb72ca6dc1162145c/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/988607fbb583f746546547d14d39cf06752417ce9aa076ccb72ca6dc1162145c/original.png)

2의 배수까지는 스킵하는 예시 코드이다. 조건을 불만족시키는 3 이후로는 모두 통과하게 된다.

```swift
let disposeBag = DisposeBag()

Observable.of(2, 2, 3, 4, 4)
    .skipWhile { $0.isMultiple(of: 2) }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/* print
3
4
4
*/
```

예를 들어 skipWhile은 보험청구 앱에서 공제액을 충족시킬 때 까지 보장을 거부하기 위해 쓸 수 있다.

지금까지는 정적 조건에 기반해서 필터링을 했다. 만약 다른 옵저버블에 기반해서 요소를 동적으로 필터링하고싶다면 몇 가지 방법이 있다.

### skipUntil

첫 번째 방법은 skipUntil이다. skipUntil은 다른 트리거 옵저버블이 방출되기 전까지 구독하게 될 소스 옵저버블의 요소를 스킵한다. 아래 다이어그램에서 보이듯이 첫 번째 옵저버블의 요소는 두 번째 옵저버블이 방출될 때까지 스킵된다. 그 이후에는 스킵을 멈추고 모두 통과시킴

![https://assets.alexandria.raywenderlich.com/books/rxs/images/23d421e194c514b019a2b3a482048d1500431a37a0fdcedcf60f177b740c58c7/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/23d421e194c514b019a2b3a482048d1500431a37a0fdcedcf60f177b740c58c7/original.png)

트리거 옵저버블의 X 이벤트가 방출 될때까지 소스 옵저버블의 이벤트를 스킵하는 예시 코드이다.

```swift
let disposeBag = DisposeBag()

let subject = PublishSubject<String>()
let trigger = PublishSubject<String>()

subject
    .skipUntil(trigger)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

subject.onNext("A")
subject.onNext("B")
trigger.onNext("X")
subject.onNext("C")
/* print
C
*/
```

## ***\*Taking operators\****

### take

taking은 skipping의 반대이다. 아래 다이어그램은 처음 2개의 요소를 취한다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/3b833d205cebc28f891c44de2d44bc5eed0846c20a8ef97a7e0281f212559fa3/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/3b833d205cebc28f891c44de2d44bc5eed0846c20a8ef97a7e0281f212559fa3/original.png)

처음 3개의 이벤트를 취하는 예시 코드이다.

```swift
let disposeBag = DisposeBag()

Observable.of(1, 2, 3, 4, 5, 6)
    .take(3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag
/* print
1
2
3
*/
```

### takeWhile

takeWhile 또한 skipWhile과 비슷하다. 대신 조건을 만족할 때까지 이벤트를 받는다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/ca67614f60cde2fbd6194a0ee8a6d3624b7faa709fc7de7da4a58ef75ec9d287/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/ca67614f60cde2fbd6194a0ee8a6d3624b7faa709fc7de7da4a58ef75ec9d287/original.png)

### enumerated

추가로, 방출되는 요소의 인덱스 참조가 필요하면 enumerated 연산자를 사용 할 수 있다. enumerated 연산자는 옵저버블에서 방출된 각 요소들의 인덱스와 요소를 포함하는 튜플을 산출한다. 스위프트 표준 라이브러리의 enumerated외 비슷하다.

takeWhile과 enumerated 연산자로 요소가 2의 배수이고 인덱스가 3 미만인 것을 필터링하는 예시 코드이다.

```swift
let disposeBag = DisposeBag()

Observable.of(2, 2, 4, 4, 6, 6)
    .enumerated() /// 1...
    .takeWhile { index, integer in /// 2...
        integer.isMultiple(of: 2) && index < 3
    }
    .map(\\.element) /// 3...
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/* print
2
2
4
*/
```

/// 1… 요소의 인덱스와 요소의 값을 포함하는 튜플을 얻기 위한 연산자 enumerated

/// 2… 튜플을 각각의 인수로 해체

/// 3… 스위프트 표준라이브러리의 map과 같이 takeWhile에서 방출된 튜플에 접근해서 요소를 얻기위해 사용

### takeUntil

takeWhile과 반대로 takeUntil도 있다. takeUntil 연산자는 조건을 만족시킬 때 까지 요소를 취한다. 첫 번째 매개변수로 행동 인자도 받는데 이 인자는 조건을 만족시키는 마지막 요소를 포함할지 배제할지를 결정한다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/c2b8a74560f5af6634629c23136aeddb3f44cd8b25184a678a4d1a02400e96d6/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/c2b8a74560f5af6634629c23136aeddb3f44cd8b25184a678a4d1a02400e96d6/original.png)

요소가 4의 배수를 만족시킬 때 까지 취하고 4의 배수를 만족했을 때 해당 요소는 포함하지 않는 예시 코드이다.

```swift
let disposeBag = DisposeBag()

Observable.of(1, 2, 3, 4, 5)
    .takeUntil(.exclusive) { $0.isMultiple(of: 4) }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/* print
1
2
3
*/
```

skipUntil처럼 takeUntil도 트리거 옵저버블하고 같이 동작할 수 있다. 아래 다이어그램은 트리거 옵저버블의 이벤트 방출 전 까지 소스 옵저버블의 이벤트를 취하는 상황을 보여준다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/8edb5636252c95a49af09f6ff86ee0fb4a953bffe2a465a7f2f1bbe8c9e4a747/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/8edb5636252c95a49af09f6ff86ee0fb4a953bffe2a465a7f2f1bbe8c9e4a747/original.png)

트리거 옵저버블의 X 이벤트 이후 발생한 소스 옵저버블의 이벤트 3은 전달받지 못하는 예시 코드이다.

```swift
let disposeBag = DisposeBag()

let subject = PublishSubject<String>()
let trigger = PublishSubject<String>()

subject
    .takeUntil(trigger)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

subject.onNext("1")
subject.onNext("2")
trigger.onNext("X")
subject.onNext("3")
/* print
1
2
*/
```

takeUntil과 곧 배울 RxCocoa를 사용해서 disposeBag없이 구독을 폐기 할 수 있다. 코드로 알아만 두자.

```swift
_ = someObservable
    .takeUntil(self.rx.deallocated)
    .subscribe(onNext: {
        print($0)
    })
```

self는 보통 ViewController나 ViewModel이 될것임. self가 deallocated되면서 takeUntil이 이벤트 수신을 멈추게 한다. 그 후 completed로 구독은 종료된다. 일반적으로는 disposeBag을 사용하는게 메모리 누수를 피하기 위한 안전한 방법임

## ***\*Distinct operators\****

## distinctUntilChanged

다음 몇가지 연산자를 이용하면 중복된 연속 항목이 통과되는 것을 막을 수 있다. 아래 다이어그램에서 보이듯이 distinctUntilChanged는 각 요소 다음의 중복된 값만을 막는다. 그래서 두 번째 1은 통과한다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/2ce362dc3b6af6e4a48693b78fa0ad25a92322fffb3475fc41c0c634771b1367/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/2ce362dc3b6af6e4a48693b78fa0ad25a92322fffb3475fc41c0c634771b1367/original.png)

연속으로 방출되는 중복 값을 필터링 하는 예시 코드를 보자.

```swift
let disposeBag = DisposeBag()

Observable.of("A", "A", "B", "B", "A")
    .distinctUntilChanged()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/* print
A
B
A
*/
```

위 예시는 Equatable 프로토콜을 따르는 String 인스턴스인데 동등성 비교를 위해 distinctUntilChanged에 커스텀 로직을 제공 할 수도 있다. 전달 매개 변수는 비교 로직임

아래 마블다이어그램은 value라는 속성을 가진 오브젝트를 value에 기반해서 비교하는 상황을 보여준다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/65ce132da6b3164dca07f7c9f8fdfa35734713b4bb1277adb79b9d6e93c3b441/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/65ce132da6b3164dca07f7c9f8fdfa35734713b4bb1277adb79b9d6e93c3b441/original.png)

각 정수 쌍에서 하나가 다른 하나의 단어 구성 요소를 포함하지 않는다는 조건을 만족하는 고유한 정수만 출력하는 예시 코드를 보자.

```swift
let disposeBag = DisposeBag()

let formatter = NumberFormatter()
formatter.numberStyle = .spellOut

Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
    .distinctUntilChanged { a, b in
        guard
            let aWords = formatter
                .string(from: a)?
                .components(separatedBy: " "),
            let bWords = formatter
                .string(from: b)?
                .components(separatedBy: " ")
        else {
            return false
        }
        
        var containsMatch = false
        
        for aWord in aWords where bWords.contains(aWord) {
            containsMatch = true
            break
        }
        
        return containsMatch
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/* print
10
20
200
*/
```