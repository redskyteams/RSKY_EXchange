// SPDX-License-Identifier: SimPL-2.0
// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.6.10;
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.6.10;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.6.10;

contract KongTou{ 
    
    
    address public owner;
    
    
    IERC20 public RSKY;
    
    IERC20 public USKY;
    
    constructor(address RSKY_addr,address USKY_addr,address _owner) public{
        RSKY = IERC20(RSKY_addr);
        USKY =IERC20(USKY_addr);
        owner = _owner;
    }
    
    event sendUSKYEvn(address indexed _to,uint256 indexed _value);
    
    event sendRSKYEvn(uint256 indexed _type,address indexed _to,uint256 indexed _usdtNum);
    
    function sendUSKY(address _to,uint256 _value) public onlyOwner{
        USKY.transfer(_to,_value);
        emit sendUSKYEvn(_to,_value);
    }
    

    function sendRSKY(uint256 _type,address _to,uint256 _value,uint256 _usdtNum) public onlyOwner{
        RSKY.transfer(_to,_value);
        emit sendRSKYEvn(_type,_to,_usdtNum);
    }

    
    modifier onlyOwner(){
        require(owner == msg.sender,"Must be an owner");
        _;
    }
    
        
    
}