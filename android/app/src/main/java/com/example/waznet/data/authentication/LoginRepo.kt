package com.example.waznet.data.authentication

import com.example.waznet.data.authentication.model.LoginRequest
import com.example.waznet.domain.repo.LoginRepo
import com.example.waznet.network.LoginApi
import javax.inject.Inject

// inject for hilt bindings
class LoginRepoImpl  @Inject constructor(
    private val loginApi: LoginApi
) : LoginRepo {
    override suspend fun login(request: LoginRequest) {
        val requestMap = mapOf<String, String>(
            "phone_number" to request.phone,
            "password" to request.password
        )
        loginApi.login(requestMap)
    }
}