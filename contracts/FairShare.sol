//SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/utils/Strings.sol";

contract FairShare {

  uint256 groupId = 0;

  //* STRUCTS
  struct GroupMember{
    address addr;
    string displayName;
    uint256 balance;
  }

  // structs
  struct Group{
    string name;
    uint256 id;
    string tag;
    string description;
    uint256 memberCount;
    uint256 balance;
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

  //* EVENTS
  event CreatedGroup(string message, string name, uint256 id, string tag, string description, uint256 memberCount, uint256 balance);
  event GroupDetail(string name, uint256 id, string tag, string description, uint256 memberCount, uint256 balance); 

  function createGroup(string memory _name, string memory _description)public{
    string memory groupStringId = Strings.toString(groupId); // converting int to string with OZ Strings library
    Group memory newGroup = Group({
      name: _name,
      id: groupId,
      tag: string(abi.encodePacked(_name,"-" ,groupStringId)),
      description: _description,
      memberCount: 1,
      balance: 0
    });

    // add the sender creating the group as a member of the group
    GroupMember memory theAlpha = GroupMember({
      addr: msg.sender,
      displayName: "The Alpha",
      balance: 0
    });
    groupMembers[newGroup.tag].push(theAlpha);

    userDisplayName[msg.sender]=theAlpha.displayName;
    isGroupMember[newGroup.tag][msg.sender] = true;
    isGroupAdmin[newGroup.tag][msg.sender] = true;
    groupUserBalance[newGroup.tag][msg.sender] = 0;
    group[newGroup.tag] = newGroup;
    groupTags.push(newGroup.tag);

    groupId++;
    emit CreatedGroup("Group created", newGroup.name, newGroup.id, newGroup.tag, newGroup.description, newGroup.memberCount, newGroup.balance);
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
    Group storage _group = group[_groupTag]; // marking it as 'storage' to make reference to existing struct for updates
    GroupMember memory newMember = GroupMember({
      addr: _addr,
      displayName: _displayName,
      balance: 0
    });
    userDisplayName[msg.sender] = newMember.displayName;
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

}