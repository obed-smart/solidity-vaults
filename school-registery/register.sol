// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SchoolRegister {
    struct Register {
        string name;
        uint256 id;
        string class;
        bytes32 hashClass;
    }
    address private owner;
    mapping(address => Register[]) private schoolrecord;
    mapping(address => mapping(string => uint256)) private schoolclassCount;

    constructor() {
        owner = msg.sender;
    }

    event RegisteredStudent(uint256 id, string name, string class);

    modifier onlySchool() {
        require(msg.sender == owner, "only school can use the function");
        _;
    }

    /*
     * function to convert a string to bytes32
     * @param(_str) - a string value to convert to bytes32
     * @returns(bytes32) - a converted bytes32 value
     */

    function hashString(string memory _str) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_str));
    }

    function registerStudent(string calldata _name, string calldata _class)
        public
        onlySchool
    {
        // require(msg.sender == address(0), "only school can register new studen");

        uint256 studentIdCount = ++schoolclassCount[msg.sender][_class];

        Register memory studentinfo = Register({
            name: _name,
            id: studentIdCount,
            class: _class,
            hashClass: hashString(_class)
        });

        schoolrecord[msg.sender].push(studentinfo);
        emit RegisteredStudent(studentIdCount, _name, _class);
    }

    function getAllStudentRecord()
        public
        view
        onlySchool
        returns (Register[] memory)
    {
        return schoolrecord[msg.sender];
    }

    function getstudentRecordById(uint256 _id, string calldata _class)
        public
        view
        returns (Register memory)
    {
        Register[] memory records = schoolrecord[msg.sender];

        for (uint256 i = 0; i < records.length; i++) {
            if (
                records[i].id == _id &&
                records[i].hashClass == hashString(_class)
            ) return records[i];
        }

        revert("student record not found ID");
    }

    /*
     * get the student record by class
     * @param(_class)- the class of each related students
     * loop through the records return the number of students in a class
     * create a new fixed size array for the students with the return number
     * for each students that match the class store them in the new arrya
     */

    function getStudentsByClass(string calldata _class)
        public
        view
        returns (Register[] memory)
    {
        Register[] memory records = schoolrecord[msg.sender]; // asign the register to records

        uint256 newRecordCount = 0; //  create a variable to store the number of students in a class

        // loop through the register to count student
        for (uint256 i = 0; i < records.length; i++) {
            if (records[i].hashClass == hashString(_class)) {
                newRecordCount++; // increase the number of students in a class if the condition is true
            }
        }

        Register[] memory matchedStudent = new Register[](newRecordCount); //  create a fixed array for the number of students in a class

        uint256 index = 0; // create a new variable to store student in a class

        // loop to find the student in a class

        for (uint256 j = 0; j < records.length; j++) {
            if (records[j].hashClass == hashString(_class)) {
                matchedStudent[index] = records[j]; // store the student in a class to new fixed array
                index++; // increase the index to store the student in a class
            }
        }

        return matchedStudent; // return the array with students in a specific class
    }
}
