// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library VaultLib {

    struct Vault {
        uint256 vaultId;
        string name;
        uint256 qty;
        uint256 amount;
        uint256 timeOpen;
        bool isDone;
    }


    struct MintedVault {
        uint256 mintedId;
        uint256 vaultId;
        address owner;
        uint256 qty;
        uint256 dateMinted;
        uint256 cost;
        bool isOpened;
    }

    
}