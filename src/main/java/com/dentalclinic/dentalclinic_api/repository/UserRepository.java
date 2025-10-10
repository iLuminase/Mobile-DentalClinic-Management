package com.dentalclinic.dentalclinic_api.repository;

import com.dentalclinic.dentalclinic_api.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
}
