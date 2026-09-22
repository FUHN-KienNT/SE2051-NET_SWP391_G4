package com.fpt.lms.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class PageResult<T> implements Serializable {
    private static final long serialVersionUID = 1L;

    private List<T> data = new ArrayList<>();
    private int currentPage;
    private int pageSize;
    private int totalRecords;
    private int totalPages;

    public PageResult() {
        this.currentPage = 1;
        this.pageSize = 10;
    }

    public PageResult(List<T> data, int currentPage, int pageSize, int totalRecords) {
        this.data = data != null ? data : new ArrayList<>();
        this.currentPage = currentPage;
        this.pageSize = pageSize;
        this.totalRecords = totalRecords;
        this.totalPages = (int) Math.ceil((double) totalRecords / pageSize);
    }

    public List<T> getData() { return data; }
    public void setData(List<T> data) { this.data = data; }

    public int getCurrentPage() { return currentPage; }
    public void setCurrentPage(int currentPage) { this.currentPage = currentPage; }

    public int getPageSize() { return pageSize; }
    public void setPageSize(int pageSize) { this.pageSize = pageSize; }

    public int getTotalRecords() { return totalRecords; }
    public void setTotalRecords(int totalRecords) {
        this.totalRecords = totalRecords;
        this.totalPages = (int) Math.ceil((double) totalRecords / this.pageSize);
    }

    public int getTotalPages() { return totalPages; }
    public void setTotalPages(int totalPages) { this.totalPages = totalPages; }

    public boolean hasPrevious() { return currentPage > 1; }
    public boolean hasNext() { return currentPage < totalPages; }
}
