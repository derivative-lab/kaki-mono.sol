pragma solidity ^0.8.0;

import "../interfaces/IVault.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockValt is IVault, ERC20 {
    ERC20 public _token;

    constructor(ERC20 token)
        public
        ERC20(string(abi.encodePacked("ib-", token.name())), string(abi.encodePacked("ib", token.symbol())))
    {
        _token = token;
        // _setupDecimals(decimals_);
        // _mint(msg.sender, amount_);
    }

    function totalToken() public view override returns (uint256) {
        return (totalSupply() * 100) / 98;
    }

    function totalSupply() public view override(IVault, ERC20) returns (uint256) {
        return super.totalSupply();
    }

    /// @dev Add more ERC20 to the bank. Hope to get some good returns.
    function deposit(uint256 amountToken) public payable override {
        _token.transferFrom(msg.sender, address(this), amountToken);
        _mint(msg.sender, (amountToken * 98) / 100);
    }

    /// @dev Withdraw ERC20 from the bank by burning the share tokens.
    function withdraw(uint256 share) public override {
        transferFrom(msg.sender, address(this), share);
        _burn(address(this), share);
        _token.transfer(msg.sender, (share * 100) / 98);
    }

    /// @dev Request funds from user through Vault
    function requestFunds(address targetedToken, uint256 amount) public override {}

    function token() public view override returns (address) {
        return address(_token);
    }
}
