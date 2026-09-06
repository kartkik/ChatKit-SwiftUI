# ChatApp-SwiftUI

A iOS chat application demonstrating a **SwiftUI chat UI delivered as a local Swift Package** (`ChatKit`), integrated into a host app with clean MVVM architecture and simulated streaming responses via `AsyncStream`.

---

## 🎬 App Demo

<video src="assets/demo.mov" width="350" controls autoplay loop muted playsinline></video>

*[Click here if video preview is not available](assets/demo.mov)*

---


## ✨ Features

| Feature | Detail |
|---|---|
| 📦 **Swift Package** | `ChatKit` is a fully self-contained local Swift Package — reusable in any iOS project |
| 🌊 **Streaming responses** | `AsyncStream<String>` delivers tokens word-by-word, mimicking a real LLM |
| 🏗 **MVVM** | `ChatViewModel` (package) + `ChatScreenViewModel` (host app) with zero logic in views |
| 🎨 **Fully configurable UI** | Host app controls every color, title, greeting, and placeholder via `ChatConfig` |
| 💬 **Typing indicator** | Animated 3-dot indicator appears before the first token arrives |
| ⏹ **Stream cancellation** | Send button morphs into a Stop button; cancels the in-flight `Task` cleanly |
| 🔄 **Conversation reset** | Resets to the configured greeting without restarting the screen |
| ✅ **Unit tested** | 14 tests covering `ChatViewModel` state, streaming, cancel, and reset |
| ♿ **Accessible** | `accessibilityLabel` and `accessibilityHint` on all interactive elements |
| 📳 **Haptic feedback** | `sensoryFeedback(.impact)` fires on every send (iOS 17+) |
| 🌙 **Dark mode first** | Carefully designed dark theme with glassmorphism-inspired surfaces |
---

## 📐 Architecture

### Package boundary

```
Host App  ──imports──▶  ChatKit (Swift Package)
   │                         │
   │  injects service ──────▶│  ChatServiceProtocol   (contract)
   │  injects config  ──────▶│  ChatConfig            (UI knobs)
   │                         │  ChatViewModel         (all state)
   │                         │  ChatScreen / sub-views (pure UI)
   │
   └── ChatScreenViewModel   (owns config + service)
   └── AppChatService        (all response data)
   └── SplashView            (simple @State animation)
```

### MVVM layers

```
┌──────────────────────────────────────────────────────────────┐
│ Model          Message · Conversation                         │
│                Pure value types (struct, Sendable, Equatable) │
├──────────────────────────────────────────────────────────────┤
│ Service        ChatServiceProtocol (protocol)                 │
│                MockChatService     (package default)          │
│                AppChatService      (host app — all data here) │
├──────────────────────────────────────────────────────────────┤
│ ViewModel      ChatViewModel       (@MainActor, @Observable)  │
│                ChatScreenViewModel (host app — config + DI)   │
├──────────────────────────────────────────────────────────────┤
│ View           ChatScreen · MessageBubble · MessageInputBar   │
│                TypingIndicator · SplashView                   │
│                Zero business logic — observe VM, render only  │
└──────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
ChatApp-SwiftUI/
│
├── ChatApp-SwiftUI/                      Host App
│   ├── ChatApp_SwiftUIApp.swift          Root router (Splash → Chat)
│   ├── ViewModels/
│   │   └── ChatScreenViewModel.swift     Chat UI config + service injection
│   ├── Views/
│   │   ├── AppChatScreen.swift           Host app's root chat view
│   │   └── Splash/
│   │       └── SplashView.swift          @State-only splash animation
│   └── Services/
│       └── AppChatService.swift          All AI responses — edit here
│
└── ChatKit/                              Local Swift Package
    ├── Package.swift
    ├── Sources/ChatKit/
    │   ├── ChatConfig.swift              Public UI configuration struct
    │   ├── DesignSystem/
    │   │   └── ChatTheme.swift           Spacing, radii, default tokens
    │   ├── Models/
    │   │   ├── Message.swift
    │   │   └── Conversation.swift
    │   ├── Services/
    │   │   └── ChatService.swift         Protocol + MockChatService
    │   ├── ViewModels/
    │   │   └── ChatViewModel.swift       @MainActor @Observable VM
    │   └── Views/
    │       ├── ChatScreen.swift          Public entry point
    │       ├── MessageBubble.swift
    │       ├── MessageInputBar.swift
    │       └── TypingIndicator.swift
    └── Tests/ChatKitTests/
        └── ChatViewModelTests.swift      14 unit tests
```

