//
//  File.swift
//  ConcurrentMacro
//
//  Created by Omar Elsayed on 13/07/2026.
//

@attached(memberAttribute)
public macro Concurrent() = #externalMacro(module: "ConcurrentMacroMacros", type: "ConcurrentMacro")
