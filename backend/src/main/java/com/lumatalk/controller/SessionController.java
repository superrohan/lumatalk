package com.lumatalk.controller;

import com.lumatalk.dto.CreateSessionRequest;
import com.lumatalk.dto.AddUtteranceRequest;
import com.lumatalk.entity.Session;
import com.lumatalk.entity.Utterance;
import com.lumatalk.entity.User;
import com.lumatalk.service.SessionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/sessions")
@RequiredArgsConstructor
public class SessionController {

    private final SessionService sessionService;

    @PostMapping
    public ResponseEntity<Session> createSession(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CreateSessionRequest request) {
        Session session = sessionService.createSession(user, request.getSourceLang(), request.getTargetLang());
        return ResponseEntity.ok(session);
    }

    @GetMapping
    public ResponseEntity<List<Session>> getUserSessions(@AuthenticationPrincipal User user) {
        List<Session> sessions = sessionService.getUserSessions(user);
        return ResponseEntity.ok(sessions);
    }

    @GetMapping("/{sessionId}")
    public ResponseEntity<Session> getSession(@PathVariable UUID sessionId) {
        Session session = sessionService.getSession(sessionId);
        return ResponseEntity.ok(session);
    }

    @GetMapping("/{sessionId}/utterances")
    public ResponseEntity<List<Utterance>> getSessionUtterances(@PathVariable UUID sessionId) {
        List<Utterance> utterances = sessionService.getSessionUtterances(sessionId);
        return ResponseEntity.ok(utterances);
    }

    @PostMapping("/{sessionId}/utterances")
    public ResponseEntity<Utterance> addUtterance(
            @PathVariable UUID sessionId,
            @Valid @RequestBody AddUtteranceRequest request) {
        Utterance utterance = sessionService.addUtterance(
                sessionId,
                request.getSourceText(),
                request.getTranslatedText(),
                request.getConfidence(),
                request.getAudioUrl()
        );
        return ResponseEntity.ok(utterance);
    }

    @PutMapping("/{sessionId}/end")
    public ResponseEntity<Session> endSession(@PathVariable UUID sessionId) {
        Session session = sessionService.endSession(sessionId);
        return ResponseEntity.ok(session);
    }

    @DeleteMapping("/{sessionId}")
    public ResponseEntity<Void> deleteSession(@PathVariable UUID sessionId) {
        sessionService.deleteSession(sessionId);
        return ResponseEntity.noContent().build();
    }

}
