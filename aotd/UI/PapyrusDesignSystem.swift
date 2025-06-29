import UIKit

// MARK: - Papyrus Design System
// A comprehensive design framework inspired by ancient papyrus manuscripts
// while maintaining iOS Human Interface Guidelines

/// A comprehensive design framework inspired by ancient papyrus manuscripts
/// while maintaining iOS Human Interface Guidelines.
///
/// ## Overview
/// The Papyrus Design System provides a unified visual language for the App of the Dead,
/// combining ancient aesthetics with modern iOS design principles.
///
/// ## Topics
/// ### Colors
/// - ``Colors``
/// ### Typography
/// - ``Typography``
/// ### Spacing & Layout
/// - ``Spacing``
/// - ``CornerRadius``
/// ### Visual Effects
/// - ``Shadow``
/// - ``Border``
/// - ``Animation``
enum PapyrusDesignSystem {
    
    // MARK: - Unified Color System
    
    /// The comprehensive color system for the App of the Dead.
    ///
    /// ## Overview
    /// Colors are organized into semantic groups that adapt to light and dark modes automatically.
    /// The color system is inspired by ancient Egyptian papyrus manuscripts while maintaining
    /// excellent readability and accessibility.
    ///
    /// ## Color Categories
    /// - **Core**: Base theme colors inspired by papyrus and ancient inks
    /// - **Semantic**: Colors with specific UI meanings (success, error, etc.)
    /// - **Dynamic**: Colors that automatically adapt to light/dark mode
    /// - **Component**: Pre-configured colors for specific UI components
    ///
    /// ## Usage Example
    /// ```swift
    /// // Using core colors
    /// view.backgroundColor = PapyrusDesignSystem.Colors.Core.beige
    /// 
    /// // Using dynamic colors (recommended)
    /// label.textColor = PapyrusDesignSystem.Colors.Dynamic.primaryText
    /// 
    /// // Using semantic colors
    /// errorView.backgroundColor = PapyrusDesignSystem.Colors.Semantic.error
    /// ```
    enum Colors {
        // MARK: - Core Theme Colors
        
        /// Core theme colors inspired by ancient papyrus manuscripts.
        ///
        /// These colors form the foundation of the Papyrus design system and are
        /// carefully chosen to evoke the feeling of ancient texts while maintaining
        /// modern usability standards.
        enum Core {
            /// The primary papyrus background color - a warm, aged paper tone
            static let beige = UIColor(red: 243/255, green: 237/255, blue: 214/255, alpha: 1.0)
            
            /// Deep ink color for primary text - inspired by ancient writing implements
            static let ancientInk = UIColor(red: 42/255, green: 32/255, blue: 24/255, alpha: 1.0)
            
            /// Luxurious gold accent - represents divine knowledge and achievement
            static let goldLeaf = UIColor(red: 212/255, green: 175/255, blue: 55/255, alpha: 1.0)
            
            /// Egyptian blue - used for sacred texts and important UI elements
            static let hieroglyphBlue = UIColor(red: 45/255, green: 85/255, blue: 125/255, alpha: 1.0)
            
            /// Deep red - for warnings and destructive actions
            static let tombRed = UIColor(red: 139/255, green: 35/255, blue: 35/255, alpha: 1.0)
            
            /// Light stone color - for secondary backgrounds and cards
            static let sandstone = UIColor(red: 226/255, green: 218/255, blue: 196/255, alpha: 1.0)
            
            /// Aged papyrus - for borders and disabled states
            static let aged = UIColor(red: 209/255, green: 196/255, blue: 162/255, alpha: 1.0)
            
            /// Darker gold - for pressed states and emphasis
            static let burnishedGold = UIColor(red: 184/255, green: 134/255, blue: 11/255, alpha: 1.0)
            
            /// Mystical purple - for special achievements and rare content
            static let mysticPurple = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1.0)
            
            /// Sacred scarab green - for success states and positive feedback
            static let scarabGreen = UIColor(red: 60/255, green: 110/255, blue: 60/255, alpha: 1.0)
            
            // MARK: Dark Mode Base Colors
            
            /// Dark mode primary background - deep charcoal papyrus
            static let darkBackground = UIColor(red: 28/255, green: 24/255, blue: 20/255, alpha: 1.0)
            
            /// Dark mode card background - slightly elevated surface
            static let darkCard = UIColor(red: 38/255, green: 34/255, blue: 30/255, alpha: 1.0)
        }
        
        // MARK: - Semantic Colors
        
        /// Colors with specific semantic meaning in the UI.
        ///
        /// Use these colors to communicate state and provide consistent feedback
        /// across the application.
        enum Semantic {
            static let success = Core.scarabGreen
            static let error = Core.tombRed
            static let warning = Core.burnishedGold
            static let info = Core.hieroglyphBlue
            static let disabled = Core.aged.withAlphaComponent(0.6)
        }
        
