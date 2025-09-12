import Foundation

let moonPhases = "🌑🌒🌓🌔🌕🌖🌗"

func randomChar() -> String {
    let index = Int.random(in: 0..<moonPhases.count)
    let strIndex = moonPhases.index(moonPhases.startIndex, offsetBy: index)
    return String(moonPhases[strIndex])
}

func generateBlock(size: Int) {
    for _ in 0..<size {
        var line = ""
        for _ in 0..<size {
            line += randomChar()
        }
        print(line)
    }
}

generateBlock(size: 10)



