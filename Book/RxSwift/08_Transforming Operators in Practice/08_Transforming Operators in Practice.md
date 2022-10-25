# 8장 Transforming Operators in Practice

이전 장에서 반응형 프로그래밍의 진정한 일꾼 map & flatMap 을 살펴봤다. 이 둘이 옵저버블을 변환하는 유일한 연산자는 아니지만 최소한 몇번이라도 써야한다. 이 둘을 잘 다루면 코드가 훨씬 발전할것임

&nbsp;

이번엔 non-Rx 코드로 만들어진 앱을 map과 flatMap을 이용해서 리팩토링 하면서 심화학습해보자.

&nbsp;

[TOC]

&nbsp;

## 1. GitFeed 앱

RxSwift 깃 레포지토리의 최신 활동들을 불러와서 표시하는 앱이며 주 기능 두가지가 있다.

* 깃허브 JSON API에 요청 뒤 JSON response를 받아서 콜렉션으로 변환하기
* 불러온 오브젝트를 디스크에 저장하고 서버에서 불러온 활동 이벤트 리스트 갱신 전에 테이블뷰에 보여주기 

&nbsp;

&nbsp;

## 2. Fetching data from the web

이전에 URLSession을 사용한 적이 있고 동작 원리를 알고 있길 바란다. 요약: web URL과 파라미터를 포함하는 URLRequest를 만든 다음 인터넷으로 보낸다. 잠시 후 서버 response를 받는다.

&nbsp;

현재 RxSwift지식으로ㅡ URLSession 클래스에 반응형 확장을 추가하는건 어렵다. 나중에 커스텀 반응형 확장을 추가하는걸 배우겠지만 이번 장에선 간단히 RxSwift의 동반 라이브러리인 RxCocoa에서 제공하는 솔루션을 쓰자.

&nbsp;

Rxcocoa는 RxSwift에 기반한 라이브러리인데 애플 프랫폼에서 RxSwift에 대한 개발을 돕는 많은 유용한 APIs들을 구현한다. RxSwift 자체를 RxJS, RxJava, RxPython 같은 구현들이 공유하는 공통 Rx API에 가깝게 유지하기위한 노력으로 모든 "그 외 기능" 들은 RxCocoa로 분리되었다. 추후 자세히 다루겠다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/754bc6f72b92e92154232b3d0382a1989434f8f1eb568be76fa408b554bd04ae/original.png](/Users/jihopark/Documents/Study/TIL/Book/RxSwift/08_Transforming Operators in Practice/assets/original-20221026002104982.png)

깃허브 API로 JSON을 빠르게 가져오기 위해 이번 장에서는 기본 RxCocoa URLSession 확장을 사용할 것임

&nbsp;

### Using map to build a request

첫 번째로 할 작업은 깃허브 서버로 보낼 URLRequest를 생성하는 것임. 반응형적으로 접근하기 때문에 처음에는 이해가 안될 수도 있지만 잠시 후 다시 보면 의미를 파악 할 수 있을거다.

&nbsp;

```swift
private let repo = "ReactiveX/RxSwift"

let response = Observable.from([repo])
```

web request를 만드는데 레포지토리 이름 string으로 시작하는 이유는 레포지토리 이름을 바꾸고 싶을 때를 대비해서 유연성을 가져가기 위함

&nbsp;

다음으로 레포지토리 주소를 받아서 활동 API 엔드포인트의 완전한 URL을 만들자.

```swift
.map { urlString -> URL in
  return URL(string: "https://api.github.com/repos/\(urlString)/events")!
}
```

완전한 URL을 만들기위해 하드코딩, 강제 추출 등 몇가지 편법을 쓰겠음. 결국 최신 이벤트의 JSON 데이터에 접근하기 위한 URL을 갖게 되었다. 클로저의 아웃풋 타입이 특정되어있는 것을 눈치 챘는가? 그래야만 할까? 분명한 답은 '아니다'이다. 대게 클로저의 인풋 아웃풋 타입을 명시할 필요는 없다. 대게 컴파일러가 추론하도록 남겨놓을 수 있다.

&nbsp;

그런데, 특히 여러 map과 flatMap 연산자가 함께 연결된 코드에서, 컴파일러를 도와줘야 한다. 컴파일러는 때때로 적절한 타입을 찾는데 실패할거다. 최소한 아웃풋 타입을 명시해서 컴파일러를 도울 수 있다. 만약 타입 mismatch나 missing 에러를 보면 클로저에 타입 정보를 추가할 수 있고 문제가 해결 될 거다.

&nbsp;

이제 URL이 있으니, 완전한 요청으로 변환 할 수 있다. 마지막 연산자에 연결하자.

```swift
.map { url -> URLRequest in
  return URLRequest(url: url)
}
```

map을 사용해서 제공된 웹 주소로 URL을 URLRequest로 변환했다.

복잡한 변환을 생성하기 위해 몇개의 map 연산자를 연결했다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/82d22f7f612c6a0ec879587afd225f4f991b68c4bbc20e27170c00d9d1b88034/original.png](/Users/jihopark/Documents/Study/TIL/Book/RxSwift/08_Transforming Operators in Practice/assets/original.png)

