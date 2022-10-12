//
// Copyright 2022 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import DSBottomSheet
import SwiftUI
import WysiwygComposer

struct Composer: View {
    @Environment(\.theme) private var theme: ThemeSwiftUI
    
    
    @ObservedObject var viewModel: ComposerViewModelType.Context
    @ObservedObject var wysiwygViewModel: WysiwygComposerViewModel
    
    let sendMessageAction: (WysiwygComposerContent) -> Void
    let showSendMediaActions: () -> Void
    
    @State private var showSendButton = false
    
    private let horizontalPadding: CGFloat = 12
    private let borderHeight: CGFloat = 44
    private let minTextViewHeight: CGFloat = 20
    private var verticalPadding: CGFloat {
        (borderHeight - minTextViewHeight) / 2
    }
    
    private var formatItems: [FormatItem] {
        FormatType.allCases.map { type in
            FormatItem(
                type: type,
                active: wysiwygViewModel.reversedActions.contains(type.composerAction),
                disabled: wysiwygViewModel.disabledActions.contains(type.composerAction)
            )
        }
    }
    
    var body: some View {
        VStack {
            let rect = RoundedRectangle(cornerRadius: borderHeight / 2)
            // TODO: Fix maximise animation bugs before re-enabling
            //            ZStack(alignment: .topTrailing) {
            VStack {
                if viewModel.viewState.shouldDisplayContext {
                    HStack {
                        if let imageName = viewModel.viewState.contextImageName {
                            Image(imageName)
                                .foregroundColor(theme.colors.secondaryContent)
                        }
                        if let contextDescription = viewModel.viewState.contextDescription {
                            Text(contextDescription)
                                .font(.system(size: 12.0, weight: .medium))
                                .foregroundColor(theme.colors.secondaryContent)
                        }
                        Spacer()
                        Button {
                            viewModel.send(viewAction: .cancel)
                        } label: {
                            Image(Asset.Images.inputCloseIcon.name)
                                .foregroundColor(theme.colors.secondaryContent)
                        }
                        .frame(height: 30)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, -verticalPadding)
                }
                WysiwygComposerView(
                    content: wysiwygViewModel.content,
                    replaceText: wysiwygViewModel.replaceText,
                    select: wysiwygViewModel.select,
                    didUpdateText: wysiwygViewModel.didUpdateText
                )
                .textColor(theme.colors.primaryContent)
                .frame(height: wysiwygViewModel.idealHeight)
                .padding(.horizontal, horizontalPadding)
                .onAppear {
                    wysiwygViewModel.setup()
                }
                //                Button {
                //                    withAnimation(.easeInOut(duration: 0.25)) {
                //                        viewModel.maximised.toggle()
                //                    }
                //                } label: {
                //                    Image(viewModel.maximised ? Asset.Images.minimiseComposer.name : Asset.Images.maximiseComposer.name)
                //                        .foregroundColor(theme.colors.tertiaryContent)
                //                }
                //                .padding(.top, 4)
                //                .padding(.trailing, 12)
                //            }
                .padding(.vertical, verticalPadding)
            }
            .clipShape(rect)
            .overlay(rect.stroke(theme.colors.quinaryContent, lineWidth: 2))
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)
            HStack {
                Button {
                    showSendMediaActions()
                } label: {
                    Image(Asset.Images.startComposeModule.name)
                        .foregroundColor(theme.colors.tertiaryContent)
                        .padding(11)
                        .background(Circle().fill(theme.colors.system))
                }
                FormattingToolbar(formatItems: formatItems) { type in
                    wysiwygViewModel.apply(type.action)
                }
                Spacer()
                ZStack {
                    // TODO: Add support for voice messages
//                    Button {
//
//                    } label: {
//                        Image(Asset.Images.voiceMessageRecordButtonDefault.name)
//                            .foregroundColor(theme.colors.tertiaryContent)
//                    }
                    //                        .isHidden(showSendButton)
//                    .isHidden(true)
                    Button {
                        sendMessageAction(wysiwygViewModel.content)
                        wysiwygViewModel.clearContent()
                    } label: {
                        if viewModel.viewState.sendMode == .edit {
                            Image(Asset.Images.saveIcon.name)
                                .foregroundColor(theme.colors.tertiaryContent)
                        } else {
                            Image(Asset.Images.sendIcon.name)
                                .foregroundColor(theme.colors.tertiaryContent)
                        }
                    }
                    .isHidden(!showSendButton)
                }
                .onChange(of: wysiwygViewModel.isContentEmpty) { empty in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSendButton = !empty
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
            .animation(.none)
        }
    }
}

struct Composer_Previews: PreviewProvider {
    static let stateRenderer = MockComposerScreenState.stateRenderer
    static var previews: some View {
        stateRenderer.screenGroup()
    }
}

enum ComposerCreateActionListViewAction {
    case selectAction(ComposerCreateAction)
}
