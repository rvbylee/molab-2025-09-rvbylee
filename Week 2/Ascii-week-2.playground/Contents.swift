import Foundation

let path = Bundle.main.path(forResource: "butterfly.txt", ofType: nil)
let str = try String(contentsOfFile: path!, encoding: .utf8)
print(str)

func load(_ file :String) -> String {
  let path = Bundle.main.path(forResource: file, ofType: nil)
  let str = try? String(contentsOfFile: path!, encoding: .utf8)
  return str!
}


print(load("butterfly.txt"))

 