---

## 📦 ChatKit — Deep Dive

ChatKit local Swift Package that exposes exactly **three public surfaces** to the host app. Everything else is internal.

### 1. `ChatScreen` — the only view you present

```swift
import ChatKit

// Minimal — uses package defaults
ChatScreen()

// Full control from the host app
ChatScreen(
    service: AppChatService(),   // your response engine
    config:  chatScreenVM.config // your visual theme
)
```

Internally `ChatScreen`:
- Creates and owns a `ChatViewModel` (injected via `@State`)
- Passes `ChatConfig` into the SwiftUI environment so every child view picks it up automatically — no prop drilling
- Renders a `NavigationStack` with a `LazyVStack` message list and a pinned `MessageInputBar`
- Auto-scrolls to the latest token on every `onChange`

---

### 2. `ChatConfig` — full UI control from the host app

Every visual and textual property is configurable. The host app sets these once in `ChatScreenViewModel`; ChatKit source never changes.

| Property | Type | Effect |
|---|---|---|
| `navigationTitle` | `String` | Nav bar title text |
| `showResetButton` | `Bool` | Show / hide the ↺ reset button |
| `greetingMessage` | `String` | First assistant message on open |
| `inputPlaceholder` | `String` | TextField hint text |
| `backgroundColor` | `Color` | Full-screen background |
| `userBubbleStartColor` | `Color` | User bubble gradient — top-leading |
| `userBubbleEndColor` | `Color` | User bubble gradient — bottom-trailing |
| `assistantBubbleColor` | `Color` | Assistant bubble fill |
| `accentColor` | `Color` | Send button, focus ring, highlights |
| `textPrimaryColor` | `Color` | Message body text |
| `textSecondaryColor` | `Color` | Timestamps, muted labels |
| `inputBarBackground` | `Color` | Text field background |
| `separatorColor` | `Color` | Dividers and bubble borders |

`ChatConfig` also exposes a computed `userBubbleGradient: LinearGradient` built from the two bubble colors — used internally by `MessageBubble` and the send button.

**Config is passed via the SwiftUI environment** inside `ChatScreen`, so `MessageBubble`, `MessageInputBar`, and `TypingIndicator` all read from `@Environment(\.chatConfig)` without any extra wiring.

---

### 3. `ChatServiceProtocol` — plug in any backend

```swift
public protocol ChatServiceProtocol: Sendable {
    func streamResponse(for prompt: String) -> AsyncStream<String>
}
```

Implement this in the host app to connect any AI backend — zero ChatKit changes required:

```swift
// Host app: Services/AppChatService.swift
final class AppChatService: ChatServiceProtocol {
    func streamResponse(for prompt: String) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                // keyword-matched responses, streamed token by token
                for token in tokenise(bestReply(for: prompt)) {
                    try? await Task.sleep(nanoseconds: ...)
                    continuation.yield(token)
                }
                continuation.finish()
            }
        }
    }
}
```

ChatKit also ships `MockChatService` as its built-in default — useful for SwiftUI Previews and unit tests.

---

### Internal models

```swift
// Message — value type, Sendable, Equatable
public struct Message: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let role: Role           // .user | .assistant
    public var text: String         // appended to during streaming
    public let timestamp: Date
    public var streamState: StreamState  // .streaming | .complete
}

// Conversation — wraps an ordered array of messages
public struct Conversation: Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var messages: [Message]
}
```

Both are **value types (structs)** so SwiftUI can efficiently diff the message list and only re-render changed rows.

---

### `ChatViewModel` state machine

