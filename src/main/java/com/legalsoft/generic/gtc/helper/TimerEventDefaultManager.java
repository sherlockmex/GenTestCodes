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

import com.legalsoft.generic.gtc.events.TimerBooleanEvent;
import com.legalsoft.generic.gtc.interfaces.TimerEventListener;
import com.legalsoft.generic.gtc.interfaces.TimerEventListenerManager;
import java.util.ArrayList;
import java.util.List;

/**
 * com.legalsoft.generic.gtc.helper.TimerEventDefaultManager.
 * Esta clase representa el manejador de los listeners
 *
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public class TimerEventDefaultManager implements TimerEventListenerManager {

    /**
     * La lista de listentes
     */
    private final List<TimerEventListener> listener_list = new ArrayList<>();
    
    /**
     * Método para agregar un listener
     * @param listener El listener a agregar
     */
    @Override
    public void addTimerEventListener(TimerEventListener listener) {
        if (!listener_list.contains(listener)) {
            listener_list.add(listener);
        }
    }

    /**
     * Método para eliminar un listener
     * @param listener El listener a eliminar
     */
    @Override
    public void removeTimerEventListener(TimerEventListener listener) {
        if (listener_list.contains(listener)) {
            listener_list.remove(listener);
        }
    }

    /**
     * Método para lanzar el evento.
     * @param result El resultado a lanzar.
     */
    @Override
    public void fireTimerEvent(boolean result) {
        for(TimerEventListener listener : listener_list) {
            listener.timerAction(new TimerBooleanEvent(result));
        }
    }

}
