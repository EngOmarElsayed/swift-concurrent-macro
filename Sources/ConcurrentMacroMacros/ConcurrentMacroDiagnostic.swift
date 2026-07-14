//
//  ConcurrentMacroDiagnostic.swift
//  ConcurrentMacro
//
//  Created by Omar Elsayed on 13/07/2026.
//

import SwiftDiagnostics

// MARK: -ConcurrentMacroDiagnostic
enum ConcurrentMacroDiagnostic: String, DiagnosticMessage {
    case appliedToActor
    case concurrentAlreadyAdded

    var message: String {
        switch self {
        case .appliedToActor:
            "'@Concurrent' cannot be applied to an actor; actor methods are isolated to the actor and '@concurrent' shouldn't be applied"
        case .concurrentAlreadyAdded:
            "'@concurrent' is redundant here; '@Concurrent' on the enclosing type already applies it to this method"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "ConcurrentMacro", id: rawValue)
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .appliedToActor:
                return .error
        case .concurrentAlreadyAdded:
            return .warning
        }
    }
}

// MARK: -ConcurrentMacroFixIt
enum ConcurrentMacroFixIt: String, FixItMessage {
    case removeAttribute
    case removeExtraConcurrentAnnotation

    var message: String {
        switch self {
        case .removeAttribute:
            "Remove '@Concurrent'"
        case .removeExtraConcurrentAnnotation:
            "Remove '@concurrent' annotation"
        }
    }
    var fixItID: MessageID { MessageID(domain: "ConcurrentMacro", id: rawValue) }
}
