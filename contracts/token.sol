// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Owership{

address public contractOwer;
address public newOwer;

event TransferOwership (address indexed _from, address indexed _to);
constructor (address set){
    contractOwer= set;
}

function changeOwer(address _to) public{
    require (msg.sender ==contractOwer, 'only Ower of the contract cen execute it');
    newOwer = _to;
}

function acceptOwer()public{
    require(msg.sender == newOwer, 'only new assigned Ower can call it');
    emit TransferOwership(contractOwer,newOwer);
    contractOwer = newOwer;
    newOwer= address(0);
}


}
