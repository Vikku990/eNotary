// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title eNotary
 * @dev A decentralized notary service that allows users to register, verify,
 * and retrieve document hashes for authenticity verification.
 */
contract eNotary {
    struct Document {
        address owner;
        bytes32 docHash;
        uint256 timestamp;
        string description;
    }

    mapping(bytes32 => Document) private documents;

    event DocumentRegistered(address indexed owner, bytes32 indexed docHash, uint256 timestamp);
    event DocumentVerified(address indexed verifier, bytes32 indexed docHash, bool valid);

    /**
     * @dev Registers a new document hash on the blockchain.
     * @param _docHash The hash of the document.
     * @param _description A short description of the document.
     */
    function registerDocument(bytes32 _docHash, string calldata _description) external {
        require(documents[_docHash].timestamp == 0, "Document already registered");

        documents[_docHash] = Document({
            owner: msg.sender,
            docHash: _docHash,
            timestamp: block.timestamp,
            description: _description
        });

        emit DocumentRegistered(msg.sender, _docHash, block.timestamp);
    }

    /**
     * @dev Verifies if a document hash exists and returns its details.
     * @param _docHash The hash of the document to verify.
     * @return owner Address of the document owner.
     * @return timestamp Timestamp when it was registered.
     * @return description Description of the document.
     */
    function verifyDocument(bytes32 _docHash)
        external
        returns (address owner, uint256 timestamp, string memory description)
    {
        Document memory doc = documents[_docHash];
        bool valid = doc.timestamp != 0;

        emit DocumentVerified(msg.sender, _docHash, valid);

        require(valid, "Document not found");
        return (doc.owner, doc.timestamp, doc.description);
    }

    /**
     * @dev Returns the total timestamp of a registered document without verification logs.
     * @param _docHash The hash of the document.
     */
    function getDocumentInfo(bytes32 _docHash)
        external
        view
        returns (address owner, uint256 timestamp, string memory description)
    {
        Document memory doc = documents[_docHash];
        require(doc.timestamp != 0, "Document not found");
        return (doc.owner, doc.timestamp, doc.description);
    }
}
