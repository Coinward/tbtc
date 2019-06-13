contract UniswapDeployment {
    address public factory;
    address public exchange;

    constructor(
        address _factory,
        address _exchange
    ) public {
        factory = _factory;
        exchange = _exchange;
    }
}