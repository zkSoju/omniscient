// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.13;

import {NonblockingLzApp} from "./lzApp/NonblockingLzApp.sol";

/// @title Everest
/// @notice The ownership manager for Omniscient.
/// @notice Contract lives on Avalanche.
/// @author zkSoju
contract Everest is NonblockingLzApp {
    constructor(address endpoint) NonblockingLzApp(endpoint) {}

    function transferOwnership(
        uint16 chainId,
        address who,
        uint256 tokenId
    ) public payable {
        bytes memory payload = abi.encode(who, tokenId);

        _lzSend(chainId, payload, payable(msg.sender), address(0x0), bytes(""));
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal virtual override {}
}
