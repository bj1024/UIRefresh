//
// Copyright (c) 2019, mycompany All rights reserved. 
//

import UIKit

struct MainData{
  var refreshInterval:Int = 1
  var refreshNum:Int = 0
  var updateNum:Int = 0
  var colors:[UIColor] = []
  var texts:[String] = []
  var refreshRate:Double = 0
  var lastDate:Date = Date()
  var lastRefreshNum:Int = 0
  var skipFrameNum:Int = 0
}
class ViewController: UIViewController {

  var displayLink:CADisplayLink!
  var lastMediaTime:CFTimeInterval = 0.0
  var data:MainData = MainData()
  var labels:[UILabel] = []
//  var dispDuration:Double = 0

  var refreshIntervals:[Int] = [
    60,
    30,
    15,
    10,
    5,
    1,
  ]

  @IBOutlet weak var rootStackView: UIStackView!

  @IBOutlet weak var labelRate: UILabel!
  @IBOutlet weak var sliderRate: UISlider!
  override func viewDidLoad() {
    super.viewDidLoad()
    sliderRate.maximumValue = 1.0
    sliderRate.minimumValue = 0
    sliderRate.value = 1.0
    data.refreshInterval = refreshIntervals.last ?? 1

    setup()
    updateUI(newData: data)
//    updateLoop()
//    refreshRateLoop()
  }

  func setup(){

    displayLink = CADisplayLink(
        target: self,
        selector: #selector(onDisplayLink)
    )
    displayLink.preferredFramesPerSecond = data.refreshInterval;
    displayLink.add(to: .main, forMode: .default)
    lastMediaTime = CACurrentMediaTime()


    var stackViews:[UIStackView] = []
    let columnNum:Int = 3
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


    let lblNum:Int = 333
    for (i,stackView ) in stackViews.enumerated() {
      for lblIndex in 0..<lblNum {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.font = lbl.font.withSize(8)
        lbl.text = "\(i+1) - \(lblIndex+1)"
        lbl.textColor = UIColor.label
        lbl.backgroundColor = UIColor.systemPink
        lbl.textAlignment = .center
        stackView.addArrangedSubview(lbl)
        labels.append(lbl)
        data.colors.append(lbl.backgroundColor ?? UIColor.black)
        data.texts.append(lbl.text ?? "")
      }
    }

  }

  @objc func onDisplayLink(displayLink: CADisplayLink) {
    let diff = (displayLink.timestamp - lastMediaTime )

    let dispDuration = 1.0 / Double(displayLink.preferredFramesPerSecond)
    let dispDurationMargin = dispDuration / 10.0

    var skipCount:Int = 0
    if( !(dispDuration - dispDurationMargin < diff  && diff < (dispDuration + dispDurationMargin)) ){
      skipCount = Int( diff / dispDuration)
      self.data.skipFrameNum += skipCount
      print("Dropped \(String(format:"%12.7f",displayLink.timestamp)) \(String(format:"%5.1f",diff  * 1000 ))ms  drop=\(String(format:"%d",skipCount))  \(String(format:"%10.7f",displayLink.duration)) \(String(format:"%3d",displayLink.preferredFramesPerSecond))")
    }



    lastMediaTime = displayLink.timestamp
//    print("\(String(format:"%12.7f",displayLink.timestamp)) \(String(format:"%5.1f",diff  * 1000 ))ms  \(String(format:"%d",skipCount))  \(String(format:"%10.7f",displayLink.duration)) \(String(format:"%3d",displayLink.preferredFramesPerSecond))")

//    self.updateData()
//    self.updateUI(newData:self.data)

    DispatchQueue.global().async() {
      self.updateData()
      DispatchQueue.main.async {
        self.updateUI(newData:self.data)
      }
    }

  }

  func updateData(){
    for (i,_ ) in data.colors.enumerated() {
      data.colors[i] = UIColor.init(displayP3Red: CGFloat.random(in: 0...1),
                                    green: CGFloat.random(in: 0...1),
                                    blue: CGFloat.random(in: 0...1),
                                    alpha: 1.0)
    }
    for (i,_ ) in data.texts.enumerated() {
//      data.texts[i] = "\(Int.random(in: 0...10000))"
      data.texts[i] = "\(data.updateNum)"
    }
    data.updateNum += 1


  }
//  func updateLoop(){
//
//    DispatchQueue.global().asyncAfter(deadline: .now() + data.refreshInterval ) {
//        self.updateData()
//        DispatchQueue.main.async {
//          self.updateUI(newData:self.data)
//        }
//        self.updateLoop()
//    }
//  }
//  func refreshRateLoop(){
//    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
//      let interval = -1  * self.data.lastDate.timeIntervalSinceNow
//      let diff = self.data.refreshNum - self.data.lastRefreshNum
//      self.data.refreshRate = Double(diff) / Double(interval)
//
//      self.data.lastRefreshNum = self.data.refreshNum
//      self.data.lastDate = Date()
//      self.refreshRateLoop()
//    }
//  }

  @IBAction func onRateChange(_ slider: UISlider) {
    let idx = Int(slider.value * Float(self.refreshIntervals.count - 1))
    data.refreshInterval = self.refreshIntervals[idx]

    displayLink.preferredFramesPerSecond = data.refreshInterval
  }

  func updateUI(newData:MainData){
//    labelRate.text = String(format:"%10.8f %8d %8d %8d %5.2f",
      labelRate.text = String(format:"%3d %5.2f %d",
                            newData.refreshInterval,
//                            newData.refreshNum,
//                            newData.updateNum,
//                            newData.updateNum - newData.refreshNum,
                            newData.refreshRate,
                            newData.skipFrameNum)
    for (i,lbl ) in labels.enumerated(){
      lbl.backgroundColor = newData.colors[i]
      lbl.text =  newData.texts[i]
    }
    self.data.refreshNum += 1
  }

}

