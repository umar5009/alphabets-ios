//
//  TracingGuide.swift
//  BabyAlphabetApp
//
//  Converts any letter/character into a scalable CGPath outline (using
//  CoreText glyph paths) so it can be drawn as a light, bold tracing guide
//  and used to score how well a child's finger-drawn stroke matches it.
//

import CoreText
import SwiftUI

/// Combined tracing score: coverage of the guide + how accurately
/// the child's stroke stays on the letter (rejects random scribbles).
struct TraceScore {
    /// Fraction of guide outline points that were traced (0...1).
    let coverage: Double
    /// Fraction of drawn points that land near the guide (0...1).
    let accuracy: Double
    /// Approximate length of the child's stroke in points.
    let drawnLength: CGFloat
    /// Approximate length of the guide outline in points.
    let guideLength: CGFloat

    /// Combined quality used for the progress bar.
    var quality: Double {
        // Both must be good — a scribble across the letter can cover
        // outline samples but fails accuracy; a tiny dab fails coverage.
        min(coverage, accuracy)
    }

    /// Whether this attempt is good enough to count as a completed letter.
    func isPassing(coverageNeeded: Double, accuracyNeeded: Double, minLengthRatio: CGFloat) -> Bool {
        guard guideLength > 0 else { return false }
        let longEnough = drawnLength >= guideLength * minLengthRatio
        return coverage >= coverageNeeded
            && accuracy >= accuracyNeeded
            && longEnough
    }
}

enum TracingGuide {

    /// Handwriting centerline strokes — the primary guide for tracing.
    static func strokePaths(for character: String, in rect: CGRect) -> [Path] {
        let centerline = StrokeData.strokePaths(for: character, in: rect)
        if !centerline.isEmpty { return centerline }
        return skeletonPaths(for: character, in: rect)
    }

    /// Legacy combined path (union of all strokes).
    static func path(for character: String, in rect: CGRect) -> Path {
        var combined = Path()
        for stroke in strokePaths(for: character, in: rect) {
            combined.addPath(stroke)
        }
        return combined
    }

    /// Builds a single centerline inside a glyph outline for scripts without
    /// predefined stroke data (e.g. Arabic).
    private static func skeletonPaths(for character: String, in rect: CGRect) -> [Path] {
        let outline = glyphOutlinePath(for: character, in: rect)
        return subpaths(from: outline).map { skeletonPath(from: $0) }
    }

    private static func skeletonPath(from outline: Path) -> Path {
        let samples = samplePoints(on: outline, count: 96)
        guard samples.count >= 4 else { return outline }

        let cx = samples.map(\.x).reduce(0, +) / CGFloat(samples.count)
        let cy = samples.map(\.y).reduce(0, +) / CGFloat(samples.count)
        let centroid = CGPoint(x: cx, y: cy)

        var path = Path()
        for (index, point) in samples.enumerated() {
            let pull: CGFloat = 0.34
            let skel = CGPoint(
                x: point.x + (centroid.x - point.x) * pull,
                y: point.y + (centroid.y - point.y) * pull
            )
            if index == 0 {
                path.move(to: skel)
            } else {
                path.addLine(to: skel)
            }
        }
        return path
    }

    /// CoreText glyph outline — used only as a fallback skeleton source.
    private static func glyphOutlinePath(for character: String, in rect: CGRect) -> Path {
        guard rect.width > 8, rect.height > 8 else { return Path() }

        let fontSize: CGFloat = 800
        let base = UIFont.systemFont(ofSize: fontSize, weight: .heavy)
        let descriptor = base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor
        let font = UIFont(descriptor: descriptor, size: fontSize)
        let ctFont = CTFontCreateWithName(font.fontName as CFString, fontSize, nil)

        let scalars = Array(character.unicodeScalars)
        guard !scalars.isEmpty else { return Path() }

        let combined = CGMutablePath()
        var xOffset: CGFloat = 0
        var glyphs = [CGGlyph](repeating: 0, count: scalars.count)
        var unichars = scalars.map { UniChar($0.value) }

        let success = CTFontGetGlyphsForCharacters(ctFont, &unichars, &glyphs, scalars.count)
        guard success else {
            var glyph = CGGlyph()
            var unichar = UniChar(scalars[0].value)
            guard CTFontGetGlyphsForCharacters(ctFont, &unichar, &glyph, 1),
                  let cgPath = CTFontCreatePathForGlyph(ctFont, glyph, nil) else {
                return Path()
            }
            return fit(Path(cgPath), in: rect)
        }

        var advances = [CGSize](repeating: .zero, count: glyphs.count)
        CTFontGetAdvancesForGlyphs(ctFont, .default, glyphs, &advances, glyphs.count)

        for (index, glyph) in glyphs.enumerated() {
            guard let cgPath = CTFontCreatePathForGlyph(ctFont, glyph, nil) else {
                xOffset += advances[index].width
                continue
            }
            var translate = CGAffineTransform(translationX: xOffset, y: 0)
            if let copied = cgPath.copy(using: &translate) {
                combined.addPath(copied)
            }
            xOffset += advances[index].width
        }

        guard !combined.isEmpty else { return Path() }
        return fit(Path(combined), in: rect)
    }

