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

pragma solidity ^0.6.10;
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
         
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;  
         
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
     // function sendValue(address payable recipient, uint256 amount) internal {
    //     require(address(this).balance >= amount, "Address: insufficient balance");
    //     (bool success, ) = recipient.call.value(amount)("");
    //     require(success, "Address: unable to send value, recipient may have reverted");
    // }
}

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


contract BrunFaFang{
    
    IERC20 private RSKY;
    
    address private owner;
    
    mapping(address => address) blackAddrMap;
    
    modifier onlyOwner(){
        require(owner == msg.sender,"Must be an owner");
        _;
    }    
    constructor(address RSKY_addr,address _owner) public{
        RSKY=IERC20(RSKY_addr);
        owner = _owner;
    }
    
    function sendRSKY(address[] memory _to,uint256[] memory _value) public onlyOwner returns(bool){
         for(uint8 i=0;i<_to.length;i++){
            if(_to[i] != address(0)){
                RSKY.transfer(_to[i],_value[i]);
            }
         }
         return true;
    }
    
    function isExits(address _addr) public view returns(bool){
        if(blackAddrMap[_addr] == address(0)){
            return false;
        }else{
            return true;
        }
    }
    
    function addBlack(address _addr) external onlyOwner returns(bool){
        require(_addr != address(0),'param is error');
        require(blackAddrMap[_addr] == address(0),'exist blacklist');
        blackAddrMap[_addr] = _addr;
        return true;
    }
    
    
    function delBlack(address _addr) external onlyOwner returns(bool){
        require(_addr != address(0),'param is error');
        require(blackAddrMap[_addr] != address(0),'exist blacklist');
        delete blackAddrMap[_addr];
        return true;
    }
    
    function getBalance() public view returns(uint256){
        RSKY.balanceOf(address(this));
    }
    
}