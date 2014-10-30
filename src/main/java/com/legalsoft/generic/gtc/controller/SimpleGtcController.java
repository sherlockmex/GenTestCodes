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
import com.legalsoft.generic.gtc.events.TimerBooleanEvent;
import com.legalsoft.generic.gtc.exception.SimpleGtcException;
import com.legalsoft.generic.gtc.helper.ParameterReader;
import com.legalsoft.generic.gtc.interfaces.TimerEventListener;
import com.legalsoft.generic.gtc.model.SimpleGtcModel;
import com.legalsoft.generic.gtc.view.SimpleGtcView;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * com.legalsoft.generic.gtc.controller.SimpleGtcController.
 * Esta clase representa el controller de la aplicación.
 * Debe seguir el ciclo de vida de un controller:
 * 
 * <ol>
 *   <li>Inicializaci&oacute;n</li>
 *   <li>Preparaci&oacute;n del modelo</li>
 *   <li>Aplicaci&oacute;n de valores de entrada</li>
 *   <li>Validaci&oacute;n de valores de entrada</li>
 *   <li>Procesar actualizaci&oacute;n del modelo</li>
 *   <li>Validaci&oacute;n de actualizaci&oacute;n del modelo</li>
 *   <li>Procesar eventos de componentes</li>
 *   <li>Enviar metadatos</li>
 * </ol>
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public class SimpleGtcController implements TimerEventListener {
    
    /**
     * Un objeto para el logger.
     */
    private final Logger logger = LoggerFactory.getLogger(SimpleGtcController.class);
    
    /** 
     * El modelo de datos.
     */
    private final SimpleGtcModel model = new SimpleGtcModel();

    /**
     * La vista en la que se mostrarán los resultados.
     */
    private final SimpleGtcView view = new SimpleGtcView();

    /**
     * Método que inicializa el controller, con el parameterReader
     * como argumento para obtener los valores necesarios de la
     * línea de comandos.
     * @param parameterReader El lector de parámetros.
     * @throws com.legalsoft.generic.gtc.exception.SimpleGtcException
     * Se lanza cuando faltan los parámetros adecuados.
     */
    public void init(ParameterReader parameterReader) throws SimpleGtcException{
        // Inicializar la vista.
        view.initView(parameterReader);
        // Ahora inicializar el modelo.
        model.initModel(parameterReader);
        // inicializar los listeners
        view.addListeners(this);
    }
    
    public void start() throws SimpleGtcException {
        logger.info("Comenzando la ejecución de la vista @{}", Main.get_TS());
        // comenzar la ejecución en la vista.
        view.startView();
    }
    
    /**
     * Método a ejecutar cuando se lanza un evento en el timer
     * @param event 
     */
    @Override
    public void timerAction(TimerBooleanEvent event) {
        logger.info("Accion de evento recibida @{}", Main.get_TS());
        // Obtener el boolean del evento
        Boolean result = event.getSource();
        // actualizar la vista con la lista de cadenas del modelo.
        view.updateView(model.getNextStrings(result), result);
        logger.info("Vista actualizada @{}", Main.get_TS());
    }

}
