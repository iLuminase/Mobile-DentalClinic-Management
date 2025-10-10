package com.dentalclinic.dentalclinic_api.service;

import com.dentalclinic.dentalclinic_api.model.User;
import java.util.List;
import java.util.Optional;

public interface UserService {
    List<User> getAllUsers();
    User createUser(User user);
    Optional<User> updateUser(Long id, User user);
    void deleteUser(Long id);
}
