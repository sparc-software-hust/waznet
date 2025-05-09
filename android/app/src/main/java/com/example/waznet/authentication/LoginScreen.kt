package com.example.waznet.authentication

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.paint
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.dimensionResource
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.waznet.R


@Preview(showBackground = true)
@Composable
fun LoginScreen(
    modifier: Modifier = Modifier,
    ) {
    Scaffold(
        modifier = Modifier.fillMaxSize(),
    ) { paddingValues ->
        LoginScreenContent(
            Modifier.padding(paddingValues)
        )

    }
}

@Composable
fun LoginScreenContent(
    modifier: Modifier = Modifier
) {
    val padding = dimensionResource(id = R.dimen.horizontal_margin)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .paint(
                painter = painterResource(R.drawable.background),
                contentScale = ContentScale.FillBounds
            ).padding(
                horizontal = padding
            ),
        contentAlignment = Alignment.Center
    ) {
        PhoneNumberComponent(modifier = modifier)
    }
}

@Composable
fun PhoneNumberComponent(
    modifier: Modifier = Modifier
) {
    val padding = dimensionResource(id = R.dimen.horizontal_margin)

    Column(
        modifier = Modifier
            .wrapContentSize()
            .background(MaterialTheme.colorScheme.background, RoundedCornerShape(8.dp))
            .padding(horizontal = padding, vertical = padding),

        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        val textModifier = Modifier.fillMaxWidth()

        Image(
            painter = painterResource(R.drawable.logo_green),
            contentDescription = null,
            modifier = Modifier.size(60.dp)
        )
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            text = stringResource(R.string.login_title),
            modifier = textModifier,
            style = MaterialTheme.typography.titleLarge,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = stringResource(R.string.login_sign_in),
            modifier = textModifier,
            style = MaterialTheme.typography.titleSmall,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            text = stringResource(R.string.phone_number),
            modifier = textModifier,
            style = MaterialTheme.typography.titleSmall,
            textAlign = TextAlign.Left
        )
        Spacer(modifier = Modifier.height(6.dp))
        PhoneNumberContainer(modifier = modifier)
    }
}

@Composable
fun PhoneNumberContainer(
    modifier: Modifier = Modifier
) {
    val padding = dimensionResource(id = R.dimen.horizontal_margin)

    Box(
        modifier = Modifier
            .wrapContentSize()
            .background(Color.White)
            .border(1.dp, MaterialTheme.colorScheme.outlineVariant, RoundedCornerShape(8.dp)),
        contentAlignment = Alignment.Center
    ) {
        Row(
            modifier = Modifier.fillMaxWidth()
        ) {
            val outlineColor = MaterialTheme.colorScheme.outlineVariant
            Row(
                modifier = Modifier
                    // right border
                    .drawBehind {
                        drawLine(
                            color = outlineColor,
                            start = Offset(size.width, 0f),
                            end = Offset(size.width, size.height),
                            strokeWidth = 1.dp.toPx()
                        )
                    }
                    .padding(12.dp)
                    .clip(
                        shape = RoundedCornerShape(
                            topStart = 8.dp,
                            bottomStart = 8.dp,
                        )
                    )
                    .background(MaterialTheme.colorScheme.surface),

                verticalAlignment = Alignment.CenterVertically
            ) {
                Image(
                    painter = painterResource(R.drawable.vietnam),
                    contentDescription = null,
                    contentScale = ContentScale.FillBounds
                )
                Spacer(modifier = Modifier.size(8.dp))
                Text(
                    stringResource(R.string.vietnam_code),
                    style = MaterialTheme.typography.headlineSmall,
                )
            }

            PhoneNumberInput(modifier = modifier)
        }
    }
}


@Composable
fun PhoneNumberInput(
    modifier: Modifier = Modifier
) {
    var text by remember { mutableStateOf("") }

    TextField(
        value = text,
        onValueChange = {
            text = it
        },
        colors = TextFieldDefaults.colors(
            unfocusedContainerColor = MaterialTheme.colorScheme.surface,
            focusedContainerColor = MaterialTheme.colorScheme.surface
        ),
        placeholder = {
            Text(stringResource(R.string.enter_phone_number))
        },
        suffix = if (text.isEmpty()) null else {
            {
                Icon(
                    imageVector = Icons.Default.Clear,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp),
                    tint = MaterialTheme.colorScheme.onPrimary
                )
            }
        },
        keyboardOptions = KeyboardOptions(
            keyboardType = KeyboardType.Phone
        ),
        modifier = Modifier
            .height(56.dp)
            .fillMaxWidth()
            .clip(
                shape = RoundedCornerShape(
                    topEnd = 8.dp,
                    bottomEnd = 8.dp,
                )
            )
    )
}
