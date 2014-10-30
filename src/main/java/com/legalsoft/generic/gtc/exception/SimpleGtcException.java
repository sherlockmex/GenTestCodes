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

package com.legalsoft.generic.gtc.exception;

/**
 * com.legalsoft.generic.gtc.exception.SimpleGtcException.
 * Esta clase representa la excepción padre de las excepciones
 * de este sistema.
 *
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public class SimpleGtcException extends Exception {
    
    private final String stringPrefix;

    /**
     * Creates a new instance of <code>SimpleGtcException</code> without detail message.
     * @param prefix El prefijo de los mensajes.
     */
    public SimpleGtcException(String prefix) {
        this.stringPrefix = prefix;
    }

    /**
     * Constructs an instance of <code>SimpleGtcException</code> with the specified detail message.
     * @param prefix El prefijo de los mensajes.
     * @param msg the detail message.
     */
    public SimpleGtcException(String prefix, String msg) {
        super(msg);
        this.stringPrefix = prefix;
    }

    /**
     * Constructs an instance of <code>SimpleGtcException</code> with the specified detail message.
     * @param stringPrefix El prefijo de los mensajes.
     * @param cause the detail cause.
     */
    public SimpleGtcException(String stringPrefix, Throwable cause) {
        super(cause);
        this.stringPrefix = stringPrefix;
    }

    /**
     * Constructs an instance of <code>SimpleGtcException</code> with the specified detail message.
     * @param stringPrefix El prefijo de los mensajes.
     * @param message the detail message.
     * @param cause the detail cause.
     */
    public SimpleGtcException(String stringPrefix, String message, Throwable cause) {
        super(message, cause);
        this.stringPrefix = stringPrefix;
    }
        
    /**
     * Método para recuperar el mensaje de esta excepción
     * @return La cadena que se recupera de la excepción
     */
    @Override
    public String getMessage() {
        return "[" + stringPrefix + "] - " + super.getMessage(); 
    }
    
}
