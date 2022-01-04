import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IKaki} from "../interfaces/IKaki.sol";

contract Kaki is ERC20PermitUpgradeable, IKaki, AccessControlUpgradeable {
    bytes32 public constant MINTER = keccak256("MINTER");
    uint256 public constant MAX_SUPPLY = 210000000 ether;

    event Mint(address indexed mintTo, address minter, uint256 amount);

    function initialize()
        public
        // string memory name,
        // string memory symbol,
        // uint256 initializedSupply
        initializer
    {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __ERC20Permit_init("Kaki");
        __ERC20_init("Kaki", "KAKI");
        //    _setRoleAdmin(MINTER, DEFAULT_ADMIN_ROLE);
    }

    function mint(address to, uint256 amount) public override onlyRole(MINTER) {
        require(totalSupply() + amount <= MAX_SUPPLY, "too much supply");
        _mint(to, amount);
        emit Mint(to, msg.sender, amount);
    }

    function version() public pure returns (uint256) {
        return 1;
    }
}
