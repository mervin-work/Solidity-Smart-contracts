// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BobaERC20 is ERC20, ERC20Burnable, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _balances;
    mapping(address => bool) administrators;

    uint256 private _totalSupply;
    uint256 private MAXSUP;
    uint256 constant MAXIMUMSUPPLY = 2000000 * 10 ** 18;
    constructor() ERC20("Shogun", "$SHOGUNS") { 
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address _to, uint256 _amount) external {
        require(administrators[msg.sender], "Only administrator can mint");
        require((MAXSUP+_amount) <= MAXIMUMSUPPLY, "Maximum suppy has been reached");
        _totalSupply = _totalSupply.add(_amount);
        MAXSUP = MAXSUP.add(_amount);
        _balances[_to] = _balances[_to].add(_amount);
         _mint(_to, _amount * 10 ** decimals());
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function maxSupply() public pure returns (uint256) {
        return MAXIMUMSUPPLY;
    }


    function burnFrom(address _account, uint256 _amount) public override {
        if(administrators[msg.sender]) {
            _burn(_account, _amount);
        } else {
            super.burnFrom(_account, _amount);
        }
    }

    function addAdministrator(address _administrator) external onlyOwner {
        administrators[_administrator] = true;
    }

    function removeAdministrator(address _administrator) external onlyOwner {
        administrators[_administrator] = false;
    }

}