// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';

/**
 * @dev IUniswapV2Router01 implementation
 * Implements the `swapExactTokensForTokens` function to simulate a successfull swap
 * between 2 tokens.
 *
 * Cheat methods to simulate the swap :
 *   - price market was definer earlier with the `setRatio` function
 *   - tokens addresses order define if ratio will be multiplied or divided
 * 
 * code from https://github.com/xas
 *
 */
contract Router is IUniswapV2Router01 {
    using SafeMath for uint256;
    uint256 ratio;
    address[] path;

    function setPath(address _path1, address _path2) external {
        path = new address[](2);
        path[0] = _path1;
        path[1] = _path2;
    }

    function setRatio(uint256 _ratio) external {
        ratio = _ratio;
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata _path,
        address to,
        uint deadline
    ) external override returns (uint[] memory amounts)
    {
        IERC20(_path[0]).transferFrom(to, address(0), amountIn);
        if (_path[0] == path[0]) {
            IERC20(_path[1]).transfer(to, amountIn.mul(ratio));
        } else {
            IERC20(_path[1]).transfer(to, amountIn.div(ratio));
        }
        return new uint[](0);
    }

    function factory() external pure override returns (address) { return address(0); }
    function WETH() external pure override returns (address) { return address(0); }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override returns (uint amountA, uint amountB, uint liquidity)
    { return (0, 0, 0); }
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable override returns (uint amountToken, uint amountETH, uint liquidity)
    { return (0, 0, 0); }
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override returns (uint amountA, uint amountB)
    { return (0, 0); }
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external override returns (uint amountToken, uint amountETH)
    { return (0, 0); }
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external override returns (uint amountA, uint amountB)
    { return (0, 0); }
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external override returns (uint amountToken, uint amountETH)
    { return (0, 0); }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external override returns (uint[] memory amounts)
     { return new uint[](0); }
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        override returns (uint[] memory amounts)
     { return new uint[](0); }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        override returns (uint[] memory amounts)
     { return new uint[](0); }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        override returns (uint[] memory amounts)
     { return new uint[](0); }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        override returns (uint[] memory amounts)
     { return new uint[](0); }

    function quote(uint amountA, uint reserveA, uint reserveB) external pure override returns (uint amountB) { return 0; }
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure override returns (uint amountOut) { return 0; }
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure override returns (uint amountIn) { return 0; }
    function getAmountsOut(uint amountIn, address[] calldata path) external view override returns (uint[] memory amounts) { return new uint[](0); }
    function getAmountsIn(uint amountOut, address[] calldata path) external view override returns (uint[] memory amounts) { return new uint[](0); }
}