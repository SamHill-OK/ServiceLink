//
//  MeetingNoteReaderView.swift
//  ServiceLink
//
//  Created by Michael Anderson on 7/11/26.
//

import SwiftUI

struct MeetingNoteReaderView: View {

    let text: String

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 14
            ) {
                ForEach(parseBlocks(text)) { block in
                    blockView(block)
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding()
        }
        .textSelection(.enabled)
    }

    @ViewBuilder
    private func blockView(
        _ block: MeetingNoteBlock
    ) -> some View {

        switch block.kind {

        case .heading:
            Text(.init(block.text))
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 8)

        case .subheading:
            Text(.init(block.text))
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top, 4)

        case .speaker:
            Text(.init(block.text))
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top, 10)

        case .timestamp:
            Text(block.text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .italic()
                .padding(.top, -8)

        case .bullet:
            HStack(
                alignment: .firstTextBaseline,
                spacing: 10
            ) {
                Text("•")

                Text(.init(block.text))
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }
        case .divider:
            Divider()
                .padding(.vertical, 4)

        case .paragraph:
            Text(.init(block.text))
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }

    private func parseBlocks(
        _ source: String
    ) -> [MeetingNoteBlock] {

        let normalized = source
            .replacingOccurrences(
                of: "\r\n",
                with: "\n"
            )
            .replacingOccurrences(
                of: "\r",
                with: "\n"
            )

        let lines = normalized
            .components(separatedBy: "\n")

        var blocks: [MeetingNoteBlock] = []
        var paragraphLines: [String] = []

        func flushParagraph() {
            let text = paragraphLines
                .joined(separator: " ")
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            if !text.isEmpty {
                blocks.append(
                    MeetingNoteBlock(
                        kind: .paragraph,
                        text: text
                    )
                )
            }

            paragraphLines.removeAll()
        }

        for rawLine in lines {

            let line = rawLine.trimmingCharacters(
                in: .whitespaces
            )

            if line.isEmpty {
                flushParagraph()
                continue
            }
            if line == "---" {
                flushParagraph()

                blocks.append(
                    MeetingNoteBlock(
                        kind: .divider,
                        text: ""
                    )
                )

                continue
            }

            // Jamie transcript title.
            if line.caseInsensitiveCompare(
                "Meeting Transcript"
            ) == .orderedSame {
                flushParagraph()

                blocks.append(
                    MeetingNoteBlock(
                        kind: .heading,
                        text: line
                    )
                )

                continue
            }

            /*
             Jamie transcript format:

             Robin Anderson

             ###### 00:01 - 00:05

             Transcript text...
             */
            if let timestamp = jamieTimestamp(
                from: line
            ) {
                flushParagraph()

                // The block directly before a Jamie timestamp
                // is the speaker name.
                if let previousBlock = blocks.last,
                   previousBlock.kind == .paragraph {

                    blocks.removeLast()

                    blocks.append(
                        MeetingNoteBlock(
                            kind: .speaker,
                            text: previousBlock.text
                        )
                    )
                }

                blocks.append(
                    MeetingNoteBlock(
                        kind: .timestamp,
                        text: timestamp
                    )
                )

                continue
            }

            if line.hasPrefix("### ") {
                flushParagraph()

                blocks.append(
                    MeetingNoteBlock(
                        kind: .subheading,
                        text: String(
                            line.dropFirst(4)
                        )
                    )
                )

                continue
            }

            if line.hasPrefix("## ") {
                flushParagraph()

                blocks.append(
                    MeetingNoteBlock(
                        kind: .heading,
                        text: String(
                            line.dropFirst(3)
                        )
                    )
                )

                continue
            }
            if line.hasPrefix("# ") {
                flushParagraph()

                blocks.append(
                    MeetingNoteBlock(
                        kind: .heading,
                        text: String(
                            line.dropFirst(2)
                        )
                    )
                )

                continue
            }

            if line.hasPrefix("- ") {
                flushParagraph()

                blocks.append(
                    MeetingNoteBlock(
                        kind: .bullet,
                        text: String(
                            line.dropFirst(2)
                        )
                    )
                )

                continue
            }

            paragraphLines.append(line)
        }

        flushParagraph()

        return blocks
    }

    private func jamieTimestamp(
        from line: String
    ) -> String? {

        guard line.hasPrefix("###### ") else {
            return nil
        }

        let value = String(
            line.dropFirst(7)
        )
        .trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let pattern =
            #"^\d{1,2}:\d{2}\s*-\s*\d{1,2}:\d{2}$"#

        guard value.range(
            of: pattern,
            options: .regularExpression
        ) != nil else {
            return nil
        }

        return value.replacingOccurrences(
            of: " - ",
            with: " – "
        )
    }
}

private struct MeetingNoteBlock: Identifiable {

    let id = UUID()
    let kind: MeetingNoteBlockKind
    let text: String
}

private enum MeetingNoteBlockKind: Equatable {
    case heading
    case subheading
    case speaker
    case timestamp
    case bullet
    case divider
    case paragraph
}
