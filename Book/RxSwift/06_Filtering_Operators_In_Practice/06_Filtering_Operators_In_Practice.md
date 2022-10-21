# 6. ***\*Filtering Operators in Practice\****

이전 장에서 RxSwfit의 함수적인 측면을 소개했다. 처음 배운 연산자들은 옵저버블 시퀀스의 요소를 필터링하는데 도움을 주었다.

이전에 설명한것 처럼, 연산자는 간단히 Observable<Element>클래스의 함수다. 그리고 몇몇은 Observable<Element>가 준수하는 ObservableType 프로토콜에 정의되어있다.

연산자는 옵저버블의 요소들에 대해 작동하고 새로운 옵저버블 시퀀스를 결과로 생성한다. 이는 매우 간편한데, 전에 보았듯이 이를 통해 연산자를 차례로 연결하고 여러 변환을 순서대로 수행 할 수있게 한다.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/0e3758d602840a66753db5f810409f3406b0a7775000b08ad3ff007bf3eefd90/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/0e3758d602840a66753db5f810409f3406b0a7775000b08ad3ff007bf3eefd90/original.png)

## ***\*Sharing subscriptions\****

### share

같은 옵저버블에 구독을 여러번 하는게 잘못됐나? 그럴 수도 있다!

언급했듯이 옵저버블은 게으르고 pull-driven 시퀀스이다. 요청하는 쪽에 의해 동작한다는 뜻인듯?

간단히 옵저버블에 몇개의 연산자를 호출하는건 실제 동작과는 연관이 없다. 옵저버블이나 옵저버블에 적용된 연산자에 구독을 하는 순간이 옵저버블이 활성화되고 요소들이 생성되기 시작한다.

그렇게 동작하기 때문에 옵저버블을 구독할때 마다 create 클로저를 호출한다. 이는 때때로 눈부신? 효과를 나타내는데.. 예시 코드를 보자

```swift
let numbers = Observable<Int>.create { observer in
    let start = getStartNumber()
    observer.onNext(start)
    observer.onNext(start+1)
    observer.onNext(start+2)
    observer.onCompleted()
    return Disposables.create()
}

var start = 0
func getStartNumber() -> Int {
    start += 1
    return start
}

numbers
  .subscribe(
    onNext: { el in
      print("element [\\(el)]")
    },
    onCompleted: {
      print("-------------")
    }
  )

numbers
  .subscribe(
    onNext: { el in
      print("element [\\(el)]")
    },
    onCompleted: {
      print("-------------")
    }
  )

/* print
element [1]
element [2]
element [3]
-------------
element [2]
element [3]
element [4]
-------------
*/
```

Int형 요소 이벤트 세 개를 방출하는 옵저버블을 만들었다.

그리고 하나의 옵저버블에 두 개의 구독을 했을 때 구독의 아웃풋이 다른걸 확인 할 수 있다.

문제는 구독을 할 때 마다 해당 구독에 대해 새로운 옵저버블을 만들기 때문이다. 그리고 각 복사본은 이전 것과 같음을 보장하지 않는다. 그리고 설령 옵저버블이 요소가 같은 시퀀스를 생성했다 하더라도, 각 구독에 같은 중복 요소를 생성하는건 낭비이다. 그럴 이유가 있을까?

구독을 공유하려면 share 연산자를 사용하자. Rx 코드의 일반적인 패턴은 각 결과에서 다른 요소를 필터링함으로써 같은 소스 옵저버블에서 여러 시퀀스를 만드는 것이다. 다시 말해서 하나의 소스 옵저버블을 필터링 연산자를 적용함으로써 여러 시퀀스를 만드는게 일반적인 패턴인것이다. 하나의 소스 옵저버블로부터 파생되기때문에 share로 같은 옵저버블을 공유하는게 중요하다는 뜻이겠다.

share 연산자는 어떻게 동작할까?

