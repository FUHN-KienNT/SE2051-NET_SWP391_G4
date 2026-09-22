package com.learnhub.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.InputStream;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.Logger;

/**
 * VNPay Gateway integration helper.
 * Designed according to SDS Enrollment & Payment Class Diagram:
 * - buildPaymentUrl()
 * - parseCallback()
 */
public class VNPayGateway {
    private static final Logger LOGGER = Logger.getLogger(VNPayGateway.class.getName());

    private static String vnpTmnCode = "LEARNHUB01";
    private static String vnpHashSecret = "LEARNHUBSECRETKEY2026VNPAYSANDBOX";
    private static String vnpPayUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    private static String vnpReturnUrl = "http://localhost:8080/learnhub/payment/result";

    static {
        try (InputStream in = VNPayGateway.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) {
                Properties props = new Properties();
                props.load(in);
                vnpTmnCode = props.getProperty("vnpay.tmn_code", vnpTmnCode);
                vnpHashSecret = props.getProperty("vnpay.hash_secret", vnpHashSecret);
                vnpPayUrl = props.getProperty("vnpay.pay_url", vnpPayUrl);
                vnpReturnUrl = props.getProperty("vnpay.return_url", vnpReturnUrl);
            }
        } catch (Exception e) {
            LOGGER.warning("Could not load VNPay properties from db.properties, using defaults.");
        }
    }

    public static String buildPaymentUrl(UUID registrationId, BigDecimal amount, String orderInfo, String clientIp) {
        try {
            String vnpVersion = "2.1.0";
            String vnpCommand = "pay";
            String vnpTxnRef = registrationId.toString().substring(0, 8) + "_" + System.currentTimeMillis();

            long amountInVnd = amount.multiply(BigDecimal.valueOf(100)).longValue();

            Map<String, String> vnpParams = new HashMap<>();
            vnpParams.put("vnp_Version", vnpVersion);
            vnpParams.put("vnp_Command", vnpCommand);
            vnpParams.put("vnp_TmnCode", vnpTmnCode);
            vnpParams.put("vnp_Amount", String.valueOf(amountInVnd));
            vnpParams.put("vnp_CurrCode", "VND");
            vnpParams.put("vnp_TxnRef", vnpTxnRef);
            vnpParams.put("vnp_OrderInfo", orderInfo != null ? orderInfo : "Payment for registration " + registrationId);
            vnpParams.put("vnp_OrderType", "other");
            vnpParams.put("vnp_Locale", "vn");
            vnpParams.put("vnp_ReturnUrl", vnpReturnUrl);
            vnpParams.put("vnp_IpAddr", clientIp != null ? clientIp : "127.0.0.1");

            Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            String vnpCreateDate = formatter.format(cld.getTime());
            vnpParams.put("vnp_CreateDate", vnpCreateDate);

            cld.add(Calendar.MINUTE, 15);
            String vnpExpireDate = formatter.format(cld.getTime());
            vnpParams.put("vnp_ExpireDate", vnpExpireDate);

            List<String> fieldNames = new ArrayList<>(vnpParams.keySet());
            Collections.sort(fieldNames);

            StringBuilder hashData = new StringBuilder();
            StringBuilder query = new StringBuilder();

            for (Iterator<String> itr = fieldNames.iterator(); itr.hasNext(); ) {
                String fieldName = itr.next();
                String fieldValue = vnpParams.get(fieldName);
                if (fieldValue != null && !fieldValue.isEmpty()) {
                    hashData.append(fieldName).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));
                    query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII)).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));
                    if (itr.hasNext()) {
                        query.append('&');
                        hashData.append('&');
                    }
                }
            }

            String vnpSecureHash = hmacSHA512(vnpHashSecret, hashData.toString());
            query.append("&vnp_SecureHash=").append(vnpSecureHash);

            return vnpPayUrl + "?" + query;
        } catch (Exception e) {
            LOGGER.severe("Error creating VNPay payment URL: " + e.getMessage());
            return vnpReturnUrl + "?error=payment_url_generation_failed";
        }
    }

    public static Map<String, String> parseCallback(Map<String, String[]> requestParams) {
        Map<String, String> params = new HashMap<>();
        for (Map.Entry<String, String[]> entry : requestParams.entrySet()) {
            if (entry.getValue() != null && entry.getValue().length > 0) {
                params.put(entry.getKey(), entry.getValue()[0]);
            }
        }
        return params;
    }

    public static boolean verifySignature(Map<String, String> params) {
        String secureHash = params.get("vnp_SecureHash");
        if (secureHash == null || secureHash.isEmpty()) {
            return false;
        }

        Map<String, String> copy = new HashMap<>(params);
        copy.remove("vnp_SecureHash");
        copy.remove("vnp_SecureHashType");

        List<String> fieldNames = new ArrayList<>(copy.keySet());
        Collections.sort(fieldNames);

        StringBuilder hashData = new StringBuilder();
        for (Iterator<String> itr = fieldNames.iterator(); itr.hasNext(); ) {
            String fieldName = itr.next();
            String fieldValue = copy.get(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                hashData.append(fieldName).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));
                if (itr.hasNext()) {
                    hashData.append('&');
                }
            }
        }

        String calculatedHash = hmacSHA512(vnpHashSecret, hashData.toString());
        return calculatedHash.equalsIgnoreCase(secureHash);
    }

    public static String hmacSHA512(String key, String data) {
        try {
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
            return "";
        }
    }
}
