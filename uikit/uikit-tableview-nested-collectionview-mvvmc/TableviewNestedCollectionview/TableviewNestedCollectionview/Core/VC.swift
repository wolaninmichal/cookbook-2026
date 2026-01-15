//
//  VC.swift
//  TableviewNestedCollectionview
//
//  Created by Michał Wolanin on 12/01/2026.
//

import UIKit

open class VC: UIViewController {
    
    public enum Orientation { case landscape, portrait }
    private var lastOrientation: Orientation?
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) { nil }

    deinit {
        print("☠️ deinit object: \(self)")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupPerIdiom()
    }
    
    private func setupPerIdiom() {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            setupIphoneUI()
        default:
            setupIpadUI()
        }
    }
    
    @objc func setupIphoneUI() {
        fatalError("setupIphoneUI should be overridden in subclass")
    }

    @objc func setupIpadUI() {
        fatalError("setupIpadUI should be overridden in subclass")
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateOrientationIfNeeded()
    }
    
    open func onOrientationChange(_ orientation: Orientation) {
        // override if needed
    }

    private func updateOrientationIfNeeded() {
        let now = currentOrientation()
        guard now != lastOrientation else { return }
        lastOrientation = now
        onOrientationChange(now)
    }

    private func currentOrientation() -> Orientation {
        let size = view.bounds.size
        return size.height >= size.width ? .portrait : .landscape
    }
}
