import UIKit

final class DeitySelectionViewController: UIViewController, ViewLayoutConfigurable {
    
    // MARK: - UI Components
    
    private let headerView = UIView()
    private let grabberView = UIView()
    private let titleLabel = UILabel()
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Properties
    
    private let deities: [OracleViewModel.Deity]
    private let onSelection: ((OracleViewModel.Deity) -> Void)?
    private let currentDeity: OracleViewModel.Deity?
    var currentLayoutPreference: ViewLayoutPreference = UserDefaults.standard.viewLayoutPreference
    
    // MARK: - Diffable Data Source
    
    private enum Section {
        case main
    }
    
    private lazy var dataSource = createDataSource()
    
    // MARK: - Initialization
    
    init(deities: [OracleViewModel.Deity], currentDeity: OracleViewModel.Deity?, onSelection: @escaping (OracleViewModel.Deity) -> Void) {
        AppLogger.ui.debug("[DeitySelectionViewController] Init", metadata: ["deityCount": deities.count])
        
        self.deities = deities
        self.currentDeity = currentDeity
        self.onSelection = onSelection
        
        super.init(nibName: nil, bundle: nil)
        
        AppLogger.ui.debug("[DeitySelectionViewController] Super init completed")
        
        // Set modal presentation style
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupLayout(for: currentLayoutPreference)
        setupNotifications()
        applySnapshot(animatingDifferences: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure proper initial selection
        if let currentDeity = currentDeity {
            let snapshot = dataSource.snapshot()
            if let index = snapshot.itemIdentifiers.firstIndex(where: { $0.id == currentDeity.id }) {
                let indexPath = IndexPath(item: index, section: 0)
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Layout will update automatically when bounds change
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update border colors when switching between light/dark mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Force layout update
            collectionView.collectionViewLayout.invalidateLayout()
            applySnapshot(animatingDifferences: false)
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        AppLogger.ui.debug("[DeitySelectionViewController] setupUI started")
        
        // Use dynamic color for background
        view.backgroundColor = UIColor.Papyrus.background
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Header container
        headerView.backgroundColor = UIColor.Papyrus.background
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        // Custom grabber (make it interactive)
        grabberView.backgroundColor = UIColor.Papyrus.aged
        grabberView.layer.cornerRadius = 2.5
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        grabberView.isUserInteractionEnabled = true
        headerView.addSubview(grabberView)
        
        // Add gesture recognizers to header for dismissal
        let grabberTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGrabberTap))
        grabberView.addGestureRecognizer(grabberTapGesture)
        
        let headerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleHeaderPan(_:)))
        headerView.addGestureRecognizer(headerPanGesture)
        
