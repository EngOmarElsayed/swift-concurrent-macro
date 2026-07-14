//
//  ConcurrentMacroPlugin.swift
//  ConcurrentMacro
//
//  Created by Omar Elsayed on 14/07/2026.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ConcurrentMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ConcurrentMacro.self,
    ]
}
