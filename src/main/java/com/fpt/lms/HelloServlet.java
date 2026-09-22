package com.fpt.lms;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "HelloServlet", value = "/hello")
public class HelloServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = resp.getWriter()) {
            out.println("<!DOCTYPE html><html><head><title>LearnHub LMS</title></head><body>");
            out.println("<h1>Hello from LearnHub - LMS System</h1>");
            out.println("<p>Project SWP391 - Java Servlet & PostgreSQL Architecture</p>");
            out.println("<a href='" + req.getContextPath() + "/home'>Go to Home Page</a>");
            out.println("</body></html>");
        }
    }
}
