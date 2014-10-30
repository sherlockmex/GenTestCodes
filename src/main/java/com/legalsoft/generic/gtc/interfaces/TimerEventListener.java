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

import com.legalsoft.generic.gtc.events.TimerBooleanEvent;
import java.util.EventListener;

/**
 * com.legalsoft.generic.gtc.interfaces.TimerEventListener.
 * Esta interfaz representa los listeners que pueden recibir 
 * eventos de tiempo.
 *
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public interface TimerEventListener extends EventListener {
    
    /**
     * El método que se ejecuta cuando se lanza un evento de este tipo.
     * @param event El evento a lanzar.
     */
    void timerAction(TimerBooleanEvent event);

}