        // Title
        titleLabel.text = "Choose Your Divine Guide"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor.Papyrus.primaryText
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        // Collection view
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Grabber
            grabberView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            grabberView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: 36),
            grabberView.heightAnchor.constraint(equalToConstant: 5),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: grabberView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            
            // Collection view
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Compositional Layout
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 0
        
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self else { return nil }
            
            if self.currentLayoutPreference == .grid {
                // Grid layout
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(190))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8)
                section.interGroupSpacing = 8
                
                return section
            } else {
                // List layout
                var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
                listConfig.backgroundColor = .clear
                listConfig.showsSeparators = false
                
                let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 20, trailing: 0)
                
                return section
            }
        }, configuration: configuration)
    }
    
    // MARK: - Diffable Data Source Setup
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Section, OracleViewModel.Deity> {
        // Grid cell registration
        let gridCellRegistration = UICollectionView.CellRegistration<DeityCell, OracleViewModel.Deity> { [weak self] cell, indexPath, deity in
            cell.configure(with: deity, isSelected: deity.id == self?.currentDeity?.id)
        }
        
        // List cell registration
        let listCellRegistration = UICollectionView.CellRegistration<DeityCollectionListCell, OracleViewModel.Deity> { [weak self] cell, indexPath, deity in
            cell.configure(with: deity, isSelected: deity.id == self?.currentDeity?.id)
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Section, OracleViewModel.Deity>(collectionView: collectionView) { [weak self] collectionView, indexPath, deity in
            guard let self = self else { return nil }
            
            if self.currentLayoutPreference == .grid {
                return collectionView.dequeueConfiguredReusableCell(using: gridCellRegistration, for: indexPath, item: deity)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: deity)
            }
        }
        
        return dataSource
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, OracleViewModel.Deity>()
        snapshot.appendSections([.main])
        snapshot.appendItems(deities)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    // MARK: - Layout Management
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLayoutPreferenceChanged(_:)),
            name: .viewLayoutPreferenceChanged,
            object: nil
        )
    }
    
    @objc private func handleLayoutPreferenceChanged(_ notification: Notification) {
        if let layout = notification.userInfo?["layout"] as? ViewLayoutPreference {
            switchToLayout(layout)
        }
    }
    
    // MARK: - ViewLayoutConfigurable
    
    func switchToLayout(_ layout: ViewLayoutPreference) {
        currentLayoutPreference = layout
        setupLayout(for: layout)
        
        // Force layout update
        collectionView.collectionViewLayout.invalidateLayout()
        applySnapshot(animatingDifferences: false)
        
        // Re-select current deity if needed
        if let currentDeity = currentDeity {
            let snapshot = dataSource.snapshot()
            if let index = snapshot.itemIdentifiers.firstIndex(where: { $0.id == currentDeity.id }) {
                let indexPath = IndexPath(item: index, section: 0)
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    func setupLayout(for preference: ViewLayoutPreference) {
        // Layout will be handled by compositional layout
        // Just update the current preference which the layout uses
        currentLayoutPreference = preference
    }
    
    // MARK: - Actions
    
    @objc private func handleGrabberTap() {
        dismiss(animated: true)
    }
    
    @objc private func handleHeaderPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            // Only allow downward pan
            if translation.y > 0 {
                view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            let velocity = gesture.velocity(in: view)
            
            // Dismiss if dragged down more than 100 points or with sufficient velocity
            if translation.y > 100 || velocity.y > 800 {
                dismiss(animated: true)
            } else {
                // Snap back to original position
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                    self.view.transform = .identity
                })
            }
        default:
            break
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}


// MARK: - UICollectionViewDelegate

extension DeitySelectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedDeity = dataSource.itemIdentifier(for: indexPath) else { return }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Dismiss and call selection handler
        dismiss(animated: true) { [weak self] in
            self?.onSelection?(selectedDeity)
        }
    }
}

// MARK: - DeityCell

private class DeityCell: UICollectionViewCell {
    
    private let containerView = UIView()
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let roleLabel = UILabel()
    private let traditionLabel = UILabel()
    private let selectionIndicator = UIImageView()
    private let contentStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        // Container with sophisticated styling
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        updateColors()
        
        // Subtle shadow for depth
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Icon container with gradient background
        iconContainerView.layer.cornerRadius = 32
        iconContainerView.clipsToBounds = true
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        iconContainerView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        // Icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.addSubview(iconImageView)
        
        // Name
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.8
        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Role
        roleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        roleLabel.textAlignment = .center
        roleLabel.numberOfLines = 2
        roleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Tradition
        traditionLabel.font = .systemFont(ofSize: 11, weight: .medium)
        traditionLabel.textAlignment = .center
        traditionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Setup stack view
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.distribution = .fill
        contentStackView.spacing = 4
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(iconContainerView)
        contentStackView.setCustomSpacing(8, after: iconContainerView)
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(roleLabel)
        contentStackView.addArrangedSubview(traditionLabel)
        
        containerView.addSubview(contentStackView)
        
