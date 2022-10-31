# 11장 프록시 패턴

### 학습 목표

- 자신이 대변하는 객체를 향해 인터넷으로 들어오는 메소드 호출을 쫓아내거나 게으른 객체를 대신해서 기다리는 일을 하는 프록시에 대해 알아보자.
- 새로운 행동을 추가하는 데코레이터 패턴과 특정 클래스로의 접근을 제어하는 프록시 패턴의 차이점을 안다.

&nbsp;

### 프록시 패턴 정의

프록시 패턴은 특정 객체를 감싸는 대리인 객체를 이용한다. 대리인 객체를 통해서 특정 객체에 접근하도록 함으로써 접근을 제어할 수 있다.

프록시 패턴에는 아래와 같이 수많은 변종이 있다.

- 원격 프록시
- 가상 프록시
- 보호 프록시
- 동적 프록시
- 방화벽 프록시
- 캐싱 프록시
- 지연 복사 프록시

이 밖에도 여러가지 프록시들이 있는데 공통점은 클라이언트로부터 특정 객체에 대한 접근을 제어함으로써 ‘어떤’ 목적을 달성하려는 것임.

예를 들어 가상 프록시는 생성하는데 비용이 많이 드는 특정 객체가 꼭 필요하여 생성되기 전까지 대리인 객체가 특정 객체인것 처럼 동작하게 만들기 위해 사용한다.

보호 프록시는 특정 객체로의 접근을 제한하기 위해 사용한다.



&nbsp;


### 클래스 다이어그램


![https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Proxy_pattern_diagram.svg/2880px-Proxy_pattern_diagram.svg.png](https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Proxy_pattern_diagram.svg/2880px-Proxy_pattern_diagram.svg.png)



Proxy와 RealSubject가 공통의 Subject 인터페이스를 구현하기때문에 클라이언트에서는 이 둘을 똑같은 방식으로 다룰 수 있다.

클라이언트가 Proxy를 통해 요청을 하면 Proxy는 구성으로 갖고 있는 RealSubject를 이용해 요청을 처리한다.

Proxy에서 RealSubject를 구성하고 있기 때문에 RealSubject의 인스턴스 생성 과정에 관여하기도 한다.



### 구현

```swift
protocol Subject {
    func request()
}

final class RealSubject: Subject {
    func request() {
        print("RealSuject requst")
    }
}

final class Proxy:Subject {
    
    private let realSubject: Subject
    
    init() {
        self.realSubject = RealSubject()
    }
    
    func request() {
        print("Accomplish a specific purpose.")
        realSubject.request()
    }
}

let proxy = Proxy()
proxy.request()
/* print
Accomplish a specific purpose.
RealSuject requst
*/
```
