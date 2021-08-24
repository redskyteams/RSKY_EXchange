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




contract collect{
    using SafeMath for uint;
    
    uint256 public totalAmount = 1000000000000000000000000 ;
    
    uint256 public alreadyAmount;
    
    uint256 public convertRate = 10;//   1:10
    
    uint256 public collectStartTime=1630498088;//StartTime
    
    uint256 public collectEndTime=1631016488;//collectEndTime
    
    uint256 public drawCoinTime = 1631016488;//drawCoinTime
    
    address public owner; 
    
    IERC20 public usdtToken; 
    
    IERC20 public RSKYToken; 
    
    uint256 public usdtDecimals = 10 ** 18;
    
    uint256 public RSKYDecimals=10 ** 8;
    
    
    struct Player{
         address walletAddress; 
         uint256 totalUsdtNum; 
         uint256 totalRSKYNum; 
    }
    
     mapping(address => Player) playerInfo; 
    
    constructor(address _RSKYAddr,address _usdtAddr,address _owner) public{
        RSKYToken=IERC20(_RSKYAddr);
        usdtToken=IERC20(_usdtAddr);
        owner = _owner;
    }  
    
    
    event convertEvn(address indexed _owner, uint indexed usdtNum);
    
    function convert(uint256 usdtNum) public returns(bool){
        uint256 getNowTime = now; 
        require(getNowTime >= collectStartTime,"Recruitment has not started");
        require(getNowTime <= collectEndTime,"Recruitment has ended");
        uint256 totaoCollectUsdt = alreadyAmount.add(usdtNum);
        require(totaoCollectUsdt <= totalAmount,"Insufficient balance");
        address _owner = msg.sender;
        if(playerInfo[_owner].totalUsdtNum <= 0){ 
            Player memory player = Player(_owner,usdtNum,0);
            playerInfo[_owner] = player;
        }else{
            Player memory player = playerInfo[_owner];
            player.totalUsdtNum=player.totalUsdtNum.add(usdtNum);
            playerInfo[_owner] = player;
        }
        alreadyAmount = alreadyAmount.add(usdtNum);
        usdtToken.transferFrom(_owner,address(this),usdtNum);
        emit convertEvn(_owner,usdtNum);
        return true;
    }
    
    event sendRSKYEvn( address indexed _owner, uint256 indexed _RSKYNum);
    
    function sendRSKY() public returns(bool){
        uint256 getNowTime = now; 
        require(getNowTime >= drawCoinTime,"has not started");
        address _owner = msg.sender;
        require(playerInfo[_owner].totalUsdtNum > 0,"Insufficient balance");
        Player memory player = playerInfo[_owner];
        uint256 _totalUsdtNum = player.totalUsdtNum;
        uint256 RSKYNum =_totalUsdtNum.div(usdtDecimals).mul(RSKYDecimals).mul(convertRate);
        uint256 totalRSKYNum = player.totalRSKYNum; 
        require(totalRSKYNum < RSKYNum,"Insufficient balance");
        uint256 nowRSKYNum = RSKYNum.sub(totalRSKYNum);
        player.totalRSKYNum = RSKYNum;
        playerInfo[_owner] = player;
        RSKYToken.transfer(_owner,nowRSKYNum);
        emit sendRSKYEvn(_owner,nowRSKYNum);
        return true;        
    }


    function sendUsdt(address _owner) public onlyOwner returns(bool){
        require(_owner != address(0x0));
        usdtToken.transfer(_owner,usdtToken.balanceOf(address(this)));
    }
    
    
    function sendRSKYAdmin(address _owner) public onlyOwner returns(bool){
        require(_owner != address(0x0));
        RSKYToken.transfer(_owner,RSKYToken.balanceOf(address(this)));
    }
    
    function getPageInfo() public view returns(uint256 ,uint256 ,uint256){
        address _owner = msg.sender;
        uint256 _RSKYNum = 0;
        if(playerInfo[_owner].totalUsdtNum > 0){
             Player memory player = playerInfo[_owner];
             uint256 _totalUsdtNum = player.totalUsdtNum;
            _RSKYNum =_totalUsdtNum.div(usdtDecimals).mul(RSKYDecimals).mul(convertRate);
            uint256 totalRSKYNum = player.totalRSKYNum; 
           _RSKYNum = _RSKYNum.sub(totalRSKYNum);
        }
         return(alreadyAmount,drawCoinTime,_RSKYNum);
    }
    
    function setStartTime(uint256 _time) public onlyOwner returns(bool){
        collectStartTime = _time;
        return true;
    }
    
    function setEndTime(uint256 _time) public onlyOwner returns(bool){
        collectEndTime = _time;
        return true;
    }
    
    function setDrawCoinTime(uint256 _time) public onlyOwner returns(bool){
        drawCoinTime = _time;
        return true;
    }
    
    modifier onlyOwner(){
        require(owner == msg.sender,"Must be an owner");
        _;
    }
}