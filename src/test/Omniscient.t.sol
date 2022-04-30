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

    function setUp() public {
        console.log(unicode"🧪 Testing Omniscient...");

        srcEndpoint = new LZEndpointMock(FUJI_CHAIN_ID);
        dstEndpoint = new LZEndpointMock(RINKEBY_CHAIN_ID);

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

    function testMintAndUpdate() public {
        // Mint omniscient nft on ethereum
        startHoax(address(1337), address(1337));
        omniscient.mint();
        assertEq(omniscient.ownerOf(0), address(1337));

        // Send message to update ownership to layer zero from everest on avalanche
        everest.transferOwnership(RINKEBY_CHAIN_ID, address(0xBEEF), 0);
        assertEq(omniscient.ownerOf(0), address(0xBEEF));

        console.log(unicode"✅ Update ownership tests passed!");
    }

    function testMintAndUpdateNotMinted() public {
        startHoax(address(1337), address(1337));

        // Send a failing message which gets stored in failed messages mapping
        everest.transferOwnership(RINKEBY_CHAIN_ID, address(0xBEEF), 0);
        assertEq(omniscient.ownerOf(0), address(0));

        // Mint the non-existent token
        omniscient.mint();
        assertEq(omniscient.ownerOf(0), address(1337));

        // Retry stored message
        omniscient.retryMessage(
            FUJI_CHAIN_ID,
            abi.encodePacked(everest),
            1,
            abi.encode(address(0xBEEF), 0)
        );

        // Verify token ownership
        assertEq(omniscient.ownerOf(0), address(0xBEEF));

        console.log(unicode"✅ Retry failed message tests passed!");
    }
}
