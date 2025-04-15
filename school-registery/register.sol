// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SchoolRegister {
    struct Register {
        string name;
        uint256 id;
        uint256 class;
    }
    mapping(address => Register[]) private schoolrecord;

    function registerStudent(
        string calldata _name,
        uint256 _id,
        uint256 _class
    ) public {
        // require(msg.sender == address(0), "only school can register new studen");

        Register memory studentinfo = Register({
            name: _name,
            id: _id,
            class: _class
        });

        schoolrecord[msg.sender].push(studentinfo);
    }

    function getAllStudentRecord() public view returns (Register[] memory) {
        return schoolrecord[msg.sender];
    }

    function getstudentRecordById(uint256 _id)
        public
        view
        returns (Register memory)
    {
        Register[] memory records = schoolrecord[msg.sender];

        for (uint256 i = 0; i < records.length; i++) {
            if (records[i].id == _id) return records[i];
        }

        revert("no student found");
    }

    function getStudentByClass(uint256 _class)
        public view 
        returns (Register[] memory)
    {
        Register[] memory records = schoolrecord[msg.sender];

        uint256 newRecordCount = 0;

        for (uint256 i = 0; i < records.length; i++) {
            if (records[i].class == _class) {
                newRecordCount++;
            }
        }

        Register[] memory matchedStudent = new Register[](newRecordCount);

        uint256 index = 0;

        for (uint256 j = 0; j < records.length; j++) {
            if (records[j].class == _class) {
                matchedStudent[index] = records[j];
                index++;
            }
        }

        return matchedStudent;
    }
}
