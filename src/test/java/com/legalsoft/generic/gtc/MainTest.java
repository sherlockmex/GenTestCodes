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

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author T41609
 */
public class MainTest {
    
    public MainTest() {
    }
    
    @BeforeClass
    public static void setUpClass() {
    }
    
    @AfterClass
    public static void tearDownClass() {
    }
    
    @Before
    public void setUp() {
    }
    
    @After
    public void tearDown() {
    }

    /**
     * Test of get_TS method, of class Main.
     */
    @Test
    public void testGet_TS() {
        System.out.println("get_TS");
        String result = Main.get_TS();
        System.out.println(result);
    }

    /**
     * Test of main method, of class Main.
     */
    @Test
    public void testMain() {
        System.out.println("main");
        // /basic_path:path_value /error_path:path_value [/delay:long_value] [/error_percent:int_value] [/min_lines:int_value] [/max_lines:int_value]
        String[] args = {
            "/basic_path:src/test/resources/logs/cadenas_basic.txt", 
            "/error_path:src/test/resources/logs/cadenas_error.txt", 
            "/delay:1000", 
            "/error_percent:50", 
            "/min_lines:7", 
            "/max_lines:7"
        };
        Main.main(args);
    }
    
}
