package com.learnhub.controller;

import com.learnhub.dto.CourseDTO;
import com.learnhub.dto.ContinueLearningDTO;
import com.learnhub.entity.Setting;
import com.learnhub.entity.User;
import com.learnhub.service.CourseService;
import com.learnhub.service.LearningProcessService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 *
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"", "/home", "/index"})
public class HomeServlet extends HttpServlet {
    private final CourseService courseService = new CourseService();
    private final LearningProcessService learningService = new LearningProcessService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = ControllerSupport.currentUser(req);
        ContinueLearningDTO continueLearning = null;
        if (user != null) {
            continueLearning = learningService.getContinueLearning(user.getId());
            req.setAttribute("continueLearning", continueLearning);
        }
        List<CourseDTO> popularCourses = courseService.getPopularPublicCourses(
                continueLearning == null ? null : continueLearning.getCourseId(), 6);
        List<Setting> categories = courseService.getActiveCategories();
        req.setAttribute("popularCourses", popularCourses);
        req.setAttribute("categories", categories);
        req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
    }
}
