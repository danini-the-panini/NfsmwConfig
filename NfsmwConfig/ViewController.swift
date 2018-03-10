//
//  ViewController.swift
//  NfsmwConfig
//
//  Created by Daniel Smith on 2018/03/10.
//  Copyright © 2018 sourlemon. All rights reserved.
//

import Cocoa

struct Display {
    static var mode: CGDisplayMode? { return CGDisplayCopyDisplayMode(CGMainDisplayID()) }
    static var modes: [CGDisplayMode] {
        var result: [CGDisplayMode] = []
        let modes = CGDisplayCopyAllDisplayModes(CGMainDisplayID(), nil).unsafelyUnwrapped
        (0..<CFArrayGetCount(modes)).forEach({result.append(unsafeBitCast(CFArrayGetValueAtIndex(modes, $0), to: CGDisplayMode.self))})
        return result
    }
}

extension CGDisplayMode {
    var resolution: String { return String(width) + " x " + String(height) }
}

enum NfsmwHudMode {
    case defaultHUD, altHUD
}

struct NfsmwSettings {
    var ResX: Int
    var ResY: Int
    var HudFix: Bool
    var HudMode: NfsmwHudMode
    var verFovCorrectionFactor: Float
    var ShadowsRes: Int
    var HudWidescreenMode: Bool
    var FMVWidescreenMode: Bool
}

class ViewController: NSViewController {
    @IBOutlet weak var resolutionList: NSPopUpButton!
    @IBOutlet weak var hudModeInput: NSPopUpButton!
    @IBOutlet weak var hudFixInput: NSButton!
    @IBOutlet weak var verFovCorrectionInput: NSTextField!
    @IBOutlet weak var shadowResInput: NSTextField!
    @IBOutlet weak var nativeWidescreenHudInput: NSButton!
    @IBOutlet weak var fullVideoInput: NSButton!
    
    var settings: NfsmwSettings = NfsmwSettings.init(ResX: 0, ResY: 0, HudFix: true, HudMode: .defaultHUD, verFovCorrectionFactor: 0.06, ShadowsRes: 4096, HudWidescreenMode: true, FMVWidescreenMode: true)
    var displayModeMap: Dictionary<String, CGDisplayMode> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CommandLine.arguments.count <= 1 {
            NSApplication.shared.terminate(self)
            return;
        }
        
        NSApp.activate(ignoringOtherApps: true)
        
        let file = CommandLine.arguments[1]
        let path = URL(fileURLWithPath: file)
        do {
            let text = try String(contentsOf: path)
            text.enumerateLines { line, _ in
                if line.contains("=") {
                    let value = line.split(separator: "=")[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    if line.hasPrefix("ResX") {
                        if let parsedValue = Int(value) {
                            self.settings.ResX = parsedValue
                        }
                    } else if line.hasPrefix("ResY") {
                        if let parsedValue = Int(value) {
                            self.settings.ResY = parsedValue
                        }
                    } else if line.hasPrefix("HudFix") {
                        self.settings.HudFix = value.contains("1")
                    } else if line.hasPrefix("HudMode") {
                        self.settings.HudMode = value.contains("1") ? .altHUD : .defaultHUD
                    } else if line.hasPrefix("verFovCorrectionFactor") {
                        if let parsedValue = Float(value) {
                            self.settings.verFovCorrectionFactor = parsedValue
                        }
                    } else if line.hasPrefix("ShadowsRes") {
                        if let parsedValue = Int(value) {
                            self.settings.ShadowsRes = parsedValue
                        }
                    } else if line.hasPrefix("HudWidescreenMode") {
                        self.settings.HudWidescreenMode = value.contains("1")
                    } else if line.hasPrefix("FMVWidescreenMode") {
                        self.settings.FMVWidescreenMode = value.contains("1")
                    }
                }
            }
        } catch {
            print("Error reading config from \(file): \(error)")
        }
        
        if self.settings.ResX == 0 || self.settings.ResY == 0 {
            if let displayMode = Display.mode {
                self.settings.ResX = displayMode.width
                self.settings.ResY = displayMode.height
            }
        }
        
        print(self.settings)
        
        resolutionList.removeAllItems()
        for mode in Display.modes {
            displayModeMap[mode.resolution] = mode
            resolutionList.addItem(withTitle: mode.resolution)
        }
        resolutionList.selectItem(withTitle: "\(self.settings.ResX) x \(self.settings.ResY)")
        
        hudModeInput.selectItem(at: self.settings.HudMode == .defaultHUD ? 0 : 1)
        hudFixInput.state = self.settings.HudFix ? .on : .off;
        verFovCorrectionInput.floatValue = self.settings.verFovCorrectionFactor
        shadowResInput.integerValue = self.settings.ShadowsRes
        nativeWidescreenHudInput.state = self.settings.HudWidescreenMode ? .on : .off
        fullVideoInput.state = self.settings.FMVWidescreenMode ? .on : .off
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func okayButtonPressed(_ sender: Any) {
        if let selectedResolution = resolutionList.selectedItem?.title {
            let displayMode = displayModeMap[selectedResolution]
            if let width = displayMode?.width, let height = displayMode?.height {
                self.settings.ResX = width
                self.settings.ResY = height
            }
        }
        
        self.settings.HudMode = hudModeInput.indexOfSelectedItem == 0 ? .defaultHUD : .altHUD
        self.settings.HudFix = hudFixInput.state == .on
        self.settings.verFovCorrectionFactor = verFovCorrectionInput.floatValue
        self.settings.ShadowsRes = shadowResInput.integerValue
        self.settings.HudWidescreenMode = nativeWidescreenHudInput.state == .on
        self.settings.FMVWidescreenMode = fullVideoInput.state == .on
        
        let newConfig = """
            [MAIN]
            ResX = \(self.settings.ResX)
            ResY = \(self.settings.ResY)
            HudFix = \(self.settings.HudFix ? "1" : "0")
            HudMode = \(self.settings.HudMode == .defaultHUD ? "0" : "1")
            verFovCorrectionFactor = \(self.settings.verFovCorrectionFactor)
            ShadowsRes = \(self.settings.ShadowsRes)
            HudWidescreenMode = \(self.settings.HudWidescreenMode ? "1" : "0")
            FMVWidescreenMode = \(self.settings.FMVWidescreenMode ? "1" : "0")
            """
        
        print(newConfig)
        
        if CommandLine.arguments.count <= 1 {
            return
        }
        
        let file = CommandLine.arguments[1]
        let path = URL(fileURLWithPath: file)
        do {
            try newConfig.write(to: path, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing new config to \(file): \(error)")
        }
        NSApplication.shared.terminate(sender)
    }
    
}

