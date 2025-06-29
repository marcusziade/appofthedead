import XCTest
@testable import aotd

final class BookReaderViewModelTests: XCTestCase {
    
    var databaseManager: DatabaseManager!
    var sut: BookReaderViewModel!
    var testBook: Book!
    var testUserId: String!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory database for testing
        databaseManager = DatabaseManager(inMemory: true)
        testUserId = "test-user-123"
        
        // Create test book with proper IDs
        let bookId = UUID().uuidString
        let chapters = [
            Chapter(
                id: UUID().uuidString,
                bookId: bookId,
                chapterNumber: 1,
                title: "Chapter 1",
                content: String(repeating: "Lorem ipsum dolor sit amet. ", count: 100),
                wordCount: 400
            ),
            Chapter(
                id: UUID().uuidString,
                bookId: bookId,
                chapterNumber: 2,
                title: "Chapter 2",
                content: String(repeating: "Consectetur adipiscing elit. ", count: 100),
                wordCount: 400
            )
        ]
        
        testBook = Book(
            id: bookId,
            beliefSystemId: "buddhism",
            title: "Test Book",
            author: "Test Author",
            coverImageName: nil,
            chapters: chapters,
            totalWords: 800,
            estimatedReadingTime: 5,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // Save book to database
        do {
            try databaseManager.saveBook(testBook)
        } catch {
            XCTFail("Failed to save test book: \(error)")
        }
    }
    
    override func tearDown() {
        sut = nil
        databaseManager = nil
        testBook = nil
        testUserId = nil
        super.tearDown()
    }
    
    func testInitialBookProgressCreation() {
        // Given & When
        sut = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        
        // Then
        XCTAssertEqual(sut.currentChapterIndex, 0)
        XCTAssertEqual(sut.readingProgress, 0.0)
        XCTAssertEqual(sut.totalReadingTime, 0.0)
        XCTAssertFalse(sut.hasBookmarkAtCurrentPosition)
    }
    
    func testDeferredScrollPositionPersistence() {
        // Given - Create initial view model
        sut = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        XCTAssertEqual(sut.preferences.scrollPosition, 0.0, "Initial scroll position should be 0")
        
        // When - Update scroll position WITHOUT saving
        sut.updateScrollPosition(0.5)
        XCTAssertEqual(sut.preferences.scrollPosition, 0.5, "Scroll position should be updated in memory")
        
        // Verify changes are NOT saved yet
        let newViewModelBeforeSave = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        XCTAssertEqual(newViewModelBeforeSave.preferences.scrollPosition, 0.0, "Scroll position should NOT be persisted without saveAll()")
        
        // When - Save explicitly
        sut.saveAll()
        
        // Then - Create new view model and verify persistence
        let newViewModelAfterSave = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        XCTAssertEqual(newViewModelAfterSave.preferences.scrollPosition, 0.5, "Scroll position should be persisted after saveAll()")
    }
    
    func testChapterNavigationResetsScrollPosition() {
        // Given
        sut = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        sut.updateScrollPosition(0.5)
        
        // When - Navigate to next chapter
        sut.goToNextChapter()
        
        // Then - Scroll position should be reset
        XCTAssertEqual(sut.currentChapterIndex, 1)
        XCTAssertEqual(sut.preferences.scrollPosition, 0.0)
    }
    
    func testReadingProgressCalculation() {
        // Given
        sut = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        
        // When - Read 50% of first chapter
        sut.updateScrollPosition(0.5)
        
        // Then - Overall progress should be 25% (50% of first chapter, which is 1/2 of book)
        XCTAssertEqual(sut.readingProgress, 0.25, accuracy: 0.01)
        
        // When - Move to second chapter
        sut.goToNextChapter()
        sut.updateScrollPosition(0.5)
        
        // Then - Overall progress should be 75% (100% of first + 50% of second)
        XCTAssertEqual(sut.readingProgress, 0.75, accuracy: 0.01)
    }
    
    func testBookmarkToggle() {
        // Given
        sut = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        
        // When - Add bookmark
        sut.toggleBookmark()
        
        // Then
        XCTAssertTrue(sut.hasBookmarkAtCurrentPosition)
        
        // When - Remove bookmark
        sut.toggleBookmark()
        
        // Then
        XCTAssertFalse(sut.hasBookmarkAtCurrentPosition)
    }
    
    func testDeferredReadingTimePersistence() {
        // Given
        sut = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        
        // When - Increment reading time without saving
        for _ in 0..<60 {
            sut.incrementReadingTime()
        }
        
        // Then - Time should be updated in memory
        XCTAssertEqual(sut.totalReadingTime, 60.0)
        
        // Verify changes are NOT saved yet
        let newViewModelBeforeSave = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        XCTAssertEqual(newViewModelBeforeSave.totalReadingTime, 0.0, "Reading time should NOT be persisted without saveAll()")
        
        // When - Save explicitly
        sut.saveAll()
        
        // Then - Create new view model and verify persistence
        let newViewModelAfterSave = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        XCTAssertEqual(newViewModelAfterSave.totalReadingTime, 60.0, "Reading time should be persisted after saveAll()")
    }
    
    func testBookCompletionImmediateSave() {
        // Given
        sut = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        
        // Create user for XP tracking
        do {
            _ = try databaseManager.createUser(name: "test", email: "test@test.com")
        } catch {
            // User might already exist
        }
        
        // When - Navigate to last chapter and read most of it
        sut.goToNextChapter()
        sut.updateScrollPosition(0.96)
        
        // Then - Book completion should be saved immediately (not deferred)
        let newViewModel = BookReaderViewModel(book: testBook, userId: testUserId, databaseManager: databaseManager)
        let progress = try? databaseManager.getBookProgress(userId: testUserId, bookId: testBook.id)
        
        XCTAssertNotNil(progress)
        XCTAssertTrue(progress?.isCompleted ?? false, "Book completion should be saved immediately")
        XCTAssertEqual(progress?.readingProgress ?? 0, 1.0, accuracy: 0.01)
    }
}