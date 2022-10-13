# 1. RxSwift

RxSwift를 정의하자면 관찰 가능한 시퀀스(흐름)과 함수형 스타일의 오퍼레이터를 이용해서 비동기 및 이벤트 기반 코드를 구현 할 수 있도록 도와주는 라이브러리라고 할 수 있다.

좀 더 개발 친화적으로 정의한다면 코드가 새로운 데이터에 반응하고 순차적이고 격리된 방식으로 처리하도록 해서 비동기 프로그래밍을 간소화 시키는 툴

## 1. 비동기 프로그래밍?

앱에서 버튼에 반응하는 것, 텍스트필드를 탭 했을때 키패드가 올라오는 것, 이미지를 다운 받는 것, 음악을 듣는 것 등의 다양한 동작이 동시에 일어난다.

각각의 작업들이 동시에 일어날때 다른 작업들의 동작을 멈추지 않는데, 이는 iOS에서 각각의 작업들이 다른 스레드레에서 동작할 수 있도록 iOS에서 NotificationCenter, Delegate Pattern, GCD, Closure, Combine등의 다양한 API를 제공하기 때문

그런데 애플이 제공하는 API들을 사용한다면 앱을 일관된 상태로 유지하는건 어려워질것임

실제로 NotificationCenter나 Delegate Pattern으로 코딩하면서 비동기 처리하는 부분이 파편화되어 가독성 및 유지보수가 어려워짐을 느끼고있었음

비동기 프로그래밍의 예시를 보고 특징을 알아보자

```
var array = [1, 2, 3]
var currentIndex = 0

// This method is connected in Interface Builder to a button
@IBAction private func printNext() {
  print(array[currentIndex])

  if currentIndex != array.count - 1 {
    currentIndex += 1
  }
}

```

유저가 버튼을 탭할때마다 array를 출력하고 있다.

그런데 다른 코드에서 array의 순서 혹은 요소를 변경하거나 currentIndex를 변경한다면?

처음에 의도한대로 동작하지 않을 수도 있다.

비동기 코드에서 드러나는 문제점은 다음과 같다

1. 작업 수행 순서
2. 변경 가능한 공유된 데이터

RxSwift가 어떻게 동작하고 위 문제를 풀어내는지 알아보기 전에 다음 용어를 숙지하자

### 비동기 프로그램 용어

RxSwift에서 등장하는 몇몇 단어는 비동기, 반응형, 함수형 프로그래밍 등과 밀접한 연관이 있는데 RxSwift는 다음과 같은 문제를 해결하고자 한다.

### 상태, 특히 변경 가능한 공유된 데이터

노트북을 몇 주 동안 종료하지 않고 사용하면 갑자기 멈추거나 느려지는 현상을 경험해봤을것이다.

하드웨어와 소프트웨어는 변한게 없는데? 그건 상태가 변했기 때문에 나타난 현상이다.

메모리의 데이터, 하드디스크의 데이터, 사용자 입력에 대한 반응과 관련된 부산물들 모든것이 노트북의 상태이다.

다양한 비동기 요소들간에 공유된 앱의 상태 관리를 배울 것임

### 명령형 프로그래밍

컴퓨터에게 어떻게 할지 일련의 코드 시퀀스를 전달하는 것

문제는 복잡한 비동기식 앱을 명령형 코드로 구현하기 어렵다는것

특히 앱의 공유된 상태가 동작과 관련되어있을 때 메소드 호출 순서가 바뀌면 의도와 다르게 동작 할 수 있음

### 부작용

변경 가능한 공유데이터와 명령형 프로그래밍 두 가지로부터 발생하는 이슈라고 할 수 있다.

부작용은 코드가 의도했던 범위 밖의 변화를 말하는데 디스크에 저장된 데이터를 변경하거나 UI를 업데이트할 때 발생한다.

용어의 뉘앙스 때문에 그렇지 나쁜건 아닌것 같다 왜냐하면 결국 부작용을 발생시키는 것이 모든 프로그램의 궁극적인 목표기때문에

잠시 동작하고 아무것도 못하는 앱은 쓸모가 없다. 프로그램의 동작이 끝나고 어떤 변화를 만들어내야 함.

중요한 것은 통제된 방식으로 부작용을 생성하는것임

어떤 코드가 부작용을 일으키는지, 단순히 데이터를 처리하고 출력하는지 결정할 수 있어야 한다.

