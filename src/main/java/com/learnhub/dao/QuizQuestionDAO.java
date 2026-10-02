/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.learnhub.dao;

import com.learnhub.entity.Question;
import com.learnhub.util.DbConnection;
import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/** Maintains Quiz <-> Question membership and ordering. */
public class QuizQuestionDAO {
    private static final Logger LOGGER=Logger.getLogger(QuizQuestionDAO.class.getName());

    public boolean replaceQuestions(UUID quizId, List<UUID> questionIds) {
        if(quizId==null)return false;
        String del="DELETE FROM quiz_question WHERE quiz_id=?";
        String ins="INSERT INTO quiz_question(id,quiz_id,question_id,order_index) VALUES(gen_random_uuid(),?,?,?)";
        try(Connection conn=DbConnection.getConnection()){
            conn.setAutoCommit(false);
            try(PreparedStatement ps=conn.prepareStatement(del)){ps.setObject(1,quizId);ps.executeUpdate();}
            if(questionIds!=null){
                try(PreparedStatement ps=conn.prepareStatement(ins)){
                    int order=1;
                    Set<UUID> unique=new LinkedHashSet<>(questionIds);
                    for(UUID qid:unique){if(qid==null)continue;ps.setObject(1,quizId);ps.setObject(2,qid);ps.setInt(3,order++);ps.addBatch();}
                    ps.executeBatch();
                }
            }
            conn.commit();return true;
        }catch(SQLException e){
            LOGGER.log(Level.SEVERE,"Error in QuizQuestionDAO.replaceQuestions",e);
            return false;
        }
    }

    public List<UUID> findQuestionIds(UUID quizId){
        List<UUID> ids=new ArrayList<>();
        String sql="SELECT question_id FROM quiz_question WHERE quiz_id=? ORDER BY order_index";
        try(Connection conn=DbConnection.getConnection();PreparedStatement ps=conn.prepareStatement(sql)){
            ps.setObject(1,quizId);try(ResultSet rs=ps.executeQuery()){while(rs.next())ids.add((UUID)rs.getObject(1));}
        }catch(SQLException e){LOGGER.log(Level.SEVERE,"Error in QuizQuestionDAO.findQuestionIds",e);}
        return ids;
    }

    public List<Question> findQuestionsNotInQuiz(UUID quizId, String keyword){
        List<Question> list=new ArrayList<>();
        StringBuilder sql=new StringBuilder("SELECT q.id,q.content,q.type,q.created_at,q.updated_at FROM question q WHERE NOT EXISTS(SELECT 1 FROM quiz_question qq WHERE qq.quiz_id=? AND qq.question_id=q.id) ");
        List<Object> params=new ArrayList<>();params.add(quizId);
        if(keyword!=null&&!keyword.trim().isEmpty()){sql.append("AND q.content ILIKE ? ");params.add("%"+keyword.trim()+"%");}
        sql.append("ORDER BY q.updated_at DESC");
        try(Connection conn=DbConnection.getConnection();PreparedStatement ps=conn.prepareStatement(sql.toString())){
            for(int i=0;i<params.size();i++)ps.setObject(i+1,params.get(i));
            try(ResultSet rs=ps.executeQuery()){while(rs.next()){Question q=new Question();q.setId((UUID)rs.getObject("id"));q.setContent(rs.getString("content"));q.setType(rs.getString("type"));q.setCreatedAt(rs.getTimestamp("created_at"));q.setUpdatedAt(rs.getTimestamp("updated_at"));list.add(q);}}
        }catch(SQLException e){LOGGER.log(Level.SEVERE,"Error in QuizQuestionDAO.findQuestionsNotInQuiz",e);}
        return list;
    }
}
