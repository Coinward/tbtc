pragma solidity 0.4.25;

library TBTCConstants {

    // This is intended to make it easy to update system params
    // During testing swap this out with another constats contract

    // Exterior Contracts
    address public constant TOKEN_CONTRACT = address(0);
    address public constant KEEP_CONTRACT = address(0);
    address public constant DIFFICULTY_RELAY_CONTRACT = address(0);
    address public constant SYSTEM_CONTRACT = address(0);

    // System Parameters
    uint256 public constant MINIMUM_LOT_SIZE = 10 ** 8;  // tsatoshi
    uint256 public constant SIGNER_FEE_DIVISOR = 200; // 1/200 == 50bps == 0.5% == 0.005
    uint256 public constant BENEFICIARY_FEE_DIVISOR = 1000;  // 1/1000 = 10 bps = 0.1% = 0.001
    uint256 public constant FUNDING_FRAUD_PARTIAL_SLASH_DIVISOR = 2;  // 1/2 = 5000bps = 50% = 0.5
    uint256 public constant DEPOSIT_TERM_LENGTH = 180 * 24 * 60 * 60; // 180 days in seconds
    uint256 public constant UNDERCOLLATERALIZED_THRESHOLD_PERCENT = 140;  // percent
    uint256 public constant SEVERELY_UNDERCOLLATERALIZED_THRESHOLD_PERCENT = 120; // percent

    // Redemption Flow
    uint256 public constant REDEMPTION_SIGNATURE_TIMEOUT = 2 * 60 * 60;  // seconds
    uint256 public constant INCREASE_FEE_TIMER = 4 * 60 * 60;  // seconds
    uint256 public constant REDEMPTION_PROOF_TIMEOUT = 6 * 60 * 60;  // seconds
    uint256 public constant MINIMUM_REDEMPTION_FEE = 2000; // satoshi

    // Funding Flow
    uint256 public constant FUNDING_PROOF_TIMEOUT = 3 * 60 * 60; // seconds
    uint256 public constant FORMATION_TIMEOUT = 3 * 60 * 60; // seconds
    uint256 public constant FRAUD_FUNDING_PROOF_TIMEOUT = 3 * 60 * 60; // seconds
    uint256 public constant FUNDER_BOND_AMOUNT_WEI = 10 ** 22; // wei

    // Liquidation Flow
    uint256 public constant COURTESY_CALL_DURATION = 6 * 60 * 60; // seconds
    uint256 public constant AUCTION_DURATION = 24 * 60 * 60; // seconds
    uint256 public constant AUCTION_BASE_PERCENTAGE = 90; // percents


    // Getters for easy access
    function getTokenContractAddress() public view returns (address) { return TOKEN_CONTRACT; }
    function getKeepContractAddress() public view returns (address) { return KEEP_CONTRACT; }
    function getDifficultyOracleContractAddress() public view returns (address) { return DIFFICULTY_RELAY_CONTRACT; }
    function getSystemContractAddress() public view returns (address) { return SYSTEM_CONTRACT; }

    function getLotSize() public view returns (uint256) { return MINIMUM_LOT_SIZE; }
    function getSignerFeeDivisor() public view returns (uint256) { return SIGNER_FEE_DIVISOR; }
    function getBeneficiaryRewardDivisor() public view returns (uint256) { return BENEFICIARY_FEE_DIVISOR; }
    function getFundingFraudPartialSlashDivisor() public view returns (uint256) { return FUNDING_FRAUD_PARTIAL_SLASH_DIVISOR; }
    function getDepositTerm() public view returns (uint256) { return DEPOSIT_TERM_LENGTH; }
    function getUndercollateralizedPercent() public view returns (uint256) { return UNDERCOLLATERALIZED_THRESHOLD_PERCENT; }
    function getSeverelyUndercollateralizedPercent() public view returns (uint256) { return SEVERELY_UNDERCOLLATERALIZED_THRESHOLD_PERCENT; }

    function getSignatureTimeout() public view returns (uint256) { return REDEMPTION_SIGNATURE_TIMEOUT; }
    function getIncreaseFeeTimer() public view returns (uint256) { return INCREASE_FEE_TIMER; }
    function getRedepmtionProofTimeout() public view returns (uint256) { return REDEMPTION_PROOF_TIMEOUT; }
    function getMinimumRedemptionFee() public view returns (uint256) { return MINIMUM_REDEMPTION_FEE; }

    function getFundingTimeout() public view returns (uint256) { return FUNDING_PROOF_TIMEOUT; }
    function getSigningGroupFormationTimeout() public view returns (uint256) { return FORMATION_TIMEOUT; }
    function getFraudFundingTimeout() public view returns (uint256) { return FRAUD_FUNDING_PROOF_TIMEOUT; }
    function getFunderBondAmount() public view returns (uint256) { return FUNDER_BOND_AMOUNT_WEI; }

    function getCourtesyCallTimeout() public view returns (uint256) { return COURTESY_CALL_DURATION; }
    function getAuctionDuration() public view returns (uint256) { return AUCTION_DURATION; }
    function getAuctionBasePercentage() public view returns (uint256) { return AUCTION_BASE_PERCENTAGE; }
}