        // MARK: - Dynamic Colors
        
        /// Colors that automatically adapt based on the user's interface style.
        ///
        /// These are the recommended colors for most UI elements as they provide
        /// optimal contrast and readability in both light and dark modes.
        ///
        /// ## Important
        /// Always prefer dynamic colors over static Core colors for text and backgrounds
        /// to ensure proper dark mode support.
        enum Dynamic {
            static var background: UIColor {
                UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ? Core.darkBackground : Core.beige
                }
            }
            
            static var cardBackground: UIColor {
                UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ? Core.darkCard : Core.sandstone
                }
            }
            
            static var primaryText: UIColor {
                UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ? Core.beige : Core.ancientInk
                }
            }
            
            static var secondaryText: UIColor {
                UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ?
                        Core.aged :
                        UIColor(red: 92/255, green: 72/255, blue: 54/255, alpha: 1.0)
                }
            }
            
            static var tertiaryText: UIColor {
                UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ?
                        UIColor(red: 162/255, green: 152/255, blue: 134/255, alpha: 1.0) :
                        UIColor(red: 142/255, green: 122/255, blue: 104/255, alpha: 1.0)
                }
            }
            
            static var separator: UIColor {
                UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ?
                        Core.aged.withAlphaComponent(0.3) :
                        Core.aged.withAlphaComponent(0.5)
                }
            }
            
            static var border: UIColor {
                UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark ?
                        Core.aged.withAlphaComponent(0.4) :
                        Core.aged
                }
            }
        }
        
        // MARK: - Component Colors
        
        /// Pre-configured color combinations for specific UI components.
        ///
        /// These color sets ensure consistent styling across similar components
        /// and maintain the design system's visual coherence.
        enum Component {
            enum Button {
                static var primaryBackground: UIColor { Core.goldLeaf }
                static var primaryForeground: UIColor { Core.ancientInk }
                static var secondaryBackground: UIColor { Core.hieroglyphBlue }
                static var secondaryForeground: UIColor { Core.beige }
                static var tertiaryBackground: UIColor { Core.aged }
                static var tertiaryForeground: UIColor { Core.ancientInk }
                static var destructiveBackground: UIColor { Core.tombRed }
                static var destructiveForeground: UIColor { Core.beige }
                static var disabledBackground: UIColor { Core.aged }
                static var disabledForeground: UIColor { Core.beige }
            }
            
            enum Progress {
                static var track: UIColor { Core.aged.withAlphaComponent(0.3) }
                static var fill: UIColor { Core.goldLeaf }
            }
            
            enum Card {
                static var background: UIColor { Dynamic.cardBackground }
                static var border: UIColor { Dynamic.border }
            }
        }
        
        // MARK: - Legacy Mappings
        // For backward compatibility during refactoring
        
        static let beige = Core.beige
        static let ancientInk = Core.ancientInk
        static let goldLeaf = Core.goldLeaf
        static let hieroglyphBlue = Core.hieroglyphBlue
        static let tombRed = Core.tombRed
        static let sandstone = Core.sandstone
        static let aged = Core.aged
        static let burnishedGold = Core.burnishedGold
        static let mysticPurple = Core.mysticPurple
        static let scarabGreen = Core.scarabGreen
        
        static let primaryBackground = Core.beige
        static let secondaryBackground = Core.sandstone
        static let tertiaryBackground = Core.aged
        
        static let primaryText = Core.ancientInk
        static let secondaryText = UIColor(red: 92/255, green: 72/255, blue: 54/255, alpha: 1.0)
        static let tertiaryText = UIColor(red: 142/255, green: 122/255, blue: 104/255, alpha: 1.0)
        
        static let success = Semantic.success
        static let error = Semantic.error
        static let warning = Semantic.warning
        static let info = Semantic.info
        
        static var background: UIColor { Dynamic.background }
        static var foreground: UIColor { Dynamic.primaryText }
    }
    
    // MARK: - Typography
    
    enum Typography {
        // Custom font names (will use system fonts as fallback)
        static let papyrusFont = "Papyrus" // Will use if available
        static let hieroglyphicFont = "American Typewriter" // Alternative ancient feel
        
        // Font Styles
        static func largeTitle(weight: UIFont.Weight = .bold) -> UIFont {
            if let font = UIFont(name: papyrusFont, size: 34) {
                return font
            }
            return UIFont.systemFont(ofSize: 34, weight: weight)
        }
        
        static func title1(weight: UIFont.Weight = .bold) -> UIFont {
            if let font = UIFont(name: papyrusFont, size: 28) {
                return font
            }
            return UIFont.systemFont(ofSize: 28, weight: weight)
        }
        
        static func title2(weight: UIFont.Weight = .semibold) -> UIFont {
            if let font = UIFont(name: papyrusFont, size: 22) {
                return font
            }
            return UIFont.systemFont(ofSize: 22, weight: weight)
        }
        
        static func title3(weight: UIFont.Weight = .semibold) -> UIFont {
            if let font = UIFont(name: papyrusFont, size: 20) {
                return font
            }
            return UIFont.systemFont(ofSize: 20, weight: weight)
        }
        
        static func headline(weight: UIFont.Weight = .semibold) -> UIFont {
            return UIFont.systemFont(ofSize: 17, weight: weight)
        }
        
        static func body(weight: UIFont.Weight = .regular) -> UIFont {
            return UIFont.systemFont(ofSize: 17, weight: weight)
        }
        
        static func callout(weight: UIFont.Weight = .regular) -> UIFont {
            return UIFont.systemFont(ofSize: 16, weight: weight)
        }
        
        static func subheadline(weight: UIFont.Weight = .regular) -> UIFont {
            return UIFont.systemFont(ofSize: 15, weight: weight)
        }
        
        static func footnote(weight: UIFont.Weight = .regular) -> UIFont {
            return UIFont.systemFont(ofSize: 13, weight: weight)
        }
        
        static func caption1(weight: UIFont.Weight = .regular) -> UIFont {
            return UIFont.systemFont(ofSize: 12, weight: weight)
        }
        
        static func caption2(weight: UIFont.Weight = .regular) -> UIFont {
            return UIFont.systemFont(ofSize: 11, weight: weight)
        }
        
        static func bodyItalic(weight: UIFont.Weight = .regular) -> UIFont {
            let descriptor = UIFont.systemFont(ofSize: 17, weight: weight).fontDescriptor
            let italicDescriptor = descriptor.withSymbolicTraits(.traitItalic) ?? descriptor
            return UIFont(descriptor: italicDescriptor, size: 17)
        }
    }
    
    // MARK: - Spacing & Layout
    
    enum Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 24
        static let rounded: CGFloat = 9999 // For circular elements
    }
    
    // MARK: - Shadows
    
    enum Shadow {
        static func papyrus(color: UIColor = .black) -> (color: CGColor, opacity: Float, offset: CGSize, radius: CGFloat) {
            return (color: color.cgColor, opacity: 0.15, offset: CGSize(width: 0, height: 2), radius: 8)
        }
        
        static func elevated(color: UIColor = .black) -> (color: CGColor, opacity: Float, offset: CGSize, radius: CGFloat) {
            return (color: color.cgColor, opacity: 0.2, offset: CGSize(width: 0, height: 4), radius: 12)
        }
        
        static func floating(color: UIColor = .black) -> (color: CGColor, opacity: Float, offset: CGSize, radius: CGFloat) {
            return (color: color.cgColor, opacity: 0.25, offset: CGSize(width: 0, height: 8), radius: 16)
        }
    }
    
    // MARK: - Borders
    
    enum Border {
        static let width: CGFloat = 1.5
        static let accentWidth: CGFloat = 2.5
        
        static func ancient(width: CGFloat = Border.width) -> (width: CGFloat, color: CGColor) {
            return (width: width, color: Colors.Dynamic.border.cgColor)
        }
        
        static func gold(width: CGFloat = Border.accentWidth) -> (width: CGFloat, color: CGColor) {
            return (width: width, color: Colors.Core.goldLeaf.cgColor)
        }
    }
    
    // MARK: - Animations
    
    enum Animation {
        static let quick: TimeInterval = 0.2
        static let normal: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        static let reveal: TimeInterval = 0.8
        
        static let springDamping: CGFloat = 0.7
        static let springVelocity: CGFloat = 0.5
    }
    
    // MARK: - Textures & Patterns
    
    enum Texture {
        static func papyrusPattern() -> UIColor {
            // Create a subtle papyrus texture pattern
            UIColor(patternImage: createPapyrusTexture())
        }
        
        private static func createPapyrusTexture() -> UIImage {
            let size = CGSize(width: 100, height: 100)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            
            // Base papyrus color
            Colors.beige.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            
            // Add subtle texture lines
            let context = UIGraphicsGetCurrentContext()!
            context.setStrokeColor(Colors.aged.withAlphaComponent(0.1).cgColor)
            context.setLineWidth(0.5)
            
            // Random papyrus fibers
            for _ in 0..<20 {
                let startX = CGFloat.random(in: 0...size.width)
                let startY = CGFloat.random(in: 0...size.height)
                let endX = startX + CGFloat.random(in: -20...20)
                let endY = startY + CGFloat.random(in: -20...20)
                
                context.move(to: CGPoint(x: startX, y: startY))
                context.addLine(to: CGPoint(x: endX, y: endY))
                context.strokePath()
            }
            
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            return image
        }
    }
    
    // MARK: - Component Styles
    
    enum ComponentStyle {
        // Card Style
        static func applyPapyrusCard(to view: UIView, elevated: Bool = false) {
            view.backgroundColor = Colors.Component.Card.background
            view.layer.cornerRadius = CornerRadius.large
            
            let border = Border.ancient()
            view.layer.borderWidth = border.width
            view.layer.borderColor = border.color
            
            if elevated {
                let shadow = Shadow.elevated()
                view.layer.shadowColor = shadow.color
                view.layer.shadowOpacity = shadow.opacity
                view.layer.shadowOffset = shadow.offset
                view.layer.shadowRadius = shadow.radius
            }
        }
        
        // Button Style
        static func applyPapyrusButton(to button: UIButton, style: ButtonStyle = .primary) {
            var config = UIButton.Configuration.filled()
            
            switch style {
            case .primary:
                config.baseBackgroundColor = Colors.Component.Button.primaryBackground
                config.baseForegroundColor = Colors.Component.Button.primaryForeground
            case .secondary:
                config.baseBackgroundColor = Colors.Component.Button.secondaryBackground
                config.baseForegroundColor = Colors.Component.Button.secondaryForeground
            case .tertiary:
                config.baseBackgroundColor = Colors.Component.Button.tertiaryBackground
                config.baseForegroundColor = Colors.Component.Button.tertiaryForeground
            case .destructive:
                config.baseBackgroundColor = Colors.Component.Button.destructiveBackground
                config.baseForegroundColor = Colors.Component.Button.destructiveForeground
            }
            
            config.cornerStyle = .medium
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = Typography.headline(weight: .semibold)
                return outgoing
            }
            
            button.configuration = config
        }
        
        enum ButtonStyle {
            case primary, secondary, tertiary, destructive
        }
    }
}

