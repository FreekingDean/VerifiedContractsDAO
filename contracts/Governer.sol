// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/compatibility/GovernorCompatibilityBravo.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";

contract VCTGovernor is Governor, GovernorCompatibilityBravo, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl {
    enum VerificationStatus { GOOD, BAD, UNKOWN }
    // Creating a mapping
    mapping (address => VerificationStatus) contracts;
    mapping(VerificationStatus => string) internal _statusStrings;
    constructor(IVotes _token, TimelockController _timelock)
        Governor("VCTGovernor")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(_timelock)
    {
        _statusStrings[VerificationStatus.GOOD] = "good";
        _statusStrings[VerificationStatus.BAD] = "bad";
        _statusStrings[VerificationStatus.UNKOWN] = "unknown";
    }

    function votingDelay() public pure override returns (uint256) {
        return 6575; // 1 day
    }

    function votingPeriod() public pure override returns (uint256) {
        return 46027; // 1 week
    }

    function proposalThreshold() public pure override returns (uint256) {
        return 0;
    }

    // The functions below are overrides required by Solidity.

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function getVotes(address account, uint256 blockNumber)
        public
        view
        override(Governor, IGovernor)
        returns (uint256)
    {
        return super.getVotes(account, blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, IGovernor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function setContract(address contractAddress, VerificationStatus newStatus)
        internal
    {
    }

    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description)
        public
        view
        override(Governor, GovernorCompatibilityBravo, IGovernor)
        returns (uint256)
    {
        console.logAddress(targets[0]);
        console.logUint(values[0]);
        console.logBytes(calldatas[0]);
        console.log(description);
        return (0);
    }

    function proposeContractForVerification(address contractAddress, VerificationStatus newStatus)
        public
    {
        bytes memory data = abi.encodeWithSignature("setContract(address,status)", contractAddress, newStatus);
        bytes memory mesg = string.concat(
            string.concat(
                string.concat(
                    "Setting contract ",
                    abi.encodePacked(address(this))
                ),
                " to "
            ),
            bytes(_statusStrings[newStatus])
        );
        address[] memory targets = new address[](1);
        targets[0] = address(this);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = data;
        super.propose(targets, values, calldatas, string(mesg));
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, IERC165, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
