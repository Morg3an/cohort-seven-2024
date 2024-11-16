// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract BookStore {
    // Mapping of book IDs to their details (title, author, price)

    address public owner;

    struct Book {
        string title;
        string author;
        uint price;
        uint256 stock;
        bool isAvailable;
    }

    mapping(uint256 => Book) public books;

    event BookAdded(address indexed owner, uint256 id);
    event BookPurchased(address indexed buyer, address indexed seller, uint256 id);
    event BookRemoved(uint256 id);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addBook(
        uint256 _id,
        string memory _title,
        string memory _author,
        uint256 _price,
        uint256 _stock
    ) external onlyOwner {
        // Check if book already exists with the given ID.
        require(bytes(books[_id].title).length == 0, "Book with this ID already added.");
        
        books[_id] = Book({
            title: _title,
            author: _author,
            price: _price,
            stock: _stock,
            isAvailable: true
        });

        emit BookAdded(msg.sender, _id);
    }

    function getBook(uint256 id) public view returns (Book memory) {
        return books[id];
    }

    // Get total number of all existing and sold books.
    function getTotalBookCount() external view returns (uint256 count) {
        uint256 i;
        for (; i < 1000; ++i) { // Limit to 1000 books for simplicity
            if (bytes(books[i].title).length > 0) {
                count++;
            }
        }
    }

function buyBook(uint256 id, uint quantity) external payable {
    // Ensure book exists
    require(bytes(books[id].title).length > 0, "This book ID does not exist.");
    
    // Ensure the book is available
    require(books[id].isAvailable, "This book is not available.");
    
    // Ensure there is enough stock of the book
    require(books[id].stock >= quantity, "Not enough stock.");

    uint256 totalPrice = books[id].price * quantity;

    // Ensure the buyer sent enough Ether
    require(msg.value >= totalPrice, "Insufficient payment.");

    // Decrease the book stock
    books[id].stock -= quantity;

    // Transfer the payment to the contract owner
    payable(owner).transfer(totalPrice);

    // Emit the purchase event
    emit BookPurchased(msg.sender, owner, id);
}


    function removeBook(uint256 id) external onlyOwner {
        require(bytes(books[id].title).length > 0, "Book does not exist.");
        delete books[id];
        emit BookRemoved(id);
    }
}
