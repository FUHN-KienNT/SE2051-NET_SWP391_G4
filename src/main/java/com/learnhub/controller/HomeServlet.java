package com.learnhub.controller;

import com.learnhub.dto.CourseDTO;
import com.learnhub.dto.PageResult;
import com.learnhub.entity.Setting;
import com.learnhub.service.CourseService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeServlet", urlPatterns = {"", "/home", "/index"})
public class HomeServlet extends HttpServlet {
    private final CourseService courseService = new CourseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        PageResult<CourseDTO> featuredCourses = courseService.searchPublicCourses("", null, 1, 6);
        List<Setting> categories = courseService.getActiveCategories();

        req.setAttribute("featuredCourses", featuredCourses.getData());
        req.setAttribute("categories", categories);
        req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
    }
}
