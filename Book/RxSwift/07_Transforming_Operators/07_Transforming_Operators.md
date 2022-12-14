# 7장 Transforming Operators

RxSwift를 처음 배울 때 난해하고 피하고싶고지만 이상하게 마스터해야 하는 것이라고 생각하지 않았는가? 맞다.. 생경한 개념이고 난해했지만 복잡한 작업을 편하게 해주는 툴이라는 느낌 받음!

RxSwift는 마법이 아니라 유저와 유저의 코드를 위해 많은 일들을 해주는 정성스럽게 구현된 API이다!

&nbsp;

이번 장에서는

- RxSwift 연산자 중 가장 중요한 카테고리인 변환 연산자에 대해 배우고

- 구독자가 사용할 옵저버블에서 온 데이터를 준비하기 위해 항상 변환 연산자를 사용할 것!

  filtering operation과 마찬가지로 RxSwift의 연산자와 스위프트 표준 라이브러리 사이에 map과 flatMap처럼 공통점이 있다.

&nbsp;

[TOC]

&nbsp;

## 1. Transforming elements

### toArray

옵저버블은 요소를 개별적으로 방출하는데, 콜렉션 형태로 처리하고 싶은 경우자 자주 있을것임. 특히 옵저버블을 테이블뷰나 컬렉션뷰에 바인딩할때. 간편한 방법은 toArray를 이용해서 개별 요소 옵저버블을 모든 요소의 배열로 변환하는것임

아래 다이어그램에서 보듯이 toArray는 옵저버블이 완료됐을 때 요소들의 옵저버블 시퀀스를 모든 요소들의 배열로 변환한다. toArray는 값을 가진 success이벤트 혹은 error이벤트만을 방출하는 Single을 리턴한다. 아래 경우 구독자에게 배열을 포함하는 success 이벤트를 방출할 것임

![https://assets.alexandria.raywenderlich.com/books/rxs/images/93f3f15fe2416830154d3d7f036499b402e82d29953a0f7f80038b62c2b583bb/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/93f3f15fe2416830154d3d7f036499b402e82d29953a0f7f80038b62c2b583bb/original.png)

&nbsp;

toArray 연산자 이후에 onSuccess를 통해 배열값을 받는걸 코드로 확인해보자.

```swift
let disposeBag = DisposeBag()

Observable.of("A", "B", "C")
    .toArray()
    .subscribe(onSuccess: {
        print($0)
    })
    .disposed(by: disposeBag)
/* print
["A", "B", "C"]
*/
```

❗서브젝트 같은 핫 옵저버블의 이벤트를 받아 toArray로 처리할 때 take(10)같이 처리할 이벤트의 개수를 명시해줘야 함. 그렇지 않으면 언제 toArray()를 해야 할 지 알 수 없음

&nbsp;

### map

RxSwift의 map연산자는 옵저버블에 대해 동작한다는 것만 제외하면 스위프트 표준 라이브러리의 map연산자 처럼 동작한다. 아래 마블 다이어그램의 map은 각 요소에 2를 곱하는 클로저를 취한다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/6a648c0e2b39e0235045487bb24e40caaaeec25566afc9b62ae40efa09c90944/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/6a648c0e2b39e0235045487bb24e40caaaeec25566afc9b62ae40efa09c90944/original.png)

&nbsp;

또 다른 Int형 타입을 받아서 철자 문자열을 리턴하는 map의 사용 예시를 코드로 보자.

```swift
let disposeBag = DisposeBag()

let formatter = NumberFormatter()
formatter.numberStyle = .spellOut

Observable<Int>.of(123, 4, 56)
    .map {
        formatter.string(for: $0) ?? ""
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
```

&nbsp;

5장에서 enumerate와 map연산자를 함께 써서 filtering 연산자와 쓰는걸 배웠는데 또 다른 예시 코드를 보자.

```swift
example(of: "enumerated and map") {
  let disposeBag = DisposeBag()

  Observable.of(1, 2, 3, 4, 5, 6)
    .enumerated() /// 1...
    .map { index, integer in /// 2...
      index > 2 ? integer * 2 : integer
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)
}
/* print
1
2
3
8
10
12
*/
```

/// 1… enumerator를 이용해서 각 요소와 요소의 인덱스로 이루어진 튜플 생성

/// 2… map을 이용해서 튜플을 각각 요소로 해체하고 인덱스가 2보다 초과이면 요소에 2를 곱하고 그 값을 리턴 2 이하이면 원래 값을 그대로 리턴

&nbsp;

### compactMap

filter 연산자 또한 배웠는데, compactMap는 특별히 nil값을 거르는 map과 filter가 결합된 연산자이다. 스위프트 표준 라이브러리의 compactMap과 비슷하다.

