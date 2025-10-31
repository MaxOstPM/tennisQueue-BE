import Foundation
import QuartzCore
import ReSwift

protocol TimelineTicking: AnyObject {
    var isRunning: Bool { get }
    func start()
    func stop()
}

final class TimelineTicker: NSObject, TimelineTicking {
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private let onTick: (TimeInterval) -> Void
    private(set) var isRunning: Bool = false

    init(onTick: @escaping (TimeInterval) -> Void) {
        self.onTick = onTick
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        lastTimestamp = 0
        let link = CADisplayLink(target: self, selector: #selector(step(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        displayLink?.invalidate()
        displayLink = nil
        lastTimestamp = 0
    }

    @objc private func step(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        let delta = link.timestamp - lastTimestamp
        lastTimestamp = link.timestamp
        onTick(delta)
    }
}

public func createTimelineMiddleware(
    tickerFactory: @escaping (@escaping (TimeInterval) -> TimelineTicking) = { handler in
        TimelineTicker(onTick: handler)
    }
) -> Middleware<AppState> {
    return { dispatch, _ in
        var ticker: TimelineTicking?

        func ensureTicker(using handler: @escaping (TimeInterval) -> Void) -> TimelineTicking {
            if let ticker {
                return ticker
            }
            let newTicker = tickerFactory(handler)
            ticker = newTicker
            return newTicker
        }

        return { next in
            { action in
                if let appAction = action as? AppAction,
                   case let .solarSystem(solarAction) = appAction {
                    switch solarAction {
                    case .startAutoSpin:
                        let tickerInstance = ensureTicker { delta in
                            let clampedDelta = min(delta, 0.02)
                            dispatch(AppAction.solarSystem(.autoSpinTick(clampedDelta)))
                        }
                        tickerInstance.start()
                    case .stopAutoSpin:
                        ticker?.stop()
                    default:
                        break
                    }
                }

                return next(action)
            }
        }
    }
}
