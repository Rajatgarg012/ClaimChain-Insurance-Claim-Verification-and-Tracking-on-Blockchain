// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ClaimChain {
     enum ClaimStatus { Submitted, Verified, Rejected, Settled }

    struct Claim {
        address claimant;
        string description;
        uint256 amount;
          ClaimStatus status;
          }
 
    address public insurer;
    uint256 public claimCount;

    mapping(uint256 => Claim) public claims;

    modifier onlyInsurer() {
         require(msg.sender == insurer, "Only insurer can call this");
        _;
          }

    modifier onlyClaimant(uint256 id) {
         require(msg.sender == claims[id].claimant, "Only claimant can call this");
        _;
      }

    event ClaimSubmitted(uint256 indexed id, address indexed claimant);
    event ClaimVerified(uint256 indexed id);
    event ClaimRejected(uint256 indexed id);
    event ClaimSettled(uint256 indexed id, uint256 amount);


    constructor() {
        insurer = msg.sender;
          }
 
    function submitClaim(string calldata description, uint256 amount) external returns (uint256) {
        require(amount > 0, "Invalid amount");

        claims[claimCount] = Claim({
            claimant: msg.sender,
            description: description,
            amount: amount,
            status: ClaimStatus.Submitted
        });

        emit ClaimSubmitted(claimCount, msg.sender);
        return claimCount++;
    }

    function verifyClaim(uint256 id) external onlyInsurer {
        require(claims[id].status == ClaimStatus.Submitted, "Invalid status");
        claims[id].status = ClaimStatus.Verified;
        emit ClaimVerified(id);
    }

    function rejectClaim(uint256 id) external onlyInsurer {
        require(claims[id].status == ClaimStatus.Submitted, "Invalid status");
        claims[id].status = ClaimStatus.Rejected;
        emit ClaimRejected(id);
     }

    function settleClaim(uint256 id) external payable onlyInsurer {
        Claim storage claim = claims[id];
        require(claim.status == ClaimStatus.Verified, "Claim must be verified");
        require(msg.value == claim.amount, "Incorrect amount");

        claim.status = ClaimStatus.Settled;
        payable(claim.claimant).transfer(msg.value);
        emit ClaimSettled(id, msg.value);
    }
}
