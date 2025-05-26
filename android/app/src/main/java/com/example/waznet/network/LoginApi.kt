package com.example.waznet.network

import com.example.waznet.data.authentication.model.LoginResponse
import retrofit2.http.Body
import retrofit2.http.POST

interface LoginApi {
    @POST("user/login")
    suspend fun login(@Body request: Map<String, String>): LoginResponse
}