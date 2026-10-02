/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.learnhub.service;

import com.learnhub.dao.QuestionDAO;
import com.learnhub.entity.Question;
import com.learnhub.entity.QuestionOption;
import java.util.*;

/** Business layer for the shared Question Bank. */
public class QuestionService {
    private final QuestionDAO dao = new QuestionDAO();

    public List<Question> search(String keyword, String type) { return dao.search(keyword,type); }
    public Question get(UUID id) { return dao.findById(id); }

    public boolean save(UUID id, String content, String type, String[] optionTexts, String[] correctIndexes) {
        if(content==null||content.trim().isEmpty()) return false;
        Question q=new Question();
        q.setId(id != null ? id : UUID.randomUUID());q.setContent(content.trim());q.setType(type);
        List<QuestionOption> options=new ArrayList<>();
        Set<Integer> correct=new HashSet<>();
        if(correctIndexes!=null) for(String s:correctIndexes) try{correct.add(Integer.parseInt(s));}catch(NumberFormatException ignored){}
        if(optionTexts!=null){
            for(int i=0;i<optionTexts.length;i++){
                if(optionTexts[i]==null||optionTexts[i].trim().isEmpty())continue;
                QuestionOption o=new QuestionOption();
                o.setQuestionId(id);o.setOptionText(optionTexts[i].trim());o.setCorrect(correct.contains(i));options.add(o);
            }
        }
        if("single_choice".equals(type)||"multiple_choice".equals(type)){
            if(options.size()<2||correct.isEmpty()) return false;
            if("single_choice".equals(type)&&correct.size()!=1)return false;
        }
        return id==null ? dao.insert(q,options) : dao.update(q,options);
    }
    public boolean delete(UUID id){ return !dao.isUsedInQuiz(id) && dao.delete(id); }
    public boolean isUsedInQuiz(UUID id){return dao.isUsedInQuiz(id);}
}

