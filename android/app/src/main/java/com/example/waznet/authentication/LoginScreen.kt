package com.example.waznet.authentication

import android.widget.Toast
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
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
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.dimensionResource
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.waznet.R


@Composable
fun LoginScreen(
    modifier: Modifier = Modifier,
    viewModel: LoginViewModel = hiltViewModel()
    ) {
    Scaffold(
        modifier = Modifier.fillMaxSize(),
    ) { paddingValues ->
        LoginScreenContent(
            modifier = Modifier.padding(paddingValues),
            onLogin = viewModel::login
        )

    }
}

@Composable
fun LoginScreenContent(
    modifier: Modifier = Modifier,
    onLogin: (String, String) -> Unit
) {
    var goToPassWord by rememberSaveable { mutableStateOf(false) }
    var goToRegister by rememberSaveable { mutableStateOf(false) }
    var phoneNumber by rememberSaveable { mutableStateOf("") }
    val padding = dimensionResource(id = R.dimen.horizontal_margin)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .paint(
                painter = painterResource(R.drawable.background),
                contentScale = ContentScale.FillBounds
            )
            .padding(
                horizontal = padding
            ),
        contentAlignment = Alignment.Center
    ) {
        if (goToPassWord)
            PasswordComponent(
                modifier = modifier,
                phoneNumber = phoneNumber,
                onBack = {
                    goToPassWord = false
                },
                onLogin = onLogin
            )
        else
            PhoneNumberComponent(
                modifier = modifier,
                phoneNumber = phoneNumber,
                onValueChange = {
                    phoneNumber = it
                },
                onGotoPassword = {
                    goToPassWord = true
                },
                onGotoRegister = {
                    goToRegister = true
                }
            )
        }
}

@Composable
fun PhoneNumberComponent(
    modifier: Modifier = Modifier,
    phoneNumber: String,
    onValueChange: (String) -> Unit,
    onGotoPassword: () -> Unit,
    onGotoRegister: () -> Unit,
) {
    val padding = dimensionResource(id = R.dimen.horizontal_margin)
    val isValidPhoneNumber = phoneNumber.length == 10

    Column(
        modifier = Modifier
            .wrapContentSize()
            .background(Color(0xffFFFFFF).copy(alpha = 0.6f), RoundedCornerShape(12.dp))
            .border(1.dp, MaterialTheme.colorScheme.surface, RoundedCornerShape(12.dp))
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
        PhoneNumberContainer(
            modifier = modifier,
            text = phoneNumber,
            isValid = isValidPhoneNumber,
            onValueChange = onValueChange,
            onSubmit = onGotoPassword
        )
        Spacer(modifier = Modifier.height(24.dp))
        ActionButton(
            isActive = isValidPhoneNumber,
            onClick = onGotoPassword,
            title = stringResource(R.string.continuee)
        )
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            stringResource(R.string.not_have_account),
            style = MaterialTheme.typography.titleSmall
        )
        Spacer(modifier = Modifier.height(24.dp))
        ActionButton(
            isActive = true,
            onClick = {},
            title = stringResource(R.string.sign_up)
        )
    }
}

@Composable
fun PhoneNumberContainer(
    modifier: Modifier = Modifier,
    text: String,
    isValid: Boolean,
    onValueChange: (String) -> Unit,
    onSubmit: () -> Unit
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

            PhoneNumberInput(
                modifier = modifier,
                text = text,
                onValueChange = onValueChange,
                onSubmit = onSubmit,
                isValid = isValid
            )
        }
    }
}


