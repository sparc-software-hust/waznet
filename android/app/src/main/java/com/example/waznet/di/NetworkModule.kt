package com.example.waznet.di

import com.example.waznet.data.authentication.LoginRepoImpl
import com.example.waznet.domain.repo.LoginRepo
import com.example.waznet.network.LoginApi
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideRetrofit(): Retrofit {
        return Retrofit.Builder()
            .baseUrl("http://14.225.211.176:4000/api/")
            .addConverterFactory(Json.asConverterFactory("application/json".toMediaType()))
            .build()
    }

    @Provides
    @Singleton
    fun provideLoginApi(retrofit: Retrofit) : LoginApi {
        return retrofit.create(LoginApi::class.java)
    }
}

@Module
@InstallIn(SingletonComponent::class)
abstract class NetworkRepo {

    @Singleton
    @Binds
    abstract fun bindNetworkRepo(loginRepoImpl: LoginRepoImpl): LoginRepo
}