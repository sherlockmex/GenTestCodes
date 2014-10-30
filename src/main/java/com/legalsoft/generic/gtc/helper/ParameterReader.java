/*
 * Copyright (C) 2014 
 * Angel Emilio de Leon Gutierrez <sherlockmex@users.noreply.github.com>.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

package com.legalsoft.generic.gtc.helper;

import com.legalsoft.generic.gtc.exception.SimpleGtcException;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * com.legalsoft.generic.gtc.helper.ParameterReader.
 * Esta clase representa...
 *
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public class ParameterReader {
    
    /**
     * Variable para el logger.
     */
    private final Logger logger = LoggerFactory.getLogger(ParameterReader.class);
    
    /**
     * Mapa para cargar los parámetros.
     * Deben ser de la forma /key:value
     */
    private Map<String, String> mapaParams = new HashMap<>();

    /**
     * Constructor para cargar los parámetros de un arreglo de cadenas.
     * @param args Los argumentos que hay que cargar.
     */
    public ParameterReader(String[] args) {
        // validar que cada parámetro sea de la forma /key:value
        Pattern pattern = Pattern.compile("/([^:]+):(.+)");
        for (String arg : args) {
            Matcher matcher = pattern.matcher(arg);
            if (matcher.matches()) {
                // Separar los elementos.
                String key = matcher.group(1);
                String value = matcher.group(2);
                // Agregarlo al mapa.
                mapaParams.put(key, value);
            }
        }
    }

    /**
     * El caracter (o caracteres) que separan las líneas
     */
    private static final String NL = System.getProperty("line.separator");
    
    /**
     * Método para convertir a cadena este mapa.
     * @return El mapa como una cadena, separada por saltos de línea.
     */
    @Override
    public String toString() {
        StringBuilder stringBuilder = new StringBuilder();
        for (String key : mapaParams.keySet()) {
            // recuperar el valor.
            stringBuilder.append(key).append(", ").append(mapaParams.get(key)).append(NL);
        }
        return stringBuilder.toString();
    }
    
    /**
     * Método para probar la existencia de un conjunto de parámetros
     * @param paramNames El nombre del parámetro.
     * @return Verdadero si todos los nombres de parámetro existen en el mapa. Falso
     * en otro caso.
     */
    public boolean testParams(String[] paramNames) {
        for (String stringParam : paramNames) {
            if (!testParam(stringParam)) {
                logger.error("El parametro solicitado [{}] no ha sido provisto", stringParam);
                return false;
            }
        }
        return true;
    }
    
    /**
     * Método para probar la existencia de un solo parámetro.
     * @param paramName El nombre del parámetro.
     * @return Verdadero si el parámetro existe. Falso en otro caso.
     */
    public boolean testParam(String paramName) {
        return mapaParams.containsKey(paramName);
    }
    
    /**
     * Método para validar la existencia de un parámetro. Lanza una
     * excepción si el parámetro solicitado no está disponible
     * @param paramName El nombre del parámetro.
     * @throws SimpleGtcException Se lanza si el parámetro no está disponible
     */
    private void assertParam(String paramName) throws SimpleGtcException {
        if (!testParam(paramName)) {
            throw new SimpleGtcException("Parameter", 
                    "El parametro solicitado [{" + paramName 
                            + "}] no ha sido provisto");
        }
    }
    
    /**
     * Método para leer un parámetro de tipo long
     * @param paramName El nombre del parámetro.
     * @return El valor dado al parámetro.
     * @throws SimpleGtcException Se lanza si no existe el parámetro, o 
     * hay un error al leer el valor como long.
     */
    public long getLong(String paramName) throws SimpleGtcException {
        // validar que el parámetro exista
        assertParam(paramName);
        // recuperar el valor.
        String stringValue = mapaParams.get(paramName);
        // ahora parsear a long.
        long value = 0;
        try {
            value = Long.parseLong(stringValue);
        } catch (NumberFormatException | NullPointerException exception) {
            logger.error("Error al leer parametro [{}]:{}", paramName, exception.getMessage());
            throw new SimpleGtcException(
                    "Parameter", "Error al leer parametro [" + 
                            paramName + "]", exception);
        }
        return value;
    }
    
    /**
     * Método para leer un parámetro de tipo long
     * @param paramName El nombre del parámetro.
     * @return El valor dado al parámetro.
     * @throws SimpleGtcException Se lanza si no existe el parámetro, o 
     * hay un error al leer el valor como int.
     */
    public int getInt(String paramName) throws SimpleGtcException {
        // validar que el parámetro exista
        assertParam(paramName);
        // recuperar el valor.
        String stringValue = mapaParams.get(paramName);
        // ahora parsear a long.
        int value = 0;
        try {
            value = Integer.parseInt(stringValue);
        } catch (NumberFormatException | NullPointerException exception) {
            logger.error("Error al leer parametro [{}]:{}", paramName, exception.getMessage());
            throw new SimpleGtcException(
                    "Parameter", "Error al leer parametro [" + 
                            paramName + "]", exception);
        }
        return value;
    }
    
    /**
     * Método para leer un parámetro de tipo String
     * @param paramName El nombre del parámetro.
     * @return El valor dado al parámetro.
     * @throws SimpleGtcException Se lanza si no existe el parámetro.
     */
    public String getString(String paramName) throws SimpleGtcException {
        // validar que el parámetro exista
        assertParam(paramName);
        // recuperar el valor.
        String stringValue = mapaParams.get(paramName);
        // ahora regresar el valor.
        return stringValue;
    }
    
     /**
     * Método para leer un parámetro de tipo Path
     * @param paramName El nombre del parámetro.
     * @return El valor dado al parámetro.
     * @throws SimpleGtcException Se lanza si no existe el parámetro, o 
     * hay un error al leer el valor como path.
     */
    public Path getPath(String paramName) throws SimpleGtcException {
        // validar que el parámetro exista
        assertParam(paramName);
        // recuperar el valor.
        String stringValue = mapaParams.get(paramName);
        // ahora parsear a Path.
        Path value = FileSystems.getDefault().getPath(stringValue);
        try {
            value = value.toRealPath();
        } catch (IOException | NullPointerException exception) {
            logger.error("Error al leer parametro [{}]:{}", paramName, exception.getMessage());
            throw new SimpleGtcException(
                    "Parameter", "Error al leer parametro [" + 
                            paramName + "]", exception);
        }
        return value;
    }

}
