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

package com.legalsoft.generic.gtc.model.dao;

import com.legalsoft.generic.gtc.interfaces.GenericDAO;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * com.legalsoft.generic.gtc.model.dao.FileStringDAO.
 * Esta clase representa...
 *
 * @author Angel Emilio de Le&oacute;n Guti&eacute;rrez (adeleon@banxico.org.mx)
 * @version 1.0
 * @since 1.0
 */
public class FileStringDAO implements GenericDAO<String> {

    /**
     * Logger para mostrar cosas.
     */
    private final Logger logger = LoggerFactory.getLogger(FileStringDAO.class);
    
    /**
     * La ruta al origen de los datos.
     */
    private Path path_source = null;

    /**
     * Método para encontrar todo los elementos que pueda del DataSource.
     * @return Una lista con todos los elementos recuperados.
     */
    @Override
    public List<String> findAll() {
        List<String> lines = new ArrayList<>();
        if (null != path_source) {
            try {
                lines = Files.readAllLines(path_source, Charset.forName("UTF-8"));
            } catch (IOException exception) {
                logger.error("No se puede cargar la lista de cadenas desde {}:{}", path_source.toString(), exception.getMessage());
            }
        } else {
            logger.error("No se ha especificado la fuente. Nada que cargar");
        }
        return lines;
    }
    
    public void setSource(String stringPath) {
        // cargar la fuente
        path_source = FileSystems.getDefault().getPath(stringPath);
    }
    
    public void setSource(Path pathSource) {
        // fijar la fuente.
        this.path_source = pathSource;
    }
    
}
