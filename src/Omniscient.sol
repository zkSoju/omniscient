// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.13;

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {NonblockingLzApp} from "./lzApp/NonblockingLzApp.sol";

/// @title Omniscient
/// @notice Interactible Cross-chain ERC721 implementation
/// @author zkSoju
contract Omniscient is NonblockingLzApp, ERC721 {
    /// :::::::::::::::::::::::  ERROR  ::::::::::::::::::::::: ///

    /// @notice Throw to when trying to update owner when token is not minted.
    error NotMinted();

    /// :::::::::::::::::::::::  EVENTS  ::::::::::::::::::::::: ///

    event ReceiveMessage(
        address indexed from,
        bytes indexed payload,
        address indexed to,
        uint256 tokenId,
        uint64 nonce
    );

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
    /// @dev Loads 20 bytes for EVM based chains, may differ for other chains
    function _nonblockingLzReceive(
        uint16 chainId,
        bytes memory source,
        uint64 nonce,
        bytes memory payload
    ) internal virtual override {
        _beforeReceive(chainId, source, payload);

        address sourceAddress;
        assembly {
            sourceAddress := mload(add(source, 20))
        }

        getRemoteCounter[sourceAddress]++;
        messageCounter++;

        (address from, address to, uint256 tokenId) = abi.decode(
            payload,
            (address, address, uint256)
        );

        emit ReceiveMessage(from, payload, to, tokenId, nonce);

        _afterReceive(chainId, from, to, tokenId);
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

    function _beforeReceive(
        uint16,
        bytes memory,
        bytes memory
    ) internal virtual {}

    /// @notice Transfers the ownership of the token to the new address.
    /// @dev Only executable internally by providing approval to this contract
    /// or when retrying the message as owner.
    function _afterReceive(
        uint16,
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        transferFrom(from, to, tokenId);
    }
}
