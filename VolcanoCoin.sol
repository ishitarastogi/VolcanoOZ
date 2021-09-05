
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * 1
 * import from Open Zeppelin’s Ownable contract
 * remove the modifiers
 */
import "@openzeppelin/contracts/access/Ownable.sol";  
/**
 * 2
 * import from Open Zeppelin’s ERC20.sol contract
 * remove the return totalSupply and balance function
 */                                                    
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract VolcanoCoin is ERC20, Ownable{
    
        uint public initialSupply = 10000;  


/**
 * 2,3,4,5
 * Added constructor arguments to inherited ERC20 , can also be set at deploy time
 * Generate new token equals to the initialSupply
 */  
        constructor() ERC20("Volcano Coin", "VLC"){
        _mint(msg.sender, initialSupply);
        administrator = msg.sender;
    }
    
    /**
 * 1
 * enums allows to set some predefined values
 * here 5 types of payment are defined
 */
    enum PaymentTypes { UNKNOWN, BASICPAYMENT, REFUND, DEVIDEND, GROUPPAYMENT }
   
    address private administrator;
    uint id;
    
    struct Payment{
        uint transferAmount;
        address recipient;
        uint timeStamp;
        string comment;
        uint uniqueId;
        PaymentTypes paymentTypes;
    }
    
    
    event changedTotalSupply(uint);
    event transferE(uint256, address);

    mapping(address => Payment[]) payments;
    
    
    modifier onlyAdminstrator(){
        if(msg.sender == administrator){
            _;
        }
    }
    
    
/**
 * 6
 * _msgSender()=> Returns the address of the current owner from OZ ownable which inherits context that has _msgSender() function.
 * totalSupply() => Return total supply  
 * mint the latest tokenSupply amount to the owner.
 */
    
    
    function changeTotalSupply() public onlyOwner {
        _mint(_msgSender(), totalSupply());
        emit changedTotalSupply(totalSupply());
    }
    
    
    function transfer(address _recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), _recipient, amount);       //transfer amount from owner to recipient
        
        Payment[] storage details = payments[_msgSender()]; //payments[_msgSender()] => holds the value of array of struct Payment
                                                            //value assinged to variable details of type array(array of struct Payment)
                                                            
        details.push(Payment({                              //push struct data in array 
            uniqueId: ++id,                                 //unique identifier(id will increase everytime by one )
            timeStamp: block.timestamp,                     //timestamp of the current block in seconds
            paymentTypes: PaymentTypes.UNKNOWN,             //accessing enum value
            comment: '',                                    //Blank comment
            recipient: _recipient,                    //address where amount need to be transfer
            transferAmount: amount                          // amount ned to be transfer
        }));
        
        //second  method
        // payments[msg.sender].push(Payment(++id, block.timestamp,, PaymentTypes.UNKNOWN ,'',recipient, ++id));

        payments[_msgSender()] = details; //assigning the values to the owner address
        emit transferE(amount,_recipient); //event emitted(logs)
        return true; //if transfer happen successfully , return true
    }
    


    
    function updatePayment(uint _id, PaymentTypes _paymenttype, string memory _comment) public  {
        require(_id != 0, "Id invalid"); //id should not be equal to zero
/**
 * enum return or accept integer value, PaymentTypes.UNKNOWN should be 0 and PaymentTypes.GROUPPAYMENT should be int48
 * the value accepted by the function should be between 1 to 4
 */
        require(_paymenttype >= PaymentTypes.UNKNOWN && _paymenttype <= PaymentTypes.GROUPPAYMENT, "Not in range");
        require(bytes(_comment).length != 0, "length should be greater than zero");
        
        Payment[] storage recordUser = payments[_msgSender()]; //storing data of struct in particular address and assigning it to variable details of type array of struct
        for(uint i=0; i<recordUser.length; i++){
            
 /**
 *   accessing id of struct   [{id:1,...},{}]           details[0]={id:1,...}  details[0].id=1
 */
 
                if(recordUser[i].uniqueId == _id){              //if id matches then code inside this executed
                Payment storage payment = recordUser[i];        //payment= details[0]={id:1,...} 
                payment.paymentTypes = _paymenttype;             //access struct values using dot , updating new PaymentType
                payment.comment = _comment;                     // updating comment
                break;                                          //go out off the loop when entered id matches
            }
        }
    }
    
    
    function updatePaymentAdmin(uint _id, PaymentTypes _paymenttype, string memory _comment) public onlyAdminstrator {
        
        require(_id != 0, "should be greater than zero"); 
        require(_paymenttype >= PaymentTypes.UNKNOWN && _paymenttype <= PaymentTypes.GROUPPAYMENT, "Not in range");
        require(bytes(_comment).length != 0, "length should be greater than zero");

        string memory text = string(abi.encodePacked( _comment, " updated by ", Strings.toHexString(uint256(uint160(administrator)))));
        updatePayment(_id, _paymenttype, text);
    }


    function returnPaymentDetails(address _address) public view returns(Payment[] memory) {
        return payments[_address];
    }
}
