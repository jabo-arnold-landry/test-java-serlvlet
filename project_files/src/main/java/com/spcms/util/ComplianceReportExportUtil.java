package com.spcms.util;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Font;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.springframework.stereotype.Component;

import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

@Component
public class ComplianceReportExportUtil {

    public byte[] toCsv(List<?> rows) {
        if (rows == null || rows.isEmpty()) {
            return "No data\n".getBytes(StandardCharsets.UTF_8);
        }

        List<PropertyDescriptor> descriptors = descriptors(rows.get(0).getClass());
        StringBuilder builder = new StringBuilder();

        builder.append(descriptors.stream()
                .map(pd -> escapeCsv(pd.getName()))
                .collect(Collectors.joining(",")));
        builder.append('\n');

        for (Object row : rows) {
            List<String> values = new ArrayList<>();
            for (PropertyDescriptor pd : descriptors) {
                values.add(escapeCsv(readProperty(row, pd)));
            }
            builder.append(String.join(",", values)).append('\n');
        }

        return builder.toString().getBytes(StandardCharsets.UTF_8);
    }

    public byte[] toPdf(String title, List<?> rows) throws IOException {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        Document document = new Document();

        try {
            PdfWriter.getInstance(document, outputStream);
            document.open();

            Font titleFont = new Font(Font.HELVETICA, 14, Font.BOLD);
            document.add(new Paragraph(title, titleFont));
            document.add(new Paragraph(" "));

            if (rows == null || rows.isEmpty()) {
                document.add(new Paragraph("No data available."));
                return outputStream.toByteArray();
            }

            List<PropertyDescriptor> descriptors = descriptors(rows.get(0).getClass());
            PdfPTable table = new PdfPTable(descriptors.size());
            table.setWidthPercentage(100f);

            for (PropertyDescriptor pd : descriptors) {
                PdfPCell header = new PdfPCell(new Phrase(formatHeader(pd.getName())));
                header.setPadding(5f);
                table.addCell(header);
            }

            for (Object row : rows) {
                for (PropertyDescriptor pd : descriptors) {
                    table.addCell(new Phrase(readProperty(row, pd)));
                }
            }

            document.add(table);
        } catch (DocumentException e) {
            throw new IOException("Failed to generate PDF", e);
        } finally {
            document.close();
        }

        return outputStream.toByteArray();
    }

    private List<PropertyDescriptor> descriptors(Class<?> type) {
        try {
            List<PropertyDescriptor> all = List.of(Introspector.getBeanInfo(type, Object.class).getPropertyDescriptors());
            return all.stream()
                    .filter(pd -> pd.getReadMethod() != null)
                    .collect(Collectors.toList());
        } catch (Exception e) {
            throw new IllegalStateException("Failed to read bean descriptors", e);
        }
    }

    private String readProperty(Object source, PropertyDescriptor pd) {
        try {
            Method readMethod = pd.getReadMethod();
            Object value = readMethod.invoke(source);
            return value == null ? "" : String.valueOf(value);
        } catch (Exception e) {
            return "";
        }
    }

    private String formatHeader(String key) {
        String normalized = key.replaceAll("([a-z])([A-Z])", "$1 $2").replace('_', ' ');
        String[] parts = normalized.split("\\s+");
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < parts.length; i++) {
            if (parts[i].isBlank()) {
                continue;
            }
            String token = parts[i].toLowerCase(Locale.ROOT);
            sb.append(Character.toUpperCase(token.charAt(0))).append(token.substring(1));
            if (i < parts.length - 1) {
                sb.append(' ');
            }
        }
        return sb.toString();
    }

    private String escapeCsv(String value) {
        String safe = value == null ? "" : value;
        boolean quote = safe.contains(",") || safe.contains("\"") || safe.contains("\n");
        if (quote) {
            safe = safe.replace("\"", "\"\"");
            return "\"" + safe + "\"";
        }
        return safe;
    }
}
