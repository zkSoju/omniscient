// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.13;

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {NonblockingLzApp} from "./lzApp/NonblockingLzApp.sol";

/// @title Omniscient
/// @notice Omnichain ERC721 Token.
/// @notice Contract lives on Ethereum.
/// @author zkSoju
contract Omniscient is NonblockingLzApp, ERC721 {
    /// :::::::::::::::::::::::  ERROR  ::::::::::::::::::::::: ///

    /// @notice Throw to when trying to update owner when token is not minted.
    error NotMinted();

    /// :::::::::::::::::::::::  STORAGE  ::::::::::::::::::::::: ///

    /// @notice Counter for total received messages from other chains.
    uint256 public messageCounter;

    /// @notice Maps remote addresses to number of received messages.
    mapping(address => uint256) public getRemoteCounter;

    /// @notice TokenId of the next token to be minted.
    uint256 internal currentSupply;

    constructor(address endpoint)
        ERC721("Omniscient", "OMNI")
        NonblockingLzApp(endpoint)
    {}

    /// @notice Overrides functionality in lzReceive from LzApp.
    function _nonblockingLzReceive(
        uint16 chainId,
        bytes memory source,
        uint64,
        bytes memory payload
    ) internal virtual override {
        address sourceAddress;
        assembly {
            sourceAddress := mload(add(source, 20))
        }
        getRemoteCounter[sourceAddress]++;
        messageCounter++;

        (address who, uint256 tokenId) = abi.decode(
            payload,
            (address, uint256)
        );

        _transferOwnership(chainId, who, tokenId);
    }

    /// @notice Transfers the ownership of the token to the new address
    function _transferOwnership(
        uint16,
        address who,
        uint256 tokenId
    ) internal {
        if (ownerOf[tokenId] == address(0)) revert NotMinted();
        ownerOf[tokenId] = who;
    }

    function mint() public {
        _mint(msg.sender, currentSupply);
        currentSupply++;
    }

    function tokenURI(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {}
}
