# 9장 반복자 패턴과 컴포지트 패턴

### 학습 목표

- 컬렉션이 객체들을 어떻게 저장했는지 등을 클라이언트로부터 캡슐화할 수 있다.
- 반복자 패턴을 이용해서 반복과 관련된 일을 집합체로부터 분리시켜 단일책임원칙을 지킬 수 있다.



## 반복자 패턴

### Situation

서로 다른 자료구조로 저장된 아침메뉴와 점심메뉴가 있다.

아침메뉴는 ArrayList에, 점심메뉴는 배열에 저장되어있다.

각각의 자료구조는 장단점과 특징이 있다. 배열은 초기화 시 사이즈가 고정이고 ArrayList는 사이즈가 가변적임

배열은 데이터 접근 속도가 빠르지만 사이즈를 바꿀 수 없고 ArrayList는 데이터 접근 속도가 느리지만 사이즈를 바 꿀 수 있다.

ArrayList를 선택한 아침메뉴는 메뉴 추가에 중점을, 배열을 선택한 점심메뉴 속도에 중점을 두었다고 볼 수 있음



### Problem

종업원이 아침메뉴와 점심메뉴 모두를 출력 할 수 있도록 해야한다. 그러기 위해서는 메뉴 개수 만큼 반복하기 위해 아침메뉴 자료구조의 크기를 알아야 하고 메뉴에 접근해야 한다. 하지만 아침메뉴와 점심메뉴는 서로 다른 자료구조로 저장되어있기 때문에 다르게 구현해줘야 하는 문제가 생김

```jsx
BreakfastMenu breakfastMenu = new BreakfastMenu();
ArrayList<MenuItem> breakfastMenu = breakfastMenu.getMenuItems(); /// ArrayList

LaunchMenu launchMenu = new LaunchMenu();
MenuItem[] launchItems = launchMenu.getMenuItems(); /// 배열
for (int i = 0; < breakfastItems.size(); i++ {
	MenuItem menuItem = brakfastItems.get(i);
	System.out.println(menuItem.getName());
}

for (int i = 0; < launchItems.lenth(); i++ {
	MenuItem menuItem = launchItems[i];
	System.out.println(menuItem.getName());
}
```

만약 다른 메뉴가 추가되면 그때마다 순환문이 추가되야할것임

즉, 코드 관리와 확정이 어렵게 된다



### solution

순환문에서 공통되지 않은 부분은 자료구조의 형식이 달라서 발생하는 breakfastItems.size() / launchItems.lenth() 과 brakfastItems.get(i) / launchItems[i]이다.

종업원이 반복과 관련된 작업을 구체적으로 몰라도 상관없도록 반복자 패턴을 이용해 캡슐화할 수 있다.

```java
public interface Iterator {
	boolean hanNext();
	MenuItem next();
}

Iterator iterator = breakfastMenu.createIterator();
Iterator iterator = launchMenu.createIterator();

/// iterator가 구체적인 접근 방법을 대신 처리
while (iterator.hasNext()) {
	MenuItem menuItem = iterator.next();
}
```



## 컴포지트 패턴

### situation

만약 점심 메뉴 안에 디저트 메뉴를 서브 메뉴로 추가해야 한다면?

디저트 메뉴를 점심 메뉴 컬렉션의 요소로 넣을 수 있으면 좋겠지만 형식이 다르기 때문에 불가능



### refactoring

리팩토링 요구 사항은 아래와 같다

- 메뉴와 메뉴 항목 그리고 서브 메뉴를 표현 할 수 있는 트리 형태의 구조여야 한다
- 각 메뉴에 있는 모든 항목을 대상으로 반복자 객체처럼 특정 작업을 할 수 있어야 한다
- 모든 메뉴 혹은 특정 서브 메뉴를 대상으로 반복 작업을 유연하게 실행 할 수 있어야 한다



### 컴포지트 패턴 정의

객체를 부분-전체 계층 구조의 트리 형태로 구현하는 패턴

각각의 요소는 부모인 복합객체가 될 수도 있고 자식인 개별객체가 될 수도 있다.

즉, 모든 요소를 똑같은 방법으로 다룰 수 있음

위 상황에서 메뉴는 복합객체, 메뉴 아이템은 개별객체라고 할 수 있다.

복합 객체는 자식으로 개별객체와 복합객체 모두를 가질 수 있기때문에 메뉴 안에 서브메뉴를 가질 수 있게 됨

컴포지트 패턴을 사용하면 복합객체와 개별객체를 구분 할 필요가 없이 똑같이 다룰 수 있음



### solution

컴포지트 패턴에서는 부모와 자식 모두에게 적용되는 공통의 인터페이스가 필요함

부모인 복합객체에서 필요한 것만 이용하고 자식인 개별객체에서 필요한 것만 이용하면 된다.

```swift
/// 부모와 자식 모두에게 적용되는 공통 인터페이스
protocol MenuComponent {
		/// 자식 객체를 다루는데 필요한 메소드
    mutating func add(menuComponent: MenuComponent)
    mutating func remove(menuComponent: MenuComponent)
    func getChild(index: Int) -> MenuComponent

		/// 공통행위(아닌 것도 있음)
    func getName() -> String
    func getDescription() -> String
    func isVegetarian() -> Bool
    func getPrice() -> Double
    func print()
}

extension MenuCompoent {
	/// ...기본구현
}
```

복합객체에는 개별객체를 다루는(get,add,remove) 기능 + 기본행동이 필요

개별객체에는 기본행동이 필요

protocol extension으로 기본구현 해놓고 각각 필요한 부분만 구현할 수 있음



```swift
///자식을 갖는 복합객체
struct Menu: MenuComponent {
    
    var menuComponents: [MenuComponent] = []
    var name: String
    var description: String
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
    
    mutating func add(menuComponent: any MenuComponent) {
        menuComponents.append(menuComponent)
    }
    
    func remove(menuComponent: any MenuComponent) {
        // 요소 삭제
    }
    
    func getChild(index: Int) -> any  MenuComponent {
        return menuComponents[index]
    }
    
    func getName() -> String {
        return name
    }
    
    func getDescription() -> String {
        return description
    }
    
    func print() {
        Swift.print(name, terminator: " / ")
        Swift.print(description)

        menuComponents.forEach {
            Swift.print($0)
        }
    }
    
}

/// 개별객체
struct MenuItem: MenuComponent {

    var name: String
    var description: String
    var vegetarian: Bool
    var price: Double
    
    init(name: String, description: String, vegetarian: Bool, price: Double) {
        self.name = name
        self.description = description
        self.vegetarian = vegetarian
        self.price = price
    }
    
    func getName() -> String {
        return name
    }
    
    func getDescription() -> String {
        return description
    }
    
    func getPrice() -> Double {
        return price
    }
    
    func isVegetarian() -> Bool {
        return vegetarian
    }
    
    func print() {
        
        Swift.print(name, terminator: " / ")
        Swift.print(price, terminator: " / ")
        Swift.print(description)
        
    }
}
```

위와 같이 구현하면 자식을 갖는 복합객체에 복합객체와 자식객체를 같은 방식으로 다룰 수 있음