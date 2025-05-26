package com.example.waznet.domain.repo

import com.example.waznet.data.authentication.model.LoginRequest

interface LoginRepo {
    suspend fun login(request: LoginRequest)


}