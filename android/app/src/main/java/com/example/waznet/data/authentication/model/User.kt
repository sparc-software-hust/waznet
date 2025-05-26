package com.example.waznet.data.authentication.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class User(
    @SerialName("avatar_url")
    val avatarUrl: String,
    @SerialName("date_of_birth")
    val dateOfBirth: String,
    val email: String,
    @SerialName("first_name")
    val firstName: String,
    val gender: Int,
    val id: String,
    @SerialName("is_removed")
    val isRemoved: Boolean,
    @SerialName("last_name")
    val lastName: String,
    val location: String,
    @SerialName("phone_number")
    val phoneNumber: String,
    @SerialName("role_id")
    val roleId: Int,
    val verified: Boolean
)