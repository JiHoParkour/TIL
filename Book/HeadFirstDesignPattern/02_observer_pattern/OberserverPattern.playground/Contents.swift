import UIKit

protocol Subject {
    func registerObserver(observer: Observer)
    func removeObserver(observer: Observer)
    func notifyObservers()
}

protocol Observer {
    func update()
}

class BroadcastStation: Subject {
    
    
    var observerList = [Observer]()
    var news: String
    
    init(news: String) {
        self.news = news
    }
    
    func getNews() -> String {
        return self.news
    }
    
    func newsArrived(news: String) {
        self.news = news
        notifyObservers()
    }
    
    func registerObserver(observer: Observer) {
        observerList.append(observer)
    }
    
    func removeObserver(observer: Observer) {
    
        
    }
    
    func notifyObservers() {
        observerList.forEach{ observer in
            observer.update()
        }
    }
    
}


class Jiho: Observer {
    
    var broadcastStation: BroadcastStation
    var news: String?
    
    init(broadcastStation: BroadcastStation) {
        self.broadcastStation = broadcastStation
        broadcastStation.registerObserver(observer: self)
    }
    
    func update() {
        news = broadcastStation.getNews()
        shoutNews()
    }
    
    func shoutNews() {
        guard let news = news else { return }
        print("Hi This is jiho. I got a news. \(news)")
    }
}

let broadcastStation = BroadcastStation(news: "wating...")

let jiho = Jiho(broadcastStation: broadcastStation)

broadcastStation.newsArrived(news: "Today is one of the most wonderful day.")

broadcastStation.newsArrived(news: "President Moon resigned and returned his hometown Yangsan. He said he will spend the rest of his life time there.")

broadcastStation.newsArrived(news: "Covid 19 spread all over the world in the very 5 months.")

