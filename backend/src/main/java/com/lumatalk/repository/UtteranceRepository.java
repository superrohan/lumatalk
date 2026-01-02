package com.lumatalk.repository;

import com.lumatalk.entity.Session;
import com.lumatalk.entity.Utterance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UtteranceRepository extends JpaRepository<Utterance, UUID> {

    List<Utterance> findBySessionOrderByTimestampAsc(Session session);

}
