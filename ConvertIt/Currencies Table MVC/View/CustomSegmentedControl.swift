//
//  CurrencyPickerView.swift
//  ConvertIt
//
//  Created by Slik on 08.05.2022.
//

import UIKit

class CustomSegmentedControl: UIView {
    
    var items: [UIView] = [] {
        didSet {
            updateView()
        }
    }
    
    var selectedItemIndex: Int = 0 {
        didSet {
            guard selectedItemIndex != oldValue else { return }
            onItemSelected(selectedItemIndex)
        }
    }
    
    var onItemSelected: (Int) -> () = { _ in }
    
    private let carriage: UIView = UIView()
    
    private let contentInset: CGFloat = 3
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = frame.height / 2
        layer.backgroundColor = UIColor.secondarySystemBackground.cgColor
        
        carriage.layer.cornerRadius = carriage.frame.height / 2
        carriage.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
        carriage.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        carriage.layer.borderWidth = contentInset
    }
    
    func updateView() {
        subviews.forEach { view in
            view.removeFromSuperview()
            view.gestureRecognizers?.removeAll()
        }
        tagItems()
        addSubviews()
        arrangeItemsInStack()
        setUpCarriage()
        addTapGestureRecognizerToEachItem()
        addPanGestureRecognizerToEachItem()
    }
    
    private func tagItems() {
        for itemIndex in 0..<items.count {
            items[itemIndex].tag = itemIndex
        }
    }
    
    private func arrangeItemsInStack() {
        let hStack = UIStackView(arrangedSubviews: items)
        hStack.axis = .horizontal
        hStack.alignment = .fill
        hStack.distribution = .fillEqually
        addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.widthAnchor.constraint(equalTo: widthAnchor),
            hStack.heightAnchor.constraint(equalTo: heightAnchor)
        ])
        hStack.layoutIfNeeded()
    }
    
    private func addTapGestureRecognizerToEachItem() {
        for item in items {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onItemTapped(_:)))
            item.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @objc private func onItemTapped(_ sender: AnyObject) {
        guard let tag = sender.view?.tag else {
            return
        }
        selectedItemIndex = tag
        moveCarriageToItemAtIndex(tag)
    }
    
    private func addPanGestureRecognizerToEachItem() {
        carriage.isUserInteractionEnabled = true
        items.forEach { view in
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onItemDragged(_:)))
            view.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    @objc private func onItemDragged(_ gesture: UIPanGestureRecognizer) {
        
        guard gesture.view != nil,
              gesture.view!.tag == selectedItemIndex else { return }
        
        let initialCarriageFrame = items[selectedItemIndex].frame
        
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self)
            if (initialCarriageFrame.origin.x + translation.x) >= 0 && (initialCarriageFrame.maxX + translation.x) <= frame.width {
                UIView.animate(withDuration: 0.2) { [unowned self] in
                    carriage.frame.origin.x = initialCarriageFrame.origin.x + translation.x
                }
            }
        case .ended:
            for item in items {
                let itemCenterSpace = (item.frame.origin.x - item.frame.width / 3)...(item.frame.origin.x + item.frame.width / 3)
                if carriage.frame.origin.x >= itemCenterSpace.lowerBound && carriage.frame.origin.x <= itemCenterSpace.upperBound {
                    selectedItemIndex = item.tag
                }
            }
            moveCarriageToItemAtIndex(selectedItemIndex)
        default: return
        }
    }
    
    private func moveCarriageToItemAtIndex(_ index: Int) {
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: []) { [unowned self] in
            carriage.frame.origin.x = items[index].frame.minX
        }
    }
    
    private func setUpCarriage() {
        carriage.frame = CGRect(x: items[selectedItemIndex].frame.minX,
                                y: 0,
                                width: frame.width / CGFloat(items.count),
                                height: frame.height)
    }
    
    private func addSubviews() {
        addSubview(carriage)
    }
}