&nbsp;

아래 코드로 compactMap이 nil 요소를 필터링 하는것을 확인해보자.

```swift
let disposeBag = DisposeBag()

Observable.of("To", "be", nil, "or", "not", "to", "be", nil)
    .compactMap { $0 }
    .toArray()
    .map { $0.joined(separator: " ") }
    .subscribe(onSuccess: {
        print($0)
    })
    .disposed(by: disposeBag)
/* print
To be or not to be
*/
```

지금까지는 정규 값의 옵저버블로 작업했다. 아마 옵저버블의 프로퍼티인 옵저버블과 어떻게 작업할지 궁금했을거다. 클래스나 구조체의 속성으로써 옵저버블을 얘기하는건가?

&nbsp;

&nbsp;

## 2. Transforming inner observables

```swift
struct Student {
  let score: BehaviorSubject<Int>
}
```

Student는 BehaviorSubject<Int>타입의 score 프로퍼티를 갖고 있는 구조체다. RxSwift는 옵저버블에 접근해서 그것의 옵저버블 프로퍼티와 작업 할 수 있도록 flatMap 가족에 몇개의 연산자를 포함한다. 두 가지 가장 흔한 경우를 배워보자.

❗시작하기 전 주의! : 이 연산자들은 RxSwift 뉴비들에게 끝없는 신음소리를 내게 해왔다. 일견 복잡해 보이겠지만 각각 자세한 설명을 통해 헤쳐나갈 것임. 이 장 막바지엔 자신있게 이 연산자들을 쓸 수 있을거다.

&nbsp;

### flatMap

flatMap부터 시작해보자. 문서에는 “옵저버블 시퀀스의 각 요소를 옵저버블 시퀀스에 투영하고, 옵저버블 시퀀스의 결과를 하나의 옵저버블 시퀀스로 합병한다.”라고 쓰여져있다. 후!

설명과 마블다이어그램을 보고 압도 될수도 있다. 마블다이어램을 따라 차근차근 알아보자.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/492a28eca6f36d04b2445d82e64553f76e7d51e12caf1bc4e35947f361618051/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/492a28eca6f36d04b2445d82e64553f76e7d51e12caf1bc4e35947f361618051/original.png)

위 다이어그램에서 무슨 일이 일어나는지 따라가는 가장 쉬운 방법은 맨 위 소스 옵저버블에서 구독자에게 요소를 전달하는 맨 아래 타겟 옵저버블로 통하는 각 경로를 보는것

&nbsp;

소스 옵저버블은 Observable<Int>타입의 value 프로퍼티를 가진 오브젝트 타입이다. value 프로퍼티의 초기값은 오브젝트의 숫자이다. 즉 Object1의 초기값은 1이고, O2는 2, O3은 3이다.

&nbsp;

O1부터, flatMap은 Object를 받아서 flatMap아래 첫 번째 라인에 있는 O1만을 위해 새로 생성한 옵저버블에 value 프로퍼티를 투영하기 위해 뻗어나간다. 새 옵저버블은 그때 맨 아래 타겟 옵저버블 라인으로 평면화 된다.

평면화? 스위프트 표준 라이브러리에서 flatMap이 2차원 배열을 1차원 배열로 만들어주는걸 생각해보자. [[1,2,3],[nil,5],[6,7]] → [optional(1),optional(2),optional(3),nil,optional(5),optional(6),optional(7)] 로 평면화 되었다!

&nbsp;

시간이 지나, O1의 value 프로퍼티는 4로 바뀐다. 마블다이어그램에는 안나타났지만 그 증거는 O1을 위한 기존 옵저버블에 4가 투영된 후 타겟 옵저버블로 평면화 됐다는 것임

&nbsp;

소스 옵저버블의 다음 값 O2도 flatMap에 보내진다. 초기값은 2이고 O2를 위한 옵저저블에 투영된다. 그 후 타겟 옵저버블로 평면화되고, 후에 O2의 value는 5로 바뀌고 5 역시 타겟 옵저버블로 평면화된다.

&nbsp;

마지막으로 O3도 flatMap으로 보내지며 초기값 3이 투영된 후 평면화된다.

&nbsp;

요약하자면, flatMap은 옵저버블의 옵저버블 value를 투영하고 변환한다. 그리고 타겟 옵저버블로 평면화 한다.

&nbsp;

아래 코드로 실습해보자.

```swift
let disposeBag = DisposeBag()

let laura = Student(score: BehaviorSubject(value: 80))
let charlotte = Student(score: BehaviorSubject(value: 90))

let student = PublishSubject<Student>() /// 1...

student
    .flatMap { /// 2...
        $0.score
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

student.onNext(laura) /// 3...
laura.score.onNext(85) /// 4...
student.onNext(charlotte)
laura.score.onNext(95)
charlotte.score.onNext(100) /// 5...

/* print
80
85
90
95
100
*/
```

