import UIKit

final class IconProvider {
    
    // MARK: - Icon Mapping
    
    /// Maps belief system icon names to SF Symbols or custom images
    static func iconImage(for iconName: String) -> UIImage? {
        // Check icon cache first
        if let cachedIcon = iconCache[iconName] {
            return cachedIcon
        }
        
        // Check for custom icon in assets
        if let customIcon = UIImage(named: iconName) {
            return customIcon
        }
        
        // Map to SF Symbols as fallback
        let symbolMapping: [String: String] = [
            "star_of_david": "star.fill",
            "cross": "cross.fill",
            "star_and_crescent": "moon.stars.fill",
            "om": "circle.hexagongrid.fill",
            "dharma_wheel": "circle.grid.3x3.fill",
            "khanda": "shield.fill",
            "ankh": "key.fill",
            "owl": "bird.fill",
            "skull": "face.smiling.inverse",
            "faravahar": "bird.fill",
            "torii_gate": "building.columns.fill",
            "yin_yang": "circle.lefthalf.filled.inverse",
            "triple_goddess": "moon.fill",
            "nine_pointed_star": "star.circle.fill",
            "sacred_fan": "fan.fill",
            "boomerang": "arrow.turn.up.right",
            "dreamcatcher": "circle.hexagongrid.circle.fill",
            "flower_of_life": "sparkles",
            "seal_of_theosophy": "seal.fill",
            "eye": "eye.fill"
        ]
        
        guard let symbolName = symbolMapping[iconName] else {
            return UIImage(systemName: "questionmark.circle.fill")
        }
        
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .medium)
        return UIImage(systemName: symbolName, withConfiguration: config)
    }
    
    /// Returns a properly configured icon for a belief system
    static func beliefSystemIcon(for iconName: String, color: UIColor, size: CGFloat = 60) -> UIImage? {
        // Get icon from cache, assets, or SF Symbols
        let icon = iconImage(for: iconName)
        
        // Apply configuration if it's an SF Symbol
        if icon?.isSymbolImage == true {
            let config = UIImage.SymbolConfiguration(pointSize: size, weight: .medium)
            return icon?.withConfiguration(config).withTintColor(color, renderingMode: .alwaysTemplate)
        }
        
        // Return custom icon with template rendering
        return icon?.withRenderingMode(.alwaysTemplate)
    }
    
    // MARK: - Custom Icon Creation
    
    /// Creates custom vector icons programmatically
    static func createCustomIcons() {
        let icons: [(name: String, creator: (CGSize) -> UIImage?)] = [
            ("star_of_david", createStarOfDavid),
            ("cross", createCross),
            ("star_and_crescent", createStarAndCrescent),
            ("om", createOm),
            ("dharma_wheel", createDharmaWheel),
            ("yin_yang", createYinYang)
        ]
        
        // Generate icons at runtime if needed
        for (name, creator) in icons {
            if UIImage(named: name) == nil {
                // Icon doesn't exist, create it programmatically
                if let image = creator(CGSize(width: 120, height: 120)) {
                    // Cache the image for this session
                    cacheIcon(image, name: name)
                }
            }
        }
    }
    
    private static var iconCache: [String: UIImage] = [:]
    
    private static func cacheIcon(_ image: UIImage, name: String) {
        iconCache[name] = image
    }
    
    // MARK: - Icon Creators
    
    private static func createStarOfDavid(_ size: CGSize) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { context in
            let ctx = context.cgContext
            let padding: CGFloat = size.width * 0.1
            let starSize = size.width - (padding * 2)
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            
            ctx.setStrokeColor(UIColor.label.cgColor)
            ctx.setLineWidth(size.width * 0.06)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            
            let radius = starSize / 2
            
            // First triangle (pointing up)
            ctx.move(to: CGPoint(x: center.x, y: center.y - radius))
            ctx.addLine(to: CGPoint(x: center.x - radius * 0.866, y: center.y + radius * 0.5))
            ctx.addLine(to: CGPoint(x: center.x + radius * 0.866, y: center.y + radius * 0.5))
            ctx.closePath()
            
            // Second triangle (pointing down)
            ctx.move(to: CGPoint(x: center.x, y: center.y + radius))
            ctx.addLine(to: CGPoint(x: center.x - radius * 0.866, y: center.y - radius * 0.5))
            ctx.addLine(to: CGPoint(x: center.x + radius * 0.866, y: center.y - radius * 0.5))
            ctx.closePath()
            
            ctx.strokePath()
        }
    }
    
    private static func createCross(_ size: CGSize) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { context in
            let ctx = context.cgContext
            let padding: CGFloat = size.width * 0.15
            let crossSize = size.width - (padding * 2)
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let thickness = size.width * 0.2
            
            ctx.setFillColor(UIColor.label.cgColor)
            
            // Vertical bar
            ctx.fill(CGRect(x: center.x - thickness/2, y: padding, width: thickness, height: crossSize))
            
            // Horizontal bar (positioned at 1/3 from top)
            let horizontalY = padding + crossSize * 0.3
            ctx.fill(CGRect(x: padding, y: horizontalY - thickness/2, width: crossSize, height: thickness))
        }
    }
    
    private static func createStarAndCrescent(_ size: CGSize) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { context in
            let ctx = context.cgContext
            let padding: CGFloat = size.width * 0.1
            let moonRadius = (size.width - padding * 2) * 0.4
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            
            ctx.setFillColor(UIColor.label.cgColor)
            
            // Draw crescent
            let moonCenter = CGPoint(x: center.x - moonRadius * 0.3, y: center.y)
            ctx.addEllipse(in: CGRect(x: moonCenter.x - moonRadius, y: moonCenter.y - moonRadius,
                                      width: moonRadius * 2, height: moonRadius * 2))
            ctx.fillPath()
            
            // Cut out inner circle to make crescent
            ctx.setBlendMode(.clear)
            let innerRadius = moonRadius * 0.8
            let innerCenter = CGPoint(x: moonCenter.x + moonRadius * 0.3, y: moonCenter.y)
            ctx.addEllipse(in: CGRect(x: innerCenter.x - innerRadius, y: innerCenter.y - innerRadius,
                                      width: innerRadius * 2, height: innerRadius * 2))
            ctx.fillPath()
            
            // Draw star
            ctx.setBlendMode(.normal)
            let starCenter = CGPoint(x: center.x + moonRadius * 0.8, y: center.y)
            let starRadius = moonRadius * 0.3
            
            drawStar(in: ctx, center: starCenter, radius: starRadius, points: 5)
            ctx.fillPath()
        }
    }
    
    private static func createOm(_ size: CGSize) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { context in
            let ctx = context.cgContext
            ctx.setStrokeColor(UIColor.label.cgColor)
            ctx.setLineWidth(size.width * 0.08)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            
            // Simplified Om symbol using bezier curves
            let scale = size.width / 100
            ctx.translateBy(x: size.width * 0.5, y: size.height * 0.5)
            ctx.scaleBy(x: scale, y: scale)
            
            // Main curve (simplified)
            ctx.move(to: CGPoint(x: -20, y: -10))
            ctx.addCurve(to: CGPoint(x: 0, y: -20),
                        control1: CGPoint(x: -15, y: -20),
                        control2: CGPoint(x: -5, y: -20))
            ctx.addCurve(to: CGPoint(x: 15, y: 0),
                        control1: CGPoint(x: 10, y: -20),
                        control2: CGPoint(x: 15, y: -10))
            ctx.addCurve(to: CGPoint(x: -5, y: 15),
                        control1: CGPoint(x: 15, y: 10),
                        control2: CGPoint(x: 5, y: 15))
            
            ctx.strokePath()
            
            // Dot
            ctx.setFillColor(UIColor.label.cgColor)
            ctx.addEllipse(in: CGRect(x: 10, y: -25, width: 8, height: 8))
            ctx.fillPath()
        }
    }
    
    private static func createDharmaWheel(_ size: CGSize) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { context in
            let ctx = context.cgContext
            let padding: CGFloat = size.width * 0.1
            let wheelSize = size.width - (padding * 2)
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = wheelSize / 2
            
            ctx.setStrokeColor(UIColor.label.cgColor)
            ctx.setLineWidth(size.width * 0.04)
            
            // Outer circle
            ctx.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius,
                                      width: radius * 2, height: radius * 2))
            ctx.strokePath()
            
            // Inner circle
            let innerRadius = radius * 0.3
            ctx.addEllipse(in: CGRect(x: center.x - innerRadius, y: center.y - innerRadius,
                                      width: innerRadius * 2, height: innerRadius * 2))
            ctx.strokePath()
            
            // Eight spokes
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4
                let startPoint = CGPoint(x: center.x + cos(angle) * innerRadius,
                                       y: center.y + sin(angle) * innerRadius)
                let endPoint = CGPoint(x: center.x + cos(angle) * radius,
                                     y: center.y + sin(angle) * radius)
                
                ctx.move(to: startPoint)
                ctx.addLine(to: endPoint)
            }
            ctx.strokePath()
        }
    }
    
    private static func createYinYang(_ size: CGSize) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { context in
            let ctx = context.cgContext
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width * 0.4
            
            // Outer circle
            ctx.setFillColor(UIColor.label.cgColor)
            ctx.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius,
                                      width: radius * 2, height: radius * 2))
            ctx.fillPath()
            
            // White half
            ctx.setFillColor(UIColor.systemBackground.cgColor)
            ctx.move(to: CGPoint(x: center.x, y: center.y - radius))
            ctx.addArc(center: center, radius: radius, startAngle: -.pi/2, endAngle: .pi/2, clockwise: true)
            ctx.addArc(center: CGPoint(x: center.x, y: center.y + radius/2), radius: radius/2,
                      startAngle: .pi/2, endAngle: -.pi/2, clockwise: false)
            ctx.addArc(center: CGPoint(x: center.x, y: center.y - radius/2), radius: radius/2,
                      startAngle: -.pi/2, endAngle: .pi/2, clockwise: true)
            ctx.fillPath()
            
            // Small circles
            let dotRadius = radius * 0.15
            
            // Black dot in white
            ctx.setFillColor(UIColor.label.cgColor)
            ctx.addEllipse(in: CGRect(x: center.x - dotRadius, y: center.y - radius/2 - dotRadius,
                                      width: dotRadius * 2, height: dotRadius * 2))
            ctx.fillPath()
            
            // White dot in black
            ctx.setFillColor(UIColor.systemBackground.cgColor)
            ctx.addEllipse(in: CGRect(x: center.x - dotRadius, y: center.y + radius/2 - dotRadius,
                                      width: dotRadius * 2, height: dotRadius * 2))
            ctx.fillPath()
        }
    }
    
    // MARK: - Helper Methods
    
    private static func drawStar(in context: CGContext, center: CGPoint, radius: CGFloat, points: Int) {
        let innerRadius = radius * 0.4
        var angle = -CGFloat.pi / 2
        let angleIncrement = CGFloat.pi * 2 / CGFloat(points)
        
        context.move(to: CGPoint(x: center.x + cos(angle) * radius,
                                y: center.y + sin(angle) * radius))
        
        for _ in 0..<points {
            angle += angleIncrement / 2
            context.addLine(to: CGPoint(x: center.x + cos(angle) * innerRadius,
                                       y: center.y + sin(angle) * innerRadius))
            angle += angleIncrement / 2
            context.addLine(to: CGPoint(x: center.x + cos(angle) * radius,
                                       y: center.y + sin(angle) * radius))
        }
        
        context.closePath()
    }
}