@Composable
fun PhoneNumberInput(
    modifier: Modifier = Modifier,
    text: String,
    isValid: Boolean,
    onValueChange: (String) -> Unit,
    onSubmit: () -> Unit
) {
    val toastTitle = stringResource(R.string.invalid_phone_number)
    val context = LocalContext.current

    TextField(
        value = text,
        onValueChange = onValueChange,
        colors = TextFieldDefaults.colors(
            unfocusedContainerColor = Color(0xFFFFFFFF),
            focusedContainerColor = Color(0xFFFFFFFF),
            focusedIndicatorColor = Color(0xFF4CAF50),
            cursorColor =  Color(0xFF4CAF50)
        ),
        placeholder = {
            Text(
                stringResource(R.string.enter_phone_number),
                style = MaterialTheme.typography.labelMedium
            )
        },
        suffix = if (text.isEmpty()) null else {
            {
                IconButton(
                    onClick = {
                        onValueChange("")
                    },
                    modifier = Modifier.size(20.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Clear,
                        contentDescription = null,
                    )
                }
            }
        },
        keyboardOptions = KeyboardOptions(
            keyboardType = KeyboardType.Phone,
            imeAction = ImeAction.Done
        ),
        keyboardActions = KeyboardActions(
            onDone = {
                if (isValid) {
                    onSubmit()
                } else {
                    Toast.makeText(
                        context,
                        toastTitle,
                        Toast.LENGTH_SHORT
                    ).show()
                }
            }
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

@Composable
fun ActionButton(
    modifier: Modifier = Modifier,
    isActive: Boolean = false,
    onClick: () -> Unit,
    title: String = ""
) {
    Button (
        onClick = onClick,
        enabled = isActive,
        colors = ButtonDefaults.buttonColors(
            containerColor = Color(0xff4CAF50),
            disabledContainerColor = Color(0xffC1C1C2)
        ),
        shape = RoundedCornerShape(12.dp),
    ) {
        Text(
            title,
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 6.dp),
            style =  MaterialTheme.typography.titleMedium,
            textAlign = TextAlign.Center
        )
    }
}




@Composable
fun PasswordComponent(
    modifier: Modifier = Modifier,
    phoneNumber: String,
    onBack: () -> Unit,
    onLogin: (String, String) -> Unit
) {
    val padding = dimensionResource(id = R.dimen.horizontal_margin)

    var passWordText by rememberSaveable() { mutableStateOf("") }
    var isValid by rememberSaveable() { mutableStateOf(true) }

    Column(
        modifier = Modifier
            .wrapContentSize()
            .background(Color(0xffFFFFFF).copy(alpha = 0.6f), RoundedCornerShape(12.dp))
            .border(1.dp, MaterialTheme.colorScheme.surface, RoundedCornerShape(12.dp))
            .padding(horizontal = padding, vertical = padding),

        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        val textModifier = Modifier.fillMaxWidth()


        IconButton(
            onClick = onBack,
            modifier = Modifier.size(24.dp).align(Alignment.Start)
        ) {
            Icon(
                imageVector = Icons.Default.ArrowBack,
                contentDescription = null,
            )
        }

        Text(
            text = stringResource(R.string.enter_password),
            modifier = textModifier,
            style = MaterialTheme.typography.titleLarge,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
            text = stringResource(R.string.login_with_phone_number),
            modifier = textModifier,
            style = MaterialTheme.typography.titleSmall,
            textAlign = TextAlign.Center
        )
        Text(
            text = phoneNumber,
            modifier = textModifier,
            style = MaterialTheme.typography.labelSmall,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(24.dp))
        ValidatingInputTextField(
            value = passWordText,
            onValueChange = {
                passWordText = it
                isValid = it.length >= 8
            },
            isValid = isValid
        )
        Spacer(modifier = Modifier.height(24.dp))
        ActionButton(
            isActive = isValid,
            onClick = {
                onLogin(phoneNumber, passWordText)
            },
            title = stringResource(R.string.login)
        )
    }
}

@Composable
fun ValidatingInputTextField(
    value: String,
    onValueChange: (String) -> Unit,
    isValid: Boolean,
) {
    val focusRequester = remember { FocusRequester() }

    Column {
        Text(
            stringResource(R.string.password),
            style = MaterialTheme.typography.titleSmall,
            textAlign = TextAlign.Left
        )
        Spacer(modifier = Modifier.height(6.dp))
        OutlinedTextField(
            value = value,
            onValueChange = {
                onValueChange(it)
            },
            colors = TextFieldDefaults.colors(
                // Disable focused underline
                unfocusedIndicatorColor = Color.Transparent,
                unfocusedContainerColor = Color(0xFFFFFFFF),
                focusedContainerColor = Color(0xFFFFFFFF),
                focusedIndicatorColor = Color(0xFF4CAF50),
                cursorColor =  Color(0xFF4CAF50),
                errorContainerColor = Color(0xFFFFFFFF)
            ),
            isError = !isValid,
            supportingText = {
                if (!isValid) {
                    Text(stringResource(R.string.password_length_min_8))
                }
            },
            keyboardOptions = KeyboardOptions(
                imeAction = ImeAction.Done
            ),
            shape = RoundedCornerShape(8.dp),
            modifier = Modifier.fillMaxWidth().focusRequester(focusRequester)
        )
    }

    LaunchedEffect(Unit) {
        focusRequester.requestFocus()
    }
}