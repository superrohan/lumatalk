package com.lumatalk.repository;

import com.lumatalk.entity.Session;
import com.lumatalk.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SessionRepository extends JpaRepository<Session, UUID> {

    List<Session> findByUserOrderByStartTimeDesc(User user);

    List<Session> findByUserAndSavedTrueOrderByStartTimeDesc(User user);

}
