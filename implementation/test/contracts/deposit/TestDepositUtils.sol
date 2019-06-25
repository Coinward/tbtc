pragma solidity 0.4.25;

import {DepositUtils} from '../../../contracts/deposit/DepositUtils.sol';
import {TestDeposit} from './TestDeposit.sol';

contract TestDepositUtils is TestDeposit {

    // Passthroughs to test view and pure functions

    function currentBlockDifficulty() public view returns (uint256) {
        return self.currentBlockDifficulty();
    }

    function previousBlockDifficulty() public view returns (uint256) {
        return self.previousBlockDifficulty();
    }

    function evaluateProofDifficulty(bytes _bitcoinHeaders) public view {
        return self.evaluateProofDifficulty(_bitcoinHeaders);
    }

    function checkProofFromTx(
        bytes _bitcoinTx,
        bytes _merkleProof,
        uint256 _index,
        bytes _bitcoinHeaders
    ) public view returns (bytes32) {
        return self.checkProofFromTx(_bitcoinTx, _merkleProof, _index, _bitcoinHeaders);
    }

    function extractOutputAtIndex(bytes _txOutputVector, uint8 _fundingOutputIndex) public view returns (bytes) {
        return DepositUtils.extractOutputAtIndex(_txOutputVector, _fundingOutputIndex);
    }

    function auctionValue() public view returns (uint256) {
        return self.auctionValue();
    }

    function signerFee() public pure returns (uint256) {
        return DepositUtils.signerFee();
    }

    function beneficiaryReward() public pure returns (uint256) {
        return DepositUtils.beneficiaryReward();
    }

    function redemptionTBTCAmount() public view returns (uint256) {
        return self.redemptionTBTCAmount();
    }

    function auctionTBTCAmount() public view returns (uint256) {
        return self.auctionTBTCAmount();
    }

    function determineCompressionPrefix(bytes32 _pubkeyY) public pure returns (bytes) {
        return DepositUtils.determineCompressionPrefix(_pubkeyY);
    }

    function compressPubkey(bytes32 _pubkeyX, bytes32 _pubkeyY) public pure returns (bytes) {
        return DepositUtils.compressPubkey(_pubkeyX, _pubkeyY);
    }

    function signerPubkey() public view returns (bytes) {
        return self.signerPubkey();
    }

    function signerPKH() public view returns (bytes20) {
        return self.signerPKH();
    }

    function utxoSize() public view returns (uint256) {
        return self.utxoSize();
    }

    function fetchOraclePrice() public view returns (uint256) {
        return self.fetchOraclePrice();
    }

    function fetchBondAmount() public view returns (uint256) {
        return self.fetchBondAmount();
    }

    function bytes8LEToUint(bytes8 _b) public pure returns (uint256) {
        return DepositUtils.bytes8LEToUint(_b);
    }

    function wasDigestApprovedForSigning(bytes32 _digest) public view returns (uint256) {
        return self.wasDigestApprovedForSigning(_digest);
    }

    function depositBeneficiary() public view returns (address) {
        return self.depositBeneficiary();
    }

    function redemptionTeardown() public {
        return self.redemptionTeardown();
    }

    function seizeSignerBonds() public returns (uint256) {
        return self.seizeSignerBonds();
    }

    function distributeBeneficiaryReward() public {
        return self.distributeBeneficiaryReward();
    }

    function pushFundsToKeepGroup(uint256 _ethValue) public returns (bool) {
        return self.pushFundsToKeepGroup(_ethValue);
    }
}
