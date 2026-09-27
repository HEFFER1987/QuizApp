import SwiftUI

struct QuizBuilderDetailsForm<ViewModel: QuizBuilderViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            titleSection
            descriptionSection
            coverSection
            categorySection
            languageSection
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(QuizTheme.cardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(icon: "doc.text.fill", text: Strings.QuizBuilder.Field.title)
            QuizBuilderOutlinedField {
                TextField("", text: $viewModel.title)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .tint(QuizTheme.draftGlow)
            }
            characterCount(
                current: viewModel.titleCharacterCount,
                max: QuizBuilderLimits.titleMaxLength
            )
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(
                icon: "list.bullet.rectangle.portrait.fill",
                text: Strings.QuizBuilder.Field.description
            )
            QuizBuilderOutlinedField(minHeight: 110) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $viewModel.descriptionText)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .tint(QuizTheme.draftGlow)
                        .frame(minHeight: 90)
                    if viewModel.descriptionText.isEmpty {
                        Text(Strings.QuizBuilder.Field.description)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(QuizTheme.mutedText.opacity(0.7))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }
            }
            characterCount(
                current: viewModel.descriptionCharacterCount,
                max: QuizBuilderLimits.descriptionMaxLength
            )
        }
    }

    private var coverSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            fieldLabel(icon: "photo.fill", text: Strings.QuizBuilder.Field.cover)
            Text(Strings.QuizBuilder.Field.Cover.hint)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(QuizCoverOption.allCases) { cover in
                        coverChip(cover)
                    }
                    moreCoverChip
                }
            }
        }
    }

    private func coverChip(_ cover: QuizCoverOption) -> some View {
        let isSelected = viewModel.selectedCover == cover
        let accent = cover.usesOrangeAccent ? QuizTheme.draftGlow : QuizTheme.publishedGlow

        return Button {
            viewModel.selectCover(cover)
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.35))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(accent, lineWidth: isSelected ? 2.4 : 1.2)
                    )
                    .shadow(color: isSelected ? accent.opacity(0.45) : .clear, radius: 8, x: 0, y: 0)

                Image(systemName: cover.systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(QuizTheme.draftGlow)
                        .padding(4)
                }
            }
            .frame(width: 56, height: 56)
        }
        .buttonStyle(.plain)
    }

    private var moreCoverChip: some View {
        Button {
            viewModel.tapMoreCovers()
        } label: {
            VStack(spacing: 2) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                Text(Strings.QuizBuilder.Field.Cover.more)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundStyle(QuizTheme.mutedText)
            .frame(width: 56, height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        QuizTheme.mutedText.opacity(0.55),
                        style: StrokeStyle(lineWidth: 1.2, dash: [5, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(icon: "folder.fill", text: Strings.QuizBuilder.Field.category)
            Menu {
                Button(Strings.QuizBuilder.Category.none) {
                    viewModel.category = nil
                }
                ForEach(QuizCategoryOption.allCases) { option in
                    Button(option.title) {
                        viewModel.category = option
                    }
                }
            } label: {
                dropdownRow(
                    icon: "bookmark.fill",
                    text: viewModel.category?.title ?? Strings.QuizBuilder.Category.none
                )
            }
        }
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(icon: "globe", text: Strings.QuizBuilder.Field.language)
            Menu {
                ForEach(QuizLanguageOption.allCases) { option in
                    Button(option.title) {
                        viewModel.language = option
                    }
                }
            } label: {
                dropdownRow(icon: "bubble.left.fill", text: viewModel.language.title)
            }
        }
    }

    private func dropdownRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(QuizTheme.draftGlow)
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(QuizTheme.mutedText)
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.35))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(QuizTheme.draftGlow, lineWidth: 1.4)
        )
    }

    private func fieldLabel(icon: String, text: String) -> some View {
        Label {
            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(QuizTheme.draftGlow)
        }
        .labelStyle(.titleAndIcon)
    }

    private func characterCount(current: Int, max: Int) -> some View {
        HStack {
            Spacer()
            Text(Strings.QuizBuilder.characterCount(current, max))
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(QuizTheme.mutedText)
        }
    }
}

struct QuizBuilderOutlinedField<Content: View>: View {
    var minHeight: CGFloat = 48
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.35))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(QuizTheme.draftGlow, lineWidth: 1.4)
            )
    }
}

extension QuizCategoryOption {
    var title: String {
        switch self {
        case .education: return Strings.QuizBuilder.Category.education
        case .science: return Strings.QuizBuilder.Category.science
        case .history: return Strings.QuizBuilder.Category.history
        case .languages: return Strings.QuizBuilder.Category.languages
        case .other: return Strings.QuizBuilder.Category.other
        }
    }
}

extension QuizLanguageOption {
    var title: String {
        switch self {
        case .english: return Strings.QuizBuilder.Language.english
        case .ukrainian: return Strings.QuizBuilder.Language.ukrainian
        case .spanish: return Strings.QuizBuilder.Language.spanish
        case .german: return Strings.QuizBuilder.Language.german
        }
    }
}
