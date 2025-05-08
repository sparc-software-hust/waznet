package com.example.waznet.authentication

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.paint
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.waznet.R

@Preview
@Composable
fun LoginScreen(
    modifier: Modifier = Modifier,
    ) {
    Scaffold(
        modifier = Modifier.fillMaxSize(),
    ) { paddingValues ->
        LoginScreenContent(
            Modifier
                .fillMaxSize()
                .paint(
                    painter = painterResource(R.drawable.background),
                    contentScale = ContentScale.FillBounds
                )
                .padding(paddingValues)
        )

    }
}

@Composable
fun LoginScreenContent(
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Image(
            painter = painterResource(R.drawable.logo_green),
            contentDescription = null,
            modifier = Modifier.size(60.dp)
        )
    }
}