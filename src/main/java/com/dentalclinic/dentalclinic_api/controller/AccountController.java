package com.dentalclinic.dentalclinic_api.controller;

import com.dentalclinic.dentalclinic_api.model.Account;
import com.dentalclinic.dentalclinic_api.service.AccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/account")
public class AccountController {

    @Autowired
    private AccountService accountService;

    // Đăng ký
    @PostMapping("/register")
    public Account register(@RequestBody Account account) {
        return accountService.register(account);
    }

    // Đăng nhập
    @PostMapping("/login")
    public String login(@RequestParam String username, @RequestParam String password) {
        Optional<Account> acc = accountService.login(username, password);
        return acc.isPresent() ? "Login success for " + username : "Invalid username or password!";
    }

    // Lấy thông tin theo ID
    @GetMapping("/{id}")
    public Optional<Account> getAccount(@PathVariable Long id) {
        return accountService.getAccountById(id);
    }

    // Lấy tất cả account
    @GetMapping("/all")
    public List<Account> getAllAccounts() {
        return accountService.getAllAccounts();
    }
}
