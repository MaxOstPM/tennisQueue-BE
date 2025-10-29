import CoreGraphics

/// Represents the trajectory of comet 3I/ATLAS as a series of keyframe points
struct AtlasPath {
    let keyframes: [(t: Double, point: CGPoint)]
    
    /// Linearly interpolate the path to find position at time t (0.0–1.0)
    func position(at t: Double) -> CGPoint {
        guard let first = keyframes.first, let last = keyframes.last else { return .zero }
        if keyframes.count == 1 { return first.point }

        // Clamp t within the bounds of provided keyframes
        let clampedT = min(max(t, first.t), last.t)
        
        // Find the keyframes just before and after clampedT
        var previous = first
        var next = last
        for index in 1..<keyframes.count {
            let candidate = keyframes[index]
            if candidate.t >= clampedT {
                next = candidate
                previous = keyframes[index - 1]
                break
            }
        }
        
        // If t exactly matches a keyframe, return it directly
        if clampedT == previous.t { return previous.point }
        if clampedT == next.t { return next.point }
        
        // Linear interpolate between previous and next
        let interval = next.t - previous.t
        guard interval != 0 else { return previous.point }
        let ratio = (clampedT - previous.t) / interval
        let x = previous.point.x + (next.point.x - previous.point.x) * ratio
        let y = previous.point.y + (next.point.y - previous.point.y) * ratio
        return CGPoint(x: x, y: y)
    }
    
    /// Return all defined path points (e.g., for drawing the trajectory line)
    func pathPoints() -> [CGPoint] {
        keyframes.map { $0.point }
    }
}

/// Provides comet trajectory presets for rendering dotted paths.
enum CometPathProvider {
    /// Preset trajectory for comet ATLAS (using relative AU coordinates for consistency)
    static func atlasPath() -> AtlasPath {
        AtlasPath(keyframes: [
            (t: 0.0, point: CGPoint(x: -45.0, y: -12.0)), // ≈45 AU inbound beyond Neptune
            (t: 0.2, point: CGPoint(x: -20.0, y: -6.0)),  // crossing the Kuiper belt region
            (t: 0.5, point: CGPoint(x: 0.0, y: 0.0)),     // closest approach near the Sun
            (t: 0.8, point: CGPoint(x: 18.0, y: 5.0)),    // outbound through inner outer solar system
            (t: 1.0, point: CGPoint(x: 45.0, y: 12.0))    // exiting toward interstellar space
        ])
    }
}

// The coordinates above are in astronomical units (AU) relative to the Sun at (0, 0).
// Rendering logic will scale these to screen space to draw a dotted path through the system.

/// Shared instance of the ATLAS comet trajectory for rendering convenience.
let cometAtlasPath: AtlasPath = CometPathProvider.atlasPath()
