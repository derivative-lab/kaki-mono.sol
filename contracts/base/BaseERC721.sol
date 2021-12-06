pragma solidity ^0.8.0;

import {IBaseERC721} from "../interfaces/IBaseERC721.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "./WithAdminRole.sol";

abstract contract BaseERC721 is WithAdminRole, IBaseERC721, ERC721EnumerableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter internal _tokenIdTracker;
    string public _baseTokenURI;

    function __BaseERC721_init(string memory name, string memory symbol_) public initializer {
        __WithAdminRole_init();
        __ERC721Enumerable_init();
        __ERC721_init(name, symbol_);
    }

    function increaceTokenId() internal {
        _tokenIdTracker.increment();
    }

    function setBaseTokenURI(string memory baseURI_) public restricted {
        _baseTokenURI = baseURI_;
    }

    function totalMinted() public view override returns (uint256) {
        return _tokenIdTracker.current();
    }

    function tokensOfOwner(address _owner) public view override returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlUpgradeable, ERC721EnumerableUpgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function batchTransfer(address[] memory to, uint256[] memory tokenIds) public override {
        uint256 toLen = to.length;
        require(toLen == tokenIds.length, "LNE"); // length not equal
        for (uint256 i = 0; i < toLen; i++) {
            _transfer(msg.sender, to[i], tokenIds[i]);
        }
    }

    function batchTransferSame(address to, uint256[] memory tokenIds) public override {
        uint256 len = tokenIds.length;
        for (uint256 i = 0; i < len; i++) {
            _transfer(msg.sender, to, tokenIds[i]);
        }
    }

    function burn(uint256 tokenId) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "not owner nor approved");
        _burn(tokenId);
    }

    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
