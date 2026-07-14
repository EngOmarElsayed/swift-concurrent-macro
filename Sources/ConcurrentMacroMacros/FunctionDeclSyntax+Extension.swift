//
//  File.swift
//  ConcurrentMacro
//
//  Created by Omar Elsayed on 14/07/2026.
//

import SwiftSyntax

extension FunctionDeclSyntax {
    func hasAttribute(named name: String) -> Bool {
        attributes.contains { element in
            guard case .attribute(let attribute) = element else { return false }

            // Common case: @MainActor
            if let identifier = attribute.attributeName.as(IdentifierTypeSyntax.self) {
                return identifier.name.text == name
            }

            // Qualified case: @_Concurrency.MainActor
            if let member = attribute.attributeName.as(MemberTypeSyntax.self) {
                return member.name.text == name
            }

            return false
        }
    }

    func hasModifier(named name: String) -> Bool {
        return modifiers.contains { $0.name.text == name }
    }

    func attributeNode(named name: String) -> AttributeSyntax? {
        for element in attributes {
            guard case .attribute(let attribute) = element else { continue }
            if attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text == name {
                return attribute
            }
        }
        return nil
    }

    func removeAttribute(named name: String) -> AttributeListSyntax {
        attributes.filter {
            guard case .attribute(let attr) = $0 else { return true }
            return attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text != name
        }
    }
}