    private static func fit(_ path: Path, in rect: CGRect) -> Path {
        let bounds = path.boundingRect
        guard bounds.width > 0, bounds.height > 0 else { return Path() }

        let padding: CGFloat = 0.12
        let availableWidth = rect.width * (1 - padding * 2)
        let availableHeight = rect.height * (1 - padding * 2)
        let scale = min(availableWidth / bounds.width, availableHeight / bounds.height)

        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: rect.midX, y: rect.midY)
        transform = transform.scaledBy(x: scale, y: -scale)
        transform = transform.translatedBy(x: -(bounds.midX), y: -(bounds.midY))

        return path.applying(transform)
    }

    /// Splits a glyph outline into separate pen-stroke subpaths (outer contour,
    /// inner holes, etc.) so the helper never draws connecting lines across gaps.
    static func subpaths(from path: Path) -> [Path] {
        var segments: [Path] = []
        var current = Path()
        var hasContent = false

        path.forEach { element in
            switch element {
            case .move(let to):
                if hasContent {
                    segments.append(current)
                    current = Path()
                }
                current.move(to: to)
                hasContent = true
            case .line(let to):
                current.addLine(to: to)
            case .curve(let to, let c1, let c2):
                current.addCurve(to: to, control1: c1, control2: c2)
            case .quadCurve(let to, let c):
                current.addQuadCurve(to: to, control: c)
            case .closeSubpath:
                current.closeSubpath()
                if hasContent {
                    segments.append(current)
                    current = Path()
                    hasContent = false
                }
            }
        }

        if hasContent {
            segments.append(current)
        }
        return segments
    }

    /// Points for the animated "Show me" tutorial — one line per stroke.
    static func tutorialSegments(from paths: [Path], pointsPerSegment: Int = 80) -> [[CGPoint]] {
        guard !paths.isEmpty else { return [] }
        return paths
            .map { samplePoints(on: $0, count: pointsPerSegment) }
            .filter { $0.count >= 2 }
    }

    /// Sample points along centerline strokes for finger-tracing score.
    static func scoringPoints(from paths: [Path], count: Int = 220) -> [CGPoint] {
        guard !paths.isEmpty else { return [] }
        let perStroke = max(24, count / paths.count)
        return paths.flatMap { samplePoints(on: $0, count: perStroke) }
    }

    /// Points for the animated "Show me" tutorial — one continuous line per subpath,
    /// never bridging across separate strokes (fixes doubled / crossed helper lines).
    static func tutorialSegments(on path: Path, pointsPerSegment: Int = 80) -> [[CGPoint]] {
        tutorialSegments(from: subpaths(from: path), pointsPerSegment: pointsPerSegment)
    }

    /// All sample points used for finger-tracing score (every subpath).
    static func scoringPoints(on path: Path, count: Int = 220) -> [CGPoint] {
        scoringPoints(from: subpaths(from: path), count: count)
    }

    /// Samples evenly-spaced points along the guide path's outline,
    /// used to score finger-tracing coverage and animate a helper stroke.
    static func samplePoints(on path: Path, count: Int = 220) -> [CGPoint] {
        let length = approximateLength(of: path)
        guard length > 0 else { return [] }

        var dense: [CGPoint] = []
        var lastPoint: CGPoint?

        path.forEach { element in
            switch element {
            case .move(let to):
                lastPoint = to
                dense.append(to)
            case .line(let to):
                if let from = lastPoint {
                    let segmentLength = distance(from, to)
                    let steps = max(1, Int(segmentLength / 4))
                    for i in 1...steps {
                        let t = CGFloat(i) / CGFloat(steps)
                        dense.append(interpolate(from, to, t))
                    }
                }
                lastPoint = to
            case .curve(let to, let c1, let c2):
                if let from = lastPoint {
                    let steps = 16
                    for i in 1...steps {
                        let t = CGFloat(i) / CGFloat(steps)
                        dense.append(cubicPoint(from, c1, c2, to, t))
                    }
                }
                lastPoint = to
            case .quadCurve(let to, let c):
                if let from = lastPoint {
                    let steps = 12
                    for i in 1...steps {
                        let t = CGFloat(i) / CGFloat(steps)
                        dense.append(quadPoint(from, c, to, t))
                    }
                }
                lastPoint = to
            case .closeSubpath:
                break
            }
        }

        guard dense.count > 1 else { return dense }

        var result: [CGPoint] = []
        let step = length / CGFloat(max(count - 1, 1))
        result.append(dense[0])
        var walked: CGFloat = 0
        var target = step

        for i in 1..<dense.count {
            let seg = distance(dense[i - 1], dense[i])
            var remaining = seg
            var from = dense[i - 1]
            while walked + remaining >= target, remaining > 0 {
                let need = target - walked
                let t = need / remaining
                let point = interpolate(from, dense[i], t)
                result.append(point)
                from = point
                remaining -= need
                walked = 0
                target = step
                if result.count >= count { return result }
            }
            walked += remaining
        }

        if let last = dense.last, result.last.map({ distance($0, last) > 1 }) ?? true {
            result.append(last)
        }
        return result
    }

    /// Full score used for acceptance / rejection of a child's attempt.
    static func score(
        guidePoints: [CGPoint],
        drawnPoints: [CGPoint],
        tolerance: CGFloat
    ) -> TraceScore {
        guard !guidePoints.isEmpty, !drawnPoints.isEmpty else {
            return TraceScore(coverage: 0, accuracy: 0, drawnLength: 0, guideLength: 0)
        }

        // Thin drawn points lightly — keep enough density for finger traces.
        let thinned = thin(drawnPoints, minSpacing: max(3, tolerance * 0.22))

        // Subsample guide points for speed while keeping shape coverage fair.
        let guideStep = max(1, guidePoints.count / 160)
        let scoredGuide = stride(from: 0, to: guidePoints.count, by: guideStep).map { guidePoints[$0] }

        var covered = 0
        for gp in scoredGuide {
            if thinned.contains(where: { distance($0, gp) <= tolerance }) {
                covered += 1
            }
        }
        let coverage = scoredGuide.isEmpty ? 0 : Double(covered) / Double(scoredGuide.count)

        var onPath = 0
        for dp in thinned {
            if scoredGuide.contains(where: { distance($0, dp) <= tolerance }) {
                onPath += 1
            }
        }
        let accuracy = thinned.isEmpty ? 0 : Double(onPath) / Double(thinned.count)

        return TraceScore(
            coverage: coverage,
            accuracy: accuracy,
            drawnLength: polylineLength(thinned),
            guideLength: polylineLength(guidePoints)
        )
    }

    /// Percentage (0...1) of guide sample points covered — kept for progress UI.
    static func coverageScore(guidePoints: [CGPoint], drawnPoints: [CGPoint], tolerance: CGFloat) -> Double {
        score(guidePoints: guidePoints, drawnPoints: drawnPoints, tolerance: tolerance).coverage
    }

    // MARK: - Geometry helpers

    static func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }

    static func polylineLength(_ points: [CGPoint]) -> CGFloat {
        guard points.count > 1 else { return 0 }
        var length: CGFloat = 0
        for i in 1..<points.count {
            length += distance(points[i - 1], points[i])
        }
        return length
    }

    /// Keeps points that are at least `minSpacing` apart along the stroke.
    private static func thin(_ points: [CGPoint], minSpacing: CGFloat) -> [CGPoint] {
        guard let first = points.first else { return [] }
        var result = [first]
        for point in points.dropFirst() {
            if let last = result.last, distance(last, point) >= minSpacing {
                result.append(point)
            }
        }
        if let last = points.last, result.last.map({ distance($0, last) > 1 }) ?? true {
            result.append(last)
        }
        return result
    }

    private static func interpolate(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
    }

    private static func cubicPoint(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, _ t: CGFloat) -> CGPoint {
        let mt = 1 - t
        let x = mt*mt*mt*p0.x + 3*mt*mt*t*p1.x + 3*mt*t*t*p2.x + t*t*t*p3.x
        let y = mt*mt*mt*p0.y + 3*mt*mt*t*p1.y + 3*mt*t*t*p2.y + t*t*t*p3.y
        return CGPoint(x: x, y: y)
    }

    private static func quadPoint(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ t: CGFloat) -> CGPoint {
        let mt = 1 - t
        let x = mt*mt*p0.x + 2*mt*t*p1.x + t*t*p2.x
        let y = mt*mt*p0.y + 2*mt*t*p1.y + t*t*p2.y
        return CGPoint(x: x, y: y)
    }

    private static func approximateLength(of path: Path) -> CGFloat {
        var length: CGFloat = 0
        var lastPoint: CGPoint?
        path.forEach { element in
            switch element {
            case .move(let to):
                lastPoint = to
            case .line(let to):
                if let from = lastPoint { length += distance(from, to) }
                lastPoint = to
            case .curve(let to, let c1, let c2):
                if let from = lastPoint {
                    var prev = from
                    for i in 1...12 {
                        let t = CGFloat(i) / 12
                        let p = cubicPoint(from, c1, c2, to, t)
                        length += distance(prev, p)
                        prev = p
                    }
                }
                lastPoint = to
            case .quadCurve(let to, let c):
                if let from = lastPoint {
                    var prev = from
                    for i in 1...10 {
                        let t = CGFloat(i) / 10
                        let p = quadPoint(from, c, to, t)
                        length += distance(prev, p)
                        prev = p
                    }
                }
                lastPoint = to
            case .closeSubpath:
                break
            }
        }
        return length
    }
}
