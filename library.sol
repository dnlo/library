// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Ownable.sol";

contract Library is Ownable {
    
    struct Book {
        uint32 id;
        uint16 copies;
        string name;
    }

    mapping(uint32 => address[]) borrowedBy;
    mapping(address => uint32[]) borrowingNow;
    
    Book[] books;
    
    function _isBorrowingNow(address _sender, uint32 _bookID) internal view returns(bool){
        bool result = false;
        for (uint i = 0; i <  borrowingNow[_sender].length; i++) {
            if (_bookID == borrowingNow[_sender][i]) {
                result = true;
                break;
            }
        }
        return result;
    }
    
    
    function addBook(string memory _name, uint16 _copies) onlyOwner public {
        // You can add books of the same title more than once
        // Removing books is not possible
        books.push(Book(uint32(books.length + 1), _copies, _name));
    }
    
    function listBooks() public view returns (Book[] memory) {
        return books;
    }
    
    function borrowBook(uint32 _bookID) public {
        uint bookIndex = _bookID - 1;
        Book memory book = books[bookIndex];
        
        require(book.copies >= 1, "All copies already borrowed");
        require(!_isBorrowingNow(msg.sender, _bookID), "Already borrowing a copy");

        bool hasBorrowedBefore = false;
        address[] memory previouslyBorrowedBy = borrowedBy[_bookID];
        for (uint i = 0; i <  previouslyBorrowedBy.length; i++) {
            if (msg.sender == previouslyBorrowedBy[i]) {
                hasBorrowedBefore = true;
            }
        }
        
        if (!hasBorrowedBefore) {
            borrowedBy[_bookID].push(msg.sender);
        }
        
        borrowingNow[msg.sender].push(_bookID);
        books[bookIndex].copies--;
    }
    
    function returnBook(uint32 _bookID) public {
        require(_isBorrowingNow(msg.sender, _bookID), "You are not borrowing a copy to return");
        for (uint i = 0; i < borrowingNow[msg.sender].length; i++) {
            if(_bookID == borrowingNow[msg.sender][i]) {
                delete borrowingNow[msg.sender][i];
            }
        }

        books[_bookID - 1].copies++;
    }
    
    function whoBorrowed(uint32 _bookID) public view returns(address[] memory){
        return borrowedBy[_bookID];
    }
}