/// 1… Student 타입의 소스 서브젝트(옵저버블) 생성

/// 2… flatMap 사용해서 student 오브젝트의 값에 접근해서 score 프로퍼티를 투영한다.

/// 3… student 구독자에게 소스 서브젝트(옵저버블) laura를 방출하면 flatMap은 laura 오브젝트를 받아서  score 프로퍼티에 대한 새 옵저버블 생성 뒤 투영한다. 그리고 score는 평면화되어 구독자에게 전달된다.

/// 4… 3에서 flatMap이 score 프로퍼티에 대한 새 옵저버블을 생성하며 계속 추적하기 때문에 laura 오브젝트의 score 프로퍼티로 값이 변경되면 새 옵저버블에 변경된 값이 투영된 후 타겟 옵저버블로 평면화된다.

/// 5… charlotte의 score의 변경 또한 평면화되는것으로 보아 소스 서브젝트(옵저버블)의 모든 오브젝트가 모니터링되고 변경이 투영되고 있음을 확인 할 수 있다.

&nbsp;

요약하자면, flatMap은 각 옵저버블로부터의 변화를 계속 투영한다. 그런데 옵저버블 요소의 최신 요소만 유지하고싶으면 flatMapLatest를 사용하자.

&nbsp;

### flatMapLatest

flatMapLatest 연산자는 사실 map과 switchLatest 연산자의 결합이다. switchLatest는 다음 장 Combining Operators에서 배울건데 살짝 엿보고 가자. switchLatest는 가장 최근의 옵저버블로부터 값을 생성하며 이전 옵저버블에서 구독을 취소한다.

&nbsp;

문서에는 “옵저버블 시퀀스의 각 요소를 옵저버블 시퀀스의 새로운 시퀀스로 투영한다. 그런 다음 옵저버블 시퀀스의 옵저버블 시퀀스를 가장 최근의 옵저버블 시퀀스에서만 값을 생성하는 옵저버블 시퀀스로 변환한다.” 라고 쓰여있다 😨. 너무 복잡하지만 이미 flatMap을 배웠고 많이 다르지 않다. 마블다이어그램을 보자.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/3fcea2810ef2d2c6fc0fc7a501c5ae05230c977cf0275cb2a4130b01a0140eb3/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/3fcea2810ef2d2c6fc0fc7a501c5ae05230c977cf0275cb2a4130b01a0140eb3/original.png)

flatMapLated는 flatMap처럼 옵저버블의 프로퍼티에 접근하기 위해 옵저버블의 요소에 도달해서 프로퍼티를 소스 옵저버블의 각 요소를 위한 새 시퀀스에 투영한다. 이들 요소는 구독자에게 요소를 제공할 타겟 옵저버블로 평면화된다. flatMap과의 다른 점은 자동으로 최신 옵저버블로 전환하고 이전의 옵저버블에 구독을 취소한다는 것이다.

&nbsp;

위 마블다이어그램에서 O1은 flatMapLatest에 보내져서 O1을 위한 새 옵저버블에 value를 투영한다. 그리고는 타겟 옵저버블로 평면화된다. 이전과 같지만 flatMapLatest는 O2를 받고 O2로 전환한다, 왜냐면 O2가 가장 최신이기 때문에.

&nbsp;

O3가 보내졌을 때 또한 같은 과정을 반복한다. 시퀀스를 전환하고 이전 옵저버블(O2)는 무시한다. 그 결과, 타겟 옵저버블은 최신 옵저버블로부터의 요소만을 받게 된다.

&nbsp;

flatMap을 flatMapLatestfh 바꾼 코드를 통해 확인해보자.

```swift
let disposeBag = DisposeBag()

let laura = Student(score: BehaviorSubject(value: 80))
let charlotte = Student(score: BehaviorSubject(value: 90))

let student = PublishSubject<Student>()

student
    .flatMapLatest { /// 1...
        $0.score
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

student.onNext(laura)
laura.score.onNext(85)
student.onNext(charlotte)
laura.score.onNext(95) /// 2...
charlotte.score.onNext(100)
/* print
80
85
90
~~95~~
100
*/
```

/// 1… flatMap → flatMapLatest로 변경

/// 2… laura의 score를 바꿔도 print되지 않는다. 왜냐면 flatMapLatest가 가장 최신 옵저버블인 charlotte으로 전환했기 때문.

&nbsp;

언제 flatMapLatest을 사용할까? 가장 흔한 경우는 네트워킹 작업이다. 나중에 배울것임. 자동완성 검색 기능을 구현한다고 상상해보자. 유저가 s,w,i,f,t 각 글자를 입력할때 새로운 검색을 실행하고 이전 검색의 결과는 무시하고 싶을거다. 이때 flatMapLatest가 좋은 선택이다.

