// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.13;

import {Omniscient} from "../Omniscient.sol";
import {Everest} from "../Everest.sol";
import {LZEndpointMock} from "./utils/mocks/LZEndpointMock.sol";

import "@std/Test.sol";

contract OmniscientTest is Test {
    Everest everest;
    Omniscient omniscient;

    LZEndpointMock srcEndpoint;
    LZEndpointMock dstEndpoint;

    address public constant LZ_RINKEBY_ENDPOINT =
        0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA;
    address public constant LZ_FUJI_ENDPOINT =
        0x93f54D755A063cE7bB9e6Ac47Eccc8e33411d706;

    uint16 constant RINKEBY_CHAIN_ID = 10001;
    uint16 constant FUJI_CHAIN_ID = 10006;

    event MessageFailed(
        uint16 _srcChainId,
        bytes _srcAddress,
        uint64 _nonce,
        bytes _payload
    );

    function setUp() public {
        console.log(unicode"🧪 Testing Omniscient...");

        srcEndpoint = new LZEndpointMock(FUJI_CHAIN_ID);
        dstEndpoint = new LZEndpointMock(RINKEBY_CHAIN_ID);

        vm.label(address(srcEndpoint), "LZ Fuji Endpoint");
        vm.label(address(dstEndpoint), "LZ Rinkeby Endpoint");

        everest = new Everest(address(srcEndpoint));
        omniscient = new Omniscient(address(dstEndpoint));

        srcEndpoint.setDestLzEndpoint(
            address(omniscient),
            address(dstEndpoint)
        );
        dstEndpoint.setDestLzEndpoint(address(everest), address(srcEndpoint));

        everest.setTrustedRemote(
            RINKEBY_CHAIN_ID,
            abi.encodePacked(address(omniscient))
        );
        omniscient.setTrustedRemote(
            FUJI_CHAIN_ID,
            abi.encodePacked(address(everest))
        );
    }

    function testMetadata() public {
        assertEq(address(everest.lzEndpoint()), address(srcEndpoint));
        assertEq(address(omniscient.lzEndpoint()), address(dstEndpoint));
    }

    function testTransfer() public {
        // Mint omniscient nft on ethereum
        startHoax(address(1337), address(1337));
        omniscient.mint();
        assertEq(omniscient.ownerOf(0), address(1337));

        // Set approval for omniscient to make internal calls
        omniscient.setApprovalForAll(address(omniscient), true);

        // Send message to update ownership to layer zero from everest on avalanche
        everest.transferOwnership(RINKEBY_CHAIN_ID, address(0xBEEF), 0);
        assertEq(omniscient.ownerOf(0), address(0xBEEF));

        vm.stopPrank();

        console.log(unicode"✅ Update ownership tests passed!");
    }

    function testTransferNotMinted() public {
        startHoax(address(1337), address(1337));

        // Send a failing message which gets stored in failed messages mapping
        everest.transferOwnership(RINKEBY_CHAIN_ID, address(0xBEEF), 0);
        assertEq(omniscient.ownerOf(0), address(0));

        // Mint the non-existent token
        omniscient.mint();
        assertEq(omniscient.ownerOf(0), address(1337));

        // Retry stored message
        // When message is stored function is retried, it is executed as msg.sender
        // No need for approval
        omniscient.retryMessage(
            FUJI_CHAIN_ID,
            abi.encodePacked(everest),
            1,
            abi.encode(address(1337), address(0xBEEF), 0)
        );

        // Verify token ownership
        assertEq(omniscient.ownerOf(0), address(0xBEEF));

        vm.stopPrank();

        console.log(unicode"✅ Retry failed message tests passed!");
    }

    function testTransferNotOwner() public {
        startHoax(address(1337), address(1337));

        // Expect message to be stored and fail event to be emitted
        // User is not allowed to transfer, token not yet minted
        vm.expectEmit(false, false, false, true);

        emit MessageFailed(
            10006,
            abi.encodePacked(address(everest)),
            1,
            abi.encode(address(1337), address(0xBEEF), 0)
        );

        everest.transferOwnership(RINKEBY_CHAIN_ID, address(0xBEEF), 0);

        // Mint the token
        omniscient.mint();
        assertEq(omniscient.ownerOf(0), address(1337));

        vm.stopPrank();

        startHoax(address(420), address(420));

        // Expect message to be stored and fail event to be emitted
        // User is not allowed to transfer
        vm.expectEmit(false, false, false, true);

        emit MessageFailed(
            10006,
            abi.encodePacked(address(everest)),
            2,
            abi.encode(address(420), address(0xBEEF), 0)
        );

        everest.transferOwnership(RINKEBY_CHAIN_ID, address(0xBEEF), 0);

        console.log(unicode"✅ Expect message failure tests passed!");
    }
}
