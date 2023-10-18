//
//  File.swift
//  
//
//  Created by Patryk Maciąg on 18/10/2023.
//

import SwiftUI

public struct DynamicSheetOptions {
    let cornerRadius: CGFloat
    let backgorundColor: Color
    
    public init(corner radius: CGFloat = 10, background color: Color = Color.system) {
        self.cornerRadius = radius
        self.backgorundColor = color
    }
}

struct DynamicSheet<SheetContent: View>: ViewModifier {
    @Binding private var isPresented: Bool {
        didSet { if !isPresented { onDismiss?() } }
    }
    
    @State private var offset: CGSize = .zero
    @State private var contentSize: CGSize = .zero {
        didSet { offset = contentSize }
    }
    
    private let options: DynamicSheetOptions
    private let sheetContent: SheetContent
    private let onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
    
        ZStack {
            content
                .disabled(isPresented)
            
            Color.black
                .opacity(isPresented ? 0.0001: 0)
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .onTapGesture {
                    isPresented.toggle() }
            
            GeometryReader { geometry in
                sheetContent
                    .cornerRadius(options.cornerRadius)
                    .onAppear { contentSize = geometry.size}
                    .padding(.bottom, 50)
                    .background(options.backgorundColor.frame(width: UIScreen.main.bounds.width, alignment: .bottom))
                    .offset(y: isPresented ? 0 : offset.height)
                    .frame(width: offset.width, height: offset.height, alignment: .bottom)
                    .transition(.move(edge: .bottom))
                    .animation(.snappy, value: isPresented)
            }
        }
        .animation(.snappy, value: isPresented)
        .gesture(DragGesture().onChanged { value in
            let height = contentSize.height + value.translation.height
            if height > contentSize.height { offset.height = height }
        }.onEnded { value in
            withAnimation(.snappy) {
                if value.translation.height > contentSize.height / 4 {
                    isPresented.toggle()
                    offset = contentSize
                } else {
                    offset = contentSize
                }
            }
        })
    }

    init(isPresented: Binding<Bool>, options: DynamicSheetOptions, onDismiss: (() -> Void)? = nil, backgorund color: Color = .primary, @ViewBuilder content: @escaping () -> SheetContent) {
        self.sheetContent = content()
        self.onDismiss = onDismiss
        self.options = options
        _isPresented = isPresented
    }
}

public extension Color {
    static let system: Color = Color(UIColor.secondarySystemGroupedBackground)
}

public extension View {
    ///Presents a Dynamic sheet when a biding to a Boolean vlaue that you provide is true.
    ///Dynamic sheet infers its height from the  content you provide
    func dynamicSheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content : @escaping () -> Content) -> some View {
        self.modifier(DynamicSheet(isPresented: isPresented, options: DynamicSheetOptions(), content: content))
    }
    
    ///Presents a Dynamic sheet when a biding to a Boolean vlaue that you provide is true.
    ///Dynamic sheet infers its height from the  content you provide
    func dynamicSheet<Content: View>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content : @escaping () -> Content) -> some View {
        self.modifier(DynamicSheet(isPresented: isPresented, options: DynamicSheetOptions(), onDismiss: onDismiss, content: content))
    }
    
    ///Presents a Dynamic sheet when a biding to a Boolean vlaue that you provide is true.
    ///Dynamic sheet infers its height from the  content you provide
    func dynamicSheet<Content: View>(isPresented: Binding<Bool>, options: DynamicSheetOptions, @ViewBuilder content : @escaping () -> Content) -> some View {
        self.modifier(DynamicSheet(isPresented: isPresented, options: options, content: content))
    }
    
    ///Presents a Dynamic sheet when a biding to a Boolean vlaue that you provide is true.
    ///Dynamic sheet infers its height from the  content you provide
    func dynamicSheet<Content: View>(isPresented: Binding<Bool>, options: DynamicSheetOptions, onDismiss: (() -> Void)? = nil, @ViewBuilder content : @escaping () -> Content) -> some View {
        self.modifier(DynamicSheet(isPresented: isPresented, options: options, onDismiss: onDismiss, content: content))
    }
    
}

