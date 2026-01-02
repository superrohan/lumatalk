package com.lumatalk.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SavePhraseRequest {

    @NotBlank(message = "Source text is required")
    private String sourceText;

    @NotBlank(message = "Translated text is required")
    private String translatedText;

    @NotBlank(message = "Source language is required")
    private String sourceLang;

    @NotBlank(message = "Target language is required")
    private String targetLang;

    private String[] tags;

}
