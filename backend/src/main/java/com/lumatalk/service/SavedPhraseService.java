package com.lumatalk.service;

import com.lumatalk.entity.SavedPhrase;
import com.lumatalk.entity.User;
import com.lumatalk.repository.SavedPhraseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SavedPhraseService {

    private final SavedPhraseRepository savedPhraseRepository;

    @Transactional
    public SavedPhrase savePhrase(User user, String sourceText, String translatedText,
                                  String sourceLang, String targetLang, String[] tags) {
        SavedPhrase phrase = new SavedPhrase();
        phrase.setUser(user);
        phrase.setSourceText(sourceText);
        phrase.setTranslatedText(translatedText);
        phrase.setSourceLang(sourceLang);
        phrase.setTargetLang(targetLang);
        phrase.setTags(tags);
        phrase.setReviewCount(0);

        return savedPhraseRepository.save(phrase);
    }

    public List<SavedPhrase> getUserPhrases(User user) {
        return savedPhraseRepository.findByUserOrderByCreatedAtDesc(user);
    }

    public List<SavedPhrase> searchPhrases(User user, String query) {
        return savedPhraseRepository.searchByUser(user, query);
    }

    public List<SavedPhrase> getPhrasesByLanguagePair(User user, String sourceLang, String targetLang) {
        return savedPhraseRepository.findByUserAndSourceLangAndTargetLangOrderByCreatedAtDesc(
                user, sourceLang, targetLang);
    }

    @Transactional
    public void deletePhrase(UUID phraseId) {
        savedPhraseRepository.deleteById(phraseId);
    }

}
