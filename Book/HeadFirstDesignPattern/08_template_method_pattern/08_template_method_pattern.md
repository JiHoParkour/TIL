# 8장 템플릿 메소드 패턴

### 학습 목표

- 알고리즘을 캡슐화해서 사용하는 방법과 이점을 안다.
- 템플릿 메소드 패턴과 전략패턴의 차이점을 안다.



### 문제 상황과 해결과정

코딩 바리스타로써 커피와 홍차를 제조해야 한다.

각각의 제조방법은 다음와 같다.

커피 제조법

1. 물을 끓인다.
2. 끓는 물에 커피를 우려낸다.
3. 커피를 컵에 따른다.
4. 설탕과 우유를 추가한다.

홍차 제조법

1. 물을 끓인다.
2. 끓는 물에 찻잎를 우려낸다.
3. 홍차를 컵에 따른다.
4. 레몬을 추가한다.

커피와 홍차를 제조하는 각각의 클래스를 만든다면 다음과 같다.

```swift
class Coffee {
	func prepareRecipe() {
		boilWater()
		brewCoffeeGrinds()
		pourInCup()
		addSugarAndMilk()	
	}
	func boilWater() {}
	func brewCoffeeGrinds() {}
	func pourInCup() {}
	func addSugarAndMilk() {}
}

class Tea {
	func prepareRecipe() {
		boilWater()
		steepTeaBag()
		pourInCup()
		addLemon()	
	}
	func boilWater() {}
	func steepTeaBag() {}
	func pourInCup() {}
	func addLemon() {}
}
```

한 눈에 보기에 prepareRecipe(), boilWater(), pourInCup() 세 메소드가 중복되고 이를 상속을 통해 해결할 수 있을것임

하지만 여전히 공통점은 남아있음. prepareRecipe() 안의 제조 방법이다. brewCoffeeGrinds()와 steepTeaBag()은 뜨거운 물에 무언가를 우려낸다는점과 addSugarAndMilk()와 addLemon()은 무언가를 첨가한다는 점이 같다.



각각 두 메소드를 공통 메소드로 묶어 prepareRecipe()을 추상화해보자

```swift
func prepareRecipe() {
	boilWater()
	brew() //뜨거운 물에 우려내다
	pourInCup()
	addCondiments() //무언가를 첨가하다
}
```



이제 prepareRecipe을 슈퍼 클래스에 두고 brew()와 addCondiments()는 서브 클래스에서 알맞게 정의해서 쓸 수 있다. Swift에 맞게 protocol과 extension을 이용하겠음

```swift
protocol CaffeineBeverage {
    func brew()
    func addCondiments()
}

extension CaffeineBeverage {
    func prepareRecipe() { //템플릿 메소드
        boilWater()
        brew() //서브클래스에서 처리
        pourInCup()
        addCondiments() //서브클래스에서 처리
    }
    func boilWater() {
        print("물 끓이는 중")
    }
    func pourInCup() {
        print("컵에 따르는 중")
    }
}

class Coffee: CaffeineBeverage {
    func brew() {
        print("필터로 커피 우려내는 중")
    }
    
    func addCondiments() {
        print("설탕과 우유를 추가하는 중")
    }
}

class Tea: CaffeineBeverage {
    func brew() {
        print("찻잎을 우려내는 중")
    }
    
    func addCondiments() {
        print("레몬을 추가하는 중")
    }
}
```

커피와 홍차 제조방법 사이에 중복 코드를 없애는 과정에 템플릿 메소드패턴이 적용되었다.

노션에서도 템플릿을 통해 미리 정해놓은 틀을 손쉽게 생성하듯이 템플릿 메소드패턴 또한 어떤 알고리즘의 템플릿 역할을 하는 메소드를 이용해 중복을 피하고 필요한 부분만 구현해서 쓸 수 있도록 해준다.



### 템플릿 메소드의 정의와 장점

템플릿 메소드는 패턴은 일련의 단계로 이루어진 알고리즘의 메소드를 정의한다. 알고리즘의 일부 단계는 서브클래스에서 구현하거나 특정 단계를 서브클래스에서 재정의 할 수도 있다. 하지만 알고리즘의 구조(틀)는 유지된다.

각각의 클래스를 만드는것과 비교해 템플릿 메소드 패턴을 사용하면 다음과 같은 장점이 있다.

- 서브클래스에서 코드를 재사용 할 수 있다.
- 알고리즘이 수정될 때 한 곳만 바꾸면된다.
- 새로운 서브클래스를 만드는 프레임워크를 제공한다.
- 알고리즘이 한 곳에 집중되어있으며 일부 구현만 서브클래스에 의존한다.



### 후크 활용하기

후크(hook)는 추상 클래스에 선언되지만 기본적인 내용만 있거나 아무 코드도 들어있지 않은 메소드. 서브클래스에서 재정의해도 되고 안해도 된다. 덕분에 알고리즘 중간에 끼어들거나 일부 알고리즘은 건너 뛰는 등의 유연한 처리를 가능하게 해줌

예를 들어 아래와 같이 customerWantsCondiments라는 후크를 서브클래스에서 재정의해서 첨가물을 넣을 수도 안넣을 수도 있다.

```swift
func prepareRecipe() {
        boilWater()
        brew()
        pourInCup()
				if (customerWantsCondiments) {
	        addCondiments()
				}
    }

func customerWantsCondiments() -> Bool {
	return true
}
```