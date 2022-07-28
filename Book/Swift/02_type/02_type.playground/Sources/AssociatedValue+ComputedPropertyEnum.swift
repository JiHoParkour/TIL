import Foundation

public enum BadmintonRacketFormat {
    case Yonex(weight: Int, price: Int)
    case Victon(weight: Int, price: Int)
    case Jubong(weight: Int, price: Int)
    case Natto(weight: Int, price: Int)
    case Daiso(weight: Int, price: Int)
    
    public var weight: Int {
        switch self {
        case .Yonex(let weight, _):
            return weight
        case .Victon(let weight, _):
            return weight
        case .Jubong(let weight, _):
            return weight
        case .Natto(let weight, _):
            return weight
        case .Daiso(let weight, _):
            return weight
        }
    }
    
    public var price: Int {
        switch self {
        case .Yonex(_, let price):
            return price
        case .Victon(_, let price):
            return price
        case .Jubong(_, let price):
            return price
        case .Natto(_, let price):
            return price
        case .Daiso(_, let price):
            return price
        }
    }
    
    public func weightTogether(otherRacket: BadmintonRacketFormat) -> Int {
        return (self.weight + otherRacket.weight)
    }
}
