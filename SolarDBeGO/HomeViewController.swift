//
//  ViewController.swift
//  SolarDBeGO
//
//  Created by Christian Menschel on 23.05.19.
//  Copyright © 2019 SolarDB. All rights reserved.
//

import UIKit
import HomeKit

class HomeViewController: UIViewController {

    // MARK: Properties
    lazy var sunViewController: PowerSliderViewController = {
        let vm = PowerSliderViewModel(title: "Sun Simulation:\nkW Power produced by solar",
                                      backgroundColor: .yellow,
                                      fontColor: .black,
                                      powerHandler: SolarSimulator.shared)
        return PowerSliderViewController(viewModel: vm)
    }()
    lazy var loadingViewController = LoadingViewController()
    lazy var batteryViewController = BatteryViewController()
    var batterySimulator: BatterySimulator { return BatterySimulator.shared }

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        addSunViewController()
        addBatteryViewController()
        addLoadingViewController()
        addBatteryLoadingSimulator()
        addObserver()
    }

    // MARK: Setup
    private func addSunViewController() {
        addChild(sunViewController)
        view.addSubview(sunViewController.view)
        sunViewController.didMove(toParent: self)
        sunViewController.view.pinToEdges([.left, .top, .right], of: view)
    }

    private func addBatteryViewController() {
        addChild(batteryViewController)
        view.addSubview(batteryViewController.view)
        batteryViewController.didMove(toParent: self)
        batteryViewController.view.centerY(of: view)
        batteryViewController.view.pinToEdges([.left, .right], of: view)
    }

    private func addBatteryLoadingSimulator() {
        batterySimulator.canStartCharging = {[weak self] battery in
            guard let self = self else { return }
            self.loadingViewController.stop()
            self.batteryViewController.update(viewModel: BatteryViewModel(battery))
            self.batterySimulator.toggleChargingIfNeeded()
        }
        batterySimulator.updateHandler = {[weak self] battery in
            guard let self = self else { return }
            self.batteryViewController.update(viewModel: BatteryViewModel(battery))
        }
    }

    private func addLoadingViewController() {
        addChild(loadingViewController)
        view.addSubview(loadingViewController.view)
        loadingViewController.didMove(toParent: self)
        loadingViewController.start()
    }

    private func addObserver() {
        SolarSimulator.shared.observe {
            self.batterySimulator.toggleChargingIfNeeded()
        }
        ChargeSettingsHandler.shared.observe {
            self.batterySimulator.toggleChargingIfNeeded()
        }
    }
}
