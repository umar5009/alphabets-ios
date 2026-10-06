//
//  StrokeData.swift
//  BabyAlphabetApp
//
//  Handwriting centerline strokes for letters and numbers.
//  Coordinates are normalized 0…1 (top-left origin) and scaled to fit the canvas.
//

import CoreGraphics
import SwiftUI

enum StrokeData {

    /// Returns pen-down centerline strokes for a character, or nil if unknown.
    static func normalizedStrokes(for character: String) -> [[CGPoint]]? {
        guard character.count == 1 else { return nil }

        if let direct = catalog[character] {
            return direct
        }

        if let scalar = character.unicodeScalars.first,
           CharacterSet.decimalDigits.contains(scalar),
           let digit = catalog[character] {
            return digit
        }

        let folded = character.folding(options: .diacriticInsensitive, locale: .current)
        let upper = folded.uppercased()
        return catalog[upper]
    }

    /// Builds drawable paths for each handwriting stroke in `rect`.
    static func strokePaths(for character: String, in rect: CGRect) -> [Path] {
        guard rect.width > 8, rect.height > 8 else { return [] }

        if character.count > 1 {
            let glyphs = Array(character)
            let slotWidth = rect.width / CGFloat(glyphs.count)
            return glyphs.enumerated().flatMap { index, glyph in
                let slot = CGRect(
                    x: rect.minX + CGFloat(index) * slotWidth,
                    y: rect.minY,
                    width: slotWidth,
                    height: rect.height
                )
                return strokePaths(for: String(glyph), in: slot)
            }
        }

        guard let strokes = normalizedStrokes(for: character) else { return [] }
        return strokes.map { path(from: $0, in: rect) }
    }

    // MARK: - Catalog (kindergarten-style writing order)

