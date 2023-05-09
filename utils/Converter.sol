// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
* @author Mervin
* @dev 
*/
contract Converter {

    /**
    * @dev It is used to convert wei to ether
    **/
    function weiToEther(uint256 valueWei) public pure returns(uint256) {
        return valueWei/(10**18);
    }
    /**
    * @dev It is used to convert ether to wei
    **/
    function etherToWei(uint valueEther) public pure returns (uint) {
       return valueEther*(10**18);
    }
}