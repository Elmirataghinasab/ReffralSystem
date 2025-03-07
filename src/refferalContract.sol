// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

/////imports/////
import {Token} from "./token.sol";

///interaces////
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}


contract RefferalSystem{



    ////errors////
    error ReferralSystem_YouHaveParticipatedBefore();
    error ReferralSystem_PleaseSendMoreToken();
    error ReferralSystem_YourReferralIdIsWrong();
    error ReferralSystem_YouCannotEnterWithoutReferralId();
    error ReferralSystem_YourTransactionHasFailed();
    error ReferralSystem_MaximumSubsetsReached();
    error ReferralSystem_OwnerDidNotReceiveRightAmount();
    error ReferralSystem_YouCantParticipateWithAddress0();



    ///events///
    event Participated(address indexed user, address refrallId);
    event AddedUser(address indexed user);
    event distributedReward();


    IERC20 public immutable MYUSDT;
    address immutable private owner;


    ///arrays///
    uint256 constant DECIMALS=10**18;
    mapping (address => User) addressToUserStruct;


    ////structs/////   
    struct User{
    uint256 amount;
    address userAdd;
    address parent;
    address leftChild;
    address rightChild;
    uint256 levelUnlocked;
    uint256 leftCount;
    uint256 rightCount;
    }

    constructor(address myusdt){
        owner=msg.sender;
        MYUSDT= IERC20(myusdt);

        User memory user= User({
            amount:0,
            userAdd:msg.sender,
            parent:address(0),
            leftChild:address(0),
            rightChild:address(0),
            levelUnlocked:3,
            leftCount:0,
            rightCount:0            
            });
        addressToUserStruct[msg.sender]=user;
        emit AddedUser(msg.sender);
       
    }

    //function for creating a newuser and pushing in to the tree 
    //upgrades counts for upperlines

    function createUserStruct(
        uint256 _amount,
        address _userAdd,
        address _parent
        )internal{
        User storage parentt = addressToUserStruct[_parent];

        if (parentt.rightChild != address(0) && parentt.leftChild != address(0)) {
            revert ReferralSystem_MaximumSubsetsReached();
        }

        User memory newUserr = User({
            amount: _amount,
            userAdd: _userAdd,
            parent: _parent,
            leftChild: address(0),
            rightChild: address(0),
            levelUnlocked: (_amount <= 30) ? 1 : (_amount <= 40) ? 2 : (_amount > 40) ? 3 : 0,
            leftCount: 0,
            rightCount: 0
        });


        addressToUserStruct[_userAdd]=newUserr;
        emit AddedUser(msg.sender);

        User storage parent = addressToUserStruct[_parent];
        User storage newUser=addressToUserStruct[_userAdd];


        if (parent.leftChild == address(0)) {
            parent.leftChild = _userAdd;
            parent.leftCount++;
        }else if(parent.rightChild == address(0)){
            parent.rightChild = _userAdd;
            parent.rightCount++;
        }
        newUser=parent;
        parent=addressToUserStruct[parent.parent];

            
        while(parent.userAdd != address(0)){
                if(newUser.userAdd == parent.rightChild){
                    parent.rightCount++;
                    newUser=parent;
                    parent=addressToUserStruct[parent.parent];
                }else if(newUser.userAdd == parent.leftChild){
                    parent.leftCount++;
                    newUser=parent;
                    parent=addressToUserStruct[parent.parent];
                }
            }

        distributeReferralRewards(_parent, _amount);
        emit distributedReward();
    }
   
   // function for rewarding upper lines whenever a new user enters

    function distributeReferralRewards(address parent,uint256 amount) internal {

            address parentAdd=addressToUserStruct[parent].parent;
            User storage parentUser = addressToUserStruct[parentAdd];
            User storage user = addressToUserStruct[parent];
            uint256 reward=(amount * DECIMALS) /20;
            bool shouldTransfer=true;

            bool successToDirectParent = MYUSDT.transfer(parent, ((amount * DECIMALS) /10));
                if (!successToDirectParent) {
                   revert ReferralSystem_YourTransactionHasFailed();
                }


        while (parentUser.userAdd != address(0)) {           
            if (parentUser.levelUnlocked == 1){
                if (parentUser.leftCount + parentUser.rightCount >= 6){
                    shouldTransfer=false;
                    break;
                }
            }else if(parentUser.levelUnlocked == 2){
                 if (parentUser.leftCount + parentUser.rightCount >= 11){
                    shouldTransfer=false;
                    break;
                }
            }else {
                if (parentUser.leftCount + parentUser.rightCount >= 16){
                    shouldTransfer=false;
                    break;                    
                }
            }
            if (shouldTransfer) {
                bool success = MYUSDT.transfer(parentUser.userAdd, reward);                
                if (!success) {
                    revert ReferralSystem_YourTransactionHasFailed();
                }               
            }
            user=parentUser;
            parentUser = addressToUserStruct[parentUser.parent];
            

            if (parentUser.parent == address(0)){
                break;
            }
        }

    }

    //function for participate and enter to the referal tree
    function participate(address referralId, uint256 amount) external {

        if(msg.sender == address(0)){
            revert ReferralSystem_YouCantParticipateWithAddress0();
        }

        if (addressToUserStruct[msg.sender].userAdd != address(0)) {
            revert ReferralSystem_YouHaveParticipatedBefore();
        }

        if (referralId == address(0)) {
            revert ReferralSystem_YouCannotEnterWithoutReferralId();
        }

        if (addressToUserStruct[referralId].userAdd == address(0)) {
            revert ReferralSystem_YourReferralIdIsWrong();
        }

        if (amount < 10) {
            revert ReferralSystem_PleaseSendMoreToken();
        }
        

        bool success = MYUSDT.transferFrom(msg.sender, address(this), amount*DECIMALS);
        if (!success) {
            revert ReferralSystem_YourTransactionHasFailed();
        }

        createUserStruct(amount, msg.sender, referralId);
        emit Participated(msg.sender, referralId);


        //transfer left Amount to the owner
        uint256 contractBalance = MYUSDT.balanceOf(address(this));
        if (contractBalance > 0) {
            bool ownerSuccess = MYUSDT.transfer(owner, contractBalance);
            if (!ownerSuccess) {
                revert ReferralSystem_OwnerDidNotReceiveRightAmount();
            }
        }

    }

    //////Getter Functions//////
    function GetOwner()public view returns(address){
        return owner;
        }
    function GetDecimal()public pure returns(uint256){
            return DECIMALS;
        }
        

}