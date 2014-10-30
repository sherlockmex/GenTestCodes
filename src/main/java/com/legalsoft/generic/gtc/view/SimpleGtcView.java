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

package com.legalsoft.generic.gtc.view;

import com.legalsoft.generic.gtc.Main;
import com.legalsoft.generic.gtc.controller.TimerBooleanController;
import com.legalsoft.generic.gtc.exception.SimpleGtcException;
import com.legalsoft.generic.gtc.helper.ParameterReader;
import com.legalsoft.generic.gtc.interfaces.TimerEventListener;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * com.legalsoft.generic.gtc.view.SimpleGtcView.
 * Esta clase representa la vista. En este caso sólo es para la transición.
 * Sólo tendrá un timer para lanzar los eventos.
 *
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public class SimpleGtcView {
    
    /**
     * El controlador de timers
     */
    private TimerBooleanController timerBooleanController = null;
    
    /**
     * La variable que controla el hilo del timer controller.
     */
    private Thread threadTimerBooleanController = null;    

    /**
     * Logger para mostrar mensajes de la aplicación
     */
    private final Logger logger = LoggerFactory.getLogger(SimpleGtcView.class);    
    
    /**
     * Logger para escribir las líneas del generador.
     */
    private final Logger loggerSimpleGen = LoggerFactory.getLogger("SIMPLEGEN");
    
    /**
     * Método para validar si el controller ha sido inicializado
     * @throws SimpleGtcException Se lanza si el controller de timers no ha sido
     * inicializado propiamente.
     */
    private void assertTimerController() throws SimpleGtcException {
        // validar que el controller exista
        if(null == timerBooleanController) {
            logger.error("El controlador de los timers no ha sido inicializado. Llamar initView primero");
            throw new SimpleGtcException("View", "El controlador de los timers no ha sido inicializado. Llamar initView primero");
        }
    }
    
    /**
     * Método para inicializar la vista.
     * Se inicializa el controller de los timers.
     * @param parameterReader El lector de parámetros, de donde se toman los
     * valores necesarios.
     * @throws SimpleGtcException Se lanza si hay error en los parámetros.
     */
    public void initView(ParameterReader parameterReader) throws SimpleGtcException {
        // validar que existan los parametros adecuados para inicializar los timers.
        if (!parameterReader.testParams(new String[]{"delay", "error_percent"})) {
            logger.warn("Faltan parametros de esta lista {\"delay\", \"error_percent\"}");
            logger.warn("Se usaran los valores por omision");
        }
        // inicializar el controller.
        long delay = TimerBooleanController.DELAY_DEFAULT;
        if (null != timerBooleanController) {
            delay = timerBooleanController.getDelay();
        }
        if (parameterReader.testParam("delay")) {
            delay = parameterReader.getLong("delay");
        }
                
        int error_percent = TimerBooleanController.ERROR_PERCENT_DEFAULT;
        if (null != timerBooleanController) {
            error_percent = timerBooleanController.getErrorPercent();
        }
        if (parameterReader.testParam("error_percent")) {
            error_percent = parameterReader.getInt("error_percent");
        }
        initView(delay, error_percent);
    }
    
    /**
     * Método para inicializar la vista.
     * Se inicializa el controller de los timers.
     * @param delay El delay para mandar los mensajes
     * @param error_percent El porcentaje de error que vamos a mostrar.
     * @throws SimpleGtcException Se lanza si hay error al inicializar la vista,
     * usualmente si los valores están fuera de rango.
     */
    public void initView(long delay, int error_percent) throws SimpleGtcException {
        // inicializar el controller. sólo si no ha sido inicializado.
        if (null == timerBooleanController) {
            timerBooleanController = 
                    new TimerBooleanController(delay, error_percent);
        } else {
            // si ya existe, reemplazar los valores.
            timerBooleanController.setDelay(delay);
            timerBooleanController.setErrorPercent(error_percent);
        }
    }
    
    public void startView() throws SimpleGtcException {
        // validar que el controller exista
        assertTimerController();
        // comenzar la ejecución del controller.
        // primero ver si ya está la instancia corriendo.
        if (null == threadTimerBooleanController || 
                threadTimerBooleanController.isInterrupted() || 
                !threadTimerBooleanController.isAlive()) {
            threadTimerBooleanController = new Thread(timerBooleanController);
        }
        logger.info("Antes de ejecutar el timerBooleanController");
        // si el hilo no está corriendo, ejecutarlo.
        if (!threadTimerBooleanController.isAlive()) {
            threadTimerBooleanController.start();
        }
        // listo.
        logger.info("timerBooleanController esta en estado [{}]",
                threadTimerBooleanController.getState().toString());
    }
    
    /**
     * Método para agregar listeners para cuando sucedan eventos en la vista.
     * En particular los eventos de tiempo
     * @param listener El listener a agregar.
     * @throws SimpleGtcException Se lanza si el controlador de los timers
     * no ha sido inicializado.
     */
    public void addListeners(TimerEventListener listener) throws SimpleGtcException {
        // validar que el controller exista
        assertTimerController();
        // si existe. Agregar listener.
        timerBooleanController.addTimerEventListener(listener);
    }
    
    private static final String NL = System.getProperty("line.separator", "\\n");
    
    /**
     * Método para actualizar la vista.
     * @param cadenas La lista de cadenas a mostrar en la vista.
     * @param isError El resultado para decidir si se muestran
     * las cadenas como error o como cadenas básicas.
     */
    public void updateView(List<String> cadenas, boolean isError) {
        // Mostrar la lista de cadenas. Si es error, sólo se muestra 
        // el encabezado del log en la primer línea.
        logger.info("Actualizando vista @{}", Main.get_TS());
        if (!isError) {
            StringBuilder stringBuilder = new StringBuilder();
            boolean firstString = true;
            for (String string : cadenas) {
                if (!firstString) {
                    stringBuilder.append(NL);
                } else {
                    firstString = false;
                }
                stringBuilder.append(string);
            }
            // ya se tiene una cadenota. Mostrar un solo mensaje
            loggerSimpleGen.error(stringBuilder.toString());
        } else {
            // cada elemento es un mensaje
            for (String string: cadenas) {
                loggerSimpleGen.info(string);
            }
        }
    }

}
