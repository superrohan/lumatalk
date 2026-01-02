package com.lumatalk.service;

import com.lumatalk.entity.User;
import com.lumatalk.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    @Transactional
    public User register(String email, String password, String fullName) {
        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email already registered");
        }

        User user = new User();
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setFullName(fullName);
        user.setSubscriptionTier("free");
        user.setActive(true);
        user.setTranslationQuota(1000);
        user.setTranslationsUsed(0);

        return userRepository.save(user);
    }

    @Transactional
    public String login(String email, String password) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Invalid credentials"));

        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new IllegalArgumentException("Invalid credentials");
        }

        if (!user.getActive()) {
            throw new IllegalArgumentException("Account is inactive");
        }

        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        return jwtService.generateToken(user);
    }

    public Optional<User> validateToken(String token) {
        String email = jwtService.extractEmail(token);
        if (email == null) {
            return Optional.empty();
        }
        return userRepository.findByEmail(email);
    }

}
