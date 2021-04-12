// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./icontract.sol";
import "./ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';

/**
 * @dev Ratio contract
 * Contract to maintain a tokens balance with a specific ratio when needed
 *
 * Call with the current market price, process the difference and call
 * uniswap router for the needed transfer
 * 
 * code from https://github.com/xas
 *
 */
contract Ratio is Ownable, IContract {
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    // Uniswap router v2
    IUniswapV2Router01 private router;
    // address for the first token (eg. WETH)
    IERC20 private token1;
    // address for the second token (eg. DAI)
    IERC20 private token2;
    // balance ratio between the 2 tokens (eg. 20 for 80% for token1 and 20% for token2)
    uint8 private ratio;
    // How much a variation is allowed before to accept a swap (eg. 0.1 ETH)
    uint256 private variationAllowed = 1e17;

    event Synced(uint256 ratio, uint256 slippage);

    function version() public pure override returns (bytes12) {
        return "0.4";
    }

    constructor(address _t1, address _t2, address _router, uint8 _r) {
        require(_t1 != address(0), "Token 1 at 0");
        require(_t2 != address(0), "Token 2 at 0");
        //require(_router != address(0), "Uniswap router at 0");
        require(_t1 != _t2, "Token 1 and 2 cannot be the same");
        require(_r < 100, "Your ratio cannot be greater or equal to 100%");
        require(_r > 1, "Your ratio must be greater than 1%");
        token1 = IERC20(_t1);
        token2 = IERC20(_t2);
        router = IUniswapV2Router01(_router);
        ratio = _r;
    }

    function sync (uint256 _currentPrice) onlyOwner external returns (bool) {
        require(_currentPrice > 0, "The token current price should be a positive value");
        uint256 _balanceToken2 = token2.balanceOf(address(this));
        uint256 _convertedBalanceToken2 = _balanceToken2.div(_currentPrice);
        uint256 _fullBalance = token1.balanceOf(address(this)).add(_convertedBalanceToken2);
        uint256 _balancedRatio = _fullBalance.mul(ratio).div(100);
        int256 _variation = int256(_balancedRatio).sub(int256(_convertedBalanceToken2));
        if (_variation < 0) {
            // absolute value
            _variation = -_variation;
        }
        uint256 _amountToSwap = uint(_variation);
        require(_amountToSwap > variationAllowed, "The variation is not enough");
        address[] memory path = new address[](2);
        if (_balancedRatio > _convertedBalanceToken2) {
            // Swap the variation from token1 to token2
            path[0] = address(token1);
            path[1] = address(token2);
            token1.approve(address(router), _amountToSwap);
        } else{
            // Swap the variation from token2 to token1
            path[0] = address(token2);
            path[1] = address(token1);
            // don't forget the re-conversion
            _amountToSwap = _amountToSwap.mul(_currentPrice);
            token2.approve(address(router), _amountToSwap);
        }
        // accept a maximal slippage of 0.5%
        uint256 _minimalSlippage = _amountToSwap.mul(995).div(1000);
        router.swapExactTokensForTokens(_amountToSwap, _minimalSlippage, path, address(this), block.timestamp);
        emit Synced(_balancedRatio, _minimalSlippage);
        return true;
    }

    /**
     * @dev Function to withdraw balance of the 2 tokens
     * Can withdraw all or a percentage
     * you need at least 1 token of each, otherwise function will fail
     */
    function withdraw(uint8 _percent) onlyOwner external returns (bool) {
        require(_percent < 101, "Your withdraw percent cannot be greater than 100%");
        require(_percent > 1, "Your withdraw percent must be greater than 1%");
        bool _withdrawReturn1 = _withdraw(token1, _percent);
        bool _withdrawReturn2 = _withdraw(token2, _percent);
        return _withdrawReturn1 && _withdrawReturn2;
    }

    function _withdraw(IERC20 _token, uint8 _percent) onlyOwner internal returns (bool) {
        uint256 _fullBalance = _token.balanceOf(address(this));
        require(_fullBalance > 0, "balanceOf token is zero");
        uint256 _amountToWithdraw = _fullBalance.mul(_percent).div(100);
        return _token.transfer(msg.sender, _amountToWithdraw);
    }

    /**
     * Function to transfer to the owner any ERC20 tokens airdropped
     * or "accidentally" transferred to this contract
     */
    function transferToken(address _token) onlyOwner public returns (bool) {
        require(_token != address(0));
        IERC20 _someToken = IERC20(_token);
        uint256 _someBalance = _someToken.balanceOf(address(this));
        require(_someBalance > 0, "balance token is zero");
        return _someToken.transfer(msg.sender, _someBalance);
    }
}