//
//  LevelDomainViewController.swift
//  Ecosystem Core Assembler
//
//  Created by Jonathan J. Lee on 5/21/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import UIKit

class LevelDomainViewController: UIViewController, DomainViewDelegate {
    
    var appDelegate: AppDelegate!
    var assemblyManager: AssemblyManager!
    var activeLevel: LevelEntity?
    var activeEcosystem: EcosystemEntity? {
        return activeLevel?.ecosystemEntity
    }
    
    @IBOutlet var domainView: DomainView!
    
    @IBOutlet var sunLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var rainLabel: UILabel!
    @IBOutlet var airLabel: UILabel!
    @IBOutlet var earthLabel: UILabel!
    @IBOutlet var waterLabel: UILabel!
    
    @IBOutlet var sunSwitch: UISwitch!
    @IBOutlet var temperatureSwitch: UISwitch!
    @IBOutlet var rainSwitch: UISwitch!
    @IBOutlet var airSwitch: UISwitch!
    @IBOutlet var earthSwitch: UISwitch!
    @IBOutlet var waterSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        assemblyManager = appDelegate.assemblyManager
        domainView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let imagePath = activeEcosystem?.imagePath
        domainView.image = (imagePath != nil) ? UIImage(named: imagePath!) : nil
        let sunPoint = activeLevel?.sunLocation as? RelativePoint
        sunSwitch.isOn = (sunPoint != nil)
        domainView.sunPoint = (sunPoint != nil) ? domainView.createPointFromRelativePoint(relativePoint: sunPoint!) : nil
        domainView.temperature = activeLevel!.temperature
        temperatureSwitch.isOn = activeLevel!.temperature
        domainView.rain = activeLevel!.rain
        rainSwitch.isOn = activeLevel!.rain
        let airRect = activeLevel?.air as? RelativeRect
        airSwitch.isOn = (airRect != nil)
        if airRect != nil {
            domainView.airRect = domainView.createRectFromRelativeRect(relativeRect: airRect!)
        } else {
            domainView.airRect = nil
        }
        let earthRect = activeLevel?.earth as? RelativeRect
        earthSwitch.isOn = (earthRect != nil)
        if earthRect != nil {
            domainView.earthRect = domainView.createRectFromRelativeRect(relativeRect: earthRect!)
        } else {
            domainView.earthRect = nil
        }
        let waterRect = activeLevel?.water as? RelativeRect
        waterSwitch.isOn = (waterRect != nil)
        if waterRect != nil {
            domainView.waterRect = domainView.createRectFromRelativeRect(relativeRect: waterRect!)
        } else {
            domainView.waterRect = nil
        }
        setLabels()
        domainView.save()
    }
    
    @IBAction func handleSwitchEvent(sender: UISwitch) {
        switch sender {
        case sunSwitch:
            domainView.enableSun(sunSwitch.isOn)
        case temperatureSwitch:
            domainView.enableTemperature(temperatureSwitch.isOn)
        case rainSwitch:
            domainView.enableRain(rainSwitch.isOn)
        case airSwitch:
            domainView.enableAir(airSwitch.isOn)
        case earthSwitch:
            domainView.enableEarth(earthSwitch.isOn)
        case waterSwitch:
            domainView.enableWater(waterSwitch.isOn)
        default: break
        }
        setLabels()
    }
    
    func setLabels() {
        sunLabel.text = (sunSwitch.isOn) ? "Sun" : "No Sun"
        temperatureLabel.text = (temperatureSwitch.isOn) ? "Temperature" : "No Temperature"
        rainLabel.text = (rainSwitch.isOn) ? "Rain" : "No Rain"
        airLabel.text = (airSwitch.isOn) ? "Air Domain" : "No Air Domain"
        earthLabel.text = (earthSwitch.isOn) ? "Earth Domain" : "No Earth Domain"
        waterLabel.text = (waterSwitch.isOn) ? "Water Domain" : "No Water Domain"
    }
    
    func saveSun(relativePoint: RelativePoint) {
        activeLevel?.sunLocation = relativePoint
        assemblyManager.save()
    }
    
    func saveTemperature(_ temp: Bool) {
        activeLevel?.temperature = temp
        assemblyManager.save()
    }
    
    func saveRain(_ precip: Bool) {
        activeLevel?.rain = precip
        assemblyManager.save()
    }
    
    func saveAir(relativeRect: RelativeRect?) {
        print("Air Saved? \(relativeRect != nil)")
        activeLevel?.air = relativeRect
        assemblyManager.save()
    }
    
    func saveEarth(relativeRect: RelativeRect?) {
        activeLevel?.earth = relativeRect
        assemblyManager.save()
    }
    
    func saveWater(relativeRect: RelativeRect?) {
        activeLevel?.water = relativeRect
        assemblyManager.save()
    }
    
}
