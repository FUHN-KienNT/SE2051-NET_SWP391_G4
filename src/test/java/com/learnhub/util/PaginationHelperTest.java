package com.learnhub.util;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PaginationHelperTest {

    @Test
    void handlesZeroOrNegativeTotalPages() {
        assertTrue(PaginationHelper.getPageNumbers(1, 0).isEmpty());
        assertTrue(PaginationHelper.getPageNumbers(1, -5).isEmpty());
    }

    @Test
    void handlesTotalPagesLessThanOrEqualToSeven() {
        assertEquals(List.of("1"), PaginationHelper.getPageNumbers(1, 1));
        assertEquals(List.of("1", "2", "3"), PaginationHelper.getPageNumbers(2, 3));
        assertEquals(List.of("1", "2", "3", "4", "5", "6", "7"), PaginationHelper.getPageNumbers(4, 7));
    }

    @Test
    void handlesCurrentPageNearBeginning() {
        // When currentPage <= 4 in 10 pages: 1, 2, 3, 4, 5, ..., 10
        assertEquals(List.of("1", "2", "3", "4", "5", "...", "10"), PaginationHelper.getPageNumbers(1, 10));
        assertEquals(List.of("1", "2", "3", "4", "5", "...", "10"), PaginationHelper.getPageNumbers(2, 10));
        assertEquals(List.of("1", "2", "3", "4", "5", "...", "10"), PaginationHelper.getPageNumbers(3, 10));
        assertEquals(List.of("1", "2", "3", "4", "5", "...", "10"), PaginationHelper.getPageNumbers(4, 10));
    }

    @Test
    void handlesCurrentPageNearEnd() {
        // When currentPage >= 10 - 3 = 7 in 10 pages: 1, ..., 6, 7, 8, 9, 10
        assertEquals(List.of("1", "...", "6", "7", "8", "9", "10"), PaginationHelper.getPageNumbers(7, 10));
        assertEquals(List.of("1", "...", "6", "7", "8", "9", "10"), PaginationHelper.getPageNumbers(8, 10));
        assertEquals(List.of("1", "...", "6", "7", "8", "9", "10"), PaginationHelper.getPageNumbers(9, 10));
        assertEquals(List.of("1", "...", "6", "7", "8", "9", "10"), PaginationHelper.getPageNumbers(10, 10));
    }

    @Test
    void handlesCurrentPageInMiddle() {
        // When currentPage = 5 or 6 in 10 pages: 1, ..., cur-1, cur, cur+1, ..., 10
        assertEquals(List.of("1", "...", "4", "5", "6", "...", "10"), PaginationHelper.getPageNumbers(5, 10));
        assertEquals(List.of("1", "...", "5", "6", "7", "...", "10"), PaginationHelper.getPageNumbers(6, 10));

        // When in 20 pages:
        assertEquals(List.of("1", "...", "9", "10", "11", "...", "20"), PaginationHelper.getPageNumbers(10, 20));
    }

    @Test
    void handlesOutOfBoundsCurrentPageGracefully() {
        // Underflow: cur = -1 -> treated as 1
        assertEquals(List.of("1", "2", "3", "4", "5", "...", "10"), PaginationHelper.getPageNumbers(-1, 10));

        // Overflow: cur = 99 -> treated as 10
        assertEquals(List.of("1", "...", "6", "7", "8", "9", "10"), PaginationHelper.getPageNumbers(99, 10));
    }
}
