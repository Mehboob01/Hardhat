// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleToken {
    mapping(address => uint256) private balances;
    
    constructor(uint256 initialSupply) {
        balances[msg.sender] = initialSupply;
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
