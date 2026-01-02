package com.lumatalk.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddUtteranceRequest {

    @NotBlank(message = "Source text is required")
    private String sourceText;

    @NotBlank(message = "Translated text is required")
    private String translatedText;

    @NotNull(message = "Confidence is required")
    private Double confidence;

    private String audioUrl;

}
