import pytest
import pytest_asyncio
import asyncio
import time
import os
import logging

from providers.rate_limit import GlobalRateLimiter

# Configure logging for tests
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class TestProviderRateLimiter:
    """Tests for providers.rate_limit.GlobalRateLimiter."""

    @pytest_asyncio.fixture(autouse=True)
    async def reset_limiter(self):
        """Reset singleton and environment before each test."""
        GlobalRateLimiter.reset_instance()
        # Defaults
        os.environ["NVIDIA_NIM_RATE_LIMIT"] = "40"
        os.environ["NVIDIA_NIM_RATE_WINDOW"] = "60.0"
        yield
        GlobalRateLimiter.reset_instance()

    @pytest.mark.asyncio
    async def test_proactive_throttling(self):
        """
        Test proactive throttling using aiolimiter.
        Logic ported from verify_provider_limiter.py
        """
        # Set limit: 1 request per 0.25 second
        os.environ["NVIDIA_NIM_RATE_LIMIT"] = "1"
        os.environ["NVIDIA_NIM_RATE_WINDOW"] = "0.25"

        # Re-init with new limits
        GlobalRateLimiter.reset_instance()
        limiter = GlobalRateLimiter.get_instance()

        start_time = time.time()

        async def call_limiter():
            await limiter.wait_if_blocked()
            return time.time()

        # 5 requests.
        # R0 -> 0s
        # R1 -> 0.25s
        # R2 -> 0.50s
        # R3 -> 0.75s
        # R4 -> 1.00s
        results = []
        for _ in range(5):
            results.append(await call_limiter())

        total_time = time.time() - start_time

        assert len(results) == 5
        # Should take at least ~1.0s
        assert total_time >= 0.9, f"Throttling failed, took too fast: {total_time:.2f}s"

    @pytest.mark.asyncio
    async def test_reactive_blocking(self):
        """
        Test reactive blocking when set_blocked is called.
        Logic ported from verify_provider_limiter.py
        """
        GlobalRateLimiter.reset_instance()
        limiter = GlobalRateLimiter.get_instance()

        start_time = time.time()

        # Manually block for 1.5s
        block_time = 1.5
        limiter.set_blocked(block_time)

        assert limiter.is_blocked()

        async def call_limiter():
            return await limiter.wait_if_blocked()

        # Run 2 calls concurrently
        # They should both wait for the block time
        results = await asyncio.gather(call_limiter(), call_limiter())

        total_time = time.time() - start_time

        # Both should report having waited reactively
        assert all(results) is True
        assert total_time >= block_time - 0.1, (
            f"Reactive block failed, took {total_time:.2f}s"
        )
