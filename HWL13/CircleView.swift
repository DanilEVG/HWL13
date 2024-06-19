//
//  CircleView.swift
//  HWL13
//
//  Created by Даниил Евгеньевич on 04.06.2024.
//

import UIKit

class CircleView: UIView {
    private var centerYAnchorCircle: NSLayoutConstraint?
    private var centerXAnchorCircle: NSLayoutConstraint?
    private var heightAnchorCircle: NSLayoutConstraint?
    private var widthAnchorCircle: NSLayoutConstraint?
    
    private var startHeight: CGFloat?
    private var startWidth: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var position: CGPoint {
        get {
            return CGPoint(x: centerXAnchorCircle?.constant ?? 0, y: centerYAnchorCircle?.constant ?? 0)
        }
        set {
            centerXAnchorCircle?.constant = newValue.x
            centerYAnchorCircle?.constant = newValue.y
        }
    }
    
    var size: CGSize {
        get {
            return CGSize(width: widthAnchorCircle?.constant ?? 0, height: heightAnchorCircle?.constant ?? 0)
        }
        set {
            widthAnchorCircle?.constant = newValue.width
            heightAnchorCircle?.constant = newValue.height
        }
    }
    
    func setConstraint(centerYAnchorCircleView: NSLayoutConstraint, centerXAnchorCircleView: NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchorCircle = centerXAnchorCircleView
        centerYAnchorCircle = centerYAnchorCircleView
        heightAnchorCircle = heightAnchor.constraint(equalToConstant: 100)
        widthAnchorCircle = widthAnchor.constraint(equalToConstant: 100)
        guard
            let centerXAnchorCircle,
            let centerYAnchorCircle,
            let heightAnchorCircle,
            let widthAnchorCircle else {
            return
        }
        
        NSLayoutConstraint.activate([
            centerXAnchorCircle,
            centerYAnchorCircle,
            heightAnchorCircle,
            widthAnchorCircle,
        ])
        
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        if point.x < 0 || point.y < 0 {
            return false
        }
        if point.x >= bounds.width {
            return false
        } else if point.y >= bounds.height {
            return false
            
        }
        
        if pow(point.x - layer.cornerRadius, 2) + pow(point.y - layer.cornerRadius, 2) >= layer.cornerRadius * layer.cornerRadius {
            return false
        }
        
        return true
    }
    
    private func setup(){
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(changedColor))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(resizeCircleView(_:)))
        self.addGestureRecognizer(pinchGestureRecognizer)
        backgroundColor = [.blue, .green, .yellow, .purple, .orange, .cyan, .brown, .darkGray].randomElement() ?? .black
        layer.cornerRadius = 50
    }
    
    @objc private func changedColor() {
        self.backgroundColor = [.blue, .green, .yellow, .purple, .orange, .cyan, .brown, .darkGray].randomElement() ?? .black
        
    }
    
    @objc private func resizeCircleView(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
            
        case .possible:
            break
        case .began:
            alpha = 0.2
            
            startWidth = widthAnchorCircle?.constant
            startHeight = heightAnchorCircle?.constant
            
            break
        case .changed:
            let scale = sender.scale
            
            guard let startWidth,
                  let startHeight else { break }
            
            heightAnchorCircle?.constant = scale * startHeight
            widthAnchorCircle?.constant = scale * startWidth
            
            guard let heightAnchorCircle,
                  let widthAnchorCircle else { return }
            
            if heightAnchorCircle.constant > 250 {
                heightAnchorCircle.constant = 250
                widthAnchorCircle.constant = 250
            }
            
            layer.cornerRadius = heightAnchorCircle.constant / 2
            
        case .cancelled:
            fallthrough
        case .ended:
            fallthrough
        case .failed:
            alpha = 1
            
            break
        @unknown default:
            print("")
        }
    }
    
}
