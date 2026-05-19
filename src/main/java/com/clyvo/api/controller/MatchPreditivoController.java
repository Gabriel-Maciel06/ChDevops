package com.clyvo.api.controller;

import com.clyvo.api.model.Clinica;
import com.clyvo.api.service.MatchPreditivoService;
import org.springframework.http.ResponseEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/match-preditivo")
@RequiredArgsConstructor
public class MatchPreditivoController {

    private final MatchPreditivoService matchPreditivoService;

    @GetMapping("/clinicas")
    public ResponseEntity<List<Clinica>> sugerirClinicas(
            @RequestParam String cpfTutor,
            @RequestParam Long idTipoServico) {
        
        List<Clinica> clinicas = matchPreditivoService.buscarClinicasProximasParaServico(cpfTutor, idTipoServico);
        return ResponseEntity.ok(clinicas);
    }
}
