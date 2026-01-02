package com.lumatalk.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "utterances")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Utterance {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private Session session;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String sourceText;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String translatedText;

    @Column(nullable = false)
    private Double confidence;

    @Column(nullable = false)
    private LocalDateTime timestamp;

    @Column(length = 500)
    private String audioUrl;

    @Column(nullable = false)
    private Boolean isFinal = true;

}