RxSwift는 아래 몇가지 개념을 통해 위 문제들을 해결하고자 한다.

### 선언현 프로그래밍

명령형 프로그래밍에서는 상태를 마음대로 바꾸고 함수형 프로그래밍에서는 부작용 일으키는 코드를 최소화 한다.

RxSwift는 두 프로그래밍의 장점을 조합한다.

선언형 프로그래밍은 행동을 정의하도록 하는데 RxSwift는 이 행동들을 관련 이벤트가 발생했을때 동작하도록 하고 불변하고 격리된 데이터를 제공한다.

이 방식으로 비동기 코드로 작업할 수 있지만 불변의 데이터로 순차적이고 결정적인 방식으로 작업하는 간단한 ****for문과 같다고 가정을 해보자.

### 반응형 시스템

반응형 시스템이란 다음과 같은 특징을 모두 혹은 일부 나타내는 웹과 앱을 포함하는 훨씬 추상적인 용어임

- (반응성)Responsive: 앱이 최신 상태를 나타내도록 항상 UI를 최신 상태로 유지한다.
- (탄력)Resilient: 각 행동은 개별 정의되어있고 유연한 오류 복구를 제공한다.(데미지를 견디고 원상태로 돌아오는 성질)
- (탄력성)Elastic: 다양한 작업을 처리하고 종종 지연 풀기반 데이터 수집과 이벤트 제한, 리소스 공유 같은 기능을 구현한다(고무처럼 상태가 유연하게 변하는 성질)
- 메세지-기반(Message-driven): 요소들은 개선된 재사용성과 격리를 위해서 메세지-기반 통신을 사용하며 수명주기와 클래스 구현을 분리시킨다.

반응형 시스템 용어가 생소하고 어렵게 느껴지는데 일단 Rx 코드의 구성요소와 동작방법을 알아보자

## 2. RxSwift의 기원

반응형 프로그래밍은 새로운 개념이 아니라 꽤 오래전부터 있던 개념이다.

하지만 최근 십수년간 핵심 개념들이 주목을 끌었다.

최근 웹앱은 복잡한 비동기적 UI를 다루는 문제를 직면해왔으며 서버측에서는 반응형 시스템이 필수가 되었다.

마이크로소프트의 팀은 비동기식의 확장가능한 실시간 앱 개발의 문제를 해결하는 과제에 착수했다.

2009년경 .net을 위한 클라이언트, 서버 측 프레임워크인 Rx가 등장했고 2012년경 다른 언어에서도 같은 기능구현을 허용하는 오픈소스가 되었다. 덕분에 Rx는 플랫폼간 표준이 되었음

오늘날 RxJava, RxKotlin, RxSwift, RxScala 등 다양한 확장이 등장

RxSwift 또한 가변 상태를 다루고, 이벤트 시퀀스를 구성할 수 있도록 하며 코드 격리, 재사용, 분리와 같은 구조적인 개선을 할 수 있도록 한다.

Observables, Operators, Schedulers 세 가지는 Rx코드의 구성요소이다.

### Observables

Observable<Element>는 Rx코드의 기초를 제공한다. 즉, Element타입의 제네릭 데이터의 변경 불가능한 스냅샷을 “전달” 할 수 있는 이벤트 시퀀스를 비동기식으로 생성하는 기능이다. 어렵다..

간단히 말해서 소비자가 시간이 흐름에 따라 다른 오브젝트에서 방출되는 이벤트나 값들을 구독할 수 있게 한다.

Observable 클래스는 하나 이상의 observer가 어떤 이벤트에 반응하고 앱 UI를 업데이트 하거나 새로 들어온 데이터를 처리하고 이용하도록 한다.

Observable이 따르는 ObservableType 프로토콜은 매우 간단한다. Observable은 (observer가 받을 수 있는)오직 세 가지의 이벤트를 방출 할 수 있다.

- Next event: 최신의 데이터를 “전달”하는 이벤트이며 observer가 값을 “받는” 방식이다. Observable은 종료 이벤트가 발생하기 전까지 계속 이벤트를 방출한다.
- Completete event: 이 이벤트는 이벤트 시퀀스를 성공으로 종료한다. Observable의 생애가 성공적으로 완료됐음을 의미하며 이벤트 방출은 끝이 난다.
- Error event: Observable 이벤트 시퀀스를 에러로 종료하며 이벤트 방출은 끝이 난다.

