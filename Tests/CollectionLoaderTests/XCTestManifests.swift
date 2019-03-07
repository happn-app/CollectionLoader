import XCTest

extension CollectionLoaderTests {
    static let __allTests = [
        ("testExample", testExample),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CollectionLoaderTests.__allTests),
    ]
}
#endif
