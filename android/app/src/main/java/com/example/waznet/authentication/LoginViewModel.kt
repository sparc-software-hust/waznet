package com.example.waznet.authentication

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.waznet.data.authentication.model.LoginRequest
import com.example.waznet.domain.repo.LoginRepo
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

//ui state
sealed interface LoginUiState {
    data class Success(val test: Boolean) : LoginUiState
    object Error : LoginUiState
    object Loading : LoginUiState
}

// di for view model
@HiltViewModel
class LoginViewModel @Inject constructor(
    private val loginRepo: LoginRepo
) : ViewModel() {
    var loginUiState: LoginUiState by mutableStateOf(LoginUiState.Loading)

    fun login(phone: String, password: String) {
        viewModelScope.launch {
            loginUiState = LoginUiState.Loading
            loginUiState = try {
                Log.d("LoginViewModel", "login: run - $phone -- $password")
                val result = loginRepo.login(LoginRequest(phone = phone, password = password))
                Log.d("LoginViewModel", "login: testtttttttttttttt")
                LoginUiState.Success(test = true)
            } catch (e: Exception) {
                Log.d("LoginViewModel", "err: $e")

                LoginUiState.Error

            }
        }
    }

}