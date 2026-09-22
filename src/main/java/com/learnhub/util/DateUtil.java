package com.learnhub.util;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;

public class DateUtil {
    public static final String DEFAULT_DATE_FORMAT = "dd/MM/yyyy HH:mm:ss";
    public static final String SHORT_DATE_FORMAT = "dd/MM/yyyy";

    private DateUtil() {
    }

    public static String formatTimestamp(Timestamp timestamp) {
        if (timestamp == null) return "";
        return new SimpleDateFormat(DEFAULT_DATE_FORMAT).format(new Date(timestamp.getTime()));
    }

    public static String formatDate(Date date) {
        if (date == null) return "";
        return new SimpleDateFormat(SHORT_DATE_FORMAT).format(date);
    }
}
