import UIKit

class PapyrusModal: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    // MARK: - Properties
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let keywordLabel = UILabel()
    private let contentTextView = UITextView()
    private let loadingView = PapyrusLoadingView(style: .oracle)
    private let grabberView = UIView()
    private var gradientLayer: CAGradientLayer?
    
    // Download UI properties
    private let downloadContainerView = UIView()
    private let downloadLoadingView = PapyrusLoadingView(style: .download)
    private let downloadButton = UIButton(type: .system)
    
    private let deity: Deity
    private let keyword: String
    private let mlxService: MLXService
    private var streamingTask: Task<Void, Never>?
    private let mlxManager = MLXModelManager.shared
    
    // Download tracking properties
    private let modelSizeGB: Double = 1.8
    private var modelSizeBytes: Int64 { Int64(modelSizeGB * 1024 * 1024 * 1024) }
    private var progressTimer: Timer?
    
    // Progress smoothing properties
    private var downloadStartTime = Date()
    private var lastReportedProgress: Float = 0.0
    private var progressHistory: [(time: Date, progress: Float)] = []
    private var smoothedProgress: Float = 0.0
    private var progressAnimator: Timer?
    
    // MARK: - Initialization
    
    init(deity: Deity, keyword: String, mlxService: MLXService) {
        self.deity = deity
        self.keyword = keyword
        self.mlxService = mlxService
        super.init(nibName: nil, bundle: nil)
        
        // Configure for sheet presentation
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = PapyrusDesignSystem.CornerRadius.xLarge
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Check if model is loaded
        if mlxManager.isModelLoaded {
            // Model is loaded, start streaming
            downloadContainerView.isHidden = true
            contentTextView.isHidden = false
            startStreamingExplanation()
        } else {
            // Model needs to be downloaded
            downloadContainerView.isHidden = false
            contentTextView.isHidden = true
            setupDownloadUI()
            updateDownloadUI()
        }
        
        // Set presentation controller delegate to detect actual dismissal
        presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Don't cancel here anymore - wait for actual dismissal
    }
    
    deinit {
        // Ensure task is cancelled if view controller is deallocated
        streamingTask?.cancel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient frame
        gradientLayer?.frame = headerView.bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            updateGradientColors()
            updateBorderColors()
            updateShadows()
            updateBackgroundColor()
            updateDownloadContainerColors()
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Add blur effect for modal background
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        } else {
            view.backgroundColor = PapyrusDesignSystem.Colors.background
        }
        
        // Scroll view setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(scrollView)
        
        // Content stack view
        contentStackView.axis = .vertical
        contentStackView.spacing = PapyrusDesignSystem.Spacing.large
        contentStackView.alignment = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        
        // Header view with gradient
        headerView.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.systemGray6
                : PapyrusDesignSystem.Colors.sandstone
        }
        headerView.layer.cornerRadius = PapyrusDesignSystem.CornerRadius.large
        headerView.layer.borderWidth = 1
        
        // Add shadow for depth in dark mode
        if traitCollection.userInterfaceStyle == .dark {
            headerView.layer.shadowColor = UIColor(hex: deity.color)?.cgColor ?? UIColor.systemPurple.cgColor
            headerView.layer.shadowOpacity = 0.3
            headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
            headerView.layer.shadowRadius = 8
        }
        
        // Store gradient layer for updates
        let gradientLayer = CAGradientLayer()
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = PapyrusDesignSystem.CornerRadius.large
        headerView.layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
        updateGradientColors()
        updateBorderColors()
        
        let headerStackView = UIStackView()
        headerStackView.axis = .horizontal
        headerStackView.alignment = .center
        headerStackView.spacing = PapyrusDesignSystem.Spacing.medium
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerStackView)
        
        // Avatar - using UIImageView for SF Symbol
        let avatarImageView = UIImageView()
        if let symbolImage = UIImage(systemName: deity.avatar) {
            avatarImageView.image = symbolImage
            avatarImageView.tintColor = UIColor { [weak self] traitCollection in
                let baseColor = UIColor(hex: self?.deity.color ?? "") ?? UIColor.systemPurple
                return traitCollection.userInterfaceStyle == .dark
                    ? baseColor
                    : baseColor.withAlphaComponent(0.9)
            }
        } else {
            // Fallback if not a valid SF Symbol
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = PapyrusDesignSystem.Colors.foreground
        }
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title and keyword
        let titleStackView = UIStackView()
        titleStackView.axis = .vertical
        titleStackView.spacing = PapyrusDesignSystem.Spacing.xxSmall
        
        titleLabel.text = "\(deity.name), \(deity.role)"
        titleLabel.font = PapyrusDesignSystem.Typography.subheadline()
        titleLabel.textColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.label
                : PapyrusDesignSystem.Colors.secondaryText
        }
        
        keywordLabel.text = keyword
        keywordLabel.font = PapyrusDesignSystem.Typography.headline(weight: .semibold)
        keywordLabel.textColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.label
                : PapyrusDesignSystem.Colors.primaryText
        }
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(keywordLabel)
        
        headerStackView.addArrangedSubview(avatarImageView)
        headerStackView.addArrangedSubview(titleStackView)
        headerStackView.addArrangedSubview(UIView()) // Spacer
        
        // Content text view
        contentTextView.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.systemGray5
                : PapyrusDesignSystem.Colors.secondaryBackground
        }
        contentTextView.layer.cornerRadius = PapyrusDesignSystem.CornerRadius.medium
        contentTextView.font = PapyrusDesignSystem.Typography.body()
        contentTextView.textColor = PapyrusDesignSystem.Colors.foreground
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false
        contentTextView.textContainerInset = UIEdgeInsets(
            top: PapyrusDesignSystem.Spacing.medium,
            left: PapyrusDesignSystem.Spacing.medium,
            bottom: PapyrusDesignSystem.Spacing.medium,
            right: PapyrusDesignSystem.Spacing.medium
        )
        
        // Add to content stack
        contentStackView.addArrangedSubview(headerView)
        contentStackView.addArrangedSubview(contentTextView)
        contentStackView.addArrangedSubview(downloadContainerView)
        
        // Add loading view to content text view
        contentTextView.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set deity color for loading view
        let deityColor = UIColor(hex: deity.color) ?? UIColor.systemPurple
        loadingView.setDeityColor(deityColor)
        
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content stack view
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: PapyrusDesignSystem.Spacing.medium),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: PapyrusDesignSystem.Spacing.medium),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -PapyrusDesignSystem.Spacing.medium),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -PapyrusDesignSystem.Spacing.medium),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -PapyrusDesignSystem.Spacing.medium * 2),
            
            // Header view
            headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            // Header stack view inside header view
            headerStackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: PapyrusDesignSystem.Spacing.medium),
            headerStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: PapyrusDesignSystem.Spacing.medium),
            headerStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -PapyrusDesignSystem.Spacing.medium),
            headerStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -PapyrusDesignSystem.Spacing.medium),
            
            // Content text view
            contentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300),
            
            // Loading view
            loadingView.centerXAnchor.constraint(equalTo: contentTextView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: contentTextView.centerYAnchor),
            loadingView.widthAnchor.constraint(equalTo: contentTextView.widthAnchor),
            loadingView.heightAnchor.constraint(equalTo: contentTextView.heightAnchor),
            
            // Avatar image view
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Actions
    
    // MARK: - Download UI
    
    private func setupDownloadUI() {
        // Container styling similar to Oracle
        downloadContainerView.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.systemGray5
                : PapyrusDesignSystem.Colors.secondaryBackground
        }
        downloadContainerView.layer.cornerRadius = PapyrusDesignSystem.CornerRadius.large
        downloadContainerView.layer.borderWidth = 1
        let baseColor = UIColor(hex: deity.color) ?? UIColor.systemPurple
        downloadContainerView.layer.borderColor = traitCollection.userInterfaceStyle == .dark
            ? baseColor.withAlphaComponent(0.3).cgColor
            : PapyrusDesignSystem.Colors.aged.cgColor
        downloadContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add download loading view
        downloadContainerView.addSubview(downloadLoadingView)
        downloadLoadingView.translatesAutoresizingMaskIntoConstraints = false
        downloadLoadingView.setDeityColor(baseColor)
        
        // Update loading view content
        if DeviceUtility.isSimulator {
            downloadLoadingView.updateTitle("Simulator Mode")
            downloadLoadingView.updateSubtitle("The Oracle runs on device. Use a physical device to experience divine wisdom.")
        } else {
            downloadLoadingView.updateTitle("Oracle Model Required")
            downloadLoadingView.updateSubtitle("Download the Oracle model to unlock divine explanations from \(deity.name).")
        }
        
        // Download button
        downloadButton.setTitle(DeviceUtility.isSimulator ? "Use Physical Device" : "Download Oracle Model", for: .normal)
        downloadButton.titleLabel?.font = PapyrusDesignSystem.Typography.body(weight: .semibold)
        downloadButton.backgroundColor = baseColor
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.layer.cornerRadius = PapyrusDesignSystem.CornerRadius.medium
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        downloadButton.isEnabled = !DeviceUtility.isSimulator
        downloadButton.alpha = DeviceUtility.isSimulator ? 0.5 : 1.0
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        downloadContainerView.addSubview(downloadButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Download container
            downloadContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300),
            
            // Download loading view
            downloadLoadingView.topAnchor.constraint(equalTo: downloadContainerView.topAnchor),
            downloadLoadingView.leadingAnchor.constraint(equalTo: downloadContainerView.leadingAnchor),
            downloadLoadingView.trailingAnchor.constraint(equalTo: downloadContainerView.trailingAnchor),
            downloadLoadingView.bottomAnchor.constraint(equalTo: downloadContainerView.bottomAnchor),
            
            // Download button
            downloadButton.centerXAnchor.constraint(equalTo: downloadContainerView.centerXAnchor),
            downloadButton.bottomAnchor.constraint(equalTo: downloadContainerView.bottomAnchor, constant: -PapyrusDesignSystem.Spacing.xLarge),
            downloadButton.widthAnchor.constraint(equalToConstant: 250),
            downloadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func updateDownloadUI() {
        guard !DeviceUtility.isSimulator else { return }
        
        // Just show the download button, don't start downloading automatically
        downloadButton.isHidden = false
    }
    
    @objc private func downloadButtonTapped() {
        guard !DeviceUtility.isSimulator else { return }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        downloadButton.isHidden = true
        downloadLoadingView.startAnimating()
        downloadLoadingView.updateProgress(0, withText: "Preparing divine connection...")
        
        downloadStartTime = Date()
        lastReportedProgress = 0.0
        progressHistory = []
        smoothedProgress = 0.0
        
        Task {
            do {
                // Start a timer to ensure UI updates even if progress doesn't report
                await MainActor.run {
                    self.progressTimer?.invalidate()
                    self.progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                        guard let self = self else {
                            timer.invalidate()
                            return
                        }
                        
                        // If we haven't received any progress updates, at least show the size
                        if self.smoothedProgress == 0 {
                            self.downloadLoadingView.updateProgress(0, withText: String(format: "0 MB / %.1f GB", 
                                                         Double(self.modelSizeBytes) / 1024 / 1024 / 1024))
                        }
                    }
                }
                
                try await mlxManager.downloadModel { [weak self] progress in
                    guard let self = self else { return }
                    
                    Task { @MainActor in
                        // Handle discrete progress steps from MLX
                        self.handleProgressUpdate(progress.progress)
                    }
                }
            } catch {
                await MainActor.run {
                    self.progressTimer?.invalidate()
                    self.progressTimer = nil
                    
                    self.downloadButton.isHidden = false
                    self.downloadLoadingView.stopAnimating()
                    
                    // Show error alert
                    let alert = UIAlertController(
                        title: "Download Failed",
                        message: "Unable to download the Oracle model. Please check your internet connection and try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    // MARK: - Data Loading
    
    private func startStreamingExplanation() {
        contentTextView.text = ""
        loadingView.startAnimating()
        
        streamingTask = Task {
            do {
                // Ensure model is loaded
                if !mlxService.isModelLoaded {
                    try await mlxService.loadModel { progress in
                        // Progress handled internally
                    }
                }
                let prompt = "Explain the concept of '\(keyword)' in the context of afterlife beliefs. Be informative yet concise, speaking in character as \(deity.name)."
                
                let messages = [
                    ChatMessage(role: .system, content: deity.systemPrompt),
                    ChatMessage(role: .user, content: prompt)
                ]
                
                let config = MLXService.GenerationConfig(
                    temperature: 0.7,
                    maxTokens: 400,
                    topP: 0.95,
                    repetitionPenalty: 1.1
                )
                
                let stream = try await mlxService.generate(messages: messages, config: config)
                
                await MainActor.run {
                    self.loadingView.stopAnimating()
                    self.loadingView.isHidden = true
                }
                
                var fullText = ""
                for try await chunk in stream {
                    // Check for cancellation
                    try Task.checkCancellation()
                    guard !Task.isCancelled else { break }
                    
                    fullText += chunk
                    
                    await MainActor.run {
                        self.contentTextView.text = fullText
                        
                        // Auto-scroll to bottom as text streams in
                        if self.contentTextView.contentSize.height > self.contentTextView.bounds.height {
                            let bottomOffset = CGPoint(
                                x: 0,
                                y: self.contentTextView.contentSize.height - self.contentTextView.bounds.size.height + self.contentTextView.contentInset.bottom
                            )
                            self.contentTextView.setContentOffset(bottomOffset, animated: false)
                        }
                    }
                }
            } catch {
                // Don't show error if task was cancelled
                if error is CancellationError || Task.isCancelled {
                    return
                }
                
                await MainActor.run {
                    self.loadingView.stopAnimating()
                    self.loadingView.isHidden = true
                    self.contentTextView.text = "I apologize, but I cannot channel the divine wisdom at this moment. The connection to the eternal realm seems disrupted. Please try again later."
                }
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateGradientColors() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        if isDarkMode {
            // More vibrant gradient in dark mode
            gradientLayer?.colors = [
                (UIColor(hex: deity.color)?.withAlphaComponent(0.4) ?? UIColor.clear).cgColor,
                (UIColor(hex: deity.color)?.withAlphaComponent(0.1) ?? UIColor.clear).cgColor
            ]
        } else {
            // Subtle gradient in light mode
            gradientLayer?.colors = [
                (UIColor(hex: deity.color)?.withAlphaComponent(0.15) ?? UIColor.clear).cgColor,
                (UIColor(hex: deity.color)?.withAlphaComponent(0.05) ?? UIColor.clear).cgColor
            ]
        }
    }
    
    private func updateBorderColors() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        if isDarkMode {
            // Use the deity color more prominently in dark mode
            headerView.layer.borderColor = UIColor(hex: deity.color)?.withAlphaComponent(0.6).cgColor ?? UIColor.systemPurple.cgColor
            headerView.layer.borderWidth = 1.5
        } else {
            headerView.layer.borderColor = UIColor(hex: deity.color)?.withAlphaComponent(0.3).cgColor ?? PapyrusDesignSystem.Colors.aged.cgColor
            headerView.layer.borderWidth = 1
        }
    }
    
    private func updateShadows() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        if isDarkMode {
            headerView.layer.shadowColor = UIColor(hex: deity.color)?.cgColor ?? UIColor.systemPurple.cgColor
            headerView.layer.shadowOpacity = 0.3
            headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
            headerView.layer.shadowRadius = 8
        } else {
            headerView.layer.shadowColor = UIColor.clear.cgColor
            headerView.layer.shadowOpacity = 0
        }
    }
    
    private func updateBackgroundColor() {
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        } else {
            view.backgroundColor = PapyrusDesignSystem.Colors.background
        }
    }
    
    private func updateDownloadContainerColors() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let baseColor = UIColor(hex: deity.color) ?? UIColor.systemPurple
        
        downloadContainerView.layer.borderColor = isDarkMode
            ? baseColor.withAlphaComponent(0.3).cgColor
            : PapyrusDesignSystem.Colors.aged.cgColor
    }
    
    // MARK: - UIAdaptivePresentationControllerDelegate
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // Modal has been fully dismissed
        streamingTask?.cancel()
        streamingTask = nil
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        // Allow dismissal at any time
        return true
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        // Modal is about to be dismissed but user can still cancel the gesture
    }
    
    // MARK: - Progress Handling
    
    private func handleProgressUpdate(_ reportedProgress: Float) {
        let currentTime = Date()
        
        // Store progress history
        progressHistory.append((time: currentTime, progress: reportedProgress))
        
        // Keep only recent history (last 10 seconds)
        progressHistory = progressHistory.filter { currentTime.timeIntervalSince($0.time) < 10 }
        
        // Start smooth animation if this is a new progress step
        if reportedProgress > lastReportedProgress {
            lastReportedProgress = reportedProgress
            startSmoothProgressAnimation(to: reportedProgress)
        }
        
        updateProgressUI()
    }
    
    private func startSmoothProgressAnimation(to targetProgress: Float) {
        // Cancel any existing animation
        progressAnimator?.invalidate()
        
        let startProgress = smoothedProgress
        let progressDelta = targetProgress - startProgress
        let animationDuration: TimeInterval = 2.0 // Smooth over 2 seconds
        let updateInterval: TimeInterval = 0.05 // 20 FPS
        let totalSteps = Int(animationDuration / updateInterval)
        var currentStep = 0
        
        progressAnimator = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            currentStep += 1
            if currentStep >= totalSteps {
                self.smoothedProgress = targetProgress
                timer.invalidate()
                self.progressAnimator = nil
            } else {
                // Ease-out animation
                let t = Float(currentStep) / Float(totalSteps)
                let easedT = 1 - pow(1 - t, 3) // Cubic ease-out
                self.smoothedProgress = startProgress + progressDelta * easedT
            }
            
            self.updateProgressUI()
        }
    }
    
    private func updateProgressUI() {
        // Generate status text based on smoothed progress
        let progressPercent = Int(smoothedProgress * 100)
        let statusText: String
        
        if progressPercent < 10 {
            statusText = "Gathering sacred texts..."
        } else if progressPercent < 30 {
            statusText = "Channeling divine wisdom..."
        } else if progressPercent < 50 {
            statusText = "Deciphering ancient knowledge..."
        } else if progressPercent < 70 {
            statusText = "Binding ethereal essence..."
        } else if progressPercent < 90 {
            statusText = "Preparing the Oracle..."
        } else {
            statusText = "Finalizing divine connection..."
        }
        
        // Calculate sizes based on smoothed progress
        let totalBytes = modelSizeBytes
        let bytesDownloaded = Int64(Double(modelSizeBytes) * Double(smoothedProgress))
        let mbDownloaded = Double(bytesDownloaded) / 1024 / 1024
        let gbTotal = Double(totalBytes) / 1024 / 1024 / 1024
        
        // Update loading view with progress
        let sizeText = String(format: "%.0f MB / %.1f GB", mbDownloaded, gbTotal)
        downloadLoadingView.updateProgress(smoothedProgress, withText: "\(statusText)\n\(sizeText)")
        
        // Check if download completed
        if smoothedProgress >= 0.99 && lastReportedProgress >= 1.0 {
            progressAnimator?.invalidate()
            progressAnimator = nil
            progressTimer?.invalidate()
            progressTimer = nil
            
            UIView.animate(withDuration: 0.3) {
                self.downloadContainerView.alpha = 0
                self.contentTextView.alpha = 1
            } completion: { _ in
                self.downloadContainerView.isHidden = true
                self.contentTextView.isHidden = false
                self.startStreamingExplanation()
            }
        }
    }
}