```
inputText filled
       │
       ▼
  sendMessage()
       │
       ├─▶ append user Message (role: .user, streamState: .complete)
       │
       ├─▶ append assistant placeholder (role: .assistant, streamState: .streaming)
       │
       ├─▶ isStreaming = true
       │
       └─▶ for await token in service.streamResponse(for:) {
               messages[last].text += token   ← SwiftUI re-renders bubble live
           }
               │
               ▼
           streamState = .complete
           isStreaming = false
```

`cancelStreaming()` calls `task.cancel()` — the `for await` loop exits on the next `Task.isCancelled` check and the partial message is finalised as `.complete`.

`resetConversation()` calls `cancelStreaming()` then replaces the message array with just the greeting — no screen navigation or re-init needed.

---

## 🌊 Streaming Implementation

```swift
// ChatService.swift — inside ChatKit
public protocol ChatServiceProtocol: Sendable {
    func streamResponse(for prompt: String) -> AsyncStream<String>
}

// ChatViewModel.swift — consumes the stream
private func streamAssistantReply(for prompt: String) async {
    isStreaming = true
    let stream = service.streamResponse(for: prompt)
    for await token in stream {
        guard !Task.isCancelled else { break }
        conversation.messages[index].text += token
    }
    isStreaming = false
}
```

Tokens are yielded every **30–70 ms** with randomised jitter to feel organic. Cancellation is handled by checking `Task.isCancelled` inside the `for await` loop — no cleanup code needed.

---

## 🎨 Customising the UI (from the host app)

Open `ChatScreenViewModel.swift` and modify `config`. **ChatKit source never changes.**

```swift
var config: ChatConfig = ChatConfig(
    navigationTitle:      "My App",
    greetingMessage:      "Hi! How can I help?",
    userBubbleStartColor: Color(hex: "#34D399"),
    userBubbleEndColor:   Color(hex: "#059669"),
    accentColor:          Color(hex: "#10B981"),
    backgroundColor:      Color(hex: "#0A0A0F")
)
```

---

## 🧪 Running Tests

```bash
cd ChatKit
swift test
```

Or in Xcode: **Product → Test** (⌘U) with the `ChatKitTests` scheme selected.

### Test coverage

| Test | What it verifies |
|---|---|
| `test_initialState_hasGreeting` | VM starts with correct greeting message |
| `test_initialState_isNotStreaming` | `isStreaming` is `false` on init |
| `test_canSend_trueWhenInputHasText` | `canSend` is `true` with non-empty input |
| `test_canSend_falseWhenInputIsEmpty` | `canSend` is `false` for empty/whitespace |
| `test_sendMessage_appendsUserMessage` | User message appended immediately |
| `test_sendMessage_clearsInput` | `inputText` cleared after send |
| `test_sendMessage_doesNothingWithEmpty` | Guard prevents empty send |
| `test_sendMessage_streamingAddsAssistant` | Assistant message added after stream |
| `test_assistantResponseContainsText` | Streamed text appears in message |
| `test_cancelStreaming_setsFalse` | `isStreaming` false after cancel |
| `test_cancelStreaming_finalisesMessage` | Partial message marked `.complete` |
| `test_reset_restoresGreeting` | Single greeting message after reset |
| `test_reset_stopsStreaming` | `isStreaming` false after reset |
| `test_canSend_falseWhenWhitespace` | Whitespace-only blocked |

---

## 📋 Requirements

| Requirement | Status |
|---|---|
| SwiftUI chat screen | ✅ |
| Delivered as Swift Package | ✅ |
| Host app integration | ✅ |
| Streaming via async/await | ✅ (`AsyncStream<String>`) |
| MVVM architecture | ✅ |
| Clean package / host app separation | ✅ |

---

## 🛠 Tech Stack

- **Language**: Swift 5.9  
- **UI**: SwiftUI  
- **Concurrency**: Swift Concurrency (`async/await`, `AsyncStream`, `Task`)  
- **Architecture**: MVVM with `@Observable` (iOS 17 macro)  
- **Packaging**: Swift Package Manager (local package)  
- **Minimum deployment**: iOS 17  
- **Toolchain**: Xcode 26  
