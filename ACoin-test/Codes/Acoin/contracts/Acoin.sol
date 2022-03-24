pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Acoin is ERC20 {

    constructor() ERC20("ACoin", "AC") {
        _mint(msg.sender, 1000000 * 10 **4);
    }


    function decimals() public view override returns (uint8) {
        return 4;
    }
}

