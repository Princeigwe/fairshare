//SPDX-License-Identifier: MIT
pragma solidity 0.8.28;


contract FairShare {

  uint256 groupId = 0;

  struct GroupMember{
    address addr;
    string displayName;
  }

  // group struct
  struct Group{
    string name;
    string identifier; // string concatenation of group name and  groupId
    string description;
    uint256 memberCount;
    uint256 balance;
  }

  mapping(address => string) private userDisplayName;

  // group membership
  mapping(string => mapping(address => bool)) private isGroupMember;

  // group members
  mapping(string => GroupMember[]) private groupMembers;

  // groups
  Group[] public groups;

  // group-user balance
  mapping(string => mapping(address => uint256)) private groupUserBalance;

  event GroupDetail(string, string, string, uint256, uint256); // name, identifier, description, memberCount, balance

  function createGroup(string memory _name, string memory _description)public {
  }

  function getGroup()public{}


  function addMember()public{}
}