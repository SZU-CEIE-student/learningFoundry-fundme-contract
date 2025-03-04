//SPDX-License-Identifier:MIT
//1. Deploy mocks when we are on a local anvial chain
//2.Keep track of contract addresses acroos different chains

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/Mock_V3Aggregator.sol";

contract HelperConfig is Script {
    //如果是anvil,本地部署
    //否则 联网
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            //Sepolia chain ID
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //Chainlink feed address
        NetworkConfig memory sepoliaEthConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaEthConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        //local price feed address
        //1.Deploy mocks when we are on a local anvial chain
        //2.return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory AnvilEthConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return AnvilEthConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //mainnet price feed address
        NetworkConfig memory MainnetEthConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return MainnetEthConfig;
    }
}
