// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract MediCore is AccessControl {

    /**
     * --- Schema ---
     */
    struct Hospital {
        string name;
        string description;
        bool isCreated;
    }

    /**
     * --- Roles ---
     */ 
    bytes32 public constant HOSPITAL_ROLE = keccak256("HOSPITAL_ROLE");
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");
    
    mapping(address => Hospital) public hospitals;

    mapping(string => uint256) public documentFileHashes;


    event CommitedMedicalDocument(
        address indexed hospital,
        address indexed patient,
        string indexed cid,
        string fileName,
        uint256 hash
    );

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * --- Auth ---
     * One address can only have one role
     */

    function registerAsHospital(string calldata name, string calldata description) external {
        require(!hasRole(PATIENT_ROLE, msg.sender) && hospitals[msg.sender].isCreated, "User already registered");
        hospitals[msg.sender] = Hospital(name, description, true);
        _grantRole(HOSPITAL_ROLE, msg.sender);
    }

    function registerAsPatient() external {
        require(!hasRole(HOSPITAL_ROLE, msg.sender), "User already registered");
        _grantRole(PATIENT_ROLE, msg.sender);
    }


    /**
     * --- Commitments ---
     */

    function commitPatientFileHashAndPatientData(
        address patient,
        string memory fileName,
        string memory cid,
        uint256 hash
    ) onlyRole(HOSPITAL_ROLE) external {
        require(documentFileHashes[cid] == 0);

        documentFileHashes[cid] = hash;

        emit CommitedMedicalDocument(msg.sender, patient, fileName, cid, hash);
    }
}
