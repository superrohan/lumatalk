package com.lumatalk.repository;

import com.lumatalk.entity.SavedPhrase;
import com.lumatalk.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SavedPhraseRepository extends JpaRepository<SavedPhrase, UUID> {

    List<SavedPhrase> findByUserOrderByCreatedAtDesc(User user);

    List<SavedPhrase> findByUserAndSourceLangAndTargetLangOrderByCreatedAtDesc(
            User user, String sourceLang, String targetLang);

    @Query("SELECT sp FROM SavedPhrase sp WHERE sp.user = :user AND " +
           "(LOWER(sp.sourceText) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(sp.translatedText) LIKE LOWER(CONCAT('%', :query, '%')))")
    List<SavedPhrase> searchByUser(@Param("user") User user, @Param("query") String query);

}
