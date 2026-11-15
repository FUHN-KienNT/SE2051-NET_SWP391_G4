package com.learnhub.service;

import com.learnhub.dao.SettingDAO;
import com.learnhub.entity.Setting;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;

class PaymentMethodStatusTest {

    private static class StubSettingDAO extends SettingDAO {
        private final List<Setting> allMethods = new ArrayList<>();

        void addMethod(UUID id, String code, String name, boolean status, int sortOrder) {
            Setting s = new Setting(id, "payment_method", code, name, "Description for " + name, status, sortOrder);
            allMethods.add(s);
        }

        @Override
        public List<Setting> findByType(String type) {
            if ("payment_method".equalsIgnoreCase(type)) {
                return allMethods.stream()
                        .filter(Setting::isStatus)
                        .sorted(Comparator.comparingInt(Setting::getSortOrder))
                        .toList();
            }
            return Collections.emptyList();
        }

        @Override
        public int countSettings(String search, String type, String status) {
            if ("payment_method".equalsIgnoreCase(type)) {
                if (status == null || "all".equalsIgnoreCase(status)) {
                    return allMethods.size();
                } else if ("active".equalsIgnoreCase(status) || "true".equalsIgnoreCase(status)) {
                    return (int) allMethods.stream().filter(Setting::isStatus).count();
                } else if ("inactive".equalsIgnoreCase(status) || "false".equalsIgnoreCase(status)) {
                    return (int) allMethods.stream().filter(s -> !s.isStatus()).count();
                }
            }
            return 0;
        }

        @Override
        public Setting findById(UUID id) {
            return allMethods.stream().filter(s -> s.getId().equals(id)).findFirst().orElse(null);
        }
    }

    @Test
    @DisplayName("When one payment method is deactivated, getPaymentMethods only returns the active ones")
    void whenOnePaymentMethodDeactivated_getPaymentMethodsOnlyReturnsActive() {
        StubSettingDAO stubDAO = new StubSettingDAO();
        UUID vnpayId = UUID.randomUUID();
        UUID sepayId = UUID.randomUUID();

        // Admin deactivates VNPay, keeps SePay active
        stubDAO.addMethod(vnpayId, "vnpay", "Cổng thanh toán VNPAY", false, 1);
        stubDAO.addMethod(sepayId, "sepay", "Cổng thanh toán SePay", true, 2);

        CourseService courseService = new CourseService(null, null, stubDAO, null);
        List<Setting> methods = courseService.getPaymentMethods();

        assertEquals(1, methods.size(), "Only active payment method should be returned");
        assertEquals("sepay", methods.get(0).getCode());
        assertEquals(sepayId, methods.get(0).getId());

        assertNull(courseService.getActivePaymentMethodById(vnpayId), "Deactivated method must not be found via getActivePaymentMethodById");
        assertNotNull(courseService.getActivePaymentMethodById(sepayId), "Active method must be found via getActivePaymentMethodById");
    }

    @Test
    @DisplayName("When all payment methods are deactivated, getPaymentMethods returns empty list")
    void whenAllPaymentMethodsDeactivated_returnsEmptyList() {
        StubSettingDAO stubDAO = new StubSettingDAO();
        UUID vnpayId = UUID.randomUUID();
        UUID sepayId = UUID.randomUUID();

        // Admin deactivates BOTH payment methods
        stubDAO.addMethod(vnpayId, "vnpay", "Cổng thanh toán VNPAY", false, 1);
        stubDAO.addMethod(sepayId, "sepay", "Cổng thanh toán SePay", false, 2);

        CourseService courseService = new CourseService(null, null, stubDAO, null);
        List<Setting> methods = courseService.getPaymentMethods();

        assertTrue(methods.isEmpty(), "When admin deactivates all methods, list must be empty");
        assertNull(courseService.getActivePaymentMethodById(vnpayId));
        assertNull(courseService.getActivePaymentMethodById(sepayId));
    }

    @Test
    @DisplayName("When database has zero configured payment methods, fallback defaults are provided")
    void whenNoPaymentMethodsConfiguredInDb_fallbackDefaultsProvided() {
        StubSettingDAO stubDAO = new StubSettingDAO();
        // Empty DB (unseeded)

        CourseService courseService = new CourseService(null, null, stubDAO, null);
        List<Setting> methods = courseService.getPaymentMethods();

        assertEquals(2, methods.size(), "Fallback defaults should be provided when table has 0 settings");
        assertEquals("vnpay", methods.get(0).getCode());
        assertEquals("sepay", methods.get(1).getCode());
    }

    @Test
    @DisplayName("getActivePaymentMethodById handles null and non-existent IDs gracefully")
    void getActivePaymentMethodById_handlesInvalidGracefully() {
        StubSettingDAO stubDAO = new StubSettingDAO();
        UUID sepayId = UUID.randomUUID();
        stubDAO.addMethod(sepayId, "sepay", "Cổng thanh toán SePay", true, 1);

        CourseService courseService = new CourseService(null, null, stubDAO, null);

        assertNull(courseService.getActivePaymentMethodById(null));
        assertNull(courseService.getActivePaymentMethodById(UUID.randomUUID()));
    }
}
