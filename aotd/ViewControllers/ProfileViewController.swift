import UIKit

final class ProfileViewController: UIViewController {
    
    private let viewModel: ProfileViewModel
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    // Header views
    private let profileHeaderView = UIView()
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let levelLabel = UILabel()
    private let xpProgressView = UIProgressView()
    private let xpLabel = UILabel()
    
    // Stats section
    private let statsContainerView = UIView()
    private let statsStackView = UIStackView()
    
    // Achievements section
    private let achievementsHeaderLabel = UILabel()
    private lazy var achievementsCollectionView = createAchievementsCollectionView()
    
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadData()
        
        // Listen for data changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataUpdate),
            name: Notification.Name("UserDataDidUpdate"),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        title = "Profile"
        
        // Reload data every time the view appears to ensure fresh stats
        viewModel.loadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.Papyrus.background
        
        setupScrollView()
        setupProfileHeader()
        setupStatsSection()
        setupUpgradeSection()
        setupAchievementsSection()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.alignment = .fill
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func setupProfileHeader() {
        profileHeaderView.backgroundColor = UIColor.Papyrus.cardBackground
        profileHeaderView.layer.cornerRadius = 16
        profileHeaderView.layer.borderWidth = 1.5
        profileHeaderView.layer.borderColor = UIColor.Papyrus.aged.cgColor
        profileHeaderView.layer.shadowColor = UIColor.black.cgColor
        profileHeaderView.layer.shadowOffset = CGSize(width: 0, height: 2)
        profileHeaderView.layer.shadowOpacity = 0.1
        profileHeaderView.layer.shadowRadius = 4
        contentStackView.addArrangedSubview(profileHeaderView)
        
        // Avatar
        avatarImageView.backgroundColor = UIColor.Papyrus.hieroglyphBlue
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.image = UIImage(systemName: "person.fill")
        avatarImageView.tintColor = UIColor.Papyrus.beige
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        profileHeaderView.addSubview(avatarImageView)
        
        // Name
        if let papyrusFont = UIFont(name: "Papyrus", size: 26) {
            nameLabel.font = papyrusFont
        } else {
            nameLabel.font = .systemFont(ofSize: 26, weight: .bold)
        }
        nameLabel.textColor = UIColor.Papyrus.primaryText
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileHeaderView.addSubview(nameLabel)
        
        // Level
        levelLabel.font = .systemFont(ofSize: 18, weight: .bold)
        levelLabel.textColor = UIColor.Papyrus.gold
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        profileHeaderView.addSubview(levelLabel)
        
        // XP Progress
        xpProgressView.progressTintColor = UIColor.Papyrus.gold
        xpProgressView.trackTintColor = UIColor.Papyrus.aged.withAlphaComponent(0.3)
        xpProgressView.layer.cornerRadius = 4
        xpProgressView.clipsToBounds = true
        xpProgressView.translatesAutoresizingMaskIntoConstraints = false
        profileHeaderView.addSubview(xpProgressView)
        
        // XP Label
        xpLabel.font = .systemFont(ofSize: 14, weight: .medium)
        xpLabel.textColor = UIColor.Papyrus.secondaryText
        xpLabel.translatesAutoresizingMaskIntoConstraints = false
        profileHeaderView.addSubview(xpLabel)
        
        NSLayoutConstraint.activate([
            profileHeaderView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            
            avatarImageView.leadingAnchor.constraint(equalTo: profileHeaderView.leadingAnchor, constant: 20),
            avatarImageView.centerYAnchor.constraint(equalTo: profileHeaderView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: profileHeaderView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: profileHeaderView.trailingAnchor, constant: -20),
            
            levelLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            levelLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            levelLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            xpProgressView.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 12),
            xpProgressView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            xpProgressView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            xpProgressView.heightAnchor.constraint(equalToConstant: 8),
            
            xpLabel.topAnchor.constraint(equalTo: xpProgressView.bottomAnchor, constant: 8),
            xpLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            xpLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            xpLabel.bottomAnchor.constraint(lessThanOrEqualTo: profileHeaderView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupStatsSection() {
        statsContainerView.backgroundColor = UIColor.Papyrus.cardBackground
        statsContainerView.layer.cornerRadius = 16
        statsContainerView.layer.borderWidth = 1.5
        statsContainerView.layer.borderColor = UIColor.Papyrus.aged.cgColor
        statsContainerView.layer.shadowColor = UIColor.black.cgColor
        statsContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        statsContainerView.layer.shadowOpacity = 0.1
        statsContainerView.layer.shadowRadius = 4
        contentStackView.addArrangedSubview(statsContainerView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Statistics"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor.Papyrus.primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.addSubview(titleLabel)
        
        statsStackView.axis = .vertical
        statsStackView.spacing = 16
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        statsContainerView.addSubview(statsStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: statsContainerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -20),
            
            statsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: statsContainerView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: statsContainerView.trailingAnchor, constant: -20),
            statsStackView.bottomAnchor.constraint(equalTo: statsContainerView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupUpgradeSection() {
        // Only show if user doesn't have ultimate access
        guard let user = viewModel.user, !user.hasUltimateAccess() else { return }
        
        let upgradeContainer = UIView()
        upgradeContainer.backgroundColor = UIColor.Papyrus.cardBackground
        upgradeContainer.layer.cornerRadius = 16
        upgradeContainer.layer.borderWidth = 2
        upgradeContainer.layer.borderColor = UIColor.systemOrange.cgColor
        
        let upgradeStack = UIStackView()
        upgradeStack.axis = .vertical
        upgradeStack.spacing = 12
        upgradeStack.alignment = .fill
        upgradeStack.translatesAutoresizingMaskIntoConstraints = false
        
        let crownIcon = UIImageView(image: UIImage(systemName: "crown.fill"))
        crownIcon.tintColor = .systemOrange
        crownIcon.contentMode = .scaleAspectFit
        crownIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Unlock Ultimate Enlightenment"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Access all paths, unlimited Oracle, cloud sync, and exclusive features"
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        let upgradeButton = UIButton(type: .system)
        upgradeButton.setTitle("View Options", for: .normal)
        upgradeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        upgradeButton.backgroundColor = .systemOrange
        upgradeButton.setTitleColor(.white, for: .normal)
        upgradeButton.layer.cornerRadius = 8
        upgradeButton.addTarget(self, action: #selector(showPaywall), for: .touchUpInside)
        
        upgradeStack.addArrangedSubview(crownIcon)
        upgradeStack.addArrangedSubview(titleLabel)
        upgradeStack.addArrangedSubview(descriptionLabel)
        upgradeStack.addArrangedSubview(upgradeButton)
        
        upgradeContainer.addSubview(upgradeStack)
        
        NSLayoutConstraint.activate([
            crownIcon.heightAnchor.constraint(equalToConstant: 40),
            upgradeButton.heightAnchor.constraint(equalToConstant: 44),
            
            upgradeStack.topAnchor.constraint(equalTo: upgradeContainer.topAnchor, constant: 20),
            upgradeStack.leadingAnchor.constraint(equalTo: upgradeContainer.leadingAnchor, constant: 20),
            upgradeStack.trailingAnchor.constraint(equalTo: upgradeContainer.trailingAnchor, constant: -20),
            upgradeStack.bottomAnchor.constraint(equalTo: upgradeContainer.bottomAnchor, constant: -20)
        ])
        
        contentStackView.addArrangedSubview(upgradeContainer)
        
        // Add XP boost indicator if active
        if user.hasActiveXPBoost() {
            let boostContainer = UIView()
            boostContainer.backgroundColor = UIColor.Papyrus.cardBackground
            boostContainer.layer.cornerRadius = 12
            
            let boostStack = UIStackView()
            boostStack.axis = .horizontal
            boostStack.spacing = 8
            boostStack.alignment = .center
            boostStack.translatesAutoresizingMaskIntoConstraints = false
            
            let boostIndicator = XPBoostIndicator()
            boostIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            let boostLabel = UILabel()
            boostLabel.text = "XP Boost Active!"
            boostLabel.font = .systemFont(ofSize: 16, weight: .medium)
            
            boostStack.addArrangedSubview(boostIndicator)
            boostStack.addArrangedSubview(boostLabel)
            boostStack.addArrangedSubview(UIView()) // Spacer
            
            boostContainer.addSubview(boostStack)
            
            NSLayoutConstraint.activate([
                boostStack.topAnchor.constraint(equalTo: boostContainer.topAnchor, constant: 12),
                boostStack.leadingAnchor.constraint(equalTo: boostContainer.leadingAnchor, constant: 16),
                boostStack.trailingAnchor.constraint(equalTo: boostContainer.trailingAnchor, constant: -16),
                boostStack.bottomAnchor.constraint(equalTo: boostContainer.bottomAnchor, constant: -12)
            ])
            
            contentStackView.addArrangedSubview(boostContainer)
        }
    }
    
    @objc private func showPaywall() {
        let paywall = PaywallViewController(reason: .generalUpgrade)
        present(paywall, animated: true)
    }
    
    private func setupAchievementsSection() {
        achievementsHeaderLabel.text = "Achievements"
        achievementsHeaderLabel.font = .systemFont(ofSize: 20, weight: .bold)
        achievementsHeaderLabel.textColor = UIColor.Papyrus.primaryText
        contentStackView.addArrangedSubview(achievementsHeaderLabel)
        
        contentStackView.addArrangedSubview(achievementsCollectionView)
        
        NSLayoutConstraint.activate([
            achievementsCollectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    
    private func createAchievementsCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 120)
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.Papyrus.background
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AchievementBadgeCell.self, forCellWithReuseIdentifier: "AchievementBadgeCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }
    
    private func bindViewModel() {
        viewModel.onDataUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }
    
    private func updateUI() {
        guard let user = viewModel.user,
              let stats = viewModel.userStats else { return }
        
        // Update header
        nameLabel.text = user.name
        levelLabel.text = "Level \(user.currentLevel)"
        
        // Calculate XP progress to next level
        let currentLevelXP = (user.currentLevel - 1) * 100
        let nextLevelXP = user.currentLevel * 100
        let progressInLevel = user.totalXP - currentLevelXP
        let xpNeededForLevel = nextLevelXP - currentLevelXP
        
        xpProgressView.progress = Float(progressInLevel) / Float(xpNeededForLevel)
        xpLabel.text = "\(progressInLevel) / \(xpNeededForLevel) XP to next level"
        
        // Update stats
        updateStatsSection(with: stats)
        
        // Reload achievements
        achievementsCollectionView.reloadData()
    }
    
    private func updateStatsSection(with stats: UserStatistics) {
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let statItems = [
            ("Total XP", "\(stats.totalXP)"),
            ("Lessons Completed", "\(stats.totalLessonsCompleted)"),
            ("Correct Answers", "\(stats.correctAnswers)"),
            ("Achievements Unlocked", "\(stats.totalAchievements)")
        ]
        
        for (title, value) in statItems {
            let statView = createStatView(title: title, value: value)
            statsStackView.addArrangedSubview(statView)
        }
    }
    
    private func createStatView(title: String, value: String) -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor.Papyrus.secondaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = UIColor.Papyrus.gold
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -8),
            
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            containerView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return containerView
    }
    
    
    @objc private func handleDataUpdate() {
        viewModel.loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.userAchievements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AchievementBadgeCell", for: indexPath) as! AchievementBadgeCell
        
        let userAchievement = viewModel.userAchievements[indexPath.item]
        if let achievement = viewModel.achievements.first(where: { $0.id == userAchievement.achievementId }) {
            cell.configure(with: achievement, userAchievement: userAchievement)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userAchievement = viewModel.userAchievements[indexPath.item]
        if let achievement = viewModel.achievements.first(where: { $0.id == userAchievement.achievementId }) {
            showAchievementDetail(achievement: achievement, userAchievement: userAchievement)
        }
    }
    
    private func showAchievementDetail(achievement: Achievement, userAchievement: UserAchievement) {
        let progressText = userAchievement.isCompleted ? "Completed!" : "Progress: \(Int(userAchievement.progress * 100))%"
        
        PapyrusAlert.showSimpleAlert(
            title: achievement.name,
            message: "\(achievement.description)\n\n\(progressText)",
            from: self
        )
    }
}