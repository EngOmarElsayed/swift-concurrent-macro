//
//  ConcurrentMacroMacro.swift
//  ConcurrentMacro
//
//  Created by Omar Elsayed on 13/07/2026.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ConcurrentMacro: MemberAttributeMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AttributeSyntax] {
        guard !declaration.is(ActorDeclSyntax.self) else {
            return generateErrorDiagnostic(
                for: node,
                declaration: declaration,
                message: ConcurrentMacroDiagnostic.appliedToActor,
                in: context
            )
        }
        guard let funcDec = member.as(FunctionDeclSyntax.self) else { return [] }
        guard funcDec.signature.effectSpecifiers?.asyncSpecifier != nil else { return [] }
        guard !funcDec.hasModifier(named: "nonisolated") else { return [] }
        guard !funcDec.hasAttribute(named: "concurrent") else {
            return generateConcurrentAnnotationWaring(
                funcDec: funcDec,
                in: context
            )
        }


        return ["@concurrent"]
    }
}

// MARK: - Private Methods
private extension ConcurrentMacro {
    static func generateErrorDiagnostic(
        for node: SwiftSyntax.AttributeSyntax,
        declaration: some SwiftSyntax.DeclGroupSyntax,
        message: DiagnosticMessage,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) -> [SwiftSyntax.AttributeSyntax] {
        let newAttributes = declaration.attributes.filter { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription != "Concurrent" }

        context.diagnose(Diagnostic(
            node: node,
            message: message,
            fixIt: FixIt(
                message: ConcurrentMacroFixIt.removeAttribute,
                changes: [.replace(
                    oldNode: Syntax(declaration.attributes),
                    newNode: Syntax(newAttributes)
                )]
            )
        ))

        return []
    }

    static func generateConcurrentAnnotationWaring(
        funcDec: FunctionDeclSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) -> [SwiftSyntax.AttributeSyntax] {
        if let node = funcDec.attributeNode(named: "concurrent") {
            let cleanedAttributes = funcDec.removeAttribute(named: "concurrent")
            context.diagnose(Diagnostic(
                node: node,
                message: ConcurrentMacroDiagnostic.concurrentAlreadyAdded,
                fixIt: FixIt(
                    message: ConcurrentMacroFixIt.removeExtraConcurrentAnnotation,
                    changes: [.replace(
                        oldNode: Syntax(funcDec.attributes),
                        newNode: Syntax(cleanedAttributes)
                    )]
                )
            ))
        }

        return []
    }
}
