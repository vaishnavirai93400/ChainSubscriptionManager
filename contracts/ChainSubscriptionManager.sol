// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ChainSubscriptionManager {
    address public owner;
    uint256 public subscriptionCounter;
    
    struct Subscription {
        uint256 id;
        address subscriber;
        uint256 planId;
        uint256 startTime;
        uint256 endTime;
        uint256 amount;
        bool isActive;
    }
    
    struct Plan {
        uint256 id;
        string name;
        uint256 price;
        uint256 duration; // in seconds
        bool isActive;
    }
    
    mapping(uint256 => Subscription) public subscriptions;
    mapping(address => uint256[]) public userSubscriptions;
    mapping(uint256 => Plan) public plans;
    uint256 public planCounter;
    
    event SubscriptionCreated(uint256 indexed subscriptionId, address indexed subscriber, uint256 planId);
    event SubscriptionCanceled(uint256 indexed subscriptionId, address indexed subscriber);
    event PlanCreated(uint256 indexed planId, string name, uint256 price, uint256 duration);
    event FundsWithdrawn(address indexed owner, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        subscriptionCounter = 0;
        planCounter = 0;
    }
    
    function createPlan(string memory _name, uint256 _price, uint256 _duration) external onlyOwner {
        planCounter++;
        plans[planCounter] = Plan(planCounter, _name, _price, _duration, true);
        emit PlanCreated(planCounter, _name, _price, _duration);
    }
    
    function subscribe(uint256 _planId) external payable {
        require(plans[_planId].isActive, "Plan does not exist or is inactive");
        require(msg.value >= plans[_planId].price, "Insufficient payment");
        
        subscriptionCounter++;
        uint256 endTime = block.timestamp + plans[_planId].duration;
        
        subscriptions[subscriptionCounter] = Subscription(
            subscriptionCounter,
            msg.sender,
            _planId,
            block.timestamp,
            endTime,
            msg.value,
            true
        );
        
        userSubscriptions[msg.sender].push(subscriptionCounter);
        emit SubscriptionCreated(subscriptionCounter, msg.sender, _planId);
    }
    
    function cancelSubscription(uint256 _subscriptionId) external {
        require(subscriptions[_subscriptionId].subscriber == msg.sender, "Not your subscription");
        require(subscriptions[_subscriptionId].isActive, "Subscription already inactive");
        
        subscriptions[_subscriptionId].isActive = false;
        emit SubscriptionCanceled(_subscriptionId, msg.sender);
    }
    
    function isSubscriptionActive(uint256 _subscriptionId) external view returns (bool) {
        Subscription memory sub = subscriptions[_subscriptionId];
        return sub.isActive && block.timestamp <= sub.endTime;
    }
    
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        payable(owner).transfer(balance);
        emit FundsWithdrawn(owner, balance);
    }
}