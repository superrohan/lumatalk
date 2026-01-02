package com.lumatalk.controller;

import com.lumatalk.dto.SavePhraseRequest;
import com.lumatalk.entity.SavedPhrase;
import com.lumatalk.entity.User;
import com.lumatalk.service.SavedPhraseService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/saved")
@RequiredArgsConstructor
public class SavedPhraseController {

    private final SavedPhraseService savedPhraseService;

    @PostMapping
    public ResponseEntity<SavedPhrase> savePhrase(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody SavePhraseRequest request) {
        SavedPhrase phrase = savedPhraseService.savePhrase(
                user,
                request.getSourceText(),
                request.getTranslatedText(),
                request.getSourceLang(),
                request.getTargetLang(),
                request.getTags()
        );
        return ResponseEntity.ok(phrase);
    }

    @GetMapping
    public ResponseEntity<List<SavedPhrase>> getUserPhrases(@AuthenticationPrincipal User user) {
        List<SavedPhrase> phrases = savedPhraseService.getUserPhrases(user);
        return ResponseEntity.ok(phrases);
    }

    @GetMapping("/search")
    public ResponseEntity<List<SavedPhrase>> searchPhrases(
            @AuthenticationPrincipal User user,
            @RequestParam String query) {
        List<SavedPhrase> phrases = savedPhraseService.searchPhrases(user, query);
        return ResponseEntity.ok(phrases);
    }

    @GetMapping("/filter")
    public ResponseEntity<List<SavedPhrase>> filterByLanguages(
            @AuthenticationPrincipal User user,
            @RequestParam String sourceLang,
            @RequestParam String targetLang) {
        List<SavedPhrase> phrases = savedPhraseService.getPhrasesByLanguagePair(user, sourceLang, targetLang);
        return ResponseEntity.ok(phrases);
    }

    @DeleteMapping("/{phraseId}")
    public ResponseEntity<Void> deletePhrase(@PathVariable UUID phraseId) {
        savedPhraseService.deletePhrase(phraseId);
        return ResponseEntity.noContent().build();
    }

}
