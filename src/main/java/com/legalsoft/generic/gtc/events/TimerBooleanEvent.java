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

package com.legalsoft.generic.gtc.events;

import com.legalsoft.generic.gtc.exception.SimpleGtcException;
import java.util.EventObject;

/**
 * com.legalsoft.generic.gtc.interfaces.TimerBooleanEvent.
 * Esta interfaz representa...
 *
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public class TimerBooleanEvent extends EventObject {

    /**
     * Constructor de eventos de este tipo.
     * @param result El valor que se quiere pasar en este evento.
     */
    public TimerBooleanEvent(boolean result) {
        super(result);
    }

    /**
     * Método para cambiar el origen del evento.
     * @param source El nuevo valor del origen del evento.
     * @throws SimpleGtcException 
     */
    public void setSource(Object source) throws SimpleGtcException {
        if (source instanceof Boolean)
            this.source = source;
        if (null == source) {
            throw new SimpleGtcException("TimerBooleanEvent", "El objeto recibido es nulo y se esperaba Boolean");
        }
        throw new SimpleGtcException("TimerBooleanEvent", 
                "El objeto recibido es de tipo {" + 
                        source.getClass().getName() +
                        "} y se esperaba Boolean");
    }

    /**
     * Método para cambiar el origen del evento.
     * @param source El nuevo valor del origen del evento.
     */
    public void setSource(boolean source) {
        this.source = source;
    }

    /**
     * Método para obtener el origen como boolean
     * @return 
     */
    @Override
    public Boolean getSource() {
        return (Boolean)this.source;
    }
       
}
