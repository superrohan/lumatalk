package com.lumatalk.controller;

import com.lumatalk.dto.LoginRequest;
import com.lumatalk.dto.RegisterRequest;
import com.lumatalk.dto.AuthResponse;
import com.lumatalk.entity.User;
import com.lumatalk.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        User user = authService.register(request.getEmail(), request.getPassword(), request.getFullName());
        String token = authService.login(request.getEmail(), request.getPassword());

        return ResponseEntity.ok(new AuthResponse(token, user.getId().toString(), user.getEmail()));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        String token = authService.login(request.getEmail(), request.getPassword());
        User user = authService.validateToken(token)
                .orElseThrow(() -> new IllegalStateException("Token validation failed"));

        return ResponseEntity.ok(new AuthResponse(token, user.getId().toString(), user.getEmail()));
    }

}
