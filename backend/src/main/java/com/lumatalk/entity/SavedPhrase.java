package com.lumatalk.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "saved_phrases")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SavedPhrase {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String sourceText;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String translatedText;

    @Column(nullable = false, length = 10)
    private String sourceLang;

    @Column(nullable = false, length = 10)
    private String targetLang;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column
    private String[] tags;

    @Column(nullable = false)
    private Integer reviewCount = 0;

    @Column
    private LocalDateTime lastReviewedAt;

}
