package com.learnhub.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Utility class handling VNPay Sandbox Payment Gateway integration.
 * Follows VNPay standard API v2.1.0 specifications.
 */
public class VNPayUtil {
    private static final Logger LOGGER = Logger.getLogger(VNPayUtil.class.getName());

    public static String TMN_CODE = "LEARNHUB01";
    public static String HASH_SECRET = "LEARNHUBSECRETKEY2026VNPAYSANDBOX";
    public static String PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public static String RETURN_URL = "http://localhost:8080/learnhub/payment/vnpay-return";

    static {
        try (InputStream is = VNPayUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (is != null) {
                Properties props = new Properties();
                props.load(is);
                TMN_CODE = props.getProperty("vnpay.tmn_code", TMN_CODE);
                HASH_SECRET = props.getProperty("vnpay.hash_secret", HASH_SECRET);
                PAY_URL = props.getProperty("vnpay.pay_url", PAY_URL);
                RETURN_URL = props.getProperty("vnpay.return_url", RETURN_URL);
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Cannot load VNPay properties from db.properties, using defaults", e);
        }
    }

    /**
     * Compute HMAC SHA512 hash required by VNPay.
     */
    public static String hmacSHA512(String key, String data) {
        try {
            if (key == null || data == null) {
                return "";
            }
            Mac hmac512 = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmac512.init(secretKey);
            byte[] result = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(2 * result.length);
            for (byte b : result) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error calculating HMAC SHA512", ex);
            return "";
        }
    }

    /**
     * Build standard VNPay payment redirect URL with alphabetical query ordering and checksum.
     */
    public static String createPaymentUrl(String orderId, long amountVnd, String orderInfo, String ipAddress, String customReturnUrl) {
        String vnp_Version = "2.1.0";
        String vnp_Command = "pay";
        String vnp_OrderType = "other";
        
        // VNPay amount format: VND multiplied by 100
        long amount = amountVnd * 100;

        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", vnp_Version);
        vnp_Params.put("vnp_Command", vnp_Command);
        vnp_Params.put("vnp_TmnCode", TMN_CODE);
        vnp_Params.put("vnp_Amount", String.valueOf(amount));
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_TxnRef", orderId);
        vnp_Params.put("vnp_OrderInfo", orderInfo);
        vnp_Params.put("vnp_OrderType", vnp_OrderType);
        vnp_Params.put("vnp_Locale", "vn");
        vnp_Params.put("vnp_ReturnUrl", (customReturnUrl != null && !customReturnUrl.isBlank()) ? customReturnUrl : RETURN_URL);
        vnp_Params.put("vnp_IpAddr", ipAddress != null && !ipAddress.isBlank() ? ipAddress : "127.0.0.1");

        TimeZone tz = TimeZone.getTimeZone("Asia/Ho_Chi_Minh");
        Calendar cld = Calendar.getInstance(tz);
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        formatter.setTimeZone(tz);
        String vnp_CreateDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);

        cld.add(Calendar.MINUTE, 15);
        String vnp_ExpireDate = formatter.format(cld.getTime());
        vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

        // Sort keys alphabetically
        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
        Collections.sort(fieldNames);

        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();

        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = vnp_Params.get(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                // Build hash data
                hashData.append(fieldName);
                hashData.append('=');
                hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));

                // Build query string
                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII));
                query.append('=');
                query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));

                if (itr.hasNext()) {
                    query.append('&');
                    hashData.append('&');
                }
            }
        }

        String queryUrl = query.toString();
        String vnp_SecureHash = hmacSHA512(HASH_SECRET, hashData.toString());
        queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;

        return PAY_URL + "?" + queryUrl;
    }

    /**
     * Validate incoming checksum from VNPay Return / IPN.
     */
    public static boolean verifyIpnChecksum(Map<String, String[]> parameterMap) {
        Map<String, String> fields = new HashMap<>();
        for (Map.Entry<String, String[]> entry : parameterMap.entrySet()) {
            String[] values = entry.getValue();
            if (values != null && values.length > 0) {
                fields.put(entry.getKey(), values[0]);
            }
        }

        String vnp_SecureHash = fields.remove("vnp_SecureHash");
        fields.remove("vnp_SecureHashType");

        if (vnp_SecureHash == null || vnp_SecureHash.isBlank()) {
            return false;
        }

        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);

        StringBuilder hashData = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = fields.get(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                hashData.append(fieldName);
                hashData.append('=');
                hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));
                if (itr.hasNext()) {
                    hashData.append('&');
                }
            }
        }

        String checkHash = hmacSHA512(HASH_SECRET, hashData.toString());
        return checkHash.equalsIgnoreCase(vnp_SecureHash);
    }
}
