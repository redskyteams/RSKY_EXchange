// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.6.10;

pragma experimental ABIEncoderV2;

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

contract PoolPledge{
    using SafeMath for uint;
        
    address public owner;

    IERC20 public RSKY;

    BrunFaFang private brunFaFang;
    
    mapping(uint=> PledgePool) public poolIdToPledge;
    
    struct PledgePool{
        uint poolId;
        IERC20 erc20;
        uint256 totalNum;
        uint decimal;
    }    
    
    struct PledgeRecord{
         uint    poolId;
         uint totalNum;
    }
    
    mapping(address => mapping(uint=>PledgeRecord)) userRecord;
    
    constructor(address _owner,address _RSKYAddress,address burnAddress) public {
        owner = _owner;
        RSKY= IERC20(_RSKYAddress);
        brunFaFang=BrunFaFang(burnAddress);
    }    
    
    function addPool(uint64  poolId,address contractAddress) public  onlyOwner returns(bool){
         require(poolIdToPledge[poolId].totalNum <= 0,'poolId is alerted');
         IERC20 token =  IERC20(contractAddress);
         uint decimal =token.decimals();
         PledgePool memory pledgePool = PledgePool(poolId,token,200,decimal);
         poolIdToPledge[poolId] = pledgePool;
         return true;
    }    
    
    event pledgeEvn(address indexed _owner,uint indexed poolId,uint256 indexed _value);
    
    function pledge(uint256 _value,uint _poolId) external returns(bool){
        address _owner = msg.sender;
        require(poolIdToPledge[_poolId].totalNum > 0,"please create before");
        IERC20 token = poolIdToPledge[_poolId].erc20;
        PledgeRecord memory pledgeRecord = userRecord[_owner][_poolId];
        if(pledgeRecord.totalNum > 0){
            pledgeRecord.totalNum = pledgeRecord.totalNum.add(_value);
            userRecord[_owner][_poolId] = pledgeRecord;
        }else{
            PledgeRecord memory myPledgeRecord = PledgeRecord(_poolId,_value);
            userRecord[_owner][_poolId] = myPledgeRecord;
        }
        token.transferFrom(_owner,address(this),_value);
        emit pledgeEvn(_owner,_poolId,_value);
        return true;
    }    
    
    event canclePledgeEvn(address indexed _owner,uint256 indexed _value,uint indexed poolId);
    
    function canclePledge(uint256 _value,uint _poolId) external returns(bool){
        address _owner = msg.sender;
        PledgeRecord memory pledgeRecord = userRecord[_owner][_poolId];
        require(pledgeRecord.totalNum > 0 ,'no pledge');
        require(pledgeRecord.totalNum >= _value,'Insufficient balance');
        IERC20 token  = poolIdToPledge[_poolId].erc20;
        pledgeRecord.totalNum = pledgeRecord.totalNum.sub(_value);
        userRecord[_owner][_poolId] = pledgeRecord;
        token.transfer(_owner,_value);
        emit canclePledgeEvn(_owner,_value,_poolId);
    }    
    
     
    
    event sendRSKYEvn(address indexed _owner,uint256 indexed _value,uint indexed poolId);
    
    function sendRSKYAdmin(address _owner,uint _poolId,uint256 RSKYNum) external onlyOwner returns(bool){
        require(!brunFaFang.isExits(_owner),'IS blacklist');
        RSKY.transfer(_owner,RSKYNum);
        emit sendRSKYEvn(_owner,RSKYNum,_poolId);
        return true;
    }

    function canclePledgeAndsendRSKYAdmin(uint _poolId,address _owner,uint256 RSKYNum,uint256 _value) external onlyOwner returns(bool){
        require(!brunFaFang.isExits(_owner),'IS blacklist');
        if(_value > 0){
            require(userRecord[_owner][_poolId].totalNum > 0 ,'Insufficient balance');
        
            PledgeRecord memory pledgeRecord = userRecord[_owner][_poolId];
            IERC20 token  = poolIdToPledge[_poolId].erc20; 
            pledgeRecord.totalNum = pledgeRecord.totalNum.sub(_value);
            userRecord[_owner][_poolId] = pledgeRecord;
            token.transfer(_owner,_value);
             emit canclePledgeEvn(_owner,_value,_poolId);
        }
        RSKY.transfer(_owner,RSKYNum);
        emit sendRSKYEvn(_owner,RSKYNum,_poolId);
    }
    
    modifier onlyOwner(){
        require(owner == msg.sender,"Must be an owner");
        _;
    }

}