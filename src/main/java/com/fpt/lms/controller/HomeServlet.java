package com.fpt.lms.controller;

import com.fpt.lms.dto.CourseDTO;
import com.fpt.lms.dto.PageResult;
import com.fpt.lms.entity.Setting;
import com.fpt.lms.service.CourseService;
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
