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

package com.legalsoft.generic.gtc.model;

import com.legalsoft.generic.gtc.Main;
import com.legalsoft.generic.gtc.exception.SimpleGtcException;
import com.legalsoft.generic.gtc.helper.Pair;
import com.legalsoft.generic.gtc.helper.ParameterReader;
import com.legalsoft.generic.gtc.model.dao.FileStringDAO;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.lang.math.RandomUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * com.legalsoft.generic.gtc.model.SimpleGtcModel.
 * Esta clase representa el modelo de datos para el Generador de Códigos de 
 * Prueba.
 * Básicamente son cadenas con patrones de reemplazo, y la clase
 * debe incluir métodos para la carga (opcional) de las cadenas
 * desde una fuente externa.
 *
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public class SimpleGtcModel {
    
    /**
     * Logger para mostrar mensajes de error.
     */
    private final Logger logger = LoggerFactory.getLogger(SimpleGtcModel.class);
    
    /**
     * Una lista de cadenas, que serán los posibles mensajes comunes.
     * Cada cadena debe ser una línea en sí.
     */
    private final ArrayList<String> basic_list = new ArrayList<>();
    
    /**
     * Una lista de cadenas, que serán los posibles mensajes de error.
     * Cada cadena debe ser una línea en sí.
     */
    private final ArrayList<String> error_list = new ArrayList<>();

    /**
     * El mínimo de líneas a mostrar en los mensajes.
     */
    private int min_code_lines;
    
    /**
     * El máximo de líneas a mostrar en los mensajes.
     */
    private int max_code_lines;
        
    /**
     * La posición dentro de la lista de mensajes básicos.
     */
    private int basic_position;
    
    /**
     * La posición dentro de la lista de mensajes de error.
     */
    private int error_position;
    
    /**
     * Constructor por default para el modelo.
     */
    public SimpleGtcModel() {
        this.min_code_lines = 1;
        this.max_code_lines = 1;
        this.basic_position = 0;
        this.error_position = 0;
    }
    
    /**
     * Método que inicializa el modelo, basado en el lector
     * 
     * @param parameterReader
     * @throws SimpleGtcException 
     */
    public void initModel(ParameterReader parameterReader) throws SimpleGtcException {
        //// Buscar los parametros.
        logger.info("Inicializando el modelo @{}", Main.get_TS());
        // numero minimo de lineas [min_lines]
        int min_lines_param = min_code_lines;
        if(parameterReader.testParam("min_lines")) {
            min_lines_param = parameterReader.getInt("min_lines");
        }
        // número máximo de líneas [max_lines]
        int max_lines_param = max_code_lines;
        if (parameterReader.testParam("max_lines")) {
            max_lines_param = parameterReader.getInt("max_lines");
        }
        // pasar los nuevos parámetros
        setMinMaxCodeLines(min_lines_param, max_lines_param);
        // ahora, el path de líneas básicas [basic_path]
        // y de líneas de error [error_path]
        Path basic_path, error_path;
        basic_path = parameterReader.getPath("basic_path");
        error_path = parameterReader.getPath("error_path");
        // inicializar las listas.
        loadModel(basic_path, error_path);
        logger.info("Fin de Inicializacion del modelo @{}", Main.get_TS());
    }
    
    /**
     * Método para pasar el mínimo de líneas
     * @param min_lines 
     */
    private void setMinCodeLines(int min_lines) {
        this.min_code_lines = min_lines;
    }
    
    /**
     * Método para pasar el máximo de líneas
     * @param max_lines 
     */
    private void setMaxCodeLines(int max_lines) {
        this.max_code_lines = max_lines;
    }
    
    /**
     * Método para pasar el mínimo y máximo de líneas
     * @param min_lines El mínimo de líneas
     * @param max_lines El máximo de lineas
     * @throws SimpleGtcException Se lanza cuando los límites no son correctos 
     */
    public void setMinMaxCodeLines(int min_lines, int max_lines) throws SimpleGtcException {
        if (min_lines < 0)
            min_lines = 1;
        if (max_lines < 1)
            max_lines = 1;
        if (min_lines > max_lines) {
            throw new SimpleGtcException("Model", "Error de parametros. El minimo debe ser <= maximo");
        }
        setMinCodeLines(min_lines);
        setMaxCodeLines(max_lines);
    }
    
    /**
     * Método para cargar las cadenas al modelo.
     * @param pathSourceBasic La ruta hacia la fuente de cadenas básicas.
     * @param pathSourceError La ruta hacia la fuente de cadenas de error.
     */
    public void loadModel(Path pathSourceBasic, Path pathSourceError) {
        logger.info("Cargando modelo con cadenas basicas y de error");
        // Crear el DAO
        FileStringDAO fileStringDAO = new FileStringDAO();
        // fijar la fuente de cadenas básicas
        fileStringDAO.setSource(pathSourceBasic);
        // cargar la fuente
        logger.info("Cargando cadenas basicas de la fuente [{}]", pathSourceBasic);
        basic_list.clear();
        basic_list.addAll(fileStringDAO.findAll());
        logger.info("Se han cargado {} cadenas de la fuente basica [{}]", basic_list.size(), pathSourceBasic);
        // fijar la fuente de errores
        fileStringDAO.setSource(pathSourceError);
        // cargar la fuente de errores
        logger.info("Cargando cadenas de error de la fuente [{}]", pathSourceError);
        error_list.clear();
        error_list.addAll(fileStringDAO.findAll());
        logger.info("Se han cargado {} cadenas de la fuente de error [{}]", error_list.size(), pathSourceError);
        // regresar las posiciones al inicio
        this.basic_position = 0;
        this.error_position = 0;
    }
        
    /**
     * Método para generar cadenas a partir del modelo, con una probabilidad 
     * de que sea un error igual al porcentaje de error del modelo.
     * @param result El valor del resultado, para saber de dónde se tomarán
     * las cadenas, si del arreglo básico o del arreglo de error.
     * @return Un par que contiene la lista de cadenas 
     * y el valor del resultado que sigue.
     */
    public List<String> getNextStrings(boolean result) {
        // calcular el numero de lineas
        int num_lines = 
                RandomUtils.nextInt(max_code_lines - min_code_lines + 1) + 
                min_code_lines;
        // arreglo con tantas líneas como lo que se calculó
        List<String> nextStrings = new ArrayList<>(num_lines);
        
        // ahora, si es verdadero, tomamos lineas del basic
        List<String> source_list;
        int source_position;
        int source_size;
        if (result) {
            source_list = basic_list;
            source_position = basic_position;
        } else {
            source_list = error_list;
            source_position = error_position;
        }
        source_size = source_list.size();
        
        for(int i=0; i < num_lines; i++) {
            nextStrings.add(source_list.get(source_position++));
            if (source_position >= source_size) {
                source_position = 0;
            }
        }
        
        // actualizar la posición
        if (result) {
            basic_position = source_position;
        } else {
            error_position = source_position;
        }
       
        return nextStrings;
    }
    
}