share는 구독자의 수가 0에서 1이 될 때만 새 구독을 생성한다. 즉, 기존에 공유된 구독이 없을 때만 생성됨

두 번째, 세 번째 등등의 구독자가 시퀀스를 관찰하기 시작할 때 share는 그들과 공유하기 위해 이미 생성된 구독을 사용한다. 만약 공유된 시퀀스에 대한 구독이 모두 폐기되면(더 이상 구독자가 없으면), share는 또한 공유된 시퀀스를 폐기할 것임. 만약 또 다른 구독자가 관찰을 시작하면, share는 언급했듯이 새로운 구독을 생성할 것임(기존에 공유된 구독이 없기 때문에)

### share(replay:scope:)

share()는 기존 구독에 방출됐던 값을 새 구독에 제공하지 않는다. 다만 share(replay:scope:)는 마지막으로 방출된 값의 버퍼를 유지하고 새로운 구독이 발생할 때 관찰자에게 제공할 수 있다.

share 연산자에 대한 경험 법칙은 완료되지 않는 옵저버블 혹은 완료 후 새 구독이 발생하지 않는걸 보장 할 수 없을 때 share 연산자를 사용하는 것이 안전하다는 것이다. 마음이 편하고 싶으면 share(replay: 1)을 사용하자.

## ***\*Ignoring all elements\****

### ignoreElements와 completable

ignoreElements() 연산자는 next이벤트를 필터링하고 completed와 error 이벤트만 통괴할 수 있도록 한다.

아마 앞 장에서 배운 Completable을 기억 할 것임 Completable은 completed와 error 이벤트만 방출하는 옵저버블의 일종인데 실제로, ignoreElements 연산자는 next이벤트를 필터링함으로써 일반적인 옵저버블 시퀀스를 completable로 변환한다.

## ***\*Filtering elements you don’t need\****

### filter

때로는 전체가 아닌 일부만 무시하고 싶을거다. 이럴때는 filter 연산자를 이용해서 특정 조건에 따라 통과시키거나 무시할 수 있다.

예를 들면 아래 코드로 가로 길이가 긴 이미지만 통과하게 할 수 있다.

```swift
.filter { newImage in
    return newImage.size.width > newImage.size.height
  }
```

## ***\*Implementing a basic uniqueness filter\****

### filter

이미지를 선택해서 사진 콜라주를 만들때 똑같은 이미지가 여러개 선택되지 않도록 구현 할 수 있다.

더 나은 방법이 있지만 지금 까지 배운 것을 이용해보자.

이미지의 인덱스를 추적하는건 도움이 안된다. 같은 이미지 오브젝트일지라도 인덱스는 다르기때문. 가장 좋은 방법은 이미지 데이터의 해시나 에셋 URL을 저장하는거지만 간단하게 이미지의 바이트 길이를 이용하자.

```swift
/// 이미지의 바이트 길이를 저장할 배열
private var imageCache = [Int]()

/// 이미지의 pngData를 이용해서 위 배열에 존재 여부를 따져 새로운 이미지만 추가되도록 함
.filter { [weak self] newImage in
        let len = newImage.pngData()?.count ?? 0
        guard self?.imageCache.contains(len) == false else {
          return false
        }
        self?.imageCache.append(len)
        return true
      }
```

## ***\*Keep taking elements while a condition is met\****

### takeWhile

이미지를 특정 조건(현재 추가된 이미지 개수가 6개 미만)을 만족할 때 까지만 추가 할 수 있도록 연산자를 이용할 수 있다.

```swift
newPhotos
  .takeWhile { [weak self] image in
    let count = self?.images.value.count ?? 0
    return count < 6
  }
```

takeWhile 연산자 술부에서 self를 이용해서 view controller의 속성에 직접 접근했는데, 반응형 프로그래밍에서는 논란의 여지가 있음. 다음 장에서 combining operators를 이용해서 여러개의 옵저버블 시퀀스를 합치는걸 배우면 상태를 얻기위해 view controller를 이용하지 않아도 된다. 아무래도 상태가 다른 요인에 의해 변경되면 원하는 대로 동작이 안될 수도 있기 때문인가보다.

