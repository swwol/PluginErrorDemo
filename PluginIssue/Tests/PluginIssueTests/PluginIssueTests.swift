@testable import PluginIssue
import PluginIssueMocks
import XCTest

final class PluginIssueTests: XCTestCase {
    func testSomething() throws {
     let mock = SomethingToMockMock()
      mock.given(.something(willReturn: "something"))
      XCTAssertEqual(mock.something(), "something")
    }
}
