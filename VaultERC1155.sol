// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "./utils/Converter.sol";
import "hardhat/console.sol";
import "./libraries/VaultLib.sol";
contract VaultERC1155 is ERC1155, Ownable, Converter,Pausable, ERC1155Supply {
   //continue incrementing values
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private vaultId;
    Counters.Counter private _mintedVaultId;

    IERC20 public tokenAddress;
    string public name;

    mapping(address => mapping(uint256 => VaultLib.MintedVault)) public myVault;
    
    mapping(address => VaultLib.MintedVault[]) public mintedVaultMap;
    mapping(uint256 => VaultLib.Vault) private vaultMap;
    mapping(uint256 => string) private _uris;
    uint256 private defaultPrice = 0.001 ether;
    uint256 private maxSupply = 1000;
    //IPFS URL ipfs://bafybeif7yxya4lo5w6sthdkn7y5i6mnhetuhrdasdasdasdasdasdaije/
    constructor() ERC1155("") {
        name = "Vault";
        addCrate("SILVER VAULT", 1, defaultPrice, 1661533841, "");
        addCrate("GOLD VAULT", 1, defaultPrice, 1661533841 ,"");
    }
    
    function addCrate(string memory _name, uint256 _qty, uint256 _amount, uint256 _timeOpen ,string memory _uri) public onlyOwner {
        vaultId.increment();
        uint newVaultId = vaultId.current();

        //set vault URI
        if(bytes(_uri).length > 0) {
            setTokenUri(newVaultId, _uri);
        }

        //check if vault token Id is exist
        VaultLib.Vault memory newVault = VaultLib.Vault({
            vaultId: newVaultId,
            name: _name,
            qty: _qty,
            amount: _amount,
            timeOpen: _timeOpen,
            isDone: false
        });
    
        //store to createdCrates Mapping
        vaultMap[newVaultId] = newVault;
        _mint(msg.sender, newVaultId, _qty, "");
    }

    function mint(uint256 _vaultId, uint256 _qty) public payable {
        // uint256 senderBalance = tokenAddress.balanceOf(msg.sender);
        VaultLib.Vault storage vault = vaultMap[_vaultId];
        
        if(vault.vaultId > 0) {
            uint256 cost = vault.amount * _qty;
           
            require(totalSupply(_vaultId) + _qty <= maxSupply, "Reached the Max Supply!");
            require(msg.value == cost, "Not enough balance to complete transaction.");
           
            _mintedVaultId.increment();
            uint256 newMintedCrateId = _mintedVaultId.current();

            // tokenAddress.transferFrom(msg.sender, address(this), etherToWei(cost));
            
            VaultLib.MintedVault memory newMintedVault = VaultLib.MintedVault({
                mintedId: newMintedCrateId,
                vaultId: vault.vaultId,
                owner: msg.sender,
                qty: _qty,
                cost: cost,
                dateMinted: block.timestamp,
                isOpened: false
            });

            mintedVaultMap[msg.sender].push(newMintedVault);

            _mint(msg.sender, _vaultId, _qty, "");
        }
    }

    function getMyVaults(address account) public view returns (VaultLib.MintedVault[] memory) {
        require(account != address(0), "No Account found!");
        return mintedVaultMap[account];
    }

    function getVault(uint256 _tokenId) public view returns (VaultLib.Vault memory) {
        VaultLib.Vault storage vault = vaultMap[_tokenId];
        return vault;
    }

    function getVaultByIndex(uint256 _tokenIndex) public view returns (VaultLib.MintedVault memory) {
        return mintedVaultMap[msg.sender][_tokenIndex]; 
    }

    function getVault() public view returns (VaultLib.Vault[] memory) {
        uint256 startGas = gasleft();
        console.log("start gas",startGas);
        
        uint vaultCount = vaultId.current();
        uint256 index = 0;

        VaultLib.Vault[] memory vaults = new VaultLib.Vault[](vaultCount);
        for (uint256 i = 0; i < vaultCount; i++) {
            uint currentId = i +1;

            VaultLib.Vault storage vault = vaultMap[currentId];
            vaults[index] = vault;
            index = index.add(1);
        }

        return vaults;
    }

    function transferVault(address playerAddress, uint256 tokenId, uint256 amount) public {
        console.log("SENDER:", msg.sender);
        console.log("TO:", playerAddress);
        console.log("tokenId:", tokenId);
        console.log("Amount: ", amount);

        safeTransferFrom(msg.sender, playerAddress, tokenId, amount, "");
    }

    function withdraw(address _address) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_address).transfer(balance);
        // tokenAddress.transfer(msg.sender, tokenAddress.balanceOf(address(this)));
    }

    /** OVERRIDE URI **/
    function uri(uint256 _id) public view virtual override returns(string memory) {
        require(exists(_id), "URI: nonexistent token");

        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id),".json"));
    }

    function setTokenUri(uint256 tokenId, string memory _uri) public onlyOwner {
        //check if uri is not exist and not empty
        require(bytes(_uris[tokenId]).length == 0, "Cannot set uri twice");
        _uris[tokenId] = _uri;
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

}