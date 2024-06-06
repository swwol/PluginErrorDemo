@testable import SwiftGenDemoProject
import XCTest

final class SwiftGenDemoProjectTests: XCTestCase {

    func testExample() throws {
      XCTAssertEqual(L10n.projectString1, "Project String 1")
      XCTAssertEqual(L10n.projectString3, "Project String 3")
    }
}
