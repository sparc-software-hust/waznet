//package com.example.waznet.di
//
//import com.example.waznet.network.LoginApi
//import dagger.Module
//import dagger.Provides
//import dagger.hilt.InstallIn
//import dagger.hilt.components.SingletonComponent
//import kotlinx.serialization.json.Json
//import okhttp3.MediaType.Companion.toMediaType
//import retrofit2.Retrofit
//import retrofit2.converter.kotlinx.serialization.asConverterFactory
//import javax.inject.Singleton
//
//@Module
//@InstallIn(SingletonComponent::class)
//object NetworkModule {
//
//    @Singleton
//    @Provides
//    fun provideRetrofit(): Retrofit {
//        return Retrofit.Builder()
//            .baseUrl("http://14.225.211.176:4000/api")
//            .addConverterFactory(Json.asConverterFactory("application/json".toMediaType()))
//            .build()
//    }
//
//    @Singleton
//    @Provides
//    fun provideApiService(retrofit: Retrofit): LoginApi {
//        return retrofit.create(LoginApi::class.java)
//
//    }
//
//}