&nbsp;

## **Observing events**

옵저버블을 이벤트의 옵저버블로 변환하고 싶을 때가 있을 수도 있다. 이게 유용한 일반적인 시나리오 중 하나는 옵저버블 프로퍼티를 갖고있는 옵저버블을 제어할 수 없고 외부 시퀀스 종료를 피하기 위해 에러 이벤트를 처리하려는 경우이다.

코드로 예시를 보자

```swift
enum MyError: Error { /// 1...
    case anError
}

let disposeBag = DisposeBag()

/// 2...
let laura = Student(score: BehaviorSubject(value: 80))
let charlotte = Student(score: BehaviorSubject(value: 100))

let student = BehaviorSubject(value: laura)
```

/// 1… 에러를 처리하기 위해 커스텀 에러 타입 생성

/// 2… Student의 인스턴스 두 개와 laura를 초기값으로 갖는 student  behavior subject를 생성

&nbsp;

앞에 두 예시처럼 flatMapLatest을 이용해서 Student 옵저버블 내부의 score 프로퍼티를 구독해보자.

```swift
let studentScore = student
    .flatMapLatest { /// 1...
        $0.score
    }

studentScore
    .subscribe(onNext: {
        print($0) /// 2...
    })
    .disposed(by: disposeBag)

/// 3...
laura.score.onNext(85)
laura.score.onError(MyError.anError)
laura.score.onNext(90)

/// 4...
student.onNext(charlotte)
/* print
80
85
Unhandled error happened: anError
*/
```

/// 1… flatMapLatest로 student 옵저버블의 score 옵저버블 프로퍼티에 접근해서 student score 생성

/// 2… score를 구독하고 방출 될 때마다 print

/// 3… student에 score(85), error, 또 다른 score(90) 추가

/// 4… student 옵저버블에 두 번째 student charlotte 추가. flatMapLatest을 사용했기 때문에 새 student로 전환되고 charlotte의 scorefmf 구독하고 이전 laura에 대한 구독은 취소

&nbsp;

에러가 처리되지 않아서 studentScore 옵저버블이 종료되고 외부 student 옵저버블도 종료됐다.

materialize 연산자를 사용해서 옵저버블안의 옵저버블에서 발생하는 각 이벤트를 래핑할 수 있다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/a65b03407dbad709f7c767261865519a3882df536ac6522e73bedb0297e7088a/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/a65b03407dbad709f7c767261865519a3882df536ac6522e73bedb0297e7088a/original.png)

&nbsp;

studentScore 구현을 다음과 같이 바꾸자.

```swift
let studentScore = student
  .flatMapLatest {
    $0.score.materialize()
  }
/* print
next(80)
next(85)
error(anError)
next(100)
*/
```

materialize를 추가함으로써 studentScore가 `Observable<Int>`에서 `Observable<Event<Int>>`로 바뀌었다. 그리고 studentScore에 대한 구독은 event를 방출한다. 에러는 여전히 studentScore를 종료시키지만 외부 student 옵저버블은 종료시키지 않는다. 그래서 새로운 student charlotte로 전환할 때 charlotte의 score는 성공적으로 수신되고 print된다.

&nbsp;

그런데 지금은 요소가 아닌 이벤트를 다루고있다. dematerialize가 등장할때다. dematerialized는 materialized된 옵저버블을 원래의 형태로 되돌린다.

&nbsp;

구독 부분을 다음과 같이 수정하자.

```swift
///1 ...
    .filter {
        guard $0.error == nil else {
            print($0.error!)
            return false
        }
        
        return true
    }
/// 2...
    .dematerialize()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/* print
80
85
anError
100
*/
```

/// 1... 어떤 에러든 거르고 print

/// 2... dematerialize를 사용해서 studentScore 옵저버블을 원래 형태로 되돌리고, score의 이벤트를 방출하고 멈추는게 아닌 score를 방출하고 이벤트를 멈춘다. 

&nbsp;

이제 student 옵저버블은 내부 score 옵저버블의 오류로 보호된다. 에러가 print되고 laura의 studentScore는 종료된다. 그래서 laura에게 새로운 score를 더해도 아무일도 일어나지 않는다. 그러나 student 서브젝트에 charlotte을 추가하면, charlotte의 score가 프린트됨

&nbsp;

### unwrap

unwrap은 RxSwiftExt의 연산자인데 옵셔널값을 다루는데 사용 되는 편의 사항이다.

```swift
Observable.of(1, 2, nil, 3)
  .filter { $0 != nil }
  .map { $0! }

Observable.of(1, 2, nil, 3)
  .unwrap()