// MARK: - UIView Extensions

extension UIView {
    func applyPapyrusBackground() {
        backgroundColor = PapyrusDesignSystem.Colors.background
    }
    
    func applyPapyrusCard(elevated: Bool = false) {
        PapyrusDesignSystem.ComponentStyle.applyPapyrusCard(to: self, elevated: elevated)
    }
    
    func addPapyrusBorder(style: BorderStyle = .ancient) {
        switch style {
        case .ancient:
            let border = PapyrusDesignSystem.Border.ancient()
            layer.borderWidth = border.width
            layer.borderColor = border.color
        case .gold:
            let border = PapyrusDesignSystem.Border.gold()
            layer.borderWidth = border.width
            layer.borderColor = border.color
        }
    }
    
    enum BorderStyle {
        case ancient, gold
    }
}

// MARK: - UILabel Extensions

extension UILabel {
    func applyPapyrusStyle(_ style: TextStyle) {
        switch style {
        case .largeTitle:
            font = PapyrusDesignSystem.Typography.largeTitle()
            textColor = PapyrusDesignSystem.Colors.Dynamic.primaryText
        case .title1:
            font = PapyrusDesignSystem.Typography.title1()
            textColor = PapyrusDesignSystem.Colors.Dynamic.primaryText
        case .title2:
            font = PapyrusDesignSystem.Typography.title2()
            textColor = PapyrusDesignSystem.Colors.Dynamic.primaryText
        case .title3:
            font = PapyrusDesignSystem.Typography.title3()
            textColor = PapyrusDesignSystem.Colors.Dynamic.primaryText
        case .headline:
            font = PapyrusDesignSystem.Typography.headline()
            textColor = PapyrusDesignSystem.Colors.Dynamic.primaryText
        case .body:
            font = PapyrusDesignSystem.Typography.body()
            textColor = PapyrusDesignSystem.Colors.Dynamic.primaryText
        case .callout:
            font = PapyrusDesignSystem.Typography.callout()
            textColor = PapyrusDesignSystem.Colors.Dynamic.secondaryText
        case .subheadline:
            font = PapyrusDesignSystem.Typography.subheadline()
            textColor = PapyrusDesignSystem.Colors.Dynamic.secondaryText
        case .footnote:
            font = PapyrusDesignSystem.Typography.footnote()
            textColor = PapyrusDesignSystem.Colors.Dynamic.tertiaryText
        case .caption:
            font = PapyrusDesignSystem.Typography.caption1()
            textColor = PapyrusDesignSystem.Colors.Dynamic.tertiaryText
        }
    }
    
    enum TextStyle {
        case largeTitle, title1, title2, title3, headline, body, callout, subheadline, footnote, caption
    }
}