// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

contract HashRewards {

    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    struct Quest {
        uint256 id;
        uint256 rewardPoints;
        bool active;
    }

    struct Receipt {
        uint256 questId;
        bytes32 receiptHash;
        uint256 timestamp;
    }

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => Quest) private quests;
    mapping(address => uint256) private userPoints;
    mapping(address => Receipt[]) private receiptHistory;

    uint256 public totalQuests;
    address public owner;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event QuestCreated(uint256 indexed questId, uint256 rewardPoints);
    event QuestStatusUpdated(uint256 indexed questId, bool active);
    event QuestCompleted(address indexed user, uint256 indexed questId, uint256 points);
    event ReceiptStored(address indexed user, uint256 indexed questId, bytes32 receiptHash);

    /*//////////////////////////////////////////////////////////////
                                MODIFIER
    //////////////////////////////////////////////////////////////*/

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        owner = msg.sender;

        _createQuest(1, 10);
        _createQuest(2, 20);
        _createQuest(3, 30);
        _createQuest(4, 50);
    }

    /*//////////////////////////////////////////////////////////////
                          QUEST MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    function _createQuest(uint256 questId, uint256 rewardPoints) internal {
        quests[questId] = Quest({
            id: questId,
            rewardPoints: rewardPoints,
            active: true
        });

        totalQuests++;
        emit QuestCreated(questId, rewardPoints);
    }

    function createQuest(uint256 questId, uint256 rewardPoints) external onlyOwner {
        require(quests[questId].id == 0, "Quest exists");
        _createQuest(questId, rewardPoints);
    }

    function setQuestStatus(uint256 questId, bool active) external onlyOwner {
        require(quests[questId].id != 0, "Invalid quest");
        quests[questId].active = active;
        emit QuestStatusUpdated(questId, active);
    }

    /*//////////////////////////////////////////////////////////////
                          QUEST COMPLETION
    //////////////////////////////////////////////////////////////*/

    function completeQuest(uint256 questId, bytes32 receiptHash) external {
        Quest memory quest = quests[questId];

        require(quest.id != 0, "Invalid quest");
        require(quest.active, "Quest inactive");
        require(receiptHash != bytes32(0), "Invalid hash");

        receiptHistory[msg.sender].push(
            Receipt({
                questId: questId,
                receiptHash: receiptHash,
                timestamp: block.timestamp
            })
        );

        userPoints[msg.sender] += quest.rewardPoints;

        emit ReceiptStored(msg.sender, questId, receiptHash);
        emit QuestCompleted(msg.sender, questId, quest.rewardPoints);
    }

    /*//////////////////////////////////////////////////////////////
                              VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getQuest(uint256 questId) external view returns (Quest memory) {
        return quests[questId];
    }

    function getUserPoints(address user) external view returns (uint256) {
        return userPoints[user];
    }

    function getUserReceipts(address user) external view returns (Receipt[] memory) {
        return receiptHistory[user];
    }

    function getAllQuests() external view returns (Quest[] memory) {
        Quest[] memory list = new Quest[](totalQuests);

        for (uint256 i = 1; i <= totalQuests; i++) {
            list[i - 1] = quests[i];
        }

        return list;
    }
}
