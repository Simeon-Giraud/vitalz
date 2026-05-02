import XCTest

final class VitalzUITests: XCTestCase {
    func testCaptureScreenshots() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Take a screenshot of the main dashboard
        let dashboardScreenshot = app.screenshot()
        let dashboardAttachment = XCTAttachment(screenshot: dashboardScreenshot)
        dashboardAttachment.name = "Dashboard_Initial"
        dashboardAttachment.lifetime = .keepAlways
        add(dashboardAttachment)
        
        // If there's a Milestones tab, navigate and take another
        let milestonesTab = app.tabBars.buttons["Milestones"]
        if milestonesTab.exists {
            milestonesTab.tap()
            let milestonesScreenshot = app.screenshot()
            let milestonesAttachment = XCTAttachment(screenshot: milestonesScreenshot)
            milestonesAttachment.name = "Milestones_View"
            milestonesAttachment.lifetime = .keepAlways
            add(milestonesAttachment)
        }
    }
}
