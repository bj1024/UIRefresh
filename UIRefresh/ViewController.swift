//
// Copyright (c) 2019, mycompany All rights reserved.
//

import UIKit

struct MainData {
  var refreshInterval: Int = 1
  var updateNum: Int = 0
  var colors: [UIColor] = []
  var texts: [String] = []
  var refreshRate: Double = 0
  var lastDate: Date = Date()
  var lastRefreshNum: Int = 0
  var frameNum: Int = 0
  var fps: Double = 0
  var controlNum: Int = 0
}

class ViewController: UIViewController {
  var displayLink: CADisplayLink!
  var lastMediaTime: CFTimeInterval = 0.0
  var data: MainData = MainData()
  var labels: [UILabel] = []
//  var dispDuration:Double = 0
  var stackViews: [UIStackView] = []

  var refreshIntervals: [Int] = [
    1,
    5,
    10,
    15,
    30,
    60
  ]

  var labelNums: [Int] = [
    100,
    150,
    200,
    250,
    300,
    350,
    400,
    450,
    500,
    600,
    700,
    800,
    900,
    1000,
//    1500,
//    2000,
//    3000,
//    5000,
  ]

  let semaphore = DispatchSemaphore(value: 1)

  @IBOutlet weak var rootStackView: UIStackView!

  @IBOutlet weak var labelRate: UILabel!
  @IBOutlet weak var sliderRate: UISlider!
  @IBOutlet weak var sliderViewNum: UISlider!
  override func viewDidLoad() {
    super.viewDidLoad()
    sliderRate.maximumValue = 1.0
    sliderRate.minimumValue = 0
    sliderRate.value = 0

    sliderViewNum.maximumValue = 1.0
    sliderViewNum.minimumValue = 0
    sliderViewNum.value = 0

    data.refreshInterval = refreshIntervals.first ?? 1
    data.controlNum = labelNums.first ?? 100
    setup()
    createLabels(num: data.controlNum)

    updateUI(newData: data)
  }

  func setup() {
    semaphore.wait()
    defer { self.semaphore.signal() }

    removeAll()

    displayLink = CADisplayLink(
      target: self,
      selector: #selector(onDisplayLink)
    )
    displayLink.preferredFramesPerSecond = data.refreshInterval
    displayLink.add(to: .main, forMode: .default)
    lastMediaTime = CACurrentMediaTime()

    stackViews = []
    let columnNum: Int = 5
    for _ in 0..<columnNum {
      let stackView = UIStackView(frame: CGRect.zero)
      stackView.axis = .vertical
      stackView.alignment = .fill
      stackView.spacing = 0
      stackView.distribution = .fillEqually
      stackView.contentMode = .scaleToFill
      stackView.backgroundColor = UIColor.brown

      rootStackView.addArrangedSubview(stackView)
      stackViews.append(stackView)
    }
  }

  func removeAll() {
    labels.forEach { $0.removeFromSuperview() }
    labels.removeAll()

    data.colors = []
    data.texts = []
  }

  func createLabels(num: Int) {
    semaphore.wait()
    defer { self.semaphore.signal() }

    removeAll()

    var newData = data
    let lblNum: Int = Int( num / stackViews.count )
    for (i, stackView ) in stackViews.enumerated() {
      for lblIndex in 0..<lblNum {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.font = lbl.font.withSize(8)
        lbl.text = "\(i + 1) - \(lblIndex + 1)"
        lbl.textColor = UIColor.label
        lbl.backgroundColor = UIColor.systemPink
        lbl.textAlignment = .center
        stackView.addArrangedSubview(lbl)
        labels.append(lbl)
        newData.colors.append(lbl.backgroundColor ?? UIColor.black)
        newData.texts.append(lbl.text ?? "")
      }
    }
    data = newData
  }

  @objc func onDisplayLink(displayLink: CADisplayLink) {
    let diff = (displayLink.timestamp - lastMediaTime )
    if diff > 1.0 {
      data.fps = Double(data.frameNum) / diff
      print("\(String(format: "%12.7f", displayLink.timestamp)) \(String(format: "%5d", data.frameNum))frames \(String(format: "%5.2f", data.fps)) FPS")

      lastMediaTime = displayLink.timestamp
      data.frameNum = 0
    }
    data.frameNum += 1

    DispatchQueue.global().async() {
      self.updateData()
      DispatchQueue.main.async {
        self.updateUI(newData: self.data)
      }
    }
  }

  func updateData() {
    semaphore.wait()
    defer { self.semaphore.signal() }

    for (i, _ ) in data.colors.enumerated() {
      data.colors[i] = UIColor(displayP3Red: CGFloat.random(in: 0...1),
                               green: CGFloat.random(in: 0...1),
                               blue: CGFloat.random(in: 0...1),
                               alpha: 1.0)
    }
    for (i, _ ) in data.texts.enumerated() {
      data.texts[i] = "\(data.updateNum)"
    }
    data.updateNum += 1
  }

  @IBAction func onRateChange(_ slider: UISlider) {
    let idx = Int(slider.value * Float(refreshIntervals.count - 1))
    data.refreshInterval = refreshIntervals[idx]

    displayLink.preferredFramesPerSecond = data.refreshInterval
  }

  @IBAction func onViewNumChange(_ slider: UISlider) {
    let idx = Int(slider.value * Float(labelNums.count - 1))

    let controlNum = labelNums[idx]
    if data.controlNum != controlNum {
      data.controlNum = controlNum
      displayLink.isPaused = true
      createLabels(num: data.controlNum)
      displayLink.isPaused = false
    }
  }

  func updateUI(newData: MainData) {
    labelRate.text = String(format: "%4dLabels %3dfps(preffered) %5.2ffps(measured)",
                            newData.controlNum,
                            newData.refreshInterval,
                            newData.fps)
    for (i, lbl ) in labels.enumerated() {
      lbl.backgroundColor = newData.colors[i]
      lbl.text = newData.texts[i]
    }
  }
}