## ***\*Improving the photo selector\****

### ***\*PHPhotoLibrary authorization observable\****

처음에 포토 라이브러리에 접근할 때 권한을 부여해야한다. 아마 처음에 권한을 허용했을 때 포토 라이브러리에 사진이 바로 나오지 않고 뒤로 갔다가 다시 들어와야 사진이 나타났을것임. 불쾌한 유저 경험임으로 개선해야한다.

포토 라이브러리에 authorized 라는 Bool타입 옵저버블을 정의하고 유저의 권한 허용 여부에 따라 허용했다면 true를 방출하고, 허용하지 않았다면 권한을 요청하고 허용 여부를 다시 true나 false로 방출하는 로직을 구현해보자. 일반적으로 옵저버블은 UI를 차단하거나 구독을 방지 할 수 있기 때문에 DispatchQueue.main.async로 현재 스레드를 차단하지 않도록해야 함

```swift
static var authorized: Observable<Bool> {
    return Observable.create { observer in

      DispatchQueue.main.async {
        if authorizationStatus() == .authorized {
          observer.onNext(true)
          observer.onCompleted()
        } else {
          observer.onNext(false)
          requestAuthorization { newStatus in
            observer.onNext(newStatus == .authorized)
            observer.onCompleted()
          }
        }
      }

      return Disposables.create()
    }
  }
```

### ***\*Reload the photos collection when access is granted\****

이제 접근 권한을 얻게 되는 두 가지 시나리오가 있음

1. 첫 앱 실행 때 유저가 OK하는 경우(false → true → completed)
2. 이후 실행 때 이전에 권한을 부여받은 경우(true → completed)

이제 PHPhotoLibrary.authorized를 구독해보자. true가 항상 마지막 요소이니 true를 받을때마다 컬렉션뷰를 리로드 하고 카메라 롤을 스크린에 나타낼 수 있음을 의미함

```swift
let authorized = PHPhotoLibrary.authorized
  .share() /// 1...

authorized
  .skipWhile { !$0 } /// 2...
  .take(1) /// 3...
  .subscribe(onNext: { [weak self] _ in
    self?.photos = PhotosViewController.loadPhotos()
    DispatchQueue.main.async { /// 4...
      self?.collectionView?.reloadData()
    }
  })
  .disposed(by: bag)
```

/// 1… share로 여러 구독에 대해 하나의 옵저버블을 공유하도록 함. 두 개의 구독 만들 예정

/// 2… 조건을 만족할때까지 스킵하다가 이후엔 쭉 통과, 즉 false를 쭉 스킵하다가 true가 나오면 통과

/// 3… 이 시퀀스에서는 true를 마지막으로 complete이벤트가 방출되며 종료되기때문에 take(1)이 필요 없지만 명시함으로써 의도를 명확하게 전달하고 추후 권한 로직이 수정되어도 제대로 동작 하게 할 수 있다.

/// 4… 왜 메인스레드로 변환해야 할까?

```swift
requestAuthorization { newStatus in
            observer.onNext(newStatus == .authorized)
            observer.onCompleted()
          }
```

에서 유저가 권한 허용을 하고 true를 방출할 때 requestAuthorization() 는 어떤 스레드에서 완료 컴플리션이 동작할지 보장하지 않기 때문에 background스레드에서 실행될것임

이후 onNext는 옵저버블에 대한 모든 구독 코드를 동일한 background 스레드에서 불러일으킴

마침내, 구독에서 self?.collectionView?.reloadData()를 background 스레드에서 호출하게 되고 UIKit은 출돌할것임. UI 업데이트는 main 스레드에서 해야 함

