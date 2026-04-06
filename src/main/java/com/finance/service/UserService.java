package com.finance.service;

import com.finance.dto.*;
import com.finance.exception.UnauthorizedException;
import com.finance.model.User;
import com.finance.repository.UserRepository;
import com.finance.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;

    @Autowired
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder,
                       JwtUtil jwtUtil, @Lazy AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.authenticationManager = authenticationManager;
    }
    
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));
    }
    
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new UnauthorizedException("Username already exists");
        }
        
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new UnauthorizedException("Email already exists");
        }
        
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setEmail(request.getEmail());
        user.setRole(request.getRole());
        user.setActive(true);
        
        user = userRepository.save(user);
        
        String token = jwtUtil.generateToken(user);
        return new AuthResponse(token, user.getUsername(), user.getEmail(), user.getRole());
    }
    
    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );
        
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new UnauthorizedException("Invalid credentials"));
        
        String token = jwtUtil.generateToken(user);
        return new AuthResponse(token, user.getUsername(), user.getEmail(), user.getRole());
    }
    
    public List<UserResponse> getAllUsers() {
        return userRepository.findAll().stream()
                .map(user -> new UserResponse(
                        user.getId(),
                        user.getUsername(),
                        user.getEmail(),
                        user.getRole(),
                        user.getActive(),
                        user.getCreatedAt()
                ))
                .collect(Collectors.toList());
    }
    
    @Transactional
    public UserResponse updateUserStatus(Long userId, Boolean active) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("User not found"));
        
        user.setActive(active);
        user = userRepository.save(user);
        
        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getRole(),
                user.getActive(),
                user.getCreatedAt()
        );
    }
}
