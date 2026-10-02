package com.learnhub.controller;

import com.learnhub.dao.ModuleDAO;
import com.learnhub.dao.QuestionDAO;
import com.learnhub.entity.Question;
import com.learnhub.entity.Quiz;
import com.learnhub.entity.Course;
import com.learnhub.entity.User;
import com.learnhub.service.QuizManagementService;
import com.learnhub.constant.AppConstants;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.*;

/** Expert Quiz List/Detail controller. */
@WebServlet(name="QuizManagementServlet", urlPatterns={"/quiz/manage","/quiz/detail"})
public class QuizManagementServlet extends HttpServlet {
    private final QuizManagementService service=new QuizManagementService();
    private final ModuleDAO moduleDAO=new ModuleDAO();
    private final QuestionDAO questionDAO=new QuestionDAO();

    private User currentUser(HttpServletRequest req){
        HttpSession s=req.getSession(false);
        return s==null?null:(User)s.getAttribute(AppConstants.SessionKey.CURRENT_USER);
    }

    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        User user=currentUser(req);
        if(user==null){resp.sendError(401);return;}
        String path=req.getServletPath();

        if("/quiz/detail".equals(path)){
            UUID courseId = parseUUID(req.getParameter("courseId"));
            Course course = courseId == null ? null : new com.learnhub.dao.CourseDAO().findById(courseId);
            List<com.learnhub.entity.Module> modules = courseId != null ? moduleDAO.findByCourseId(courseId) : moduleDAO.findByExpertId(user.getId());
            req.setAttribute("course", course);
            req.setAttribute("courseId", courseId);
            req.setAttribute("modules",modules);
            req.setAttribute("questions",questionDAO.search(null,null));
            req.setAttribute("selectedQuestionIds", new ArrayList<UUID>());

            String id=req.getParameter("id");
            if(id!=null&&!id.isBlank()){
                try{
                    UUID quizId=UUID.fromString(id);
                    Quiz quiz=service.get(quizId);
                    if(quiz!=null){
                        req.setAttribute("quiz",quiz);
                        req.setAttribute("selectedQuestionIds",service.getQuestionIds(quizId));
                        if(courseId == null){
                            com.learnhub.entity.Module module = moduleDAO.findById(quiz.getModuleId());
                            if(module != null){
                                courseId = module.getCourseId();
                                course = new com.learnhub.dao.CourseDAO().findById(courseId);
                                req.setAttribute("courseId", courseId);
                                req.setAttribute("course", course);
                                req.setAttribute("modules", moduleDAO.findByCourseId(courseId));
                            }
                        }
                    }
                }catch(IllegalArgumentException ignored){}
            }
            req.getRequestDispatcher("/WEB-INF/views/expert/quiz-detail.jsp").forward(req,resp);
            return;
        }

        String keyword=req.getParameter("keyword");
        UUID courseId=parseUUID(req.getParameter("courseId"));
        Course course = courseId == null ? null : new com.learnhub.dao.CourseDAO().findById(courseId);
        UUID moduleId=null;
        try{if(req.getParameter("moduleId")!=null&&!req.getParameter("moduleId").isBlank())moduleId=UUID.fromString(req.getParameter("moduleId"));}catch(IllegalArgumentException ignored){}
        req.setAttribute("keyword",keyword==null?"":keyword);
        req.setAttribute("moduleId",moduleId);
        req.setAttribute("courseId",courseId);
        req.setAttribute("course",course);
        req.setAttribute("modules",courseId != null ? moduleDAO.findByCourseId(courseId) : moduleDAO.findByExpertId(user.getId()));
        req.setAttribute("quizzes",service.findByExpert(user.getId(),keyword,moduleId,courseId));

        if("delete".equalsIgnoreCase(req.getParameter("action"))){
            try{
                boolean ok=service.delete(user.getId(),UUID.fromString(req.getParameter("id")));
                String suffix = courseId == null ? "" : "&courseId=" + courseId;
                resp.sendRedirect(req.getContextPath()+"/quiz/manage?deleted="+ok+suffix);
            }catch(Exception e){resp.sendRedirect(req.getContextPath()+"/quiz/manage?deleted=false");}
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/expert/quiz-list.jsp").forward(req,resp);
    }

    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        req.setCharacterEncoding("UTF-8");
        User user=currentUser(req);
        if(user==null){resp.sendError(401);return;}

        UUID id=parseUUID(req.getParameter("id"));
        UUID courseId=parseUUID(req.getParameter("courseId"));
        UUID moduleId=parseUUID(req.getParameter("moduleId"));
        String title=req.getParameter("title");
        Integer timeLimit=parseInt(req.getParameter("timeLimit"));
        java.math.BigDecimal passScore=parseDecimal(req.getParameter("passScore"));
        List<UUID> questionIds=new ArrayList<>();
        String[] raw=req.getParameterValues("questionId");
        if(raw!=null) for(String s:raw){UUID x=parseUUID(s);if(x!=null)questionIds.add(x);}

        boolean ok=service.save(user.getId(),id,moduleId,title,timeLimit,passScore,questionIds);
        if(ok) {
            String suffix = courseId == null ? "" : "&courseId=" + courseId;
            resp.sendRedirect(req.getContextPath()+"/quiz/manage?saved=true"+suffix);
        }
        else{
            req.setAttribute("error","Không thể lưu quiz. Hãy kiểm tra Module, tên quiz, thời gian và Pass Score (0-10).");
            req.setAttribute("courseId",courseId);
            req.setAttribute("course", courseId == null ? null : new com.learnhub.dao.CourseDAO().findById(courseId));
            req.setAttribute("modules",courseId != null ? moduleDAO.findByCourseId(courseId) : moduleDAO.findByExpertId(user.getId()));
            req.setAttribute("questions",questionDAO.search(null,null));
            if(id!=null)req.setAttribute("selectedQuestionIds",questionIds);
            req.getRequestDispatcher("/WEB-INF/views/expert/quiz-detail.jsp").forward(req,resp);
        }
    }

    private UUID parseUUID(String s){try{return s==null||s.isBlank()?null:UUID.fromString(s);}catch(Exception e){return null;}}
    private Integer parseInt(String s){try{return s==null||s.isBlank()?null:Integer.valueOf(s);}catch(Exception e){return null;}}
    private java.math.BigDecimal parseDecimal(String s){try{return s==null||s.isBlank()?new java.math.BigDecimal("5.0"):new java.math.BigDecimal(s);}catch(Exception e){return null;}}
}
