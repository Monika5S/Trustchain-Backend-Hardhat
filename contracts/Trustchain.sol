// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract  Trustchain{
    struct Campaign{
        address owner;
        string title;
        string description;
        uint targetGoal;
        uint deadline;
        uint amountCollected;
        string image;
        address[] donators;
        uint[] donations;
        string charity_org;
        string support_keyword;
    }

    mapping(uint=>Campaign) public campaigns; //to access the campaign list campaigns[0], campaigns[1] etc
    
    uint public numberOfCampaigns=0;

    // Track unique charity organizations
    string[] private charityOrgs;
    mapping(string => bool) private charityOrgExists; // To prevent duplicates

// function to create campaign and return id of that
    function createCampaign(address _owner, string memory _title, string memory _description, uint256 _targetGoal, uint256 _deadline, string memory _image, string memory _charity_org ,string memory _support_keyword) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        // require(campaign.deadline < block.timestamp, "The deadline should be a date in the future.");

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.targetGoal = _targetGoal;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;
        campaign.charity_org = _charity_org;
        campaign.support_keyword = _support_keyword;

        numberOfCampaigns++;

        // Add charity organization if it's not already in the list
        if (!charityOrgExists[_charity_org]) {
            charityOrgs.push(_charity_org);
            charityOrgExists[_charity_org] = true; // Mark it as added
        }

        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id, uint256 price, uint256 dn_percentage, address store_address) public payable {
        
        require(msg.value >= price, "ETH sent is Insufficient!");

        Campaign storage campaign = campaigns[_id];

        // Calculating the amounts to send
        uint256 campaignAmount = (price * dn_percentage) / 100; // store set percentage 1-3% , 5% for the campaign owner
        uint256 storeAmount = price - campaignAmount; // Remaining amount for store owner

        //to check if charity target is less than 5% of price
        if (campaign.targetGoal < campaignAmount) {
            // Add remaining to store amount
            storeAmount += campaignAmount - campaign.targetGoal;
            campaignAmount = campaign.targetGoal;
        }

        // Transfer 5% to the campaign owner
        payable(campaign.owner).transfer(campaignAmount);

        // Update campaign details
        campaign.amountCollected = campaign.amountCollected + campaignAmount;
        campaign.donators.push(msg.sender);
        campaign.donations.push(campaignAmount);

        // Transfer remaining amount to store owner
        // payable(0x90F79bf6EB2c4f870365E785982E1f101E93b906).transfer(storeAmount);
        payable(store_address).transfer(storeAmount);
    }



    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for(uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

    // Function to get all unique charity organizations
    function getCharityOrgs() public view returns (string[] memory) {
        return charityOrgs;
    }
}