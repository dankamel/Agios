//
//  SheetModel.swift
//  Agios
//
//  Created by Victor on 6/22/24.
//

import SwiftUI

struct SheetModel: View {
    
    @State var showSheet: Bool? = nil
    
    let passage: Passage
    let verse: Verse
    let subSection: SubSection
    
    @EnvironmentObject private var occasionViewModel: OccasionsViewModel
    
    var body: some View {
        Button(action: {
            
            showSheet = true
            
        }, label:{Text("Tap me to pull up sheet")})
        .halfSheet(showSheet: $showSheet) {
            
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea()
                
                Rectangle()
                    .fill(LinearGradient(colors: [.primary300, .clear], startPoint: .top, endPoint: .bottom))
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea()
                    
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
    //                    NavigationButton(labelName: .down)
    //                        .onTapGesture {
    //                            occasionViewModel.openSheet = false
    //                        }
                        
                        VStack(alignment: .leading, spacing: 32) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(passage.bookTranslation ?? "")  \(passage.ref ?? "")")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                
                                HStack(alignment: .center, spacing: 8, content: {
                                    Text(subSection.title ?? "")

                                    Circle()
                                        .frame(width: 4, height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    
                                    Text("Liturgy")
                                })
                                .font(.body)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .background(.primary300)
                                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                            }
                            
                            VStack(alignment: .leading, spacing: 24, content: {
                                if ((subSection.introduction?.isEmpty) != nil) {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Introduction".uppercased())
                                            .font(.headline)
                                            .foregroundStyle(.gray400)
                                            .kerning(0.5)
                                        Text(subSection.introduction ?? "")
                                            .fontWeight(.medium)
                                            .font(.title2)
                                        .foregroundStyle(.gray900)
                                        
                                    }
                                
                                    Divider()
                                }
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Chapter \(verse.chapter ?? 0)".uppercased())
                                        .font(.headline)
                                        .foregroundStyle(.gray400)
                                        .kerning(0.5)
                                    ForEach(passage.verses ?? []) { verse in
                                        HStack(alignment: .firstTextBaseline) {
                                            Text("\(verse.number ?? 0)")
                                                .font(.callout)
                                            Text(verse.text ?? "")
                                                .fontWeight(.medium)
                                            .font(.title2)
                                        }
                                    }
                                }
                            })
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 64)
                    .textSelection(.enabled)
                }
                .scrollIndicators(.hidden)
            }
            .kerning(-0.4)
            .foregroundStyle(.gray900)
            .fontDesign(.rounded)

            .edgesIgnoringSafeArea(.bottom)
        } onDismiss: {
            print("sheet dismissed")
        }
        
    }
}

struct SheetModel_Previews: PreviewProvider {
    static var previews: some View {
        SheetModel(passage: dev.passages, verse: dev.verses, subSection: dev.subSection)
            .environmentObject(OccasionsViewModel())
    }
}

extension View {
    //binding show bariable...
    func halfSheet<Content: View>(
        showSheet: Binding<Bool?>,
        @ViewBuilder content: @escaping () -> Content,
        onDismiss: @escaping () -> Void
    ) -> some View {
        return self
            .background(
                HalfSheetHelper(sheetView: content(), showSheet: showSheet, onDismiss: onDismiss)
            )
    }
}

// UIKit integration
struct HalfSheetHelper<Content: View>: UIViewControllerRepresentable {
    
    var sheetView: Content
    let controller: UIViewController = UIViewController()
    @Binding var showSheet: Bool?
    var onDismiss: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let showSheet: Bool = showSheet {
            if showSheet {
                let sheetController = CustomHostingController(rootView: sheetView)
                sheetController.presentationController?.delegate = context.coordinator
                uiViewController.present(sheetController, animated: true)
            }
        }
    }
    
    //on dismiss...
    final class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        
        var parent: HalfSheetHelper
        
        init(parent: HalfSheetHelper) {
            self.parent = parent
        }
        
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
        }
    }
}

// Custom UIHostingController for halfSheet...
final class CustomHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        view.backgroundColor = .clear
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .medium(),
                .large()
            ]
            
            //MARK: - sheet grabber visbility:
            presentationController.prefersGrabberVisible = false
            
            // i added the code below so that you can scroll when you have medium view
            // here is good article for customising sheet in UIKit - https://sarunw.com/posts/bottom-sheet-in-ios-15-with-uisheetpresentationcontroller/#scrolling
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = true
            
            //MARK: - sheet corner radius:
            presentationController.preferredCornerRadius = 30
        }
    }
}

public struct LazyView<Content: View>: View {
    private let build: () -> Content
    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    public var body: Content {
        build()
    }
}

