// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";

contract GenerateInput is Script {
    uint256 amount = 25 * 1e18;
    string[] types = new string[](2);
    uint256 count;
    string[] whiteList = new string[](4);
    string private inputPath = "/script/target/input.json";

    function run() public {
        types[0] = "address";
        types[1] = "uint";

        whiteList[0] = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D";
        whiteList[1] = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";
        whiteList[2] = "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC";
        whiteList[3] = "0x90F79bf6EB2c4f870365E785982E1f101E93b906";
        count = whiteList.length;
        string memory input = _createJSON();
        vm.writeFile(string.concat(vm.projectRoot(), inputPath), input);

        console.log("DONE: The output is found at %s", inputPath);
    }

    function _createJSON() internal view returns (string memory) {
        string memory countString = vm.toString(count);
        string memory amountString = vm.toString(amount);
        string memory json = string.concat('{"types": ["address", "uint"], "count":', countString, ',"values": {');
        for (uint256 i = 0; i < whiteList.length; i++) {
            if (i == whiteList.length - 1) {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ': { "0":',
                    '"',
                    whiteList[i],
                    '"',
                    ',"1":',
                    '"',
                    amountString,
                    '"',
                    "}"
                );
            } else {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(i),
                    '"',
                    ':{"0":',
                    '"',
                    whiteList[i],
                    '"',
                    ',"1":',
                    '"',
                    amountString,
                    '"',
                    "},"
                );
            }
        }
        json = string.concat(json, "}}");

        return json;
    }
}
