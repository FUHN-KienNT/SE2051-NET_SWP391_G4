/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package com.learnhub.controller;

import com.learnhub.entity.Question;
import com.learnhub.service.QuestionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.UUID;

/** Expert Question Bank: list, create, edit and delete questions. */
@WebServlet(name="QuestionServlet", urlPatterns={"/questions/manage","/questions/detail"})
public class QuestionServlet extends HttpServlet {
    private final QuestionService service=new QuestionService();

    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        String path=req.getServletPath();
        if("/questions/detail".equals(path)){
            String id=req.getParameter("id");
            if(id!=null&&!id.isBlank()){
                try{
                    Question q=service.get(UUID.fromString(id));
                    if(q!=null)req.setAttribute("question",q);
                }catch(IllegalArgumentException ignored){}
            }
            req.getRequestDispatcher("/WEB-INF/views/expert/question-detail.jsp").forward(req,resp);
            return;
        }

        String keyword=req.getParameter("keyword");
        String type=req.getParameter("type");
        req.setAttribute("keyword",keyword==null?"":keyword);
        req.setAttribute("type",type==null?"":type);
        req.setAttribute("questions",service.search(keyword,type));

        if("delete".equalsIgnoreCase(req.getParameter("action"))){
            try{
                boolean ok=service.delete(UUID.fromString(req.getParameter("id")));
                resp.sendRedirect(req.getContextPath()+"/questions/manage?deleted="+ok);
            }catch(Exception e){resp.sendRedirect(req.getContextPath()+"/questions/manage?deleted=false");}
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/expert/question-list.jsp").forward(req,resp);
    }

    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        req.setCharacterEncoding("UTF-8");
        String id=req.getParameter("id");
        UUID questionId=null;
        try{if(id!=null&&!id.isBlank())questionId=UUID.fromString(id);}catch(IllegalArgumentException e){questionId=null;}

        boolean ok=service.save(
            questionId,
            req.getParameter("content"),
            req.getParameter("type"),
            req.getParameterValues("optionText"),
            req.getParameterValues("correctIndex")
        );
        if(ok)resp.sendRedirect(req.getContextPath()+"/questions/manage?saved=true");
        else{
            req.setAttribute("error","Cannot save question. Single choice requires exactly 1 correct answer; Multiple choice requires at least 1 correct answer and a minimum of 2 options.");
            Question q=new Question(questionId,req.getParameter("content"),req.getParameter("type"));
            req.setAttribute("question",q);
            req.getRequestDispatcher("/WEB-INF/views/expert/question-detail.jsp").forward(req,resp);
        }
    }
}
