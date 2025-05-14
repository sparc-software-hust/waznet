//package com.example.waznet.authentication
//
//import androidx.compose.runtime.getValue
//import androidx.compose.runtime.mutableStateOf
//import androidx.compose.runtime.setValue
//import androidx.lifecycle.ViewModel
//import dagger.hilt.android.lifecycle.HiltViewModel
//
//// ui state
//data class LoginUiState(
//    val phone: String = "",
//    val isValidFormatPhone: Boolean = false,
//)
//
//// di for view model
//@HiltViewModel
//class LoginViewModel : ViewModel() {
//    var uiState by mutableStateOf(LoginUiState())
//        private set
//}