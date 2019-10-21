//
//  M2Tests.swift
//  M2Tests
//
//  Created by Vincent Friedrich on 17.02.19.
//  Copyright © 2019 neoxapps. All rights reserved.
//

import XCTest
@testable import M2

class BackendWorkerTests: XCTestCase {
    
    let testUser = User(id: UUID(uuidString: "CD0DEB93-B129-411A-B9D6-2FA11ECC6352") ?? UUID(),
                        username: "test",
                        password: "test")
    let testUser2 = User(id: UUID(uuidString: "5D05B202-93AB-4627-9B04-DBD33039AD8B") ?? UUID(),
                         username: "test2",
                         password: "test2")
    
    static var friendsRequest: FriendsRequestResponse?
    
    func testA_RegisterUser() {
        let expectation1 = XCTestExpectation(description: "Register user")
        let expectation2 = XCTestExpectation(description: "Check for registered user")

        let registerRequest = UserEndpoint.register(id: testUser.id.uuidString,
                                                    username: testUser.username,
                                                    password: testUser.password)
        BackendWorker.shared.request(registerRequest) { (result: Result<Bool, Error>) in
            guard let success = try? result.get() else { return }
            
            XCGLogger.default.debug(success)
            
            XCTAssert(success)
            expectation1.fulfill()
            
            
            let checkUserRequest = UserEndpoint.checkUsername(username: self.testUser.username)
            BackendWorker.shared.request(checkUserRequest) { (result: Result<CheckUsernameResponse, Error>) in
                guard let response = try? result.get() else { return }
                
                XCGLogger.default.debug(response)
                
                XCTAssertFalse(response.isAvailable)
                expectation2.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 5)
    }
    
    func testB_RegisterUser2() {
        let expectation1 = XCTestExpectation(description: "Register user 2")
        let expectation2 = XCTestExpectation(description: "Check for registered user 2")
        
        let registerRequest = UserEndpoint.register(id: testUser2.id.uuidString,
                                                    username: testUser2.username,
                                                    password: testUser2.password)
        BackendWorker.shared.request(registerRequest) { [weak self] (result: Result<Bool, Error>) in
            guard let self = self, let success = try? result.get() else { return }
            
            XCGLogger.default.debug(success)
            
            XCTAssert(success)
            expectation1.fulfill()
            
            let checkUserRequest = UserEndpoint.checkUsername(username: self.testUser2.username)
            BackendWorker.shared.request(checkUserRequest) { (result: Result<CheckUsernameResponse, Error>) in
                guard let response = try? result.get() else { return }
                
                XCGLogger.default.debug(response)
                
                XCTAssertFalse(response.isAvailable)
                expectation2.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 5)
    }
    
    func testC_SendFriendsRequest() {
        let expectation1 = XCTestExpectation(description: "Send friends request")
        let expectation2 = XCTestExpectation(description: "Check friends request")

        let request = FriendsRequestsEndpoint.sendFriendsRequests(requester: testUser.username,
                                                                  receiver: testUser2.username)
        BackendWorker.shared.request(request) { [weak self] (result: Result<Bool, Error>) in
            guard let self = self, let success = try? result.get() else { return }
            
            XCGLogger.default.debug(success)
            
            XCTAssert(success)
            expectation1.fulfill()
            
            let getFriendsRequests = FriendsRequestsEndpoint.getFriendsRequests(requester: self.testUser2.username)
            BackendWorker.shared.request(getFriendsRequests) { (result: Result<[FriendsRequestResponse], Error>) in
                guard let response = try? result.get() else { return }
                guard let entry = response.filter({ $0.receiver == self.testUser2.username }).first else {
                    XCTAssert(false)
                    return
                }
                
                XCGLogger.default.debug(entry)
                
                XCTAssert(entry.requester == self.testUser.username)
                XCTAssert(entry.receiver == self.testUser2.username)
                XCTAssert(entry.state == .unanswered)
                expectation2.fulfill()
                
                BackendWorkerTests.friendsRequest = entry
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 5)
    }
    
    func testD_GetFriendsRequestsAvailable() {
        guard let friendsRequest = BackendWorkerTests.friendsRequest else {
            XCTAssert(false)
            return
        }

        let expectation = XCTestExpectation(description: "Get friends requests avaliable")
        
        let request = FriendsRequestsEndpoint.getFriendsRequests(requester: friendsRequest.receiver)
        BackendWorker.shared.request(request) { (result: Result<[FriendsRequestResponse], Error>) in
            guard let response = try? result.get() else { return }
            guard let entry = response.filter({ $0.id == friendsRequest.id }).first else {
                XCTAssert(false)
                return
            }
            
            XCGLogger.default.debug(entry)
            
            XCTAssert(entry.requester == friendsRequest.requester)
            XCTAssert(entry.receiver == friendsRequest.receiver)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testE_GetChatsEmpty() {
        let expectation = XCTestExpectation(description: "Get chats empty")

        let request = ChatEndpoint.getChats(requester: testUser.username)
        BackendWorker.shared.request(request) { (result: Result<[FriendsRequestResponse], Error>) in
            guard let response = try? result.get() else { return }
            
            XCGLogger.default.debug(response)
            
            XCTAssert(response.isEmpty)
            
            expectation.fulfill()
        }
    }
    
    func testF_AnswerFriendsRequests() {
        guard let friendsRequest = BackendWorkerTests.friendsRequest else {
            XCTAssert(false)
            return
        }
        
        let expectation = XCTestExpectation(description: "Answer friends request declined")
        
        let request = FriendsRequestsEndpoint.answerFriendsRequests(id: friendsRequest.id,
                                                                    requester: friendsRequest.requester,
                                                                    state: .accepted)
        BackendWorker.shared.request(request) { (result: Result<[FriendsRequestResponse], Error>) in
            guard let response = try? result.get() else { return }
            guard let entry = response.filter({ $0.id == friendsRequest.id }).first else {
                XCTAssert(false)
                return
            }
            
            XCGLogger.default.debug(entry)
            
            XCTAssert(entry.state == .accepted)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testG_GetFriendsRequestsEmpty() {
        guard let friendsRequest = BackendWorkerTests.friendsRequest else {
            XCTAssert(false)
            return
        }
        
        let expectation = XCTestExpectation(description: "Get friends requests empty")
        
        let request = FriendsRequestsEndpoint.getFriendsRequests(requester: friendsRequest.receiver)
        BackendWorker.shared.request(request) { (result: Result<[FriendsRequestResponse], Error>) in
            guard let response = try? result.get() else { return }
            
            XCGLogger.default.debug(response)
            
            XCTAssert(response.isEmpty)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testH_GetChatsAvailable() {
        let expectation = XCTestExpectation(description: "Get chats available")
        
        let request = ChatEndpoint.getChats(requester: testUser.username)
        BackendWorker.shared.request(request) { [weak self] (result: Result<[FriendsRequestResponse], Error>) in
            guard let self = self, let response = try? result.get() else { return }
            guard let entry = response.filter({ $0.requester == self.testUser.username && $0.receiver == self.testUser2.username }).first else {
                XCTAssert(false)
                return
            }
            
            XCGLogger.default.debug(entry)
            
            XCTAssert(entry.state == .accepted)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testI_GetChatsAvailableInverted() {
        let expectation = XCTestExpectation(description: "Get chats available inverted")
        
        let request = ChatEndpoint.getChats(requester: testUser2.username)
        BackendWorker.shared.request(request) { [weak self] (result: Result<[FriendsRequestResponse], Error>) in
            guard let self = self, let response = try? result.get() else { return }
            guard let entry = response.filter({ $0.requester == self.testUser.username && $0.receiver == self.testUser2.username }).first else {
                XCTAssert(false)
                return
            }
            
            XCGLogger.default.debug(entry)
            
            XCTAssert(entry.state == .accepted)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testJ_DeleteFriendsRequest() {
        guard let friendsRequest = BackendWorkerTests.friendsRequest else {
            XCTAssert(false)
            return
        }
        
        let expectation1 = XCTestExpectation(description: "Delete friends request")
        let expectation2 = XCTestExpectation(description: "Check no friends requests available")

        let deleteRequest = FriendsRequestsEndpoint.deleteFriendsRequest(id: friendsRequest.id, requester: testUser.username)
        BackendWorker.shared.request(deleteRequest) { (result: Result<Bool, Error>) in
            guard let success = try? result.get() else { return }
            
            XCGLogger.default.debug(success)
            
            XCTAssert(success)
            expectation1.fulfill()
            
            let request = FriendsRequestsEndpoint.getFriendsRequests(requester: friendsRequest.receiver)
            BackendWorker.shared.request(request) { (result: Result<[FriendsRequestResponse], Error>) in
                guard let response = try? result.get() else { return }
                
                XCGLogger.default.debug(response)
                
                XCTAssert(response.isEmpty)
                expectation2.fulfill()
            }
        }
        
        wait(for: [expectation1, expectation2], timeout: 5)
        
        addTeardownBlock {
            BackendWorkerTests.friendsRequest = nil
        }
    }

    func testK_DeleteUser() {
        let expectation = XCTestExpectation(description: "Delete user")
        
        let registerRequest = UserEndpoint.register(id: testUser.id.uuidString,
                                                    username: testUser.username,
                                                    password: testUser.password)
        BackendWorker.shared.request(registerRequest) { [weak self] (result: Result<Bool, Error>) in
            guard let self = self else { return }
            
            let deleteUserRequest = UserEndpoint.deleteUser(id: self.testUser.id.uuidString,
                                                            username: self.testUser.username,
                                                            password: self.testUser.password)
            BackendWorker.shared.request(deleteUserRequest) { (result: Result<Bool, Error>) in
                guard let response = try? result.get() else { return }
                
                XCGLogger.default.debug(response)
                
                XCTAssert(response)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testL_DeleteUser2() {
        let expectation = XCTestExpectation(description: "Delete user 2")
        
        let registerRequest = UserEndpoint.register(id: testUser2.id.uuidString,
                                                    username: testUser2.username,
                                                    password: testUser2.password)
        BackendWorker.shared.request(registerRequest) { [weak self] (result: Result<Bool, Error>) in
            guard let self = self else { return }
            
            let deleteUserRequest = UserEndpoint.deleteUser(id: self.testUser2.id.uuidString,
                                                            username: self.testUser2.username,
                                                            password: self.testUser2.password)
            BackendWorker.shared.request(deleteUserRequest) { (result: Result<Bool, Error>) in
                guard let response = try? result.get() else { return }
                
                XCGLogger.default.debug(response)
                
                XCTAssert(response)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testM_UploadVoiceMemo() {
        let testBundle = Bundle(for: type(of: self))
        
        guard let fileURL = testBundle.url(forResource: "test", withExtension: "m4a"),
            let uploadData = try? Data(contentsOf: fileURL) else { return }
        
        let expectation = XCTestExpectation(description: "Upload voice memo")
        
        let fileName = fileURL.lastPathComponent
        let mimeType = "audio/x-m4a"
        
        let uploadRequest = VoiceMemoEndpoint.uploadMemo(id: "1", owner: testUser.username)
        
        BackendWorker.shared.upload(endpoint: uploadRequest, fileName: fileName, mimeType: mimeType, data: uploadData) { progress in
            XCGLogger.default.debug("Upload progress \(progress.fractionCompleted)")
            
            if progress.fractionCompleted == 1.0 {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testN_GetMemo() {
        let expectation = XCTestExpectation(description: "Get voice memo")
        
        let getMemoRequest = VoiceMemoEndpoint.getMemo(id: "1")
        
        BackendWorker.shared.request(getMemoRequest) { [weak self] (result: Result<GetMemoResponse, Error>) in
            guard let self = self, let response = try? result.get() else { return }
            XCTAssert(response.owner == self.testUser.username)
            XCTAssert(response.messageId == "1")
            XCTAssert(response.filename == "/Applications/MAMP/htdocs/m2/voice_memos/test.m4a")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testO_DownloadMemo() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory.path)
            for filePath in filePaths {
                try FileManager.default.removeItem(atPath: documentsDirectory.appendingPathComponent(filePath).path)
                XCTAssert(true)
            }
        } catch {
            XCTAssert(false)
        }
        
        let expectation = XCTestExpectation(description: "Download voice memo")
        let expectation2 = XCTestExpectation(description: "Download exists in filemanager")

        let id = "2AE11029-FBBF-440B-84DA-D6B8AE58BAD3"
        let downloadMemoRequest = VoiceMemoEndpoint.downloadMemo(id: id)
        
        BackendWorker.shared.download(downloadMemoRequest) { (result: Result<Data, Error>) in
            switch result {
            case .success:
                expectation.fulfill()
                
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory.path)
                    XCGLogger.default.debug("contents of directory  \(contents)")
                    
                    if FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("\(id).m4a").path) {
                        expectation2.fulfill()
                    }
                } catch (let error) {
                    XCGLogger.default.debug("error: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                XCGLogger.default.debug("error: \(error.localizedDescription)")
            }
        }
        
        wait(for: [expectation, expectation2], timeout: 5)
    }
    
    func testP_DeleteMemo() {
        let expectation = XCTestExpectation(description: "Delete voice memo")
        let expectation2 = XCTestExpectation(description: "Get deleted voice memo")

        let deleteMemoRequest = VoiceMemoEndpoint.deleteMemo(id: "1", owner: testUser.username)
        
        BackendWorker.shared.request(deleteMemoRequest) { (result: Result<Bool, Error>) in
            guard let success = try? result.get() else { return }
            XCTAssert(success)
            
            let getMemoRequest = VoiceMemoEndpoint.getMemo(id: "1")
            
            BackendWorker.shared.request(getMemoRequest) { (result: Result<GetMemoResponse, Error>) in
                if case .failure(let error as NSError) = result {
                    XCTAssert(error.code == 615)
                }
                
                expectation2.fulfill()
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation, expectation2], timeout: 5)
    }
}
