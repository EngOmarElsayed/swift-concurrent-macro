# swift-concurrent-macro

**A Swift macro that keeps your heavy work off the main actor — automatically.**
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FEngOmarElsayed%2Fswift-concurrent-macro%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/EngOmarElsayed/swift-concurrent-macro)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FEngOmarElsayed%2Fswift-concurrent-macro%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/EngOmarElsayed/swift-concurrent-macro)
![Swift 6.2+](https://img.shields.io/badge/Swift-6.2+-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20|%20Linux-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

Add `@Concurrent` to a type, and every `async` method inside it gets the `@concurrent` attribute. No more annotating methods one by one, no more silently blocking the main actor because you forgot one.

```swift
@Concurrent
struct ImageCompressor {
  func compress(_ image: Data) async -> Data { ... }          // ✅ runs on the global concurrent executor
  private func encode(_ image: CGImage) async -> Data { ... } // ✅ this one too
}
```

## The Problem

Since Swift 6.2 ([SE-0461](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md), enabled via the `NonisolatedNonsendingByDefault` upcoming feature — part of Xcode's "Approachable Concurrency" setting), nonisolated `async` functions run on the **caller's actor** by default.

This is a great default for most code. But it has a sneaky side effect: if you call this from the main actor, all of its synchronous work now happens **on the main actor**.

```swift
struct ImageCompressor {
  func compress(_ image: Data) async -> Data {
    // Called from a SwiftUI view? Congratulations,
    // you're now compressing images on the main thread. 😅
  }
}
```

The fix is the `@concurrent` attribute, which guarantees the function runs on the global concurrent executor:

```swift
struct ImageCompressor {
  @concurrent func compress(_ image: Data) async -> Data { ... }
}
```

That works — until you have a type whose *entire purpose* is heavy CPU-bound work. Image compression, decoding large JSON payloads, hashing files, data processing in use cases. Now every single `async` method needs the annotation:

```swift
struct ImageCompressor {
  @concurrent func compress(_ image: Data) async -> Data { ... }
  @concurrent func resize(_ image: Data, to size: CGSize) async -> Data { ... }
  @concurrent private func encode(_ image: CGImage) async -> Data { ... }
}
```

Forget one, and there's no compiler error. No warning. Just heavy work quietly running on the main actor — exactly the performance bug the attribute exists to prevent.

## The Solution

One annotation on the type. Done.

```swift
@Concurrent
struct ImageCompressor {
  func compress(_ image: Data) async -> Data { ... }
  func resize(_ image: Data, to size: CGSize) async -> Data { ... }
  private func encode(_ image: CGImage) async -> Data { ... }
}
```

It works on `struct`, `class`, `enum` — and extensions, so you can scope it to just the part of a type that does the heavy lifting:

```swift
struct FetchDataUseCase { ... }

@Concurrent
extension FetchDataUseCase {
  // @concurrent is added only to async methods in this extension
  func process(_ response: Response) async -> Model { ... }
}
```

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/EngOmarElsayed/swift-concurrent-macro", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
  name: "YourTarget",
  dependencies: [
    .product(name: "ConcurrentMacro", package: "swift-concurrent-macro")
  ]
)
```

Or in Xcode: **File → Add Package Dependencies…** and paste the repo URL.

```swift
import ConcurrentMacro
```

## Requirements

- Swift 6.2+
- The `NonisolatedNonsendingByDefault` upcoming feature enabled (or Xcode's "Approachable Concurrency" setting, which includes it)

> **Note:** Without SE-0461's new behavior enabled, nonisolated `async` functions already run on the global concurrent executor, so this macro isn't doing anything you need. It exists specifically for codebases adopting Swift 6.2's new defaults.

## How It Works

The macro follows a few simple rules — no surprises:

| Rule | Behavior |
|---|---|
| **Only `async` methods** | Synchronous methods are untouched. `@concurrent` only changes where nonisolated `async` functions execute, so the macro skips sync methods entirely. |
| **Implies `nonisolated`** | `@concurrent` already implies `nonisolated`. Under `defaultIsolation = MainActor` (SE-0466), the annotated methods run on the global concurrent executor instead of the main actor. |
| **Explicit isolation wins** | Methods explicitly marked `@MainActor`, `nonisolated(nonsending)`, or with any other explicit isolation are skipped. Your per-method decisions always take priority. |
| **No actors** | Applying `@Concurrent` to an `actor` contradicts the whole point of actor isolation, so the macro emits a compile-time error. |

## When Should You Use This?

Be honest with yourself here: most async code doesn't need `@concurrent` at all. Functions that suspend immediately and wait (like network calls) don't block the caller's actor — the suspension already frees it.

Reach for `@Concurrent` when a type does **CPU-bound work between suspension points**:

- Image compression and processing pipelines
- Decoding large JSON payloads
- Hashing or encrypting files
- Data transformation in use cases after fetching from a backend

If that describes the whole type, annotate the type. If it describes one method, just use `@concurrent` directly — this package isn't trying to replace it.

## Background

This started as a [Swift Evolution pitch](https://forums.swift.org/t/pitch-concurrent-macro/87978). The feedback nudged it toward the package-first route — prove it in the ecosystem, evolve it freely, and maybe revisit stdlib inclusion later. So here we are.

Want to go deeper into Swift concurrency? I write full deep-dives on exactly these topics at swiftdifferently.com.

## Contributing

Found a bug? Have an idea? Issues and PRs are very welcome — that's the beauty of this being a package instead of the stdlib: we can actually fix things *today*. 😂

## License

swift-concurrent-macro is available under the MIT license. See [LICENSE](LICENSE) for details.

---

Made with ❤️ by [Omar Elsayed](https://swiftdifferently.com/about).