이제 flatMap을 사용해서 JSON 데이터를 가져와보자.

&nbsp;

### Using flatMap to wait for a web response

이전 장에서 flatMap이 옵저버블 시퀀스를 평면화 한다고 배웠다. flatMap의 일반적인 응용 중 하나는 변환 연결에 비동기성을 추가하는 것이다. 

&nbsp;

몇개의 변환(transformation)을 연결 할 때 작업은 동기적으로 일어난다. 말하자면, 모든 변환 연산자는 그들의 아웃풋을 즉시 실행한다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/30e13504e3b2162f89a72913b5dd1cf424b70b7fe3e2ba35dba9f100681774ad/original.png](/Users/jihopark/Documents/Study/TIL/Book/RxSwift/08_Transforming Operators in Practice/assets/original-20221026004408311-6712651.png)

이 연결 사이에 flatMap을 삽입하면 다양한 효과를 얻을 수 있다.

* string이나 int형 배열로 만든 옵저버블 같이 요소를 즉시 방출하고 완료하는 옵저버블을 평면화 할 수 있다. 
* 일부 비동기 작업을 수행하고 옵저버블이 완료될 때 까지 효과적으로 대기하는 옵저버블을 평면화 할 수 있고 그런 다음에만 나머지 연결 작업이 동작하도록 할 수 있습니다.

&nbsp;

GifFeed에서는 다음과 같은 동작이 필요하다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/6140a2c15bfa56dfaffb9429ba5d4e81ca67dd97f0ca8b24ef39f54434992132/original.png](/Users/jihopark/Documents/Study/TIL/Book/RxSwift/08_Transforming Operators in Practice/assets/original-20221026010153002-6713715.png)

그러기 위해 다음 코드를 마지막 연산자 체인에 추가하자.

```swift
.flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
  return URLSession.shared.rx.response(request: request)
}
```

shared URLSession에 RxCocoa의 response(request:) 메소드를 쓰자. 메소드는 앱이 웹 서버로부터 전체 응답을 받을 때마다 완료되는 Observable<(response: HTTPURLResponse, data: Data)>를 리턴한다.

&nbsp;

RxCocoa의 rx 확장과 Foundation과 UIKit을 어떻게 확장하는지 그리고 response(request:) 는 연결이 없거나 URL이 잘못됐을 때 에러를 뱉기 때문에 flatMap body에서 에러 캐치를 해야 하는데 나중에 살펴보자.

&nbsp;

웹 요청의 결과에 더 많은 구독을 허용하기 위해 share를 마지막 연결에 추가하자. 옵저버블을 공유하고 마지막 방출 이벤트를 버퍼(메모리의 임시 저장 공간)에 담을 수 있다.

```swift
.share(replay: 1)
```

6장에서의 share()를 썻던것과 다른데 차이를 보자

&nbsp;

**share() vs. share(replay: 1)**

URLSession.rx.response(request:)는 요청을 서버로 보내고 응답을 받는 즉시 응답 데이터와 함께 next 이벤트를 한 번 방출하고 완료된다.

&nbsp;

이 상황에서, 만약 옵저버블이 완료되고 그런 다음 그 옵저버블을 다시 구독하면, 새로운 구독이 생성되고 또 다른 서버 요청이 발생한다.

&nbsp;

이런 일이 발생하는 걸 막기 위해 share(replay:scope:)를 사용한다. 이 연산자는 방출된 마지막 요소를 버퍼에 보관하고 새로 구독한 관찰자에게 전달한다. 그러므로 만약 요청이 완료되고 새로운 관찰자가 share(replay:scope:)로 공유된 시퀀스를 구독하면, 관찰자는 버퍼된 이전에 실행된 네트워크 요청에 대한 응답을 즉시 받는다. 

&nbsp;


.whileConnected과 .forever 두 가지 사용 범위를 고를 수 있다. whileConnected는 요소를 구독자가 전부 사라지는 순간까지 보관하고 forever는 버퍼 된 요소를 영원히 유지한다. 멋지지만 앱에 의해 얼마나 많은 메모리가 사용될지 고려하자.

&nbsp;

각각 범위에 따라 앱이 어떻게 동작하는지 보자.

* .forever : 버퍼 된 네트워크 응답이 영원히 유지된다. 새 구독자는 버퍼 된 응답을 받는다.
* .whileConnected : 버퍼 된 네트워크 응답은 더 이상 구독자가 없을 때까지 유지된다. 그리고 폐기된다. 새 구독자는 새로운 네트워크 응답을 받는다.

share(replay:scope:) 사용의 경험법칙은 완료될 것으로 기대하는 어떤 시퀀스에든 사용하거나 혹은 무거운 작업을 유발하는데 여러 번 구독되는 시퀀스에 사용하는 것이다. 이 방법으로 옵저버블이 어떤 추가 구독으로부터 재생성 되는 것을 막을 수 있다.

&nbsp;

또한 새 구독자가 자동으로 마지막 방출된 n개의 이벤트를 받게 하고 싶을 때 쓸 수 있다. 











