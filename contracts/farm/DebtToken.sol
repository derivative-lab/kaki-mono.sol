pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IDebtToken} from "../interfaces/IDebtToken.sol";

contract DebtToken is IDebtToken, ERC20, Ownable {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function burn(address account, uint256 amount) public override onlyOwner {
        _burn(account, amount);
    }

    function mint(address account, uint256 amount) public override onlyOwner {
        _mint(account, amount);
    }
}
