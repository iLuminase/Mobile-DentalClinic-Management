package com.dentalclinic.dentalclinic_api.service;

import com.dentalclinic.dentalclinic_api.model.Account;

import java.util.List;
import java.util.Optional;

public interface AccountService {
    Account register(Account account);

    Optional<Account> login(String username, String password);

    Optional<Account> getAccountById(Long id);

    List<Account> getAllAccounts();
}
