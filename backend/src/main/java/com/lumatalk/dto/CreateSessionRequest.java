package com.lumatalk.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateSessionRequest {

    @NotBlank(message = "Source language is required")
    private String sourceLang;

    @NotBlank(message = "Target language is required")
    private String targetLang;

}