시간이 흐름에 따라 방출되는 비동기 이벤트를 얘기할 때 아래와 같이 int형 데이터의 observable 스트림으로 나타낼 수 있다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/f8d3cff7dafeb96562b1d9031cf41b30959aea0c036be76b0bb03070e392fed9/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/f8d3cff7dafeb96562b1d9031cf41b30959aea0c036be76b0bb03070e392fed9/original.png)

Observable이 방출하는 next, complete, error 세 개의 이벤트가 Rx의 전부라고 할 수 있다.

매우 보편적이어서 복잡한 앱 로직을 만드는데에 사용 할 수 있기 때문이다.

세 이벤트는 Observable과 observer의 본질에 대해 어떠한 가정도 하지 않기 때문에 궁극적인 분리(decoupleing) 방법이라고 할 수 있다. 즉, 클래스간 소통을 위해 delegate pattern을 사용하거나 closure를 사용할 필요가 없다.

finite(유한), infinite(무한) 두 가지 observable의 예시를 통해 알아보자

**finite observable sequence**

유한 관찰가능한 시퀀스는 0개 혹은 1개 이상의 값을 방출한다. 후에, 성공 혹은 에러로 종료된다.

인터넷으로 파일을 다운로드 하는 예시 코드를 생각해보자

1. 먼저, 다운로드를 시작하고 들어오는 데이터를 관찰한다.
2. 그리고 파일의 조각덩어리들을 반복적으로 받는다.
3. 네트워크 연결이 끊기면, 다운로드는 멈추고 연결을 타임아웃 에러로 종료될것임
4. 대신 만약 데이터를 다 받으면, 성공으로 완료될것임

위 흐름은 전형적인 옴저버블의 생애를 정확히 묘사한다.

```
API.download(file: "<http://www>...") /// 1...
   .subscribe(
     onNext: { data in /// 2...
      // Append data to temporary file
     },
     onError: { error in /// 3...
       // Display error to user
     },
     onCompleted: { /// 4...
       // Use downloaded file
     }
   )

```

///1… API.download는 데이터 값을 방출하는 Observable<Data>를 리턴한다.

///2… onNext 클로저로 next 이벤트를 구독하며 다운 받은 데이터를 임시 파일에 저장한다.

///3… onError 클로저로 error 이벤트를 구독하며 alert를 표시하는 등 에러를 다룰 수 있다.

///4… onCompleted 클로저로 completed 이벤트를 구독하며 화면 이동이나 다운 받은 파일 표시 등의 작업을 한다.

**Infinite observable sequences**

다운로드와 다르게 무한 관찰가능한 시퀀스는 자연적이든 강제로든 종료되어야 한다. 간단한 무한 관찰가능한 시퀀스를 보자. UI 이벤트는 종종 무한히 관찰할 수 있다.

기기 회전에 반응하는 코드를 생각해보자.

1. 클래스를 NotificationCenter의 UIDeviceOrientationDidChange이벤트의 옵저버로 등록한다.
2. 기기회전 변화를 다를 콜백 메소드를 구현한다. 화면의 회전 상태를 UIDevice로부터 가져와서 마지막 생태에 따라 반응한다.

이 방향 변화 시퀀스는 자연적으로 종료되지 않는다. 장치가 있는한 방향 변화는 계속 지속된다. 더욱이 이 시퀀스는 무한하고 상태를 갖고 있기 때문에 관찰 시작 시 항상 초기값을 갖는다.

아마 한번도 일어나지 않을 수 있지만 시퀀스가 종료된건 아니다. 이벤트 방출이 없었을 뿐이다.

```
UIDevice.rx.orientation /// 1...
  .subscribe(onNext: { current in /// 2...
    switch current {
    case .landscape:
      // Re-arrange UI for landscape
    case .portrait:
      // Re-arrange UI for portrait
    }
  })

```

///1… Observable<Orientation> 데이터를 방출하는 가상의 요소

///2… onError와 onCompleted 두 이벤트는 방출되지 않을 거기때문에 다루지 않는다.

### Operators

ObservableType과 Observable 클래스의 구현은 비동기 작업과 이벤트 조작의 개별 조각들을 추상화 하는 수많은 메소드를 포함한다. 이 메소드들은 조합될 수 있고 더 복잡한 로직으로 구현될 수 있다. 각각 매우 분리되어있고 구성가능하기 때문에 연산자라고 불린다.

