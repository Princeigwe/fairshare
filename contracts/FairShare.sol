//SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/utils/Strings.sol";

contract FairShare {

  uint256 groupId = 0;
  uint256 expenseId = 0;

  //* STRUCTS
  struct GroupMember{
    address addr;
    string displayName;
  }

  // structs
  struct Group{
    string name;
    uint256 id;
    string tag;
    string description;
    uint256 memberCount;
    uint256 contribution; // total Ether contributions to the group
  }

  struct Expense{
    string name;
    uint256 id;
    string tag;
    uint256 amount;
    string paidByDisplayName;
    address paidByAddr;
    address payeeAddr;
  }

  struct AddedMemberResponse{
    string message;
    string displayName;
    address addr;
    string groupTag; 
  }

  struct GroupMembersResponse{
    GroupMember[] members;
    uint256 memberCount;
  }

  //* ARRAYS
  // groups
  string[] public groupTags;

  //* MAPPINGS
  mapping(address => string) private userDisplayName;

  // group membership
  mapping(string => mapping(address => bool)) private isGroupMember;

  // group admin
  mapping(string => mapping(address => bool)) private isGroupAdmin;

  // group members
  mapping(string => GroupMember[]) private groupMembers;

  // group-user balance
  mapping(string => mapping(address => int256)) private groupUserBalance;

  mapping(string => Group)group;

  // group expenses
  mapping(string => Expense[]) private groupExpenses;

  //* EVENTS
  event CreatedGroup(string message, string name, uint256 id, string tag, string description, uint256 memberCount, uint256 balance);
  event GroupDetail(string name, uint256 id, string tag, string description, uint256 memberCount, uint256 balance); 
  event PaidExpenseResponse(string message, string groupTag, Expense expense, uint256 memberCount);
  event Settlement(string message, uint256 balance, address addr, string displayName);


  // function to receive Ether
  receive() external payable {}

  function createGroup(string memory _name, string memory _description)public{
    string memory groupStringId = Strings.toString(groupId); // converting int to string with OZ Strings library
    Group memory newGroup = Group({
      name: _name,
      id: groupId,
      tag: string(abi.encodePacked(_name,"-" ,groupStringId)),
      description: _description,
      memberCount: 1,
      contribution: 0
    });

    // add the sender creating the group as a member of the group
    GroupMember memory theAlpha = GroupMember({
      addr: msg.sender,
      displayName: "The Alpha"
    });
    groupMembers[newGroup.tag].push(theAlpha);

    userDisplayName[msg.sender]=theAlpha.displayName;
    isGroupMember[newGroup.tag][msg.sender] = true;
    isGroupAdmin[newGroup.tag][msg.sender] = true;
    groupUserBalance[newGroup.tag][msg.sender] = 0;
    group[newGroup.tag] = newGroup;
    groupTags.push(newGroup.tag);

    groupId++;
    emit CreatedGroup("Group created", newGroup.name, newGroup.id, newGroup.tag, newGroup.description, newGroup.memberCount, newGroup.contribution);
  }

  function getGroups() public view returns(string[] memory){
    return groupTags;
  }

  function getGroup(string memory _groupTag)public view returns(Group memory){
    require(isGroupMember[_groupTag][msg.sender], "Unauthorized request to group detail");
    return group[_groupTag];
  }


  function addMember(string memory _groupTag, address _addr, string memory _displayName)public returns(AddedMemberResponse memory) {
    require(isGroupAdmin[_groupTag][msg.sender], "Unauthorized request to add group member");
    require(!isGroupMember[_groupTag][_addr], "This address is already a member of this group");
    Group storage _group = group[_groupTag]; // marking it as 'storage' to make reference to existing struct for updates
    GroupMember memory newMember = GroupMember({
      addr: _addr,
      displayName: _displayName
    });
    userDisplayName[_addr] = newMember.displayName;
    isGroupMember[_groupTag][_addr] = true;
    groupUserBalance[_groupTag][_addr] = 0;
    
    groupMembers[_groupTag].push(newMember);
    _group.memberCount = _group.memberCount + 1;

    groupUserBalance[_groupTag][_addr] = 0;

    AddedMemberResponse memory response = AddedMemberResponse({
      message: string(abi.encodePacked("New member added to ", _groupTag)),
      displayName: _displayName,
      addr: _addr,
      groupTag: _groupTag
    });
    return response;
  }

  function getGroupMembers(string memory _groupTag) public view returns(GroupMembersResponse memory) {
    require(isGroupMember[_groupTag][msg.sender], "Unauthorized request to group detail");
    Group memory _group = getGroup(_groupTag);
    GroupMember[] memory _groupMembers = groupMembers[_groupTag];
    GroupMembersResponse memory groupMembersResponse = GroupMembersResponse({
      members: _groupMembers,
      memberCount: _group.memberCount
    });
    return groupMembersResponse;
  }

  function payExpense(string memory _groupTag, string memory _name , address payable _payee)public payable {
    require(isGroupMember[_groupTag][msg.sender], "Unauthorized request to pay expense");
    require(msg.value > 0, "Must send ETH to pay expense");
    require(_payee != address(0), "Invalid payee address");

    string memory expenseStringId = Strings.toString(expenseId); // converting int to string with OZ Strings library
    string memory displayName = userDisplayName[msg.sender];
    // create a new expense
    Expense memory newExpense = Expense({
      name: _name,
      id: expenseId,
      tag: string(abi.encodePacked(_name,"-" ,expenseStringId)),
      amount: msg.value,
      paidByAddr: msg.sender,
      paidByDisplayName: displayName,
      payeeAddr: _payee
    });

    // update group expenses
    groupExpenses[_groupTag].push(newExpense);

    expenseId++;

    GroupMember[] storage _groupMembers = groupMembers[_groupTag];
    Group storage groupUpdate = group[_groupTag];
    uint256 memberCount = group[_groupTag].memberCount;

    int256 share = int256(msg.value) / int256(memberCount);
    for(uint256 i = 0; i < _groupMembers.length; i++){
      GroupMember storage memberUpdate =  _groupMembers[i];
      if(memberUpdate.addr == msg.sender){
        groupUserBalance[_groupTag][memberUpdate.addr] += int256(share * int256(memberCount - 1));
      }
      else{
        groupUserBalance[_groupTag][memberUpdate.addr] -= share;
      }
      
    }

    groupUpdate.contribution = groupUpdate.contribution + msg.value;

    // transfer funds to payee
    _payee.transfer(msg.value);

    emit PaidExpenseResponse("Expense paid successfully", _groupTag, newExpense, memberCount);
  }

  function getExpenses(string memory _groupTag)public view returns(Expense[] memory){
    require(isGroupMember[_groupTag][msg.sender], "Unauthorized request to fetch expenses for group");
    Expense[] memory expenses = groupExpenses[_groupTag];
    return expenses;
  }

  function getUserBalance(string memory _groupTag)public view returns(int256){
    require(isGroupMember[_groupTag][msg.sender], "Unauthorized request to check balance");
    return groupUserBalance[_groupTag][msg.sender];
  }

  function getGroupBalances(string memory _groupTag)public view returns(address[] memory addressesReturn, int256[] memory balancesReturn){
    require(isGroupMember[_groupTag][msg.sender], "Unauthorized: Not a group member");

    GroupMember[] storage _groupMembers = groupMembers[_groupTag];
    uint256 memberCount = _groupMembers.length;
    address[] memory addresses = new address[](memberCount);
    int256[] memory balances = new int256[](memberCount);
    for (uint256 i = 0; i < memberCount; i++) {
      address memberAddress = _groupMembers[i].addr;
      addresses[i] = memberAddress;
      balances[i] = groupUserBalance[_groupTag][memberAddress];
    }
    return(addresses, balances);
  }
  

  function settleUp(string memory _groupTag) external payable {
    require(isGroupMember[_groupTag][msg.sender], "Not a group member");

    int256 debtorBalance = groupUserBalance[_groupTag][msg.sender];
    require(debtorBalance < 0, "You owe nothing");
    uint256 debt = uint256(-debtorBalance);
    require(msg.value <= debt, "Too much sent");

    uint256 remaining = msg.value;
    GroupMember[] storage _groupMembers = groupMembers[_groupTag];

    // this loop works to credit those that are being owed
    for (uint256 i = 0; i < _groupMembers.length && remaining > 0; i++) {
      address creditor = _groupMembers[i].addr;
      int256 creditorBalance = groupUserBalance[_groupTag][creditor];

      if (creditorBalance > 0) {
        // if creditor balance is less than the amount of ETH sent, 
        // then the amount to pay is the creditor balance, else the amount to pay is the amount of ETH sent
        uint256 amountToPay = creditorBalance < int256(remaining) ? uint256(creditorBalance) : remaining;

        // update balances
        groupUserBalance[_groupTag][msg.sender] += int256(amountToPay);
        groupUserBalance[_groupTag][creditor] -= int256(amountToPay);

        // transfer ETH
        payable(creditor).transfer(amountToPay);

        remaining -= amountToPay;
      }
    }

    emit Settlement("Settlement successful", msg.value, msg.sender, userDisplayName[msg.sender]);

    if (remaining > 0) {
      // the overpaid ETH is sent to the contract's account, then to the sender's account
      payable(msg.sender).transfer(remaining);
    }
  }

}