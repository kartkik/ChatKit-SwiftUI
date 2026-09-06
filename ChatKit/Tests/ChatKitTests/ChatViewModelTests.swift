// ChatViewModelTests.swift
// ChatKitTests
//
// Unit tests for ChatViewModel — the core of ChatKit's business logic.
// Tests focus on: message lifecycle, streaming state, send guards, and reset.

import XCTest
@testable import ChatKit

// MARK: - Instant mock for fast tests (0-delay streaming)

private final class InstantMockService: ChatServiceProtocol {
    let response: String
    init(response: String = "Test response") {
        self.response = response
    }

    func streamResponse(for prompt: String) -> AsyncStream<String> {
        let words = response.split(separator: " ").map(String.init)
        return AsyncStream { continuation in
            Task {
                for word in words {
                    continuation.yield(word + " ")
                }
                continuation.finish()
            }
        }
    }
}

// MARK: - Tests

@MainActor
final class ChatViewModelTests: XCTestCase {

    // MARK: - Initial state

    func test_initialState_hasGreeting() {
        let vm = ChatViewModel(greeting: "Welcome!")
        XCTAssertEqual(vm.conversation.messages.count, 1)
        XCTAssertEqual(vm.conversation.messages[0].role, .assistant)
        XCTAssertEqual(vm.conversation.messages[0].text, "Welcome!")
        XCTAssertEqual(vm.conversation.messages[0].streamState, .complete)
    }

    func test_initialState_isNotStreaming() {
        let vm = ChatViewModel()
        XCTAssertFalse(vm.isStreaming)
    }

    func test_initialState_emptyInput() {
        let vm = ChatViewModel()
        XCTAssertEqual(vm.inputText, "")
    }

    // MARK: - canSend computed property

    func test_canSend_trueWhenInputHasTextAndNotStreaming() {
        let vm = ChatViewModel()
        vm.inputText = "Hello"
        XCTAssertTrue(vm.canSend)
    }

    func test_canSend_falseWhenInputIsEmpty() {
        let vm = ChatViewModel()
        vm.inputText = ""
        XCTAssertFalse(vm.canSend)
    }

    func test_canSend_falseWhenInputIsWhitespaceOnly() {
        let vm = ChatViewModel()
        vm.inputText = "   \n  "
        XCTAssertFalse(vm.canSend)
    }

    // MARK: - sendMessage

    func test_sendMessage_appendsUserMessageImmediately() {
        let vm = ChatViewModel(service: InstantMockService())
        vm.inputText = "Test message"
        vm.sendMessage()

        XCTAssertEqual(vm.conversation.messages.count, 2)
        XCTAssertEqual(vm.conversation.messages[1].role, .user)
        XCTAssertEqual(vm.conversation.messages[1].text, "Test message")
    }

    func test_sendMessage_clearsInputAfterSend() {
        let vm = ChatViewModel(service: InstantMockService())
        vm.inputText = "Hello"
        vm.sendMessage()
        XCTAssertEqual(vm.inputText, "")
    }

    func test_sendMessage_doesNothingWithEmptyInput() {
        let vm = ChatViewModel(service: InstantMockService(), greeting: "Hi")
        vm.inputText = "   "
        vm.sendMessage()
        XCTAssertEqual(vm.conversation.messages.count, 1) // only greeting
    }

    func test_sendMessage_streamingResponseAddsAssistantMessage() async throws {
        let vm = ChatViewModel(service: InstantMockService(response: "Hello world"))
        vm.inputText = "Ping"
        vm.sendMessage()

        // Allow streaming to complete
        try await Task.sleep(for: .milliseconds(300))

        XCTAssertGreaterThanOrEqual(vm.conversation.messages.count, 3)
        XCTAssertEqual(vm.conversation.messages.last?.role, .assistant)
        XCTAssertEqual(vm.conversation.messages.last?.streamState, .complete)
    }

    func test_sendMessage_assistantResponseContainsExpectedText() async throws {
        let vm = ChatViewModel(service: InstantMockService(response: "pong"))
        vm.inputText = "ping"
        vm.sendMessage()

        try await Task.sleep(for: .milliseconds(300))

        let lastText = vm.conversation.messages.last?.text ?? ""
        XCTAssertTrue(lastText.contains("pong"))
    }

    // MARK: - cancelStreaming

    func test_cancelStreaming_setsIsStreamingFalse() {
        let vm = ChatViewModel(service: MockChatService())
        vm.inputText = "Go"
        vm.sendMessage()           // starts streaming
        vm.cancelStreaming()       // cancel immediately
        XCTAssertFalse(vm.isStreaming)
    }

    func test_cancelStreaming_finalisesLastMessage() {
        let vm = ChatViewModel(service: MockChatService())
        vm.inputText = "Go"
        vm.sendMessage()
        vm.cancelStreaming()

        // The partial assistant message (if any) should be marked complete
        if let last = vm.conversation.messages.last, last.role == .assistant {
            XCTAssertEqual(last.streamState, .complete)
        }
    }

    // MARK: - resetConversation

    func test_reset_restoresGreeting() {
        let vm = ChatViewModel(service: InstantMockService(), greeting: "Hello!")
        vm.inputText = "Hi"
        vm.sendMessage()
        vm.resetConversation()

        XCTAssertEqual(vm.conversation.messages.count, 1)
        XCTAssertEqual(vm.conversation.messages[0].text, "Hello!")
        XCTAssertEqual(vm.conversation.messages[0].role, .assistant)
    }

    func test_reset_stopsStreaming() {
        let vm = ChatViewModel(service: MockChatService())
        vm.inputText = "Hello"
        vm.sendMessage()
        vm.resetConversation()
        XCTAssertFalse(vm.isStreaming)
    }
}