    private static let catalog: [String: [[CGPoint]]] = [
        "0": [[
            p(0.62, 0.14), p(0.42, 0.10), p(0.26, 0.24), p(0.18, 0.44),
            p(0.18, 0.58), p(0.26, 0.76), p(0.42, 0.90), p(0.58, 0.90),
            p(0.74, 0.76), p(0.82, 0.58), p(0.82, 0.42), p(0.74, 0.24),
            p(0.58, 0.10), p(0.42, 0.10)
        ]],
        "1": [[
            p(0.38, 0.22), p(0.52, 0.08), p(0.50, 0.16), p(0.50, 0.92)
        ]],
        "2": [[
            p(0.22, 0.24), p(0.34, 0.12), p(0.56, 0.10), p(0.72, 0.20),
            p(0.78, 0.34), p(0.68, 0.48), p(0.30, 0.72), p(0.18, 0.92),
            p(0.82, 0.92)
        ]],
        "3": [[
            p(0.24, 0.16), p(0.46, 0.10), p(0.68, 0.18), p(0.72, 0.32),
            p(0.58, 0.44), p(0.42, 0.48), p(0.58, 0.54), p(0.74, 0.66),
            p(0.70, 0.82), p(0.48, 0.92), p(0.26, 0.86)
        ]],
        "4": [[
            p(0.62, 0.08), p(0.22, 0.68), p(0.82, 0.68), p(0.50, 0.68), p(0.50, 0.92)
        ]],
        "5": [[
            p(0.70, 0.12), p(0.28, 0.12), p(0.24, 0.40), p(0.52, 0.38),
            p(0.72, 0.50), p(0.74, 0.70), p(0.54, 0.88), p(0.30, 0.84)
        ]],
        "6": [[
            p(0.58, 0.16), p(0.38, 0.28), p(0.26, 0.50), p(0.26, 0.68),
            p(0.36, 0.86), p(0.56, 0.90), p(0.72, 0.76), p(0.74, 0.56),
            p(0.60, 0.44), p(0.40, 0.44), p(0.30, 0.54)
        ]],
        "7": [[
            p(0.22, 0.12), p(0.78, 0.12), p(0.40, 0.92)
        ]],
        "8": [[
            p(0.50, 0.46), p(0.34, 0.36), p(0.30, 0.22), p(0.44, 0.10),
            p(0.60, 0.12), p(0.70, 0.24), p(0.66, 0.38), p(0.50, 0.46),
            p(0.34, 0.56), p(0.28, 0.72), p(0.38, 0.88), p(0.56, 0.90),
            p(0.72, 0.78), p(0.72, 0.60), p(0.58, 0.50), p(0.50, 0.46)
        ]],
        "9": [[
            p(0.42, 0.84), p(0.62, 0.74), p(0.74, 0.54), p(0.74, 0.36),
            p(0.64, 0.18), p(0.44, 0.10), p(0.28, 0.20), p(0.26, 0.40),
            p(0.40, 0.54), p(0.60, 0.54), p(0.72, 0.44)
        ]],

        "A": [
            [p(0.34, 0.94), p(0.50, 0.08), p(0.66, 0.94)],
            [p(0.40, 0.56), p(0.60, 0.56)]
        ],
        "B": [
            [p(0.22, 0.06), p(0.22, 0.94)],
            [p(0.22, 0.06), p(0.48, 0.06), p(0.70, 0.12), p(0.74, 0.24),
             p(0.68, 0.36), p(0.46, 0.40), p(0.22, 0.40)],
            [p(0.22, 0.44), p(0.50, 0.44), p(0.74, 0.52), p(0.78, 0.66),
             p(0.70, 0.80), p(0.46, 0.88), p(0.22, 0.88)]
        ],
        "C": [[
            p(0.74, 0.18), p(0.54, 0.08), p(0.32, 0.14), p(0.20, 0.36),
            p(0.20, 0.64), p(0.32, 0.86), p(0.54, 0.92), p(0.74, 0.82)
        ]],
        "D": [
            [p(0.22, 0.06), p(0.22, 0.94)],
            [p(0.22, 0.06), p(0.48, 0.06), p(0.70, 0.18), p(0.78, 0.38),
             p(0.78, 0.62), p(0.70, 0.82), p(0.48, 0.94), p(0.22, 0.94)]
        ],
        "E": [
            [p(0.72, 0.08), p(0.24, 0.08), p(0.24, 0.94), p(0.72, 0.94)],
            [p(0.24, 0.50), p(0.62, 0.50)]
        ],
        "F": [
            [p(0.72, 0.08), p(0.24, 0.08), p(0.24, 0.94)],
            [p(0.24, 0.50), p(0.62, 0.50)]
        ],
        "G": [
            [p(0.74, 0.20), p(0.54, 0.08), p(0.32, 0.14), p(0.20, 0.36),
             p(0.20, 0.64), p(0.32, 0.86), p(0.58, 0.92), p(0.76, 0.78)],
            [p(0.76, 0.78), p(0.76, 0.58), p(0.54, 0.58)]
        ],
        "H": [
            [p(0.22, 0.06), p(0.22, 0.94)],
            [p(0.22, 0.50), p(0.78, 0.50)],
            [p(0.78, 0.06), p(0.78, 0.94)]
        ],
        "I": [
            [p(0.34, 0.08), p(0.66, 0.08)],
            [p(0.50, 0.08), p(0.50, 0.94)],
            [p(0.34, 0.94), p(0.66, 0.94)]
        ],
        "J": [
            [p(0.62, 0.08), p(0.38, 0.08)],
            [p(0.50, 0.08), p(0.50, 0.78), p(0.42, 0.92), p(0.28, 0.90)]
        ],
        "K": [
            [p(0.22, 0.06), p(0.22, 0.94)],
            [p(0.72, 0.06), p(0.22, 0.52), p(0.74, 0.94)]
        ],
        "L": [
            [p(0.22, 0.08), p(0.22, 0.94), p(0.76, 0.94)]
        ],
        "M": [[
            p(0.16, 0.94), p(0.16, 0.08), p(0.50, 0.52), p(0.84, 0.08),
            p(0.84, 0.94)
        ]],
        "N": [
            [p(0.22, 0.94), p(0.22, 0.06), p(0.78, 0.94), p(0.78, 0.06)]
        ],
        "O": [[
            p(0.50, 0.10), p(0.30, 0.14), p(0.18, 0.36), p(0.18, 0.64),
            p(0.30, 0.86), p(0.50, 0.90), p(0.70, 0.86), p(0.82, 0.64),
            p(0.82, 0.36), p(0.70, 0.14), p(0.50, 0.10)
        ]],
        "P": [
            [p(0.22, 0.06), p(0.22, 0.94)],
            [p(0.22, 0.06), p(0.50, 0.06), p(0.72, 0.14), p(0.76, 0.28),
             p(0.68, 0.40), p(0.44, 0.44), p(0.22, 0.44)]
        ],
        "Q": [
            [p(0.50, 0.10), p(0.30, 0.14), p(0.18, 0.36), p(0.18, 0.64),
             p(0.30, 0.86), p(0.50, 0.90), p(0.70, 0.86), p(0.82, 0.64),
             p(0.82, 0.36), p(0.70, 0.14), p(0.50, 0.10)],
            [p(0.58, 0.72), p(0.82, 0.94)]
        ],
        "R": [
            [p(0.22, 0.06), p(0.22, 0.94)],
            [p(0.22, 0.06), p(0.50, 0.06), p(0.72, 0.14), p(0.76, 0.28),
             p(0.68, 0.40), p(0.44, 0.44), p(0.22, 0.44)],
            [p(0.44, 0.44), p(0.76, 0.94)]
        ],
        "S": [[
            p(0.70, 0.16), p(0.50, 0.08), p(0.30, 0.14), p(0.26, 0.28),
            p(0.36, 0.42), p(0.64, 0.48), p(0.74, 0.62), p(0.66, 0.80),
            p(0.44, 0.90), p(0.26, 0.84)
        ]],
        "T": [
            [p(0.18, 0.08), p(0.82, 0.08)],
            [p(0.50, 0.08), p(0.50, 0.94)]
        ],
        "U": [[
            p(0.22, 0.08), p(0.22, 0.76), p(0.32, 0.90), p(0.50, 0.94),
            p(0.68, 0.90), p(0.78, 0.76), p(0.78, 0.08)
        ]],
        "V": [[
            p(0.18, 0.08), p(0.50, 0.94), p(0.82, 0.08)
        ]],
        "W": [[
            p(0.10, 0.08), p(0.28, 0.94), p(0.50, 0.40), p(0.72, 0.94), p(0.90, 0.08)
        ]],
        "X": [
            [p(0.20, 0.08), p(0.80, 0.94)],
            [p(0.80, 0.08), p(0.20, 0.94)]
        ],
        "Y": [
            [p(0.18, 0.08), p(0.50, 0.50), p(0.82, 0.08)],
            [p(0.50, 0.50), p(0.50, 0.94)]
        ],
        "Z": [[
            p(0.20, 0.10), p(0.80, 0.10), p(0.22, 0.90), p(0.80, 0.90)
        ]]
    ]

    // MARK: - Mapping

    private static func path(from stroke: [CGPoint], in rect: CGRect) -> Path {
        guard let first = stroke.first else { return Path() }
        let padding: CGFloat = 0.10
        let inset = rect.insetBy(
            dx: rect.width * padding,
            dy: rect.height * padding
        )

        var path = Path()
        path.move(to: map(first, into: inset))
        for point in stroke.dropFirst() {
            path.addLine(to: map(point, into: inset))
        }
        return path
    }

    private static func map(_ point: CGPoint, into rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + point.x * rect.width,
            y: rect.minY + point.y * rect.height
        )
    }

    @inline(__always)
    private static func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }
}
