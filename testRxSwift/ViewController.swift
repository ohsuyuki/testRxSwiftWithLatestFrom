//
//  ViewController.swift
//  testRxSwift
//
//  Created by yuki.osu on 2021/02/17.
//

import UIKit
import RxSwift
import RxCocoa

extension ObservableType {
    
    func catchErrorJustComplete() -> Observable<Element> {
            return catchError { _ in
                return Observable.empty()
            }
        }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
        
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
}

class ViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    let disposeBag = DisposeBag()
    var tapGesture: UITapGestureRecognizer!

    var count1: Int = 1
    var count2: Int = -1
    var count3: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let obs1: Single<Int> = Single.create { (observer) -> Disposable in
            DispatchQueue.init(label: "obs1").async {
//                sleep(1)
                observer(.success(1))
            }
            return Disposables.create()
        }

        let obs2: Single<Int> = Single.create { (observer) -> Disposable in
            DispatchQueue.init(label: "obs2").async {
//                sleep(1)
                print("success")
                observer(.success(10))
            }
//            observer(.success(10))
            return Disposables.create()
        }

//        let wrappedObs2: Observable<Int> = button1.rx.tap
//            .flatMap {
//                return obs2
//            }
//            .asObservable()
        let wrappedObs2: Observable<Int> = button1.rx.tap
            .flatMap {
//                return Observable.just(10)
                return obs2.asObservable()
            }
            .asObservable()

        let tappedObs = button1.rx.tap
            .flatMap {
                return obs1
            }
            .asObservable()

        #if false
//        let relay = PublishRelay<Int>()
//        wrappedObs2
//            .subscribe(onNext: { relay.accept($0) })
//            .disposed(by: disposeBag)

        let target = button1.rx.tap
            .debug("withLatestFrom", trimOutput: false)
            .withLatestFrom(
                Observable.combineLatest(
//                    tappedObs.debug("tappedObs", trimOutput: false),
                    wrappedObs2.debug("obs2", trimOutput: false),
//                    relay.asObservable().debug("relay", trimOutput: false)
//                    Observable.just(1).debug("just", trimOutput: false)
//                    Observable.just(2)
                    BehaviorSubject<Int>(value: 1).asObservable().debug("behavior", trimOutput: false)
                )
                .debug("combine", trimOutput: false)
            )
            .debug("map", trimOutput: false)
            .map { (obs1, obs2) -> Int in
                return obs1 + obs2
            }
        #else
        #if false
        let relay = PublishRelay<Int>()
        wrappedObs2
            .subscribe(onNext: { relay.accept($0) })
            .disposed(by: disposeBag)

        let target = button1.rx.tap
            .debug("withLatestFrom", trimOutput: false)
            .withLatestFrom(relay.asObservable().debug("relay", trimOutput: false))
            .withLatestFrom(wrappedObs2.debug("obs2", trimOutput: false)) { ($0, $1) }
//            .withLatestFrom(comb)
            .debug("map", trimOutput: false)
            .map { (obs1, obs2) -> Int in
                return obs1 + obs2
            }
        #else

        #if false
        let relay = PublishRelay<Int>()
        tappedObs
            .subscribe(onNext: { relay.accept($0) })
            .disposed(by: disposeBag)

        let target = button1.rx.tap
            .debug("withLatestFrom", trimOutput: false)
//            .withLatestFrom(relay.asObservable().debug("relay", trimOutput: false))
//            .debug("flatMap", trimOutput: false)
            .map { 1 }
            .flatMap { (obs1) -> Observable<(Int, Int)> in
                return wrappedObs2
                    .debug("wrappedObs2", trimOutput: false)
                    .withLatestFrom(Observable.just(obs1)) { ($0, $1) }
                    .debug("wrappedObs2 withLatestFrom", trimOutput: false)
            }
            .debug("map", trimOutput: false)
            .map { (obs1, obs2) -> Int in
                return obs1 + obs2
            }
        #else
        let target = button1.rx.tap
            .debug("withLatestFrom", trimOutput: false)
            .flatMap { _ -> Observable<Int> in
                return wrappedObs2
            }



        #endif
        #endif
        #endif

        target.asDriver(onErrorDriveWith: .empty())
            .map { String($0) }
            .debug("drive", trimOutput: false)
            .drive(label1.rx.text)
            .disposed(by: disposeBag)
    }
}
