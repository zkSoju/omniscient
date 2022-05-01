// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.13;

import {NonblockingLzApp} from "./lzApp/NonblockingLzApp.sol";

/// @title Everest
/// @notice The ownership manager for Omniscient.
/// @notice Contract lives on Avalanche.
/// @author zkSoju
contract Everest is NonblockingLzApp {
    /// :::::::::::::::::::::::  EVENTS  ::::::::::::::::::::::: ///

    event SendMessage(
        address indexed from,
        bytes indexed payload,
        address indexed to,
        uint256 tokenId,
        uint64 nonce
    );

    constructor(address endpoint) NonblockingLzApp(endpoint) {}

    function estimateFees(
        uint16 chainId,
        address to,
        uint256 tokenId
    ) external view returns (uint256) {
        (uint256 fees, ) = lzEndpoint.estimateFees(
            chainId,
            to,
            abi.encode(msg.sender, to, tokenId),
            false,
            bytes("")
        );

        return fees;
    }

    /// @notice Sends LayerZero message to transfer ownership on another chain
    function transferOwnership(
        uint16 chainId,
        address to,
        uint256 tokenId
    ) public payable {
        bytes memory payload = abi.encode(msg.sender, to, tokenId);

        _lzSend(
            chainId,
            payload,
            payable(msg.sender),
            address(0x0),
            abi.encodePacked(uint16(1), uint256(200000))
        );

        uint64 nonce = lzEndpoint.getOutboundNonce(chainId, address(this));

        emit SendMessage(msg.sender, payload, to, tokenId, nonce);
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal virtual override {}
}
