//
//  MyFont.swift
//  SSC
//
//  Created by Graciella Michelle Siswoyo on 27/02/26.
//


// Source - https://stackoverflow.com/a/73337077
// Posted by Fabez
// Retrieved 2026-02-27, License - CC BY-SA 4.0

internal import SwiftUI

public struct MyFont {
    public static func registerFonts() {
        registerFont(bundle: Bundle.main , fontName: "YOUR-FONT-HERE", fontExtension: ".ttf") //change according to your ext.
    }
    fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
        
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font from data")
        }
        
//        var error: Unmanaged<CFError>?
        
//        CTFontManagerRegisterGraphicsFont(font, &error)
        CTFontManagerCreateFontDescriptorFromData(font as! CFData)
    }
}
