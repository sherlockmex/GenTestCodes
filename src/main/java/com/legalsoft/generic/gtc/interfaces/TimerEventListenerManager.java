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

package com.legalsoft.generic.gtc.interfaces;

/**
 * com.legalsoft.generic.gtc.interfaces.TimerEventListenerManager.
 * Esta interfaz representa a un manager de listeners de eventos de tiempo.
 *
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public interface TimerEventListenerManager {
    
    /**
     * Método para agregar un listener de este tipo.
     * @param listener El listener a agregar.
     */
    void addTimerEventListener(TimerEventListener listener);
    
    /**
     * Método para eliminar un listener de este tipo.
     * @param listener El listener a eliminar.
     */
    void removeTimerEventListener(TimerEventListener listener);

    /**
     * Método para lanzar el evento a través de todos los listeners
     * registrados en el manager.
     * @param result El valor a propagar por los listeners.
     */
    void fireTimerEvent(boolean result);
    
}
