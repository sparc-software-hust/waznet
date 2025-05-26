package com.example.waznet.data.authentication.model

import kotlinx.serialization.Serializable


@Serializable
data class LoginResponse(
    val data: LoginResponseData,
    val message: String,
    val success: Boolean
)


