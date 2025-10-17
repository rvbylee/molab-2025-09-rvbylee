import SwiftUI


let animInterval = 0.10
let ncell = 10.0
let lineWidth = 2.0
let colorSpecs = [Color.pink, Color.cyan, Color.yellow, Color.orange, Color.purple, Color.green]

var loc = CGPoint.zero
var isAnimation:Bool = true
var nsize: CGSize = .zero

struct PathData {
    var path: Path
    var color: Color
}

var paths: [PathData] = []

struct CanvasAnimView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: animInterval)) { timeline in
            Canvas { context, size in
                
                nsize = CGSize(width: size.width / ncell, height: size.width / ncell)
                
               
                let path = randomCircle(loc)
                let color = colorSpecs.randomElement()!
                paths.append(PathData(path: path, color: color))
                
             
                for p in paths {
                    context.fill(p.path, with: .color(p.color))
                    let style = StrokeStyle(lineWidth: lineWidth)
                    context.stroke(p.path, with: .color(.white.opacity(0.2)), style: style)
                }
                
        
                loc.x += nsize.width
                if loc.x > size.width {
                    loc.x = 0
                    loc.y += nsize.height
                    if loc.y > size.height {
                        // reset canvas
                        loc = .zero
                        paths = []
                    }
                }
                
        
                _ = timeline.date
            }
            .background(Color.black)
            .ignoresSafeArea()
        }
    }
}

func randomCircle(_ p: CGPoint) -> Path {
    var path = Path()
    let x = loc.x
    let y = loc.y
    let cellW = nsize.width
    let cellH = nsize.height
    let radius = CGFloat.random(in: cellW * 0.3 ... cellW * 0.9)
    
    let center = CGPoint(
        x: x + cellW / 2,
        y: y + cellH / 2
    )
    
    path.addEllipse(in: CGRect(
        x: center.x - radius / 2,
        y: center.y - radius / 2,
        width: radius,
        height: radius
    ))
    
    return path
}

#Preview {
    CanvasAnimView()
}

