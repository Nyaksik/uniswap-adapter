//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract UniswapAdapter {
    using SafeERC20 for IERC20;

    address public constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair)
    {
        pair = IUniswapV2Factory(FACTORY).createPair(tokenA, tokenB);
    }

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair)
    {
        pair = IUniswapV2Factory(FACTORY).getPair(tokenA, tokenB);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        IERC20(tokenA).safeTransferFrom(
            msg.sender,
            address(this),
            amountADesired
        );
        IERC20(tokenA).approve(ROUTER, amountADesired);
        IERC20(tokenB).safeTransferFrom(
            msg.sender,
            address(this),
            amountBDesired
        );
        IERC20(tokenB).approve(ROUTER, amountBDesired);
        (amountA, amountB, liquidity) = IUniswapV2Router02(ROUTER).addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
        if (amountADesired > amountA)
            IERC20(tokenA).safeTransfer(msg.sender, amountADesired - amountA);
        if (amountBDesired > amountB)
            IERC20(tokenB).safeTransfer(msg.sender, amountBDesired - amountA);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB) {
        address pair = IUniswapV2Factory(FACTORY).getPair(tokenA, tokenB);
        IERC20(pair).safeTransferFrom(msg.sender, address(this), liquidity);
        IERC20(pair).approve(ROUTER, liquidity);
        (amountA, amountB) = IUniswapV2Router02(ROUTER).removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountOut);
        IERC20(path[0]).approve(ROUTER, amountOut);
        amounts = IUniswapV2Router02(ROUTER).swapTokensForExactTokens(
            amountOut,
            amountInMax,
            path,
            to,
            deadline
        );
    }
}
