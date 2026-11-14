package com.learnhub.dao;

import com.learnhub.util.DbConnection;
import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/** Maintains Quiz <-> Question membership and ordering. */
public class QuizQuestionDAO {
    private static final Logger LOGGER=Logger.getLogger(QuizQuestionDAO.class.getName());

    public List<UUID> findQuestionIds(UUID quizId){
        List<UUID> ids=new ArrayList<>();
        String sql="SELECT question_id FROM quiz_question WHERE quiz_id=? ORDER BY order_index";
        try(Connection conn=DbConnection.getConnection();PreparedStatement ps=conn.prepareStatement(sql)){
            ps.setObject(1,quizId);try(ResultSet rs=ps.executeQuery()){while(rs.next())ids.add((UUID)rs.getObject(1));}
        }catch(SQLException e){LOGGER.log(Level.SEVERE,"Error in QuizQuestionDAO.findQuestionIds",e);}
        return ids;
    }
}
