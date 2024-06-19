//
//  ViewController.swift
//  HWL13
//
//  Created by Даниил Евгеньевич on 04.06.2024.
//
/*
 
 Добавить увеличение и уменьшение кружочков по pinch gesture
 Переписать на констреинты вместо фреймов
 *Учитывать центр pinch gesture при изменении размера для смещения всего кружочка
 *Добавлять новые кружочки избегая пересечения с имеющимися (алгоритмы)
 Сделать CircleView своим классом. Добавить внутрь по тапу смену цвета (обработка тапа внутри класса а не ViewController'а).
 *Смена цвета и добавление кружочка должны работать одновременно, не мешая друг другу не смотря на то, что реализованы разными tap gesture recognizer'ами.
 
 */

import UIKit

class ViewController: UIViewController {
    private var circlePositions: [CircleView] = []
    private var trackedCircleView: CircleView?
    private var originalCirclePosition: CGPoint?
     
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let panGesureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        view.addGestureRecognizer(panGesureRecognizer)
        
    }
    
    @objc func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            //circlePositions.append(sender.location(in: view))
            
            addNewCircle(at: sender.location(in: view))
        }
    }
    
    @objc func panGestureHandler(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
            
        case .possible:
            //обозначить пользователю интерактивность действия
            guard let circleView = findCircle(at: sender.location(in: view)) else {
                break
            }
            trackedCircleView = circleView
            circleView.alpha = 0.5
            
        case .began:
            //подготовить состояние для отслеживания
            guard let circleView = findCircle(at: sender.location(in: view)) else {
                break
            }
            trackedCircleView = circleView
            circleView.alpha = 0.5
            originalCirclePosition = circleView.position
        case .changed:
            //обновить информацию
            let translation = sender.translation(in: view)
            guard let trackedCircleView else {
                break
            }
            
            print(translation)
            trackedCircleView.position = CGPoint(x: trackedCircleView.position.x + translation.x, y: trackedCircleView.position.y + translation.y)
            
            sender.setTranslation(.zero, in: view)
            break
        case .cancelled:
            //откатить изменения после began и changed
            guard let originalCirclePosition else {break}
            trackedCircleView?.position = originalCirclePosition
            fallthrough
        case .ended:
            //закончить отслеживание жеста
            guard let trackedCircleView,
                  let idx = circlePositions.lastIndex(of: trackedCircleView) else {
                fallthrough
            }
            circlePositions[idx].position = trackedCircleView.position
            fallthrough
        case .failed:
            //откатить изменения после possible
            trackedCircleView?.alpha = 1
            trackedCircleView = nil
            originalCirclePosition = nil
        @unknown default:
            print("Unsupported")
        }
    }
    
    private func findCircle(at point: CGPoint) -> CircleView? {
        
        guard let circleView = view.hitTest(point, with: nil),
              circleView.layer.cornerRadius != 0 else {
            return nil
        }
        return (circleView as! CircleView)
    }
    
    private func addNewCircle(at point: CGPoint) {
        if !isFreePosition(at: point) {
            return
        }
        
        let circleView = CircleView(frame: .zero)
        view.addSubview(circleView)
        circlePositions.append(circleView)
        circleView.setConstraint(
            centerYAnchorCircleView: circleView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: point.y),
            centerXAnchorCircleView: circleView.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: point.x))
        
    }
    
    private func isFreePosition(at point: CGPoint) -> Bool {
        for item in circlePositions {
            if item.position.y - item.size.height / 2 > point.y + 50 ||
                item.position.y + item.size.height / 2 < point.y - 50 ||
                item.position.x - item.size.height / 2 > point.x + 50 ||
                item.position.x + item.size.height / 2 < point.x - 50 {
            } else {
                return false
            }
        }
        return true
    }
}

