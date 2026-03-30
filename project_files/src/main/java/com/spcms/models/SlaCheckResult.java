package com.spcms.models;

public class SlaCheckResult {

    private final String name;
    private final String description;
    private final String target;
    private final String actual;
    private final boolean compliant;
    private final String notes;

    public SlaCheckResult(String name, String description, String target, String actual, boolean compliant, String notes) {
        this.name = name;
        this.description = description;
        this.target = target;
        this.actual = actual;
        this.compliant = compliant;
        this.notes = notes;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getTarget() {
        return target;
    }

    public String getActual() {
        return actual;
    }

    public boolean isCompliant() {
        return compliant;
    }

    public String getNotes() {
        return notes;
    }
}
