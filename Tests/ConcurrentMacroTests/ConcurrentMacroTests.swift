import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ConcurrentMacroMacros)
import ConcurrentMacroMacros

let testMacros: [String: Macro.Type] = [
    "Concurrent": ConcurrentMacro.self,
]
#endif

final class ConcurrentMacroTests: XCTestCase {

    // MARK: - Adding @concurrent

    func testAddsConcurrentToAsyncMethodInClass() throws {
        #if canImport(ConcurrentMacroMacros)
        assertMacroExpansion(
            """
            @Concurrent
            class Service {
                func fetch() async {
                }
            }
            """,
            expandedSource: """
            class Service {
                @concurrent
                func fetch() async {
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAddsConcurrentToAsyncMethodInStruct() throws {
        #if canImport(ConcurrentMacroMacros)
        assertMacroExpansion(
            """
            @Concurrent
            struct Service {
                func fetch() async {
                }
            }
            """,
            expandedSource: """
            struct Service {
                @concurrent
                func fetch() async {
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAddsConcurrentToAsyncMethodInEnum() throws {
        #if canImport(ConcurrentMacroMacros)
        assertMacroExpansion(
            """
            @Concurrent
            enum Service {
                static func fetch() async {
                }
            }
            """,
            expandedSource: """
            enum Service {
                @concurrent
                static func fetch() async {
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testAddsConcurrentToAsyncThrowsMethod() throws {
        #if canImport(ConcurrentMacroMacros)
        assertMacroExpansion(
            """
            @Concurrent
            class Service {
                func fetch() async throws -> String {
                    ""
                }
            }
            """,
            expandedSource: """
            class Service {
                @concurrent
                func fetch() async throws -> String {
                    ""
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testOnlyAsyncMethodsGetConcurrentInMixedType() throws {
        #if canImport(ConcurrentMacroMacros)
        assertMacroExpansion(
            """
            @Concurrent
            class Service {
                var count = 0

                func sync() {
                }

                func fetch() async {
                }
            }
            """,
            expandedSource: """
            class Service {
                var count = 0

                func sync() {
                }
                @concurrent

                func fetch() async {
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Members left untouched

    func testDoesNotAddConcurrentToNonAsyncMethod() throws {
        #if canImport(ConcurrentMacroMacros)
        assertMacroExpansion(
            """
            @Concurrent
            class Service {
                func compute() -> Int {
                    0
                }
            }
            """,
            expandedSource: """
            class Service {
                func compute() -> Int {
                    0
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testDoesNotAddConcurrentToNonisolatedAsyncMethod() throws {
        #if canImport(ConcurrentMacroMacros)
        assertMacroExpansion(
            """
            @Concurrent
            class Service {
                nonisolated func fetch() async {
                }
            }
            """,
            expandedSource: """
            class Service {
                nonisolated func fetch() async {
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testDoesNotAnnotateStoredProperties() throws {
        #if canImport(ConcurrentMacroMacros)
        assertMacroExpansion(
            """
            @Concurrent
            class Service {
                var count = 0
            }
            """,
            expandedSource: """
            class Service {
                var count = 0
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Actor diagnostic

    func testAppliedToActorEmitsErrorAndAddsNothing() throws {
        #if canImport(ConcurrentMacroMacros)
        assertMacroExpansion(
            """
            @Concurrent
            actor Worker {
                func fetch() async {
                }
            }
            """,
            expandedSource: """
            actor Worker {
                func fetch() async {
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'@Concurrent' cannot be applied to an actor; actor methods are isolated to the actor and '@concurrent' shouldn't be applied",
                    line: 1,
                    column: 1,
                    severity: .error,
                    fixIts: [
                        FixItSpec(message: "Remove '@Concurrent'")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Redundant @concurrent diagnostic

    func testExistingConcurrentAnnotationEmitsWarningAndAddsNothing() throws {
        #if canImport(ConcurrentMacroMacros)
        assertMacroExpansion(
            """
            @Concurrent
            class Service {
                @concurrent
                func fetch() async {
                }
            }
            """,
            expandedSource: """
            class Service {
                @concurrent
                func fetch() async {
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "'@concurrent' is redundant here; '@Concurrent' on the enclosing type already applies it to this method",
                    line: 3,
                    column: 5,
                    severity: .warning,
                    fixIts: [
                        FixItSpec(message: "Remove '@concurrent' annotation")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
