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



pragma solidity ^0.6.10;


interface UniPrice{
    function getPrice(address token1,address token2) external view returns(uint256 amount1,uint256 amount2);    
}

contract DividendPool{ 
    
    using Address for address;
    using SafeMath for uint;
    
    BrunFaFang private brunFaFang;
    
    UniPrice public uinPrice;
    
    address public usdtAddress;
    
    
    IERC20 public RSKY;
    
    address public RSKY_ADDR;
    
    IERC20 public USKY;
    
    address public USKY_ADDR;
    
    address public owner;
    
    uint256 public WEI_RSKY;
    
    uint256 private WEI_USKY;
    
    uint256 public MIAO_INCOME_FENZI = 1388;
    
    uint256 public YEAR_RATE = 73000000000;
    
    uint256 private totalUSKYValue;
    
    uint256 private myUnit = 10 ** 6;
    
    uint256 private rateUnit = 10 ** 8;
    
    
    
    
    struct Player{
         address walletAddress;
         uint  join_timestamp;
         uint  pledgeTime;
         uint  next_profit_time;
         uint256 totalValue;
         uint256 lastValue;
         uint256 totalIncome;
         uint256 lastIncome;
         uint256 destroyUSKY;
    }
    
    mapping(address => Player) playerInfo;    
    
    constructor(address _RSKYAddr,address _USKYAddr,address _owner,address burnAddress,address _uniAddress,address _usdtAddress) public{
        RSKY_ADDR =_RSKYAddr;
        RSKY = IERC20(RSKY_ADDR);
        USKY_ADDR = _USKYAddr;
        USKY=IERC20(USKY_ADDR);
        owner = _owner;
        WEI_RSKY =10 ** 8;
        WEI_USKY =10 ** 8;
        brunFaFang=BrunFaFang(burnAddress);
        uinPrice = UniPrice(_uniAddress);
        usdtAddress = _usdtAddress;
    }      
    

    event pledgeTokenEvn(address indexed fromAddress, uint indexed value);
    
    

    function findPlayerInfo() public view returns(uint256 _totalUSKYValue,uint256 _YEAR_RATE,uint256 _usdtRSKYPrice,uint256 _RSKYNum,
    uint256 _incomeNum,uint256 _USKYNum,uint256 _hisUSKYNum,uint256 _hisRSKYNum,uint256 _hisDestUSKYNum,uint256 pledgeTime                    
    ){
        address _owner = msg.sender;
        //require(_owner != address(0),'request error');
        _totalUSKYValue = totalUSKYValue;
        _YEAR_RATE = YEAR_RATE;
        _usdtRSKYPrice = getRSKYUsdtPrice();
         _RSKYNum = RSKY.balanceOf(address(this));
        if(playerInfo[_owner].totalValue <= 0){
            return(_totalUSKYValue,_YEAR_RATE,_usdtRSKYPrice,_RSKYNum,0,0,0,0,0,0);
        }
        Player memory player = playerInfo[_owner];
         _USKYNum = player.lastValue;
        _incomeNum =player.lastIncome.add(getTotalIncome(player.next_profit_time,_USKYNum,player.lastIncome));
        _hisUSKYNum = player.totalValue;
        _hisRSKYNum = player.totalIncome;
        _hisDestUSKYNum = player.destroyUSKY;
        return(_totalUSKYValue,_YEAR_RATE,_usdtRSKYPrice,_RSKYNum,_incomeNum,_USKYNum,_hisUSKYNum,_hisRSKYNum,_hisDestUSKYNum,player.pledgeTime);
    }


    function pledgeToken(uint256 _value) public onlyAuthModify returns(bool){
        address _owner = msg.sender;
        if(playerInfo[_owner].totalValue <= 0){
            Player memory player = Player(msg.sender,block.timestamp,block.timestamp,block.timestamp,_value,_value,0,0,0);
            playerInfo[_owner] = player;
        }else{
            Player memory player = playerInfo[msg.sender];
            player.totalValue=player.totalValue.add(_value);
            uint256 incomeVaue = getTotalIncome(player.next_profit_time,player.lastValue,player.lastIncome);
            uint256 lastValue = player.lastValue.add(_value);
            player.lastValue=lastValue;
            player.lastIncome = player.lastIncome.add(incomeVaue);
            player.next_profit_time = block.timestamp;
            playerInfo[msg.sender] = player;
        }
        totalUSKYValue =totalUSKYValue.add(_value); 
        USKY.transferFrom(_owner,address(this),_value);
        emit pledgeTokenEvn(_owner,_value);
    }
    
    
    
    event sendUSKYEvn(address indexed _owner,uint256 indexed USKYNum); 
    
    function sendUSKY(uint256 _value) public onlyAuthModify returns(bool){
        address _owner = msg.sender;
        require(playerInfo[_owner].totalValue > 0,'Insufficient balance');
        Player memory player = playerInfo[_owner];
        uint256 lastValue =  player.lastValue;
        require(lastValue >= _value,'Insufficient balance');
        uint256 incomeVaue = player.lastIncome.add(getTotalIncome(player.next_profit_time,lastValue,player.lastIncome));
        uint256 higValue = lastValue.sub(incomeVaue);
        require(higValue >= _value,'Insufficient balance');
        player.lastValue = lastValue.sub(_value);
        player.lastIncome = incomeVaue;
        player.next_profit_time = block.timestamp;        
        playerInfo[_owner] = player;
        totalUSKYValue = totalUSKYValue.sub(_value);
        USKY.transfer(_owner,_value);
        emit sendUSKYEvn(_owner,_value);
        return true;
    }    
    
     event sendRSKYEvn(address indexed _owner,uint256 indexed USKYNum);     

    function sendRSKY(uint256 _RSKYNum) public onlyAuthModify returns(bool){
        address _owner = msg.sender;
        require(!brunFaFang.isExits(_owner),'IS blacklist');
        require(playerInfo[_owner].totalValue > 0,'Insufficient balance');
        Player memory player = playerInfo[_owner];
        uint256 _incomeNum =player.lastIncome.add(getTotalIncome(player.next_profit_time,player.lastValue,player.lastIncome));
        require(_RSKYNum <= _incomeNum,'Insufficient balance income');
        _incomeNum = _RSKYNum;
        uint256 lastValue =  player.lastValue;
        uint256 usdtNum = _incomeNum;
        uint256 RSKYNum = usdtNum.mul(myUnit).div(getRSKYUsdtPrice());
        uint256 destroyUSKY =player.destroyUSKY.add(usdtNum);
        lastValue = lastValue.sub(usdtNum);
        player.lastValue = lastValue;
        player.totalIncome = player.totalIncome.add(usdtNum);
        player.lastIncome = 0;
        player.destroyUSKY = destroyUSKY;
        player.next_profit_time = block.timestamp;
        playerInfo[_owner] = player;
        RSKY.transfer(_owner,RSKYNum);
        emit sendRSKYEvn(_owner,RSKYNum);
        return true;
    }    
    
    function sendRSKYAndUSKY(uint256 USKYNum,uint256 _RSKYNum) public returns(bool){
        sendRSKY(_RSKYNum);
        sendUSKY(USKYNum);
        return true;
    }       

    function getRSKYUsdtPrice() public view returns(uint256){
        (uint256 amount1,uint256 amount2) = uinPrice.getPrice(RSKY_ADDR,usdtAddress);
        uint256 RSKYUint = 10 ** 8;
        uint256 usdtUint = 10 ** 18;
        uint256 RSKYNum = amount1.div(RSKYUint,'RSKYNum div error');
        uint256 usdtNum = amount2.div(usdtUint,'usdtNum div error');
        return usdtNum.mul(myUnit).div(RSKYNum);
    } 
    
    
    
    function getTotalIncome(uint _nextTime,uint _USKYNum,uint256 _lstIncome) private view returns(uint256){
        uint256 nowTime = now;
        if(nowTime <= _nextTime){
            return 0;
        }else{
            uint256 difseconds = nowTime.sub(_nextTime);
            uint256 secondsm = 60;
            uint minutesm = difseconds.div(secondsm);
            uint256 USKYNum = _USKYNum.div(rateUnit);
            uint256 lastIncome = MIAO_INCOME_FENZI.mul(minutesm).mul(USKYNum);
            uint256 totalIncome = lastIncome.add(_lstIncome);
            if(totalIncome > _USKYNum){
                lastIncome = _USKYNum.sub(_lstIncome);
            }
            return lastIncome;
        }
    }

    function setRate(uint _YEAR_RATE,uint _MIAO_INCOME_FENZI) public onlyOwner returns(bool){
        YEAR_RATE = _YEAR_RATE;
        MIAO_INCOME_FENZI = _MIAO_INCOME_FENZI;
        return true;
    }


    modifier onlyOwner(){
        require(owner == msg.sender,"Must be an owner");
        _;
    }
   modifier onlyAuthModify(){
        require(!isContract(msg.sender),"contract not allowed");
        require(msg.sender==tx.origin,"proxy contract not allowed");
        _;
    }
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size>0;
    }    
    
}