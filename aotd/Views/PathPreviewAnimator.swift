import UIKit

class PathPreviewAnimator: NSObject {
    
    // MARK: - Properties
    private weak var containerView: UIView?
    private weak var previewView: PathPreviewView?
    private weak var blurView: UIVisualEffectView?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    private var isPresented = false
    private var originalFrame: CGRect = .zero
    private var dismissThreshold: CGFloat = 100
    private var dismissVelocityThreshold: CGFloat = 1000
    
    // MARK: - Initialization
    init(containerView: UIView) {
        self.containerView = containerView
        super.init()
        setupGestures()
    }
    
    // MARK: - Gesture Setup
    private func setupGestures() {
        guard let containerView = containerView else { return }
        
        // Pan gesture for dismissal
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        panGestureRecognizer = pan
        
        // Tap gesture for background dismissal
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        tapGestureRecognizer = tap
        
        containerView.addGestureRecognizer(pan)
        containerView.addGestureRecognizer(tap)
        
        // Initially disable gestures
        pan.isEnabled = false
        tap.isEnabled = false
    }
    
    // MARK: - Presentation
    func present(pathPreview: PathPreviewView, from sourceView: UIView?, animated: Bool = true) {
        guard let containerView = containerView, !isPresented else { return }
        
        self.previewView = pathPreview
        
        // Create blur background
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: nil)
        blurView.frame = containerView.bounds
        blurView.alpha = 0
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(blurView)
        self.blurView = blurView
        
        // Setup preview view
        pathPreview.alpha = 0
        pathPreview.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: 50)
        containerView.addSubview(pathPreview)
        
        // Calculate frame - responsive for smaller screens
        let margin: CGFloat = 20
        let maxWidth: CGFloat = min(containerView.bounds.width - (margin * 2), 380) // Max width for iPad
        let previewWidth = maxWidth
        
        // Adjust height based on screen size
        let screenHeight = containerView.bounds.height
        let baseHeight: CGFloat = 480
        let minHeight: CGFloat = 420 // For iPhone SE
        let maxHeight: CGFloat = min(baseHeight, screenHeight - 120) // Leave space for dismiss
        let previewHeight: CGFloat = max(minHeight, maxHeight)
        
        let previewX = (containerView.bounds.width - previewWidth) / 2
        let previewY = (containerView.bounds.height - previewHeight) / 2
        
        pathPreview.frame = CGRect(x: previewX, y: previewY, width: previewWidth, height: previewHeight)
        originalFrame = pathPreview.frame
        
        // Animate presentation
        if animated {
            // Add haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                blurView.effect = blurEffect
                blurView.alpha = 1
                pathPreview.alpha = 1
                pathPreview.transform = .identity
            }) { _ in
                self.isPresented = true
                self.panGestureRecognizer?.isEnabled = true
                self.tapGestureRecognizer?.isEnabled = true
            }
        } else {
            blurView.effect = blurEffect
            blurView.alpha = 1
            pathPreview.alpha = 1
            pathPreview.transform = .identity
            isPresented = true
            panGestureRecognizer?.isEnabled = true
            tapGestureRecognizer?.isEnabled = true
        }
    }
    
    // MARK: - Dismissal
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard isPresented else { return }
        
        panGestureRecognizer?.isEnabled = false
        tapGestureRecognizer?.isEnabled = false
        
        if animated {
            // Add haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.blurView?.alpha = 0
                self.previewView?.alpha = 0
                self.previewView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).translatedBy(x: 0, y: 50)
            }) { _ in
                self.cleanup()
                completion?()
            }
        } else {
            cleanup()
            completion?()
        }
    }
    
    private func cleanup() {
        blurView?.removeFromSuperview()
        previewView?.removeFromSuperview()
        blurView = nil
        previewView = nil
        isPresented = false
    }
    
    // MARK: - Gesture Handlers
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let previewView = previewView else { return }
        
        let translation = gesture.translation(in: containerView)
        let velocity = gesture.velocity(in: containerView)
        
        switch gesture.state {
        case .changed:
            // Only allow downward dragging
            let yOffset = max(0, translation.y)
            previewView.transform = CGAffineTransform(translationX: 0, y: yOffset)
            
            // Adjust blur opacity based on drag distance
            let progress = min(1, yOffset / dismissThreshold)
            blurView?.alpha = 1 - (progress * 0.5)
            
        case .ended, .cancelled:
            // Check if should dismiss based on distance or velocity
            let shouldDismiss = translation.y > dismissThreshold || velocity.y > dismissVelocityThreshold
            
            if shouldDismiss {
                dismiss(animated: true)
            } else {
                // Snap back to original position
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    previewView.transform = .identity
                    self.blurView?.alpha = 1
                }
            }
            
        default:
            break
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let previewView = previewView else { return }
        
        let location = gesture.location(in: containerView)
        if !previewView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PathPreviewAnimator: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == tapGestureRecognizer {
            // Only receive tap if it's outside the preview view
            guard let previewView = previewView else { return true }
            let location = touch.location(in: containerView)
            return !previewView.frame.contains(location)
        }
        return true
    }
}