        // Selection indicator
        selectionIndicator.image = UIImage(systemName: "checkmark.circle.fill")
        selectionIndicator.tintColor = UIColor.Papyrus.gold
        selectionIndicator.isHidden = true
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(selectionIndicator)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Center stack view with flexible top/bottom
            contentStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            contentStackView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 12),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            
            roleLabel.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            roleLabel.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            
            traditionLabel.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            traditionLabel.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            
            selectionIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            selectionIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 24),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with deity: OracleViewModel.Deity, isSelected: Bool) {
        nameLabel.text = deity.name
        roleLabel.text = deity.role
        traditionLabel.text = deity.tradition.uppercased()
        
        // Safely get the color
        let deityColor = UIColor(hex: deity.color) ?? UIColor.Papyrus.gold
        traditionLabel.textColor = deityColor.withAlphaComponent(0.8)
        
        // Enhanced icon with better configuration
        let iconName = deity.avatar
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        
        // Try to load the icon with fallbacks
        if let image = UIImage(systemName: iconName) {
            iconImageView.image = image.withConfiguration(config)
        } else {
            // Fallback to a generic person icon
            iconImageView.image = UIImage(systemName: "person.circle.fill")?.withConfiguration(config)
        }
        iconImageView.tintColor = .white
        
        // Store the deity color for gradient creation
        iconContainerView.backgroundColor = deityColor
        
        // Create gradient immediately if bounds are valid
        if iconContainerView.bounds.width > 0 {
            updateIconGradient(with: deityColor)
        } else {
            // Force layout to ensure bounds are valid
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        // Selection state
        selectionIndicator.isHidden = !isSelected
        if isSelected {
            containerView.layer.borderColor = UIColor.Papyrus.gold.cgColor
            containerView.layer.borderWidth = 2
            containerView.backgroundColor = UIColor.Papyrus.cardBackground.withAlphaComponent(0.95)
            
            // Add glow effect
            containerView.layer.shadowColor = UIColor.Papyrus.gold.cgColor
            containerView.layer.shadowOpacity = 0.3
            containerView.layer.shadowRadius = 12
            
            // Add floating animation to selected icon
            startFloatingAnimation()
        } else {
            containerView.layer.borderColor = UIColor.Papyrus.aged.cgColor
            containerView.layer.borderWidth = 1
            containerView.backgroundColor = UIColor.Papyrus.cardBackground
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOpacity = 0.1
            containerView.layer.shadowRadius = 8
            
            // Stop floating animation
            iconContainerView.layer.removeAllAnimations()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update shadow path when bounds are valid
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 20).cgPath
        
        // Create or update gradient
        if iconContainerView.bounds.width > 0, let deityColor = iconContainerView.backgroundColor {
            updateIconGradient(with: deityColor)
        }
    }
    
    private func updateIconGradient(with deityColor: UIColor) {
        // Remove existing gradient layers
        if let sublayers = iconContainerView.layer.sublayers {
            for layer in sublayers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        // Create gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = iconContainerView.bounds
        gradientLayer.cornerRadius = 32
        gradientLayer.colors = [
            deityColor.withAlphaComponent(0.8).cgColor,
            deityColor.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        iconContainerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectionIndicator.isHidden = true
        containerView.layer.borderWidth = 1
        updateColors()
        
        // Safely remove gradient layers
        if let sublayers = iconContainerView.layer.sublayers {
            for layer in sublayers {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        containerView.transform = .identity
        iconContainerView.layer.removeAllAnimations()
        
        // Reset shadow to default
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 8
    }
    
    // MARK: - Touch Animations
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateScale(to: 0.95)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateScale(to: 1.0)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateScale(to: 1.0)
    }
    
    private func animateScale(to scale: CGFloat) {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.containerView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        )
    }
    
    private func startFloatingAnimation() {
        // Ensure we have valid bounds before animating
        guard iconContainerView.bounds.width > 0 else { return }
        
        // Remove any existing animations
        iconContainerView.layer.removeAllAnimations()
        
        // Create a gentle floating animation
        let floatAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        floatAnimation.fromValue = -3
        floatAnimation.toValue = 3
        floatAnimation.duration = 2.0
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        floatAnimation.isRemovedOnCompletion = false
        floatAnimation.fillMode = .forwards
        
        iconContainerView.layer.add(floatAnimation, forKey: "floating")
    }
    
    private func updateColors() {
        containerView.backgroundColor = UIColor.Papyrus.cardBackground
        
        containerView.layer.borderColor = self.traitCollection.userInterfaceStyle == .dark ?
            UIColor.Papyrus.aged.withAlphaComponent(0.3).cgColor :
            UIColor.Papyrus.aged.cgColor
        
        nameLabel.textColor = UIColor.Papyrus.primaryText
        roleLabel.textColor = UIColor.Papyrus.secondaryText
    }
}