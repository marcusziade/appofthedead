import UIKit

class PathPreviewView: UIView {
    
    // MARK: - Properties
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let journeyView = UIView()
    private let milestonesStackView = UIStackView()
    private let pathLineView = UIView()
    private let statsLabel = UILabel()
    private let topicsLabel = UILabel()
    private let unlockButton = UIButton()
    private let priceLabel = UILabel()
    private let ultimateContainer = UIView()
    private let ultimateButton = UIButton()
    
    private var pathColor: UIColor = PapyrusDesignSystem.Colors.goldLeaf
    private var onUnlockTapped: ((ProductIdentifier) -> Void)?
    private var productId: ProductIdentifier?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        
        // Container with rounded corners and shadow
        containerView.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 42/255, green: 38/255, blue: 34/255, alpha: 0.98)
                : UIColor.white.withAlphaComponent(0.98)
        }
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowRadius = 30
        containerView.layer.shadowOpacity = 0.3
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Title
        titleLabel.font = PapyrusDesignSystem.Typography.title2()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Journey visualization container
        journeyView.backgroundColor = .clear
        journeyView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(journeyView)
        
        // Path line (will be drawn behind milestones)
        pathLineView.backgroundColor = UIColor.separator.withAlphaComponent(0.3)
        pathLineView.layer.cornerRadius = 2
        pathLineView.translatesAutoresizingMaskIntoConstraints = false
        journeyView.addSubview(pathLineView)
        
        // Milestones
        milestonesStackView.axis = .horizontal
        milestonesStackView.distribution = .equalSpacing
        milestonesStackView.alignment = .center
        milestonesStackView.translatesAutoresizingMaskIntoConstraints = false
        journeyView.addSubview(milestonesStackView)
        
        // Stats
        statsLabel.font = PapyrusDesignSystem.Typography.subheadline()
        statsLabel.textColor = .secondaryLabel
        statsLabel.textAlignment = .center
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(statsLabel)
        
        // Topics
        topicsLabel.font = PapyrusDesignSystem.Typography.caption1()
        topicsLabel.textColor = .tertiaryLabel
        topicsLabel.textAlignment = .center
        topicsLabel.numberOfLines = 0
        topicsLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(topicsLabel)
        
        // Divider
        let divider = UIView()
        divider.backgroundColor = UIColor.separator.withAlphaComponent(0.2)
        divider.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(divider)
        
        // Unlock button
        unlockButton.titleLabel?.font = PapyrusDesignSystem.Typography.headline()
        unlockButton.setTitleColor(.white, for: .normal)
        unlockButton.layer.cornerRadius = 12
        unlockButton.addTarget(self, action: #selector(unlockTapped), for: .touchUpInside)
        unlockButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(unlockButton)
        
        // Price
        priceLabel.font = PapyrusDesignSystem.Typography.title3()
        priceLabel.textAlignment = .center
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(priceLabel)
        
        // Ultimate container
        ultimateContainer.backgroundColor = PapyrusDesignSystem.Colors.Dynamic.cardBackground
        ultimateContainer.layer.cornerRadius = 12
        ultimateContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(ultimateContainer)
        
        // Ultimate button
        let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
        starIcon.tintColor = PapyrusDesignSystem.Colors.goldLeaf
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let ultimateLabel = UILabel()
        ultimateLabel.text = "Unlock Everything"
        ultimateLabel.font = PapyrusDesignSystem.Typography.subheadline()
        ultimateLabel.textColor = .label
        
        let ultimateSubtitle = UILabel()
        ultimateSubtitle.text = "All 21 paths • Unlimited Oracle"
        ultimateSubtitle.font = PapyrusDesignSystem.Typography.caption1()
        ultimateSubtitle.textColor = .secondaryLabel
        
        let ultimateTextStack = UIStackView(arrangedSubviews: [ultimateLabel, ultimateSubtitle])
        ultimateTextStack.axis = .vertical
        ultimateTextStack.spacing = 2
        
        let ultimatePriceLabel = UILabel()
        ultimatePriceLabel.text = "$19.99"
        ultimatePriceLabel.font = PapyrusDesignSystem.Typography.headline()
        ultimatePriceLabel.textColor = PapyrusDesignSystem.Colors.goldLeaf
        
        let ultimateStack = UIStackView(arrangedSubviews: [starIcon, ultimateTextStack, UIView(), ultimatePriceLabel])
        ultimateStack.axis = .horizontal
        ultimateStack.alignment = .center
        ultimateStack.spacing = 12
        ultimateStack.translatesAutoresizingMaskIntoConstraints = false
        ultimateContainer.addSubview(ultimateStack)
        
        ultimateButton.addTarget(self, action: #selector(ultimateTapped), for: .touchUpInside)
        ultimateButton.translatesAutoresizingMaskIntoConstraints = false
        ultimateContainer.addSubview(ultimateButton)
        
        // VoiceOver for ultimate container
        ultimateContainer.isAccessibilityElement = true
        ultimateContainer.accessibilityLabel = "Unlock Everything: All 21 paths and unlimited Oracle access"
        ultimateContainer.accessibilityHint = "Purchase the ultimate enlightenment package"
        ultimateContainer.accessibilityTraits = .button
        
        // Constraints
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Journey view
            journeyView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            journeyView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            journeyView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            journeyView.heightAnchor.constraint(equalToConstant: 80),
            
            // Path line (centered vertically in journey view)
            pathLineView.centerYAnchor.constraint(equalTo: journeyView.centerYAnchor),
            pathLineView.leadingAnchor.constraint(equalTo: journeyView.leadingAnchor, constant: 40),
            pathLineView.trailingAnchor.constraint(equalTo: journeyView.trailingAnchor, constant: -40),
            pathLineView.heightAnchor.constraint(equalToConstant: 4),
            
            // Milestones
            milestonesStackView.centerYAnchor.constraint(equalTo: journeyView.centerYAnchor),
            milestonesStackView.leadingAnchor.constraint(equalTo: journeyView.leadingAnchor),
            milestonesStackView.trailingAnchor.constraint(equalTo: journeyView.trailingAnchor),
            
            // Stats
            statsLabel.topAnchor.constraint(equalTo: journeyView.bottomAnchor, constant: 16),
            statsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            statsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Topics
            topicsLabel.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 8),
            topicsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            topicsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Divider
            divider.topAnchor.constraint(equalTo: topicsLabel.bottomAnchor, constant: 20),
            divider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            // Unlock button
            unlockButton.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 20),
            unlockButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            unlockButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            unlockButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Price
            priceLabel.topAnchor.constraint(equalTo: unlockButton.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Ultimate container
            ultimateContainer.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 16),
            ultimateContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            ultimateContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            ultimateContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            ultimateContainer.heightAnchor.constraint(equalToConstant: 64),
            
            // Ultimate stack
            ultimateStack.leadingAnchor.constraint(equalTo: ultimateContainer.leadingAnchor, constant: 16),
            ultimateStack.trailingAnchor.constraint(equalTo: ultimateContainer.trailingAnchor, constant: -16),
            ultimateStack.centerYAnchor.constraint(equalTo: ultimateContainer.centerYAnchor),
            
            starIcon.widthAnchor.constraint(equalToConstant: 20),
            starIcon.heightAnchor.constraint(equalToConstant: 20),
            
            // Ultimate button overlay
            ultimateButton.topAnchor.constraint(equalTo: ultimateContainer.topAnchor),
            ultimateButton.leadingAnchor.constraint(equalTo: ultimateContainer.leadingAnchor),
            ultimateButton.trailingAnchor.constraint(equalTo: ultimateContainer.trailingAnchor),
            ultimateButton.bottomAnchor.constraint(equalTo: ultimateContainer.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with preview: PathPreview, beliefSystem: BeliefSystem, price: String, onUnlock: @escaping (ProductIdentifier) -> Void) {
        self.onUnlockTapped = onUnlock
        self.pathColor = UIColor(hex: beliefSystem.color) ?? PapyrusDesignSystem.Colors.goldLeaf
        
        // Find matching product ID
        self.productId = ProductIdentifier.allCases.first { $0.beliefSystemId == beliefSystem.id }
        
        // Title
        titleLabel.text = "\(beliefSystem.name) Journey"
        
        // VoiceOver
        titleLabel.accessibilityTraits = .header
        containerView.accessibilityLabel = "\(beliefSystem.name) learning path preview"
        containerView.accessibilityHint = "Shows the journey through \(beliefSystem.name) beliefs"
        
        // Create milestones
        milestonesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, stop) in preview.previewStops.enumerated() {
            let milestone = createMilestone(stop: stop, index: index, total: preview.previewStops.count)
            milestonesStackView.addArrangedSubview(milestone)
        }
        
        // Animate path color
        UIView.animate(withDuration: 0.3) {
            self.pathLineView.backgroundColor = self.pathColor.withAlphaComponent(0.3)
        }
        
        // Stats
        let achievementText = preview.unlockCount == 1 ? "achievement" : "achievements"
        statsLabel.text = "\(preview.totalLessons) lessons • \(preview.unlockCount) \(achievementText)"
        statsLabel.accessibilityLabel = "\(preview.totalLessons) lessons and \(preview.unlockCount) \(achievementText) to unlock"
        
        // Topics
        topicsLabel.text = preview.keyTopics.joined(separator: " • ")
        topicsLabel.accessibilityLabel = "Key topics include: \(preview.keyTopics.joined(separator: ", "))"
        
        // Unlock button
        unlockButton.setTitle("Unlock This Path", for: .normal)
        unlockButton.backgroundColor = pathColor
        unlockButton.accessibilityLabel = "Unlock \(beliefSystem.name) path"
        unlockButton.accessibilityHint = "Purchase for \(price)"
        
        // Price
        priceLabel.text = price
        priceLabel.textColor = pathColor
        priceLabel.accessibilityElementsHidden = true // Already included in button hint
        
        // Update ultimate price if available
        if let ultimatePrice = StoreManager.shared.formattedPrice(for: .ultimateEnlightenment) {
            if let ultimatePriceLabel = ultimateContainer.subviews.compactMap({ $0 as? UIStackView }).first?.arrangedSubviews.last as? UILabel {
                ultimatePriceLabel.text = ultimatePrice
            }
        }
    }
    
    private func createMilestone(stop: PathPreview.PreviewStop, index: Int, total: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Adaptive sizing based on screen width
        let screenWidth = UIScreen.main.bounds.width
        let isSmallScreen = screenWidth <= 375 // iPhone SE, 12/13 mini
        let circleSize: CGFloat = isSmallScreen ? 50 : 60
        let iconSize: CGFloat = isSmallScreen ? 20 : 24
        
        // Circle background
        let circle = UIView()
        circle.backgroundColor = PapyrusDesignSystem.Colors.Dynamic.cardBackground
        circle.layer.cornerRadius = circleSize / 2
        circle.layer.borderWidth = 3
        circle.layer.borderColor = pathColor.withAlphaComponent(0.3).cgColor
        circle.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(circle)
        
        // Icon
        let icon = UIImageView(image: UIImage(systemName: stop.icon))
        icon.tintColor = pathColor
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(icon)
        
        // Label
        let label = UILabel()
        label.text = stop.title
        label.font = isSmallScreen ? PapyrusDesignSystem.Typography.caption2() : PapyrusDesignSystem.Typography.caption1()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        // VoiceOver for milestone
        container.isAccessibilityElement = true
        container.accessibilityLabel = "Milestone \(index + 1) of \(total): \(stop.title)"
        container.accessibilityTraits = .none
        
        let labelWidth: CGFloat = isSmallScreen ? 70 : 80
        
        NSLayoutConstraint.activate([
            circle.topAnchor.constraint(equalTo: container.topAnchor),
            circle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circle.widthAnchor.constraint(equalToConstant: circleSize),
            circle.heightAnchor.constraint(equalToConstant: circleSize),
            
            icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: iconSize),
            icon.heightAnchor.constraint(equalToConstant: iconSize),
            
            label.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.widthAnchor.constraint(equalToConstant: labelWidth)
        ])
        
        // Animate in with delay
        container.alpha = 0
        container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                container.alpha = 1
                container.transform = .identity
            }
        }
        
        return container
    }
    
    // MARK: - Actions
    @objc private func unlockTapped() {
        if let productId = productId, let onUnlock = onUnlockTapped {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            onUnlock(productId)
        }
    }
    
    @objc private func ultimateTapped() {
        if let onUnlock = onUnlockTapped {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            
            onUnlock(.ultimateEnlightenment)
        }
    }
}

// MARK: - Path Preview Model
struct PathPreview: Codable {
    struct PreviewStop: Codable {
        let icon: String
        let title: String
    }
    
    let previewStops: [PreviewStop]
    let totalLessons: Int
    let unlockCount: Int
    let keyTopics: [String]
    
    enum CodingKeys: String, CodingKey {
        case previewStops = "preview_stops"
        case totalLessons = "total_lessons"
        case unlockCount = "unlock_count"
        case keyTopics = "key_topics"
    }
}