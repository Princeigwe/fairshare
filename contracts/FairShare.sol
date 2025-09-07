//SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/utils/Strings.sol";

contract FairShare {

  uint256 groupId = 0;

  //* STRUCTS
  struct GroupMember{
    address addr;
    string displayName;
  }

  // group struct
  struct Group{
    string name;
    uint256 id;
    string tag;
    string description;
    uint256 memberCount;
    uint256 balance;
  }

  //* ARRAYS
  // groups
  string[] public groupTags;

  //* MAPPINGS
  mapping(address => string) private userDisplayName;

  // group membership
  mapping(string => mapping(address => bool)) private isGroupMember;

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
      memberCount: 0,
      balance: 0
    });

    // add the sender creating the group as a member of the group
    GroupMember memory theAlpha = GroupMember({
      addr: msg.sender,
      displayName: "The Alpha"
    });
    groupMembers[newGroup.tag].push(theAlpha);

    userDisplayName[msg.sender]=theAlpha.displayName;
    isGroupMember[newGroup.tag][msg.sender] = true;
    groupUserBalance[newGroup.tag][msg.sender] = 0;
    group[newGroup.tag] = newGroup;
    groupTags.push(newGroup.tag);

    groupId++;
    emit CreatedGroup("Group created", newGroup.name, newGroup.id, newGroup.tag, newGroup.description, newGroup.memberCount, newGroup.balance);
  }

  function getGroups() public view returns(string[] memory){
    return groupTags;
  }

  function getGroup(string memory groupTag)public view returns(Group memory){
    require(isGroupMember[groupTag][msg.sender], "Unauthorized request to group detail");
    return group[groupTag];
  }


  function addMember()public{}
}