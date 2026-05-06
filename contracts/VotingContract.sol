// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";

import "hardhat/console.sol";
contract Create {
  using Counters for Counters.Counter;

  Counters.Counter public _voterId;
  Counters.Counter public _candidateId;

  address public votingOrganizer;//the one who deploys the contract

  //candidate for voting
  struct Candidate {
    uint256 candidateId;
    string age;
    string name;
    string image;
    uint256 voterCount;  //how much vote candidate have recieved
    address _address;
    string ipfs;
//     IPFS is a decentralized storage system where:
// Files are not stored on a central server
// Instead, they are stored across a network
// Each file gets a unique hash (CID)
  }
  //event is cheaper way to store data on blockchain and can be accessed by off-chain applications
  // searchable and filterable from outside the blockchain
  event CandidateCreate(
    uint256 indexed candidateId,
    string age,
    string name,
    string image,
    uint256 voterCount,
    address _address,
    string ipfs
  );

  address[] public candidateAddress;
  mapping(address => Candidate) public candidates; //function candidates(address) returns (Candidate)
  //candidates[msg.sender].name;

  //voters Data Structure
  address[] public votedVoters;
  address[] public votersAddress;
  mapping(address => Voter) public voters; //function voters(address) returns (Voter)

  struct Voter {
    uint256 voter_voterId;
    string voter_name;
    string voter_image;
    address voter_address;
    uint256 voter_allowed;
    bool voter_voted;
    uint256 voter_vote; //candidateId
    string voter_ipfs;
  }

  event VoterCreated(
    uint256 indexed voter_voterId,
    string voter_name,
    string voter_image,
    address voter_address,
    uint256 voter_allowed,
    bool voter_voted,
    uint256 voter_vote,
    string voter_ipfs
  );

  // ----------------End of voter data----------------------//
  constructor () {
    votingOrganizer = msg.sender;
  }

  //🧠 temporary memory during execution and dynamic its referance not directly stored address referance 
  function  setCandidate(address _address,string memory _age,string memory _name,string memory _image,string memory _ipfs) public{
    require(msg.sender == votingOrganizer, "Only voting organizer can add or createcandidates");
    _candidateId.increment();
    uint256 newCandidateId = _candidateId.current();
    Candidate storage candidate = candidates[_address];//it doesnot copy data ref point to storage and update the original data in storage
    candidate.age = _age;
    candidate.name = _name;
    candidate.image = _image;
    candidate.candidateId = newCandidateId;
    candidate._address = _address;
    candidate.ipfs = _ipfs;
    candidate.voterCount = 0;
    candidateAddress.push(_address);
    emit CandidateCreate(newCandidateId, _age, _name, _image, candidate.voterCount, _address, _ipfs);
  }

//   view ===============View functions=================
// 👉 This means:
// Read-only function
// Does NOT modify blockchain state
// Free (no gas if called externally)
  //Return a list of all candidate addresses stored in your contract.
  function getCandidate() public view returns (address[] memory){
    return candidateAddress;
  }
  function getCandidateLength()  public view returns (uint256) {
    return candidateAddress.length;
  }
  // Candidate memory means it creates a temporary data in memory and returns it after that removes
  function getCandidateData(address _address) public view returns (Candidate memory) {
    return candidates[_address];
  }
  function voterRight(address _address,string memory name , string memory _image,string memory _ipfs) public {
    require(votingOrganizer == msg.sender, "Only voting organizer can give right to vote");
    _voterId.increment();
    uint256 newVoterId = _voterId.current();
    Voter storage voter = voters[_address];
    require(voter.voter_allowed == 0, "Voter already has the right to vote");
    voter.voter_allowed = 1;
    voter.voter_voterId = newVoterId;
    voter.voter_name = name;
    voter.voter_image = _image;
    voter.voter_address = _address;
    voter.voter_ipfs = _ipfs;
    voter.voter_voted = false;
    voter.voter_vote = 1000; //for safe side
    votersAddress.push(_address);
    emit VoterCreated(newVoterId, name, _image, _address, voter.voter_allowed, voter.voter_voted, voter.voter_vote, _ipfs);
  }

  function vote(address _candidateAddress,uint _candidateVoteId) external{
    Voter storage voter = voters[msg.sender];
    require(!voter.voter_voted, "You have already voted");
    require(voter.voter_allowed == 1, "You do not have the right to vote");
    voter.voter_voted = true;
    voter.voter_vote = _candidateVoteId;
    votedVoters.push(msg.sender);
    // Candidate storage candidate = candidates[_candidateAddress];
    candidates[_candidateAddress].voterCount += 1;
  }
  function getVoterLength() public view returns (uint256) {
    return votersAddress.length;
  }
  function getVoterData(address _address) public view returns(Voter memory){
    return voters[_address];
  }
  function getVotedVoterList() public view returns (address[] memory) {
    return votedVoters;
  }
  function getVoterList() public view returns (address[] memory) {
    return votersAddress;
  }
}