![https://assets.alexandria.raywenderlich.com/books/rxs/images/f3db24e89beec4c854201efa4391bf179d2c3b0ef099c6bcbb04c14e008d9db3/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/f3db24e89beec4c854201efa4391bf179d2c3b0ef099c6bcbb04c14e008d9db3/original.png)

스레딩은 비동기프로그래밍에서 항상 중요하다. 그리고 RxSwift를 사용하면 스레드를 쉽게 다룰 수 있다. RxSwift 코드에서 스레드를 변환하기 위해 GDC가 아닌 Schedulers를 사용해야 한다. 추후 자세히 알아보자

## ***\*Display an error message if the user doesn’t grant access\****

지금까지 유저가 포토 라이브러리 접근 권한을 부여했을 경우를 위한 구독을 했다.

이제는 유저가 권한을 거절했을 경우를 위한 구독을 해서 에러 메세지 alert를 띄어보자.

전과 달리 두 경우에 시퀀스 요소가 같음

1. 첫 앱 실행 때 유저가 거절하는 경우(false → false → completed)
2. 이후 실행 때 이전에 권한을 거절했던 경우(false → false → completed)

위 시퀀스를 어떻게 처리하면 에러 메세지를 띄우는 조건을 만들 수 있을까?

- false가 두번 연속으로 방출되고 종료되니까 첫 번째 요소는 무시한다.
- 마지막으로 방출된 요소가 false인지 체크해서 그런 경우 에러 메세지를 출력한다.

위 로직을 구현한 코드이다.

```swift
authorized
  .skip(1)
  .takeLast(1)
  .filter { !$0 }
  .subscribe(onNext: { [weak self] _ in
    guard let errorMessage = self?.errorMessage else { return }
    DispatchQueue.main.async(execute: errorMessage)
  })
  .disposed(by: bag)
```

skip, takeLast, filter 세 개의 연산자가 사용됐는데 과하다고 생각 할 수도 있다. 실제로 전부 필요한건 아님

takeLast(1)는 마지막 방출된 1개의 요소를 받는단 의미이고 이는 첫 번째 요소를 스킵한다는 의미인 skip(1)과 동떨어져있지 않다. filter로 false만 통과시키는 일 또한 정말 마지막 요소만 거르는게 필요할까?

```swift
authorized
  .distinctUntilChanged()
  .takeLast(1)
  .filter { !$0 }
```

또한 위와 같이 구현해도 똑같이 동작한다. 정답은 없지만 나중에 시퀀스 로직이 변하지 않는다고 보장할 수 없기 때문에 최대한 완전하고 안전한 코드를 위해 과하게, 의도를 명확하게 구현하는것도 괜찮은 방법이다. 다시 말하지만 정답은 없다.

## ***\*Trying out time-based filter operators\****

곧 time-base 연산자에 대해 더 많이 배우겠지만 그 중 일부 역시 filtering 연산자이기 때문에 지금 사용해보자.

time-base 연산자는 scheduler라는걸 쓴다. scheduler는 곧 배우게 될 중요한 개념이다. 아래 예시에서 MainScheduler.instance를 사용할건데 이는 다른 기능과 함께 메인 스레드에서 코드를 실행하는 공유 스케쥴러 객체이다. 긴 설명은 뒤로하고 두 개의 간단한 시간 기반 필터링 예시를 보자.

## ***\*Completing a subscription after given time interval\****

위에서 유저가 포토 라이브러리 접근 권한을 거절한 경우 에러 메세지를 띄우고 Close버튼 탭과 함께 뒤로가는것까지 구현함

메세지가 보여지고 유저의 입력 없이 잠시 후 사라지는건 일반적인 패턴이다. 이번엔 메세지가 최대 5초간 보여지고 5초 동안 유저가 Close버튼을 탭하지 않으면 자동으로 메세지가 사라지고 뒤로 간 후 구독을 폐기하는 동작을 구현해보자.

```swift
alert(title: "No access to Camera Roll",
      text: "You can grant access to Combinestagram from the Settings app")
    .asObservable() /// 1...
    .take(.seconds(5), scheduler: MainScheduler.instance) /// 2...
      .subscribe(onCompleted: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
        _ = self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: bag)
```

/// 1… alert에서 리턴 받은 completable을 observable로 변환. take 연산자는 completable 타입에서 동작하지 않기 때문에. completed이나 error 이벤트 밖에 없어서?

/// 2… take(_:scheduler:)는 소스 시퀀스로부터 주어진 시간 동안 이벤트 요소를 취한다. 일단 시간이 지나면 시퀀스가 completed(완료)된다.

## ***\*Using throttle to reduce work on subscriptions with high load\****

때로는 시퀀스의 현재 요소에만 관심이 있으며 이전 값들은 쓸모가 없는 경우가 있다.

아래 코드를 보자.

```swift
images
  .subscribe(onNext: { [weak imagePreview] photos in
    guard let preview = imagePreview else { return }

    preview.image = photos.collage(size: preview.frame.size)
  })
```

유저가 사진을 선택할 때 마다 구독은 사진 콜렉션을 받아서 콜라주를 생성한다. 새로운 사진 콜렉션을 받자마자 이전 콜렉션은 쓸모가 없어진다. 그런데 만약 유저가 사진을 연속으로 빠르게 추가하면, 구독은 모든 요소에 대해 새로운 콜라주를 만들것임. 중간 과정 콜라주를 생성하는건 낭비이다.

그러나 곧 새로운 요소가 구독에 들어올걸 어떻게 알 수 있을까?

위 상황같이 많은 요소들이 계속해서 들어오는 경우 마지막 것만 취해야하는 상황이 매우 빈번할것이다. 비동기 프로그래밍의 흔한 패턴이기 때문에, Rx에서 특별한 연산자를 제공한다.

### throttle

```swift
images
  .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
  .subscribe(onNext: { [weak imagePreview] photos in
    guard let preview = imagePreview else { return }

    preview.image = photos.collage(size: preview.frame.size)
  })
```

위와 같이 구독 전에 throttle을 삽입하면 특정 시간 이내에 들어오는 다음 요소를 필터링해준다.

RxTimeInterval은 분수를 허용하지 않기 때문에 500 milliseconds사용. 0.5초와 같다.

만약 유저가 사진을 선택하고 0.2초 후에 다른 사진을 또 선택하면 throttle이 첫 번째 요소를 걸러내고 두 번째 요소만 통과시킬것임. 이렇게 하면 처음 콜라주 생성하는 일을 하지 않게됨.

![https://assets.alexandria.raywenderlich.com/books/rxs/images/91fbe73d8dc6e2f4cb8a471cbdc86b6ef2938e739e66c0a25271dd130b5a01bc/original.png](https://assets.alexandria.raywenderlich.com/books/rxs/images/91fbe73d8dc6e2f4cb8a471cbdc86b6ef2938e739e66c0a25271dd130b5a01bc/original.png)

throttle을 응용 할 수 있는 상황들

- 현재 검색어를 서버 API통신으로 보내는 검색 텍스트 필드에서 유저가 빠르게 타이필 할 때 타이핑이 끝난 뒤 한 번의 요청만 보낼 수 있다.
- 바 버튼을 눌러서 모달 뷰 컨트롤러를 띄울 때 창이 두개 뜨게하는 더블 탭을 막을 수 있다.
- 화면에서 드래깅을 하다 멈춘 순간의 지점에 관심이 있을 때 이전 터치 위치를 무시 할 수 있다.

대게 throttle은 너무 많은 인풋이 주어질 때 유용하다.

이번 장에서 filtering 연산자의 활용을 알아보았다. 또한 스레드를 변경하는 연산자도 맛보고 time-base 연산자도 맛봤다. RxSwift는 비동기 이벤트 기반 프레임워크이기 때문에 time-base 연산자로 할 수 있는 더 많은 것들을 배울 것임