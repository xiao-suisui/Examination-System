package com.example.exam;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 密码加密工具 - 用于生成初始化数据的密码
 *
 * @author Exam System
 * @version 2.0
 */
public class PasswordGenerator {

    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        // 生成常用密码的Bcrypt加密结果
        System.out.println("=".repeat(60));
        System.out.println("密码加密工具 - 用于数据库初始化");
        System.out.println("=".repeat(60));

        String[] passwords = {"123456", "Admin@123", "teacher123", "student123"};

        for (String password : passwords) {
            String encrypted = encoder.encode(password);
            System.out.println("\n原密码: " + password);
            System.out.println("加密后: " + encrypted);
            System.out.println("SQL语句:");
            System.out.println("UPDATE sys_user SET password='" + encrypted + "' WHERE username='admin';");
        }

        System.out.println("\n" + "=".repeat(60));
        System.out.println("复制上面的SQL语句到数据库中执行即可");
        System.out.println("=".repeat(60));
    }
}

