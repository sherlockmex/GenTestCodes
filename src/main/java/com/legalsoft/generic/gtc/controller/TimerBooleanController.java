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

package com.legalsoft.generic.gtc.controller;

import com.legalsoft.generic.gtc.Main;
import com.legalsoft.generic.gtc.exception.SimpleGtcException;
import com.legalsoft.generic.gtc.helper.TimerEventDefaultManager;
import com.legalsoft.generic.gtc.interfaces.TimerEventListener;
import org.apache.commons.lang.math.RandomUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * com.legalsoft.generic.gtc.controller.TimerBooleanController.
 * Esta clase representa el controller que lanza eventos periodicos.
 *
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public final class TimerBooleanController extends TimerEventDefaultManager implements Runnable {
    
    /**
     * Un logger para el log
     */
    private final Logger logger = LoggerFactory.getLogger(TimerBooleanController.class);

    /**
     * El delay por omisión
     */
    public static final long DELAY_DEFAULT = 1000;
    
    /**
     * El delay que se requiere, como un arreglo para poderlo cambiar después.
     */
    private final long[] delay = new long[]{DELAY_DEFAULT};
    
    /**
     * El valor del error porcentual por omisión
     */    
    public static final int ERROR_PERCENT_DEFAULT = 30;
    
    /**
     * El porcentaje de veces que mandamos true
     */
    private final int[] error_percent = new int[]{ERROR_PERCENT_DEFAULT};
    
    /**
     * Constructor del controller. Requiere un delay para configurarlo
     * de inicio
     * @param delay El parámetro del delay.
     * @param error_percent El parámetro del error porcentual.
     * @throws com.legalsoft.generic.gtc.exception.SimpleGtcException 
     * Se lanza cuando alguno de los parámetros viene con el rango incorrecto.
     */
    public TimerBooleanController(long delay, int error_percent) throws SimpleGtcException {
        setDelay(delay);
        setErrorPercent(error_percent);
    }
    
    /**
     * Método para obtener el delay del Controller.
     * @return El delay del Controller.
     */
    public synchronized long getDelay() {
        return this.delay[0];
    }
    
    /**
     * Método sincronizado para actualizar el delay.
     * @param delay El parámetro del delay.
     * @throws com.legalsoft.generic.gtc.exception.SimpleGtcException
     * Se lanza cuando el parámetro del delay viene con el rango incorrecto.
     */
    public void setDelay (long delay) throws SimpleGtcException {
        if (delay < 200) {
            throw new SimpleGtcException("Model", "Error de parametro de entrada [delay]. Fuera de rango [200..Inf]");
        }
        synchronized(this.delay) {
            this.delay[0] = delay;
        }
    }

    /**
     * Método para obtener el porcentaje de error del Controller.
     * @return El porcentaje de error del Controller.
     */
    public synchronized int getErrorPercent() {
        return this.error_percent[0];
    }
    
    /**
     * Método sincronizado para actualizar el error porcentual.
     * @param error_percent El parámetro del error porcentual.
     * @throws com.legalsoft.generic.gtc.exception.SimpleGtcException 
     * Se lanza cuando el parámetro del error porcentual está fuera de rango.
     */
    public void setErrorPercent(int error_percent) throws SimpleGtcException {
        if (error_percent < 1 || error_percent > 99) {
            throw new SimpleGtcException("Model", "Error de parametro de entrada [error_percent]. Fuera de rango [1..99]");
        }
        synchronized(this.error_percent) {
            this.error_percent[0] = error_percent;
        }
    }
    
    /**
     * Método para calcular un resultado, con una probabilidad del % de error
     * dado
     * @return Verdadero si cae dentro del % de error. Falso en otro caso.
     */
    private boolean calculateResult() {
        synchronized(error_percent) {
            int dice = RandomUtils.nextInt(100);
            boolean result = (dice <= error_percent[0]);
            return result;
        }
    }
    
    /**
     * Método para ejecutar este controller.
     */
    @Override
    public void run() {
        // Cambiar el nombre del thread.
        Thread thread = Thread.currentThread();
        thread.setName("TIMER");
        logger.info("Ejecutando el hilo del Timer @{}", Main.get_TS());
        // ejecutar en un bloque controlado.
        try {
            while (!thread.isInterrupted()) {
                // obtener el delay... en un bloque sincronizado.
                long cicleDelay;
                synchronized(delay) {
                    cicleDelay = delay[0];
                }
                // ahora, una espera con este delay.
                Thread.sleep(cicleDelay);
                // Luego, llamar a los listeners.
                // el cálculo del resultado es sincronizado.
                boolean result = calculateResult();
                fireTimerEvent(result);
            }
        } catch (InterruptedException exception) {
            logger.error("Ejecución interrumpida: {}", exception);
            // terminando....
            thread.interrupt();
        }
        logger.info("Terminada la ejecucion del Timer @{}", Main.get_TS() );
    }

    /**
     * Método sobreescrito para volverlo sincronizado.
     * Este método agrega un listener a este manager
     * @param listener El listener a agregar.
     */
    @Override
    public synchronized void addTimerEventListener(TimerEventListener listener) {
        super.addTimerEventListener(listener); 
    }

    /**
     * Método sobreescrito para volverlo sincronizado.
     * Este método remueve un listener a este manager
     * @param listener El listener a remover.
     */
    @Override
    public synchronized void removeTimerEventListener(TimerEventListener listener) {
        super.removeTimerEventListener(listener); 
    }

    /**
     * Método sobreescrito para volverlo sincronizado.
     * Este método lanza un evento a todos los listeners registrados
     * @param result El valor a mandar en el evento.
     */
    @Override
    public synchronized void fireTimerEvent(boolean result) {
        super.fireTimerEvent(result); 
    }

}
