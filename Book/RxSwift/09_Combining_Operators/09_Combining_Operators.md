# 9장 Combining Operators

이전 장에서 옵저버블 시퀀스를 어떻게 만들고 filter하고 transform하는지 배웠다. RxSwift의 filtering과 transforming 연산자는 스위프트의 표준 라이브러리의 콜렉션 연산자처럼 동작한다. 또한 적은 코드로 많은 일을 가능케하는 flatMap을 통해 RxSwift의 진정한 힘을 맛봤다.

&nbsp;

이번 장은 시퀀스를 모으는 몇가지 다른 방법과 각 시퀀스의 데이터를 어떻게 합치는지를 보여줄 것임. 몇가지 연산자는 마찬가지로 스위프트 콜렉션 연산자와 비슷하게 동작할 것임. 이 연산자는 배열과 마찬가지로 비동기 시퀀스의 요소를 결합하는데 도움을 준다.

&nbsp;

[TOC]

&nbsp;

## 1. Prefixing and concatenating

옵저버블을 사용할 때 가장 먼저 필요한건 옵저버가 초기 값을 받도록 보장하는 것임. "현재 상태"가 먼저 필요한 상황이 있다. 좋은 용례는 "현재 위치"와 "네트워크 연결 상태" 이다. 이런 것들은 현재 상태를 접두사로 붙이고 싶은 옵저버블이다.

&nbsp;

### startWith

아래 다이어그램은 startWith 연산자가 하는 일을 잘 나타냄

![https://assets.alexandria.raywenderlich.com/books/rxs/images/696c2a32f2b9b3771978c060c98b422912647f90841ba140a7921127b4d2c7de/original.png](./assets/original-20221108231611779.png)

코드로 표현하면 다음과 같다

```swift
  let numbers = Observable.of(2, 3, 4)

  let observable = numbers.startWith(1)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
/* print
1
2
3
4 */
```

startWith 연산자는 주어진 초기 값을 옵저버블 시퀀스 앞에 붙인다. 초기 값은 옵저버블의 요소와 같은 타입이어야 함

numbers 옵저버블 뒤에 연결했기 때문에 순서는 뒤이지만 맨 앞 초기 값으로 방출되는것에 주의

&nbsp;

startWith 연산자는 많은 상황에서 쓰게 될 것임. RxSwift의 결정론적인 특성과 잘맞고 옵저버들이 초기값을 즉시 받은 이후 업데이트를 받는것을 보장한다.

stratWith는 더 일반적인 concat 연산자 계열의 간단한 변형이다. 초기 값은 한 개 요소의 시퀀스인데, RxSwift는 startWith 연결로 그 시퀀스에 다른 시퀀스를 추가한다. concat 정적 함수는 두 시퀀스를 연결한다.

&nbsp;

### concat

concat 연산자의 다이어그램과 코드를 보자

![https://assets.alexandria.raywenderlich.com/books/rxs/images/fd1e4309638dd5fdeea664ce6ba0ef0cca4a34775c87b4fe09e5dd7660c8c174/original.png](./assets/original-20221108231545773.png)

```swift
 let first = Observable.of(1, 2, 3)
 let second = Observable.of(4, 5, 6)

 let observable = Observable.concat([first, second])

 observable.subscribe(onNext: { value in
    print(value)
 })
```

startWith를 사용할 때 보다 연결 순서가 더 명확하다. 123 다음 456을 볼 수 있다.

&nbsp;

Observable.concat(_:) 정적 메소드는 옵저버블의 정렬된 콜렉션(배열) 혹은 옵저버블의 다양한 리스트를 취한다. 콜렉션의 첫번째 시퀀스를 구독하고 요소가 complete될때까지 전달한다음 다음 시퀀스로 넘어간다. 과정은 콜렉션안의 모든 옵저버블이 사용될 때 까지 반복된다. 만약 옵저버블의 어느 지점에서 에러가 방출되면, 연결된 옵저버블은 차례로 에러를 방출하고 종료된다.

&nbsp;

시퀀스를 추가하는 또 다른 방법은 concat 연산자이다(클래스 메소드가 아닌 Observable의 인스턴스 메소드임). 다음 코드를 보자.

```swift
  let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
  let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")

  let observable = germanCities.concat(spanishCities)
  _ = observable.subscribe(onNext: { value in
    print(value)
  })
/* print
Berlin
Münich
Frankfurt
Madrid
Barcelona
Valencia
*/
```

이런 변형은 기존의 옵저버블에 적용한다. 소스 옵저버블이 complete될 때까지 기다린 후, 매개 변수 옵저버블을 구독한다. 인스턴스화를 제외하곤 Observable.concat(클래스 메소드)처럼 동작한다. 콘솔을 보면 독일 도시 목록과 뒤따르는 스페인 도시 목록을 확인 할 수 있을 것임

옵저버블 시퀀스는 매우 형식적이다. 그래서 타입이 같은 요소의 시퀀스만을 연결 지을 수 있다!

다른 타입의 시퀀스를 연결지으려고하면 컴파일러 에러가 날 것임. 스위프트 컴파일러는 시퀀스 타입을 알기 때문에 Observable<String>과 Observable<Int>를 섞는걸 허용하지 않을것임

&nbsp;

### concatMap

마지막으로 concatMap 연산자는 7장에서 배운 flatMap과 밀접한 연관이 있다. concatMap에 전달한 클로저는 연산자가 먼저 구독한 옵저버블 시퀀스를 리턴한다. 그런다음 방출하는 값을 결과 시퀀스로 전달한다. concatMap(_:)은 클로저가 생성하는 각 시퀀스가 다음 옵저버블 시퀀스를 구독하기 전에 완료됨을 보장한다. flatMap의 힘과 함께 순차적인 순서를 보장하는 편리한 방법이다(concat + flatMap인듯?). 아래 코드를 보자.

```swift
  /// 1...
  let sequences = [
    "German cities": Observable.of("Berlin", "Münich", "Frankfurt"),
    "Spanish cities": Observable.of("Madrid", "Barcelona", "Valencia")
  ]

  /// 2...
  let observable = Observable.of("German cities", "Spanish cities")
    .concatMap { country in sequences[country] ?? .empty() }

  /// 3...
  _ = observable.subscribe(onNext: { string in
      print(string)
    })
/* print
Berlin
Münich
Frankfurt
Madrid
Barcelona
Valencia
*/
```

/// 1... 독일과 스페인의 도시 이름을 생성하는 두 개의 시퀀스 준비

/// 2... 나라 이름을 방출하는 시퀀스가 있고 차례로 이 나라의 도시 이름을 방출하는 시퀀스에 매핑

/// 3... 다음 국가 시작을 고려하기 전 먼저 독일의 모든 시퀀스를 방출 한다.

이제 시퀀스를 어떻게 함께 추가하는지 알았으니 여러 시퀀스로부터 요소들을 결합하는것을 알아보자.

&nbsp;

&nbsp;

## 2. Merging









 





















