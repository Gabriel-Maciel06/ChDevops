package com.clyvo.api.controller;
import com.clyvo.api.model.HistoricoClinico;
import com.clyvo.api.repository.HistoricoClinicoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import java.net.URI;
@RestController
@RequiredArgsConstructor @RequestMapping("/api/historico")
public class HistoricoClinicoController {
    private final HistoricoClinicoRepository repository;
    @GetMapping("/{id}") public ResponseEntity<HistoricoClinico> buscar(@PathVariable Long id) { return repository.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build()); }
    @PostMapping public ResponseEntity<HistoricoClinico> salvar(@RequestBody HistoricoClinico h) { return ResponseEntity.ok(repository.save(h)); }
    
    @PutMapping("/{id}")
    public ResponseEntity<HistoricoClinico> atualizar(@PathVariable Long id, @RequestBody HistoricoClinico h) {
        if(!repository.existsById(id)) return ResponseEntity.notFound().build();
        h.setId(id);
        return ResponseEntity.ok(repository.save(h));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        if(!repository.existsById(id)) return ResponseEntity.notFound().build();
        repository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