예를 들어 ‘(2+4) * 10 - 2’ 표현을 생각해보자.

( ), +, *, - 연산자를 미리 정의된 순서와 인풋 숫자에 따라 처리하기만 하면 된다.

비슷한 방식으로 아래와 같이 observable에서 방출된 이벤트에 Rx 연산자를 적용 할 수 있다.

```
UIDevice.rx.orientation
  .filter { $0 != .landscape } /// 1...
  .map { _ in "Portrait is the best!" } /// 2...
  .subscribe(onNext: { string in
    showAlert(text: string)
  })

```

///1… filtersms .landscape이 아닌 값만 통과 시킨다.

///2… map은 Operation타입 input을 String타입 output으로 변환한다.

연산자는 매우 구성가능하다? 여러 조합이 가능하다는 말인듯

언제나 Input data를 받아서 output data를 내놓기 때문에 서로 연결해서 복잡한 동작도 수행 할 수 있음

### Schedulers

스케쥴러는 Rx의 dispatch queue나 operation queue같은것. 훨씬 사용하기 쉽다. 특정 작업의 실행 컨텍스트를 정의할 수 있게 해준다. 메인스레드, 백그라운드스레드 정의하는것 같다.

RxSwift에 미리 정의된 스케쥴러는 대부분의 케이스를 99퍼센트 커버하기때문에 직접 만들 필요는 없다.

그리고 앞으로도 쉬운 예시만 볼 거라서 당장은 스케쥴러를 유심히 들여다 볼 필요는 없을것임

아래와 같이 같은 구독에서 발생한 작업을 상황에 따라 적절한 컨텍스트로 보낼 수 있다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/28bdd14bbb8cebcb00fcdc724a10d4f34c19a2b14bcdda5c7ed1f59af513b6f4/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/28bdd14bbb8cebcb00fcdc724a10d4f34c19a2b14bcdda5c7ed1f59af513b6f4/original.png)

## 3. App Architecture

RxSwift는 앱 아키텍처 변경을 강제하진 않는다. 주로 이벤트, 비동기 데이터 시퀀스 처리와 요소 간 범용 소통 계약을 다룬다.

MVC, MVVM에서 모두 사용 가능하지만 특히 MVVM 아키텍처와 궁합이 좋다. ViewModel을 사용하면 Observable 속성을 노출할 수 있고 ViewController에서 UIKit에 직접 바인딩 할 수 있기때문에.

모델 데이터를 UI에 바인딩하고 표현하기 간단하다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/0625dc8cc2e93bdc9324fafea84fadaaf4729dfd39d114996486bb185bdb53e0/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/0625dc8cc2e93bdc9324fafea84fadaaf4729dfd39d114996486bb185bdb53e0/original.png)

## 4. RxCocoa

RxSwift는 Rx공통을 구현한 것이기 때문에 Cocoa나 UIKit관련 클래스를 알지 못한다.

RxCocoa는 UIKit, Cocoa 개발을 지원하는 클래스를 갖고 있는 RxSwift 동반 라이브러리이다.

쉽게 말해서 UIKit이 Rx의 이벤트를 방출하고 구독할 수 있도록 해서 앱에 반응적 확장을 추가할 수 있다.

```
toggleSwitch.rx.isOn
  .subscribe(onNext: { isOn in
    print(isOn ? "It's ON" : "It's OFF")
  })

```

위와 같이 rx.isOn속성을 이용해서 토글 스위치의 상태 변경을 구독할 수 있다.

## 5. **RxSwift and Combine**

Combine은 애플에서 기본 제공하는 자체 프레임워크이다.

RxSwift와 문법만 다를 뿐 유사한 개념을 공유한다.

iOS13 이상부터 지원한다. 관찰 가능한 시퀀스와 오퍼레이터를 이용해서 비동기 및 이벤트 기반 처리를 도와주는 툴이라는 면에서는 같다.

## 6. **Where to go from here?**

이번 장에서는 RxSwift가 해결하려고 하는 여러 문제를 살펴보았다. 비동기 프로그래밍의 복잡성, 변경 가능한 공유된 데이터, 부수 작용 등등.. 앞으로 기본적인 observable 구현부터 시작해서 MVVM 아키텍처 앱을 구현하는는 과정에 염두에 두면 좋을 것임