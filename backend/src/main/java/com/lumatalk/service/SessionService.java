package com.lumatalk.service;

import com.lumatalk.entity.Session;
import com.lumatalk.entity.User;
import com.lumatalk.entity.Utterance;
import com.lumatalk.repository.SessionRepository;
import com.lumatalk.repository.UtteranceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SessionService {

    private final SessionRepository sessionRepository;
    private final UtteranceRepository utteranceRepository;

    @Transactional
    public Session createSession(User user, String sourceLang, String targetLang) {
        Session session = new Session();
        session.setUser(user);
        session.setSourceLang(sourceLang);
        session.setTargetLang(targetLang);
        session.setStartTime(LocalDateTime.now());
        session.setTotalUtterances(0);
        session.setSaved(false);

        return sessionRepository.save(session);
    }

    @Transactional
    public Session endSession(UUID sessionId) {
        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Session not found"));

        session.setEndTime(LocalDateTime.now());
        return sessionRepository.save(session);
    }

    @Transactional
    public Utterance addUtterance(UUID sessionId, String sourceText, String translatedText,
                                  Double confidence, String audioUrl) {
        Session session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Session not found"));

        Utterance utterance = new Utterance();
        utterance.setSession(session);
        utterance.setSourceText(sourceText);
        utterance.setTranslatedText(translatedText);
        utterance.setConfidence(confidence);
        utterance.setTimestamp(LocalDateTime.now());
        utterance.setAudioUrl(audioUrl);
        utterance.setIsFinal(true);

        session.setTotalUtterances(session.getTotalUtterances() + 1);
        sessionRepository.save(session);

        return utteranceRepository.save(utterance);
    }

    public List<Session> getUserSessions(User user) {
        return sessionRepository.findByUserOrderByStartTimeDesc(user);
    }

    public Session getSession(UUID sessionId) {
        return sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Session not found"));
    }

    public List<Utterance> getSessionUtterances(UUID sessionId) {
        Session session = getSession(sessionId);
        return utteranceRepository.findBySessionOrderByTimestampAsc(session);
    }

    @Transactional
    public void deleteSession(UUID sessionId) {
        sessionRepository.deleteById(sessionId);
    }

}
