//
//  UserDefaults.swift
//  WhyFi_Watch WatchKit Extension
//
//  Created by Tom on 2020/5/27.
//  Copyright © 2020 Tom. All rights reserved.
//

//
//  UserDefaults.swift
//  SwiftUIPlayground
//
//  Created by stereye on 2020/5/22.
//  Copyright © 2020 Tom. All rights reserved.
//

import Foundation
import Combine

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

final class UserSettings: ObservableObject {

    let objectWillChange = PassthroughSubject<Void, Never>()

    @UserDefault("username", defaultValue: "")
    var username: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("password", defaultValue: "")
    var password: String {
        willSet {
            objectWillChange.send()
        }
    }
}





