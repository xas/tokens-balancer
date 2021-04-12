// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Simple standard contract interface
 * Provide a version function returning simply a version of the contract
 * 
 * code from https://github.com/xas
 *
 */
interface IContract {
    /// @return the current version of the contract
    function version() external pure returns (bytes12);
}