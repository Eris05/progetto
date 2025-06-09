package com.javaproject.sistemi_distribuiti.entity;

public enum Subject {
        TECHNICAL_SUPPORT("Supporto Tecnico"),
        BILLING("Fatturazione"),
        ACCOUNT_MANAGEMENT("Gestione Account"),
        PRODUCT_INQUIRY("Richiesta Prodotto"),
        GENERAL_INFORMATION("Informazioni Generali");

    private final String description;

    Subject(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }

    // Metodo per trovare un enum dal suo nome (case insensitive)
    public static Subject fromName(String name) {
        for (Subject subject : Subject.values()) {
            if (subject.name().equalsIgnoreCase(name)) {
                return subject;
            }
        }
        throw new IllegalArgumentException("Invalid department name: " + name);
    }

    // Metodo per trovare un enum dalla sua descrizione
    public static Subject fromDescription(String description) {
        for (Subject subject : Subject.values()) {
            if (subject.getDescription().equalsIgnoreCase(description)) {
                return subject;
            }
        }
        throw new IllegalArgumentException("Invalid department description: " + description);
    }
}

