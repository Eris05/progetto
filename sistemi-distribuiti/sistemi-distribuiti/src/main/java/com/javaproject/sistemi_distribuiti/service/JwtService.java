package com.javaproject.sistemi_distribuiti.service;

import com.javaproject.sistemi_distribuiti.entity.Role;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.time.Instant;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JwtService {

    @Value("${security.jwt.secret-key}")
    private String secretKey;

    @Value("${security.jwt.expiration-time}")
    private long jwtExpiration;

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    public String generateToken(Map<String, Object> extraClaims, UserDetails userDetails) {
        return buildToken(extraClaims, userDetails, jwtExpiration);
    }

    public String generateToken(UserDetails userDetails, Role role) {
        Map<String, Object> extraClaims = new HashMap<>();
        extraClaims.put("role", role); // Aggiungi il ruolo come claim
        return generateToken(extraClaims, userDetails);
    }

    public Role extractRole(String token) {
        String roleName = extractClaim(token, claims -> claims.get("role", String.class));
        return Role.valueOf(roleName); // Converte il valore String in un enum Role
    }


    public long getExpirationTime() {
        return jwtExpiration;
    }

    private String buildToken(
            Map<String, Object> extraClaims,
            UserDetails userDetails,
            long expiration
    ) {
        // Usa Instant.now() per garantire che il tempo sia in UTC
        Instant now = Instant.now();  // Ora UTC
        Date issuedAt = Date.from(now);  // Tempo di emissione in UTC
        Date expirationTime = Date.from(now.plusSeconds(expiration));  // Tempo di scadenza in UTC

        return Jwts.builder()
                .setClaims(extraClaims)
                .setSubject(userDetails.getUsername())
                .setIssuedAt(issuedAt)  // Imposta il tempo di emissione
                .setExpiration(expirationTime)  // Imposta il tempo di scadenza
                .signWith(getSignInKey(), SignatureAlgorithm.HS256)
                .compact();
    }


    public boolean isTokenValid(String token, UserDetails userDetails, Role expectedRole) {
        final String username = extractUsername(token);
        final Role role = extractRole(token);
        return username.equals(userDetails.getUsername())
                && role.equals(expectedRole)
                && !isTokenExpired(token);
    }

    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSignInKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private Key getSignInKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyBytes);
    }

}
