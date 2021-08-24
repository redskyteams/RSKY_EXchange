/**
 *Submitted for verification at BscScan.com on 2021-08-10
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.6.10;
abstract contract Erc20Token{  
    
    function balanceOf(address _owner) public view virtual returns (uint256 val);
    function transfer(address _to, uint256 _value) public virtual returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success);
    function approve(address _spender, uint256 _value) public virtual returns (bool success);
    function allowance(address _owner, address _spender) public view virtual returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256  _value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}


interface IERC20 {
    function transfer(address recipient, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool) ;
    function decimals() external view returns (uint8);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract TokenRSKY is Erc20Token {
    using SafeMath for uint256;
    uint256 public totalSupply = 1000000000 * 100000000;
	uint256 public BurnFee =5;
	
	uint256 public deadFee  = 20;
	uint256 public stakeFee = 20;
	uint256 public bonusFee = 60;
	
    string public name = "RedSKY Coin";
    string public symbol = "RSKY";
    uint8 public constant decimals = 8;
    address public owner;
    mapping (address => uint256) balance;  
    mapping (address => mapping (address => uint256)) allowed; 
    
    mapping(address => address) whiteAddress;
    
    address public deadAddress;
    
    address public bonusAddress;
    
    address public stakeAddress;
    
    constructor(address _owner) public {
        owner = _owner;
        balance[owner] = totalSupply;
    }


    function setFee(uint256 _BurnFee,uint256 _deadFee,uint256 _stakeFee,uint256 _bonusFee ) public onlyOwner{
        BurnFee = _BurnFee;
		deadFee = _deadFee;
		stakeFee= _stakeFee;
		bonusFee= _bonusFee;
		
		
    }
	
    
    function setDeadAddress(address _deadAddress) public onlyOwner{
        deadAddress = _deadAddress;
    }
    
    
    function setBonusAddress(address _bonusAddress) public onlyOwner{
        bonusAddress = _bonusAddress;
    }
    
    function setStakeAddress(address _stakeAddress) public onlyOwner{
        stakeAddress = _stakeAddress;
    }    
    
    function addWhite(address _white) public onlyOwner{
        whiteAddress[_white]=_white;
    }
    
    function delWhite(address _white) public onlyOwner{
        delete whiteAddress[_white];
    }
  
    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(_to != address(0x0));
        uint256 reladAmount;
        if(whiteAddress[_to] == address(0x0)){
            uint256 burnValue = _value.mul(BurnFee)/100;
            uint256 deadAddressValue = burnValue.mul(deadFee)/100;
            uint256 stakeAddressValue = burnValue.mul(stakeFee)/100;
            uint256 bonusAddressValue = burnValue.mul(bonusFee)/100;
            balance[stakeAddress]=balance[stakeAddress].add(stakeAddressValue);
            balance[bonusAddress]=balance[bonusAddress].add(bonusAddressValue);
            balance[deadAddress]=balance[deadAddress].add(deadAddressValue);      
            reladAmount = _value.sub(burnValue);
        }else{
            reladAmount = _value;
        }
        require(balance[msg.sender] >= _value && balance[_to].add(reladAmount) > balance[_to]);
        balance[msg.sender] = balance[msg.sender].sub(_value);
        balance[_to] = balance[_to].add(reladAmount);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }



    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(_to != address(0x0) && _from != address(0x0) ,'_from is invalid or _to is invalid');
        uint256 reladAmount;
        if(whiteAddress[_to] == address(0x0)){
            uint256 burnValue = _value.mul(BurnFee)/100;
            uint256 deadAddressValue = burnValue.mul(deadFee)/100;
            uint256 stakeAddressValue = burnValue.mul(stakeFee)/100;
            uint256 bonusAddressValue = burnValue.mul(bonusFee)/100;
            balance[stakeAddress]=balance[stakeAddress].add(stakeAddressValue);
            balance[bonusAddress]=balance[bonusAddress].add(bonusAddressValue);
            balance[deadAddress]=balance[deadAddress].add(deadAddressValue);      
            reladAmount = _value.sub(burnValue);
        }else{
            reladAmount = _value;
        }        
        require(balance[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balance[_from] = balance[_from].sub(_value);
        balance[_to] = balance[_to].add(reladAmount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);  
        return true;
    }

    function balanceOf(address _owner) public view override returns (uint256 val) {  
        return balance[_owner];
    }
  
    function approve(address _spender, uint256 _value) public override returns (bool success) {   
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
  
    function allowance(address _owner, address _spender) public view override returns (uint256 remaining) {  
        return allowed[_owner][_spender];
    }

    modifier onlyOwner(){
        require(msg.sender ==  owner,'Must be the owner');
        _;
    }

}