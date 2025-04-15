// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MessageBoard {
    // message structs
    struct Message {
        string text;
        uint256 sentTime;
        address sender;
    }

    mapping(address => Message[]) private messages;

    event MessageSent(
        address indexed _from,
        address indexed _to,
        string _text,
        uint256 indexed _timestamp
    );

    /*
     * @dev a function to send a message to another address
     * @param(_receiver) the address of the receiver
     * @param(_text) the text/message to send
     */

    function send(address _reciever, string memory _text) public {
        require(
            _reciever != msg.sender,
            "you can't send a message to yourself"
        );

        emit MessageSent(_reciever, msg.sender, _text, block.timestamp);

        // creat a new structs instance for each message
        Message memory data = Message({
            text: _text,
            sender: _reciever,
            sentTime: block.timestamp
        });

        // push the new struct in userMessage mappings or hash table
        messages[_reciever].push(data);
    }

    // function to see
    function getMessages(address _reciever)
        external
        view
        returns (Message[] memory)
    {
        require(
            _reciever != msg.sender,
            "you can not see another users messages"
        );
        require(messages[_reciever].length > 0, "user does not have message");

        return messages[_reciever];
    }


// function to get the current user message
    function getSenderMessages() external view returns (Message[] memory) {
        require(messages[msg.sender].length > 0, "user does not have message");

        return messages[msg.sender];
    }
}
