# NGSBadgeBarButton

[![Version](https://img.shields.io/cocoapods/v/NGSBadgeBarButton.svg)](http://cocoapods.org/pods/NGSBadgeBarButton)
[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://github.com/PauliusVindzigelskis/NGSBadgeBarButton)
[![Language](https://img.shields.io/badge/language-Swift-blue.svg)](https://github.com/PauliusVindzigelskis/NGSBadgeBarButton)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/PauliusVindzigelskis/NGSBadgeBarButton/master/LICENSE)

v1.1 Swift 3.2

v1.2 Swift 4.0

v1.3 Swift 5

## Install

### Cocoapod

    pod 'NGSBadgeBarButton'
    
### Manual

Import NGSBadgeBarButton.swift file into Your project

## Dependencies

None

## Usage

Note: 'insets' parameter can be omit to use default value

    // Set badge value and control label appearance
    public private(set) weak var badgeLabel:UILabel! = nil


    // Badge Bar Button with image
    init(badgeButtonWithImage image: UIImage, 
                              target: Any,
                              selector: Selector, 
                              insets: UIEdgeInsets = NGSBadgeBarButton.kDefaultBadgeInsets)
    
    // Badge Bar Button with title
    init(badgeButtonWithTitle text: String, 
                              target: Any, 
                              selector: Selector, 
                              insets: UIEdgeInsets = NGSBadgeBarButton.kDefaultBadgeInsets)
                              
    // Custom Badge Bar Button
    init(badgeButtonWithCustomView customView: UIView, 
                                   insets: UIEdgeInsets = NGSBadgeBarButton.kDefaultBadgeInsets)
                                   
 
## Demo

![ngsbadgebarbutton_demo](https://user-images.githubusercontent.com/2383901/36121468-e32e9756-100b-11e8-9e64-ddcd0d6e8514.gif)
