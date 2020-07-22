// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is disstributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.5.12;

// Builds new BPools, logging their addresses and providing `isBPool(address) -> (bool)`

import "./BPool.sol";
import { NullCloneConstructor } from "./NullCloneConstructor.sol";
import { CloneLib } from "./CloneLib.sol";
import { BPoolTemplateLib } from "./BPoolTemplateLib.sol";

contract BFactory is BBronze, NullCloneConstructor {
    event LOG_NEW_POOL(
        address indexed caller,
        address indexed pool
    );

    event LOG_BLABS(
        address indexed caller,
        address indexed blabs
    );

    mapping(address=>bool) private _isBPool;

    function isBPool(address b)
        external view returns (bool)
    {
        return _isBPool[b];
    }

    // ============== new =============

    address public bPoolTemplate; // the fully deployed pool with creation bytecode

    /**
     * @dev Deploys the template contract with the full bytecode.
     */
    function deployBPoolTemplate() public {
        bPoolTemplate = BPoolTemplateLib.deployTemplate();
    }

    function getSalt(uint extraSalt) public view returns (bytes32 salt) {
        salt = keccak256(
            abi.encodePacked(
                BPoolTemplateLib.BPOOL_SALT(),
                extraSalt
            )
        );
    }

    function getAddress(uint extraSalt) public view returns (address) {
        return CloneLib.deriveInstanceAddress(bPoolTemplate, getSalt(extraSalt));
    }

    /**
     * @dev Modified to deploy a create2 clone of a BPool based off a salt and the template contract.
     */
    function newBPool(uint extraSalt)
        external
        returns (BPool)
    {
        require(bPoolTemplate != address(0x0), "ERR_NO_DEPLOYED_TEMPLATE");
        // can be anything, uses the parameter uint for the salt.
        bytes32 salt = getSalt(extraSalt);
        // deploys the clone
        BPool bpool = BPool(CloneLib.create2Clone(bPoolTemplate, uint(salt)));
        _isBPool[address(bpool)] = true;
        emit LOG_NEW_POOL(msg.sender, address(bpool));
        // initializes instead of using constructor
        bpool.initialize();
        bpool.setController(msg.sender);
        return bpool;
    }

    // ============== end new ==============

    address private _blabs;

    constructor() public {
        _blabs = msg.sender;
    }

    function getBLabs()
        external view
        returns (address)
    {
        return _blabs;
    }

    function setBLabs(address b)
        external
    {
        require(msg.sender == _blabs, "ERR_NOT_BLABS");
        emit LOG_BLABS(msg.sender, b);
        _blabs = b;
    }

    function collect(BPool pool)
        external 
    {
        require(msg.sender == _blabs, "ERR_NOT_BLABS");
        uint collected = IERC20(pool).balanceOf(address(this));
        bool xfer = pool.transfer(_blabs, collected);
        require(xfer, "ERR_ERC20_FAILED");
    }
}
