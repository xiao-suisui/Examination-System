package com.example.exam;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 考试系统启动类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@SpringBootApplication
@org.springframework.scheduling.annotation.EnableAsync
public class ExamSystemApplication {

    public static void main(String[] args) {
        SpringApplication.run(ExamSystemApplication.class, args);
        System.out.println("\n" +
                "  _____ __  __    _    __  __   ______   _______ _____ __  __ \n" +
                " | ____|  \\/  |  / \\  |  \\/  | / ___\\ \\ / / ____|_   _|  \\/  |\n" +
                " |  _| | |\\/| | / _ \\ | |\\/| | \\___ \\\\ V /|  _|   | | | |\\/| |\n" +
                " | |___| |  | |/ ___ \\| |  | |  ___) || | | |___  | | | |  | |\n" +
                " |_____|_|  |_/_/   \\_\\_|  |_| |____/ |_| |_____| |_| |_|  |_|\n" +
                "\n" +
                "=============================================================\n" +
                "  考试系统启动成功！\n" +
                "  访问地址: http://localhost:8080\n" +
                "  API文档: http://localhost:8080/doc.html\n" +
                "  版本: V2.0.0-SNAPSHOT\n" +
                "=============================================================\n");
    }
}

