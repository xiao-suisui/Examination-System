package com.example.exam.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.exam.entity.system.SysOperationLog;
import com.example.exam.mapper.system.SysOperationLogMapper;
import com.example.exam.service.OperationLogService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

/**
 * 操作日志Service实现类
 *
 * @author Exam System
 * @version 2.0
 * @since 2025-11-06
 */
@Slf4j
@Service
public class OperationLogServiceImpl extends ServiceImpl<SysOperationLogMapper, SysOperationLog>
        implements OperationLogService {

    /**
     * 异步保存操作日志
     */
    @Async
    public void saveAsync(SysOperationLog entity) {
        try {
            super.save(entity);
        } catch (Exception e) {
            log.error("异步保存操作日志失败：{}", e.getMessage(), e);
        }
    }
}

