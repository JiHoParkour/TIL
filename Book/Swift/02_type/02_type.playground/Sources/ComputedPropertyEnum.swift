import Foundation

public enum Member: String {
    case Jiho, Hojin, Dew, Heyjeong, Nuri, CheongA, Seonghoon, Ingwon
    static var allCases: [Member] {
        return [Jiho, Hojin, Dew, Heyjeong, Nuri, CheongA, Seonghoon, Ingwon]
    }

    public static func randomCase() -> Member {
        let randomValue = Int(arc4random_uniform(UInt32(allCases.count)))
        return allCases[randomValue]
    }
}
