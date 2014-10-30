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

package com.legalsoft.generic.gtc;

import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.core.util.StatusPrinter;
import com.legalsoft.generic.gtc.controller.SimpleGtcController;
import com.legalsoft.generic.gtc.exception.SimpleGtcException;
import com.legalsoft.generic.gtc.helper.ParameterReader;
import java.text.SimpleDateFormat;
import java.util.Date;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * com.legalsoft.generic.gtc.Main.
 * Esta clase representa el punto de entrada para el servidor de generación
 * de códigos de prueba
 *
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public class Main {

    /**
     * Variable logger para el log
     */
    private static final Logger logger = LoggerFactory.getLogger(Main.class);
    
    /**
     * Variable para formatear TS.
     */
    private static final SimpleDateFormat TS_FORMAT = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss.SSS");
    
    /**
     * Método sincronizado para recuperar el TS.
     * Debe ser así porque el formateador no es seguro entre threads.
     * @return Una cadena con el TS ya formateado.
     */
    public synchronized static String get_TS() {
        return TS_FORMAT.format(new Date());
    }
    
    /**
     * Método para mostrar la ayuda y salir.
     */
    private static void showHelp() {
        System.out.println("Uso del sistema:");
        System.out.println("GenTestCodes /basic_path:path_value /error_path:path_value [/delay:long_value] [/error_percent:int_value] [/min_lines:int_value] [/max_lines:int_value]");
        System.out.println("  Donde:");
        System.out.println("  basic_path   : Es la ruta del archivo con las cadenas basicas");
        System.out.println("  error_path   : Es la ruta del archivo con las cadenas de error");
        System.out.println("  delay        : Es la espera entre escrituras del log. Debe ser un long => 200");
        System.out.println("  error_percent: Es el porcentaje de lineas de error. Debe ser un entero entre 1 y 99");
        System.out.println("  min_lines    : Es el minimo de lineas que se escribiran por cada ejecucion");
        System.out.println("  max_lines    : Es el maximo de lineas que se escribiran por cada ejecucion");
    }
    
    /**
     * Punto de entrada a la aplicación.
     * @param args Los argumentos recibidos de la línea de comandos.
     */
    public static void main(String[] args) {
        
        // assume SLF4J is bound to logback in the current environment
        LoggerContext lc = (LoggerContext) LoggerFactory.getILoggerFactory();
        // print logback's internal status
        StatusPrinter.print(lc);
        
        logger.info("***** Comenzando ejecucion @{}", get_TS());
        // leer los parámetros.
        ParameterReader parameterReader = new ParameterReader(args);
        logger.info("Parametros: \n{}", parameterReader.toString());
        // Cargar el controlador de timer.
        SimpleGtcController controller = new SimpleGtcController();
        try {
            // Inicializar todo en el controller.
            controller.init(parameterReader);
        } catch (SimpleGtcException exception) {
            logger.error("Error de inicializacion: ", exception);
            // es probable que falte un parámetro.
            showHelp();
            System.exit(0);
        }
        try {
            // Ejecutar todo en el controller.
            controller.start();
        } catch (SimpleGtcException exception) {
            logger.error("Error de ejecucion: ", exception);
            System.exit(-1);
        }
        
    }
    
}
