// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./HtmlPage.sol";
import "./DnsManager.sol";

contract HtmlPageFactory {
    mapping(address => address[]) public userPages;
    mapping(uint256 => address) public pageLinkedDomain;
    DomainNFT public domainContract;

    event PageCreated(address indexed user, address pageContract);
    event ContentUpdated(
        address indexed user,
        address pageContract,
        string newContent
    );
    event NameUpdated(
        address indexed user,
        address pageContract,
        string newName
    );
    event DomainLinked(
        address indexed user,
        address pageContract,
        uint256 tokenId,
        string domain
    );
    event DomainUnlinked(
        address indexed user,
        address pageContract,
        uint256 tokenId,
        string domain
    );

    constructor(address _domainContract) {
        domainContract = DomainNFT(_domainContract);
    }

    function createPage(
        string memory initialContent,
        string memory _name
    ) external {
        HtmlPage newPage = new HtmlPage(initialContent, _name);
        userPages[msg.sender].push(address(newPage));
        emit PageCreated(msg.sender, address(newPage));
    }

    function updatePageContent(
        address pageContract,
        string memory newContent
    ) external {
        require(
            HtmlPage(pageContract).owner() == msg.sender,
            "Not the Page owner"
        );
        HtmlPage(pageContract).updateContent(newContent);
        emit ContentUpdated(msg.sender, pageContract, newContent);
    }

    function updatePageName(
        address pageContract,
        string memory newName
    ) external {
        require(
            HtmlPage(pageContract).owner() == msg.sender,
            "Not the Page owner"
        );
        HtmlPage(pageContract).updateName(newName);
        emit NameUpdated(msg.sender, pageContract, newName);
    }

    function linkDomain(address pageContract, uint256 tokenId) external {
        require(
            domainContract.ownerOf(tokenId) == msg.sender,
            "Not the NFT owner"
        );
        require(
            HtmlPage(pageContract).owner() == msg.sender,
            "Not the Page owner"
        );
        string memory domain = domainContract.getDomainByTokenId(tokenId);
        require(bytes(domain).length > 0, "Invalid domain");
        pageLinkedDomain[tokenId] = pageContract;
        emit DomainLinked(msg.sender, pageContract, tokenId, domain);
    }

    function unlinkDomain(address pageContract, uint256 tokenId) external {
        require(
            domainContract.ownerOf(tokenId) == msg.sender,
            "Not the NFT owner"
        );
        require(
            HtmlPage(pageContract).owner() == msg.sender,
            "Not the Page owner"
        );
        string memory domain = domainContract.getDomainByTokenId(tokenId);
        require(bytes(domain).length > 0, "Invalid domain");
        pageLinkedDomain[tokenId] = address(0);
        emit DomainUnlinked(msg.sender, pageContract, tokenId, domain);
    }

    function getUserPages(
        address user
    ) external view returns (address[] memory) {
        return userPages[user];
    }

    function getLinkedDomain(uint256 tokenId) external view returns (address) {
        return pageLinkedDomain[tokenId];
    }
}
