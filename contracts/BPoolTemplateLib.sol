// SPDX-License-Identifier: MIT

pragma solidity 0.5.12;

import { Create2 } from "./Create2.sol";
import { BPool } from "./BPool.sol";

library BPoolTemplateLib {
    // solhint-disable-next-line max-line-length
    bytes32 private constant _BPOOL_SALT = 0x41d65594e8d4ee3e8a2e64a49f1dd8c0cf5ad0ff90d16fce146c327baf8b5438; // keccak("balancer-bpool")

    // solhint-disable-next-line func-name-mixedcase
    function BPOOL_SALT() internal pure returns (bytes32) {
        return _BPOOL_SALT;
    }

    /**
     * @dev Deploys a clone of the deployed BPool.sol contract.
     */
    function deployTemplate() external returns (address implementationAddress) {
        bytes memory creationCode = type(BPool).creationCode;
        implementationAddress = Create2.deploy(0, _BPOOL_SALT, creationCode);
    }
}