package com.dentalclinic.dentalclinic_api.service;

import com.dentalclinic.dentalclinic_api.model.Account;
import com.dentalclinic.dentalclinic_api.repository.AccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AccountServiceImpl implements AccountService {

    @Autowired
    private AccountRepository accountRepository;

    @Override
    public Account register(Account account) {
        return accountRepository.save(account);
    }

    @Override
    public Optional<Account> login(String username, String password) {
        return accountRepository.findByUsername(username)
                .filter(acc -> acc.getPassword().equals(password));
    }

    @Override
    public Optional<Account> getAccountById(Long id) {
        return accountRepository.findById(id);
    }

    @Override
    public List<Account> getAllAccounts() {
        return accountRepository.findAll();
    }
}
