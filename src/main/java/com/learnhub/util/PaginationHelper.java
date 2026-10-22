package com.learnhub.util;

import java.util.ArrayList;
import java.util.List;

/**
 * Utility class providing helper methods for pagination controls.
 * Generates sliding window page number sequences with ellipsis ("...")
 * to prevent layout overflow when total pages is large.
 */
public final class PaginationHelper {

    private PaginationHelper() {
    }

    /**
     * Generates a list of page number strings with ellipsis for pagination UI.
     * Always limits the number of visible buttons to a maximum of 7 items.
     *
     * @param currentPage the current active page (1-based)
     * @param totalPages  the total number of pages
     * @return a list of page number strings (e.g., ["1", "2", "3", "4", "5", "...", "20"])
     */
    public static List<String> getPageNumbers(int currentPage, int totalPages) {
        List<String> pages = new ArrayList<>();
        if (totalPages <= 0) {
            return pages;
        }

        // Bound checking
        if (currentPage < 1) {
            currentPage = 1;
        }
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        // If total pages is 7 or fewer, show all pages
        if (totalPages <= 7) {
            for (int i = 1; i <= totalPages; i++) {
                pages.add(String.valueOf(i));
            }
            return pages;
        }

        // Always show the first page
        pages.add("1");

        if (currentPage <= 4) {
            // Near the start: 1, 2, 3, 4, 5, ..., N
            for (int i = 2; i <= 5; i++) {
                pages.add(String.valueOf(i));
            }
            pages.add("...");
            pages.add(String.valueOf(totalPages));
        } else if (currentPage >= totalPages - 3) {
            // Near the end: 1, ..., N-4, N-3, N-2, N-1, N
            pages.add("...");
            for (int i = totalPages - 4; i <= totalPages; i++) {
                pages.add(String.valueOf(i));
            }
        } else {
            // In the middle: 1, ..., cur-1, cur, cur+1, ..., N
            pages.add("...");
            for (int i = currentPage - 1; i <= currentPage + 1; i++) {
                pages.add(String.valueOf(i));
            }
            pages.add("...");
            pages.add(String.valueOf(totalPages));
        }

        return pages;
    }
}
