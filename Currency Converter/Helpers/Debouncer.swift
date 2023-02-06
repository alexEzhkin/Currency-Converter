//
//  Debouncer.swift
//  Currency Converter
//
//  Created by Alex on 6.02.23.
//

import Foundation

final class Debouncer {
    private var timer: Timer?
    private let interval: TimeInterval
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func call(callback: @escaping () -> ()) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { [weak self] _ in
            callback()
            self?.timer = nil
        })
    }
}
