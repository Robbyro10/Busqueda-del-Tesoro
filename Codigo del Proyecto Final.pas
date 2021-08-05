program Proyectico;
uses crt;

const                                                                            // Se declaran constantes
     max = 15;                                                                   //Maximas dimensiones del mapa del juego
     abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';                                         //Abecedario para la creacion de pistas

Type
    mapa = array[1..max, 1..max] of string;                                      //Se guarda el mapa como un array de dos dimensiones para poder almacenar varios elementos sin usar muchas variables
    mapa2 = array[1..max, 1..max] of boolean;                                    // Se guardan los submapas
    mapa3 = array[1..max, 1..max] of integer;
var
   opcion,f,c,i,j,pi,pj,nminas,nvidas,ncaminos,npistas,cx,cy,px,py,amarillas, azules, verdes,restantesA,restantesV,restantesF,orden,iteraciones,almacen:integer;
   modo, color,caminos,caminos2,caminos3:string;
   menuP, submenu, fijo, mortalidad,error,auto, filas,columnas,MinasM,vidas,mort,comportamiento,fin,juego,seguirA,seguirF,seguirV,creacionM,creacionF,consulta,creacionA:boolean;             //Variables
   casilla: mapa;
   indice: mapa3;
   A:text;
   yavisitada, minado, invalida: mapa2;                 //Submapas booleanos

PROCEDURE Valorar;                       // Por defecto, la carga del juego es aleatoria, y las variables necesarias son asignadas para que el usuario no tenga que configurar todo el juego antes de jugar
begin
     randomize;
     if (filas = False) then                                                                // En caso de que no se defina la cantidad de filas
     begin
          repeat                                                                         // Se genera cantidad aleatoria de filas
          f:= random(16);
          until (f > 4);
     end;

     if (columnas = False) then                                                             // En caso de que no se defina la cantidad de filas
     begin
          repeat                                                                     // Se genera cantidad aleatoria de columnas
          c:= random(16);
          until (c > 4);
     end;

     if (minasM = False) then                                                       // En caso de que no se defina una cantidad de minas
     begin
          repeat                                                                   // Se genera cantidad aleatoria de minas
          nminas:= random(16);
          until (nminas >= 5) and (nminas <= f);
     end;

     if (vidas = False) then                                                      // En caso de que no se defina una cantidad de vidas
     begin                                                                        // Se jugara con una sola vida
          nvidas:= 1;
     end;

     if (mort = False) then                                                       // En caso de que no se defina la mortalidad del jugador
     begin                                                                        // Se jugara como simple mortal
          mortalidad:= True;
     end;

     if (comportamiento = False) then                                             // En caso de que no se defina una cantidad de minas
     begin                                                                        // Las minas seran Fijas
          fijo:= True;
     end;

end;

PROCEDURE Validar (var a:integer; min,max:integer);    // Procedimiento que recibe la variable a evaluar, el valor minimo que puede recibir y el valor maximo, y envia error si no se cumple
begin
     repeat
     readln(a);
     if (a > max) or (a < min) then                      //Si el valor es mayor al maximo o menor al minimo, da error
     begin
          textcolor(red);
          writeln('ERROR... valor no valido.');
          textcolor(white);
     end;
     until(a <= max) and (a >= min);                     //Se repite hasta que el usario introduzca un valor valido
end;

PROCEDURE Despedir;
begin
     clrscr;
     textcolor(white);
     writeln('--------------------');
     write('|');
     textcolor(yellow);
     write('GRACIAS ');                       // Mensaje de despedida
     textcolor(cyan);
     write('POR ');
     textcolor(10);
     write('JUGAR!');
     textcolor(white);
     writeln('|');
     writeln('--------------------');
     readkey;
end;

PROCEDURE Asignar (var A:text);
var                                                          //Procedimiento para asignar archivos
   archi: string;
begin
     write('Introduzca la direccion de archivo que contiene el mapa: ');
     readln(archi);
     assign(A,archi);
end;

PROCEDURE archivar;
var
   B:text;
   num:char;
begin
     writeln;
     asignar(B);
     if (IOResult <> 0) then
     begin                             //Si el archivo es invalido, se muestra el mensaje de error
          textcolor(red);
          writeln('Error en el archivo');
          textcolor(white);
          asignar(B);
          readkey;
     end
     else                                           //De ser valido...
     begin
          rewrite(B);                         //Se crea y abre B para escritura

          write(B,'Caminos realizados:  ');
          writeln(B,caminos + caminos2 + caminos3);                                  //Se escribe el camino realizado por el jugador
          writeln(B);
          writeln(B,'La casilla "1-2" es el lugar donde se recogio el tesoro.');
          writeln(B);

          for i:= 1 to f do
          begin
               write(B,'| ');                                                      //Se lee cada casilla del mapa
               for j:= 1 to c do
               begin
                    if (casilla[i,j] = 'PA') then                              //Si la casilla es una pista, dependiendo del color se ingresara un numero diferente
                    begin                                                      //Amarillo = 5, Azul = 6, Verde = 7
                         num:= '5';                                            //Se establce el valor del numero como char
                         write(B,num + copy(abc,indice[i,j],1):3);             //Se escribe la letra
                         write(B,'| ');
                    end
                    else if (casilla[i,j] = 'PF') then
                    begin
                         num:= '6';                                                 //Mismo procedimiento para cada color de pista
                         write(B,num + copy(abc,indice[i,j],1):3);
                         write(B,'| ');
                    end
                    else if (casilla[i,j] = 'PV') then
                    begin
                         num:= '7';                                            //Mismo procedimiento para cada color de pista
                         write(B,num + copy(abc,indice[i,j],1):3);
                         write(B,'| ');
                    end
                    else if (casilla[i,j] = ':^)') then
                    begin                                                    //Si la casilla es el jugador, se cambia al char '1'
                         casilla[i,j]:= '1';
                         write(B,casilla[i,j]:3);
                         write(B,'| ');
                    end
                    else
                    begin
                         write(B,casilla[i,j]:3);                       //De lo contrario, se escribe la casilla como esta en el mapa
                         write(B,'| ');
                    end;
               end;
               writeln(B);
          end;
     close(B);                 //Se cierra B
     writeln('Archivo Creado!!');
     end;
end;

PROCEDURE felicitar (var movimientos:integer);                // Mensaje de victoria
var
   puntos,pistas,x,y,ans:integer;
begin
     pistas:= amarillas + azules + verdes;                                // Numero de pistas recogidas
     puntos:= (amarillas*100) + (azules*100) + (verdes*100);               // Por cada pista que se obtiene se suman 100 puntos
     x:= movimientos * 10;
     puntos:= puntos - x;                                                //Cada movimiento resta puntos

     clrscr;
     textcolor(10);
     writeln('------------');
     writeln('|HAS GANADO!|');
     writeln('------------');
     writeln;
     delay(1500);
     textcolor(cyan);
     writeln('Pistas Recolectadas:',pistas);
     delay(1500);
     textcolor(white);
     writeln('Movimientos Realizados:',movimientos);
     delay(1500);
     writeln('Vidas iniciales:',nvidas);
     delay(1500);

     if (nvidas = 1) then                                                   //Si se jugo con una sola vida, se da un bono de puntos
     begin
          textcolor(10);
          writeln('Bonus por simple mortal! + 750 ptos');
          puntos:= puntos + 750;
     end
     else if (nvidas > 1) then                                             //Si se jugo con mas de una vida, se restan puntos por cada vida que tenga
     begin
          y:= nvidas * 200;
          puntos:= puntos - y;
     end
     else if (mortalidad = False) then                                   //Si se juega en modo inmortal, el puntaje siempre sera 100
     begin
          textcolor(red);
          writeln('Modo Inmortal Activado');
          puntos:= 100;
     end;
     delay(1000);
     textcolor(10);
     writeln('PUNTACION TOTAL: ');
     textcolor(white);                                             //Se imprime la puntuacion total
     writeln(puntos);
     delay(1000);
     writeln('Desea generar el Archivo con el Camino Recorrido y el Mapa Resultante?');
     writeln;
     writeln('Si (1)');
     writeln('No (2)');                                    //Se pregunta a generar archivo con mapa y movimientos
     writeln;
     validar(ans,1,2);
     if (ans = 1) then
     begin                                      //Si se elige que si se va al procedimiento Archivar
          archivar;
     end;
end;

PROCEDURE mover (var casilla:mapa; i,j:integer);                   // Procedimiento para mover las minas
var
   z:integer;
begin
     z:= random(2);                               //Se genera un numero aleatorio del 0 al 1
     for i:= 1 to f do
     begin
          for j:= 1 to c do                                   //Se hace un ciclo para leer todo el mapa
          begin
               if (casilla[i,j] = '*') or (minado[i,j] = True) then                                            //Si encuentra una mina
               begin
                    if (casilla[i+1,j] = ' ') and (i < f) and (z = 1) then              //Prueba con la fila de abajo
                    begin
                         casilla[i+1,j]:= '*';
                         casilla[i,j]:= ' ';                                                //Se comprueba que la casilla proxima a ella este vacia y si el numero aleatorio es el adecuado
                         minado[i+1,j]:= True;
                         minado[i,j]:= False;
                    end
                    else if (casilla[i-1,j] = ' ') and (i > 1) and (z = 0) then              //Se esas dos condiciones se cumplen, se vacia la casilla original de la mina y se rellena la casilla vacia con una mina
                    begin
                         casilla[i-1,j]:= '*';                                               //Prueba con la fila de arriba
                         minado[i-1,j]:= True;                                               //Tambien cambia en el mapa de minas booleano para el modo jugador;
                         minado[i,j]:= False;
                         casilla[i,j]:= ' ';
                    end
                    else if (casilla[i,j+1] = ' ') and (j < c) and (z = 1) then               //Prueba con la columna a la derecha
                    begin
                         casilla[i,j+1]:= '*';
                         casilla[i,j]:= ' ';
                         minado[i,j+1]:= True;
                         minado[i,j]:= False;
                    end
                    else if (casilla[i,j-1] = ' ') and (j > 1) and (z = 0) then             //Prueba con la columna a la isquierda
                    begin
                         casilla[i,j-1]:= '*';
                         casilla[i,j]:= ' ';
                         minado[i,j-1]:= True;
                         minado[i,j]:= False;
                    end;
               end;
          end;
      end;
      writeln('Las minas se han movido!');                                  //Se advierte que las minas se han movido
end;

PROCEDURE buscar (casilla:mapa; f,c,i,j:integer; var restantes,caminos:integer; color:string);
begin
     iteraciones:= iteraciones + 1;
     if ((i >= 1) and (j >= 1) and (i <= f) and (j <= c) and (casilla[i,j] <> '*') and (not(yavisitada[i,j]))) then
     begin
          if (casilla[i,j] = 'PA') then
          begin
               if (color = 'Amarillo') and (indice[i,j] = orden) then                    //Se chequea si se cayo en una pista y si la pista es del color buscado y en orden alfabetico
               begin
                    restantes:= restantes - 1;
                    orden:= orden + 1;
                    yavisitada[i,j]:= True;
                    write('[',i,',',j,']');
               end
               else if (color <> 'Amarillo') then
               begin
                    write('[',i,',',j,']');
               end;
          end
          else if (casilla[i,j] = 'PV') then
          begin
               if (color = 'Verde') and (indice[i,j] = orden) then
               begin
                    restantes:= restantes - 1;
                    orden:= orden + 1;
                    yavisitada[i,j]:= True;
                    write('[',i,',',j,']');
               end
               else if (color <> 'Verde') then
               begin
                    write('[',i,',',j,']');
               end;
          end
          else if (casilla[i,j] = 'PF') then
          begin
               if (color = 'Azul') and (indice[i,j] = orden) then
               begin
                    restantes:= restantes - 1;
                    orden:= orden + 1;
                    yavisitada[i,j]:= True;
                    write('[',i,',',j,']');
               end
               else if (color <> 'Azul') then
               begin
                    write('[',i,',',j,']');
               end;
          end
          else if (casilla[i,j] = ' ') then
          begin
               write('[',i,',',j,']');
          end
          else if ((restantes = 0) and (casilla[i,j] = '<3')) then           //Ya no quedan pistas a recolectar en el mapa y se consigue el tesoro
          begin
               caminos:= caminos + 1;
               write('[',i,',',j,']');
               writeln;
               if (caminos < ncaminos) then
               begin
                    restantes:= almacen;
                    writeln;
                    write('Camino ', caminos + 1,':');
                    buscar(casilla,f,c,i,j+1,restantes,caminos,color);
               end;
               i:= pi;
               j:= pj;
          end
          else
          begin
               yavisitada[i,j]:= true;
               buscar(casilla,f,c,i,j+1,restantes,caminos,color);                  // Se busca en la casilla a la derecha
               buscar(casilla,f,c,i+1,j,restantes,caminos,color);                  // Se busca en la casilla de abajo
               buscar(casilla,f,c,i,j-1,restantes,caminos,color);                  // Se busca en la casilla a la isquierda
               buscar(casilla,f,c,i-1,j,restantes,caminos,color);                  // Se busca en la casilla de arriba
               yavisitada[i,j]:= false;
          end;
     end;
end;

PROCEDURE Alterar(var error:boolean);                                    //Menu para las acciones especiales
var
   ans:integer;
   menu:boolean;
begin
     menu:= True;                                                      //Se establece error como true, para que anule las coordenadas [0,0] y pida unas coordenadas validas
     error:= True;
     textcolor(10);
     writeln('Acciones Especiales');
     textcolor(darkgray);
     writeln('Nota: Se puede cambiar de modo para vizualisar el mapa.');
     textcolor(white);
     writeln;                                                                    //Se imprimen las opciones al jugador
     writeln('Cambiar de Modo (1)');
     writeln('Cambiar de Color a Seguir (2)');
     writeln('Cambiar Numero de Vidas (3)');
     writeln('Consultar Camino Realizado (4)');
     writeln('Salir del Juego (5)');
     writeln('Volver al Juego (6)');
     writeln;
     while (menu = True) do
     begin
          textcolor(cyan);
          write('Introduzca un numero valido para cada accion: ');       //Se pide una opcion al jugador
          textcolor(white);
          validar(ans,1,6);
          if (ans = 1) then
          begin                                                         //Si la opcion es 1, se cambia de modo de juego
               if (modo = 'Supervisor') then
               begin                                             //Si se estaba en modo supervisor, se cambia a jugador, y viceversa
                    modo:= 'Jugador';
               end
               else if (modo = 'Jugador') then
               begin
                    modo:= 'Supervisor';
               end;
               writeln('Modo Cambiado!');
               readkey;
          end
          else if (ans = 2) then                                          //Si la opcion es dos, se puede cambiar el color a seguir las pistas
          begin
               textcolor(yellow);
               writeln('Pistas Amarillas(1)');
               textcolor(cyan);
               writeln('Pistas Azules(2)');
               textcolor(10);
               writeln('Pistas Verdes(3)');                                  //Se imprimen las opciones de colores
               textcolor(white);
               writeln;
               write('Seleccione un color de pistas a seguir: ');
               validar(ans,1,3);                                      //Se pide la opcion para el color
               if (ans = 1) then
                  color:= 'Amarillo'
               else if (ans = 2) then
                  color:= 'Azul'                                  //Se elige el color
               else if (ans = 3) then
               begin
                    color:= 'Verde';
               end;
               writeln('Color Seleccionado!');
               readkey;
          end
          else if (ans = 3) then                                                          //Si la opcion es 3, se puede establecer una nueva cantidad de vidas
          begin
               writeln('Introduzca cuantas vidas desea tener(min 1 - max 16): ');
               validar(nvidas,1,16);                                                  //Se piden cantidad de vidas al jugador
               writeln('Tendras ',nvidas,' vidas!');
               readkey;
          end
          else if (ans = 4) then                  //Si la opcion es 4, se muestra el camino realizado hasta el momento
          begin
               writeln;
               writeln('Camino Realizado: ',caminos + caminos2 + caminos3);
               readkey;
          end
          else if (ans = 5) then
          begin                                                                    //Si la opcion es 4, se sale del juego
               writeln('Seguro que desea Salir del Juego?');
               writeln('Si (1)');
               writeln('Cancelar (2)');
               writeln;
               validar(ans,1,2);
               if (ans = 1) then
               begin
                    menu:= False;
                    error:= False;                                   //Al salir del juego, se establece error como falso, para que no vuelva a pedir otro movimiento
                    juego:= False;
               end;
          end
          else if (ans = 6) then                                   //Si la opcion es 5, se vuelve al juego
          begin
               menu:= False;
          end;
     end;
end;

PROCEDURE imprimir (var casilla:mapa; f,c:integer);                              // Se imprime el mapa con los elementos ya guardados
var
   movimientos,caminosA,CaminosV,caminosF:integer;
   primero,error,inicio: boolean;
   xs,ys,si,sj:string;
begin
     caminosA:= 0;                                          //La cantidad de caminos que se generaron para cada color
     CaminosV:= 0;
     CaminosF:= 0;
     writeln;
     movimientos:= 0;
     juego:= True;                                            //Mientras Juego sea verdadero, el juego continua
     primero:= True;                                           //Primero se refiere a la primera vez que se genera el mapa, una vez que se genera, sera falso
     inicio:= True;
     amarillas:= 0;                                            //Cantidad de pistas de cada color recolectadas por el usuario
     azules:= 0;
     verdes:= 0;
     error:= false;
     orden:= 1;

     while (juego = true) do
     begin                                                                    //X,Y y Z son subindices para las letras, asi poder imprimir las pistas en orden alfabetico
          clrscr;                                                                  //Se limpia la pantalla y se imprimen datos de relevancia para el jugador
          writeln('Modo de Juego: ',modo);
          if (mortalidad = true) then
          begin
               writeln('Vidas: ',nvidas);                                                  //Se imprime la cantidad de vidas restantes del jugador
          end
          else if (mortalidad = False) then
          begin
               writeln('Dios Inmortal.');
          end;
          if (color = 'Amarillo') then
             textcolor(yellow)
          else if (color = 'Verde') then
             textcolor(10)
          else if (color = 'Azul') then
          begin
               textcolor(cyan);
          end;
          if (auto = False) then
          begin
               writeln('Color de pistas elejido: ',color);
               writeln;
               textcolor(white);                                                                       // Cantidad de pistas obtenidas por el jugador de cada color
               writeln('Pistas amarillas recolectadas: ',amarillas);                             // Mientras mas pistas se recojan, mas puntos tendra el jugador al finalizar
               writeln('Pistas azules recolectadas: ',azules);
               writeln('Pistas verdes recolectadas: ',verdes);
               writeln;
               write('Pistas Restantes: ');
               if (color = 'Amarillo') then
                  writeln(restantesA)
               else if (color = 'Verde') then                                        //Se muestran las pistas restantes
                  writeln(restantesV)
               else
               begin
                    writeln(restantesF);
               end;
               writeln;
               textcolor(magenta);                                                   //Menu de acciones especiales
               writeln('Acciones Especiales [0,0]');
          end;
          writeln;
          textcolor(white);

          for i:= 1 to f do
          begin
               write('| ');
               for j:= 1 to c do
               begin
                    if (casilla[i,j] = '*') or (minado[i,j] = True) then                                     //La casilla es una mina
                    begin
                         if (modo = 'Supervisor') then                                   // Debe estar en modo supervsisor para que se vea la mina en el mapa
                         begin
                              textcolor(red);
                              write('*':3);
                              textcolor(white);
                              minado[i,j]:= True;
                              write('| ');
                         end
                         else if (modo = 'Jugador') then                               // Si se esta en modo jugador, la mina se escribe como un espacio en blanco
                         begin
                              casilla[i,j]:= ' ';
                              write(casilla[i,j]:3);
                              minado[i,j]:= True;
                              write('| ');
                         end;                                           //Se llena el mapa de minas boolean para el modo jugador
                    end
                    else if (i = cx) and (j = cy) then                                    // Se imprime el jugador sobre la posicion que se ingreso
                    begin
                         casilla[i,j]:= ':^)';
                         write(casilla[i,j]:3);
                         write('| ');
                         primero:= False;
                         px:= i;
                         py:= j;
                    end
                    else if (yavisitada[i,j] = True) then                             //Si la casilla esta marcada como ya visitada, se marca permanentemente
                    begin
                         casilla[i,j]:= '\\\';
                         write(casilla[i,j]:3);
                         write('| ');
                    end
                    else if (casilla[i,j] = 'PA') then                                     // Se imprime una pista amarilla
                    begin
                         casilla[i,j]:= copy(abc,indice[i,j],1);
                         if (((orden = indice[i,j]) and (color = 'Amarillo')) or (color <> 'Amarillo')) then        //Si la pista es del color buscado y en orden alfabetico, o no es del color buscado, la pista sera valida
                         begin
                              invalida[i,j]:= False;
                         end
                         else
                         begin                                                                            //De lo contrario, sera invalida
                              invalida[i,j]:= True;
                         end;
                         textcolor(yellow);                                                 //Se escribe la pista
                         write(casilla[i,j]:3);
                         textcolor(white);
                         write('| ');
                         casilla[i,j]:= 'PA';                                              //Se inicializa como 'PA' para reconocimiento mas facil
                    end
                    else if (casilla[i,j] = 'PV')  then                                    // Se imprime una pista Verde
                    begin
                         casilla[i,j]:= copy(abc,indice[i,j],1);
                         if (((orden = indice[i,j]) and (color = 'Verde')) or (color <> 'Verde')) then        //Si la pista es del color buscado y en orden alfabetico, o no es del color buscado, la pista sera valida
                         begin
                              invalida[i,j]:= False;
                         end
                         else
                         begin                                                                            //De lo contrario, sera invalida
                              invalida[i,j]:= True;
                         end;
                         textcolor(10);
                         write(casilla[i,j]:3);
                         textcolor(white);
                         write('| ');
                         casilla[i,j]:= 'PV';
                    end
                    else if (casilla[i,j] = 'PF') then
                    begin
                         casilla[i,j]:= copy(abc,indice[i,j],1);
                         if (((orden = indice[i,j]) and (color = 'Azul')) or (color <> 'Azul')) then        //Si la pista es del color buscado y en orden alfabetico, o no es del color buscado, la pista sera valida
                         begin
                              invalida[i,j]:= False;
                         end
                         else
                         begin                                                                            //De lo contrario, sera invalida
                              invalida[i,j]:= True;
                         end;
                         textcolor(cyan);
                         write(casilla[i,j]:3);
                         textcolor(white);
                         write('| ');
                         casilla[i,j]:= 'PF'
                    end
                    else if (casilla[i,j] = '<3') then                                    // Se imprime el tesoro
                    begin
                         textcolor(magenta);
                         write(casilla[i,j]:3);
                         textcolor(white);
                         write('| ');
                    end
                    else if (casilla[i,j] = ':^)') then                            // Jugador y punto de partida
                    begin
                         if (primero = False) then
                         begin                                                     //Despues de la primera inicializacion del juego
                              textcolor(white);
                              casilla[i,j]:= ' ';
                              write(casilla[i,j]:3);
                              write('| ');
                         end
                         else
                         begin
                              casilla[i,j]:= ':^)';                                  //Cuando se inicializa el mapa por primera vez
                              str(i,si);
                              str(j,sj);
                              caminos:= '[' + si + ',' + sj + '],';
                              write(casilla[i,j]:3);
                              write('| ');
                              primero:= False;
                         end;
                         px:= i;                                                  //px y py se refieren a la ubicacion del usuario en el presente
                         py:= j;
                    end
                    else
                    begin
                         casilla[i,j]:=' ';
                         write(casilla[i,j]:3,'| ');                                      // Se imprime un espacio vacio
                    end;
               end;
               writeln;
          end;

          if (px - cx = 1) and (inicio = False) then                           // Caso borde, los movimientos para atras presentaban problemas al momento de guardar los datos
          begin
               px:= cx;
          end
          else if (py - cy = 1) and (inicio = False) then
          begin
               py:= cy;
          end;
          inicio:= False;

          if ((casilla[px+1,py] = '*') or (px = f)) and ((casilla[px-1,py] = '*') or (px = 1)) then           //Caso borde
          begin
               if ((casilla[px,py+1] = '*') or (py = c)) and ((casilla[px,py-1] = '*') or (py = 1)) and (mortalidad = True) then    //Si el jugador esta siendo bloqueado por las minas y no es inmortal
               begin
                    writeln;
                    writeln('Error en el Mapa, ningun movimiento es valido, cerrando el mapa.');
                    juego:= False;
                    readkey;
               end;
          end;

          if ((invalida[px+1,py] = True) or (px = f)) and ((invalida[px-1,py] = True) or (px = 1)) then           //Caso borde
          begin
               if ((invalida[px,py+1] = True) or (py = c)) and ((invalida[px,py-1] = True) or (py = 1)) then    //Si el jugador esta siendo bloqueado por la pistas que no puede recoger
               begin
                    writeln;
                    writeln('Error en el Mapa, ningun movimiento es valido, cerrando el mapa.');
                    juego:= False;
                    readkey;
               end;
          end;

          if (auto = True) and (juego = True) then                                         //Ejecucion Automatica
          begin
               writeln;
               writeln('Posicion Inicial: [',px,',',py,']');
               orden:= 1;                                    //Se inicializa el orden de casillas que debe seguir
               if (seguirA = True) and (error = False) then
               begin
                    writeln('Caminos para pistas amarillas obtenidos: ');
                    writeln;
                    almacen:= restantesA;
                    write('Camino 1: ');
                    buscar(casilla,f,c,px,py,restantesA,caminosA,'Amarillo');
                    writeln;
               end;

               if (iteraciones < 5) then
               begin
                    writeln('ERROR EN EL MAPA');
               end;

               if (seguirF = True) and (error = False) then                                             //Si el usuario eligio otro color, se vuelve a inicializar el orden
               begin
                    orden:= 1;
                    writeln('Caminos para pistas Azules obtenidos: ');
                    writeln;
                    almacen:= restantesF;
                    write('Camino 1: ');
                    buscar(casilla,f,c,px,py,restantesF,caminosF,'Azul');
                    writeln;
               end;

               if (seguirV = True) and (error = False) then
               begin
                    orden:= 1;
                    writeln('Caminos para pistas verdes obtenidos: ');
                    writeln;
                    almacen:= restantesV;
                    write('Camino 1: ');
                    buscar(casilla,f,c,px,py,restantesV,caminosV,'Verde');
                    writeln;
               end;
               writeln;
               writeln('Busqueda completada!');                          //La ejecucion automatica termina
               readkey;
               juego:= False;
          end
          else if (auto = False) and (juego = True) then                           //Ejecucion Manual
          begin
               textcolor(white);
               writeln;
               writeln('Ubicacion Actual: [',px,',',py,'].');       //Ubicacion Actual
               writeln;

               repeat
               begin
                     error:= False;
                     repeat
                     write('Introduzca numero de fila a moverse: ');                       //Cambio de fila
                     validar(cx,0,f);
                     if ((cx > px + 1) or (cx < px - 1) and (cx <> 0)) then
                     begin
                          textcolor(red);
                          writeln('Error... Movimiento no valido. Solo puede moverse una casilla a la vez.');    //Mensaje de error
                          textcolor(white);
                     end;
                     until (cx = 0) or (cx = px + 1) or (px = cx) or (cx = px - 1);

                     repeat
                     write('Introduzca numero de columna a moverse: ');                  // Cambio de columna
                     validar(cy,0,c);
                     if ((cy > py + 1) or (cy < py - 1) and (cy <> 0))then
                     begin
                          textcolor(red);
                          writeln('Error... Movimiento no valido. Solo puede moverse una casilla a la vez.');      //Mensaje de error
                          textcolor(white);
                     end;
                     until (cy = 0) or (cy = py + 1) or (py = cy) or (cy = py - 1);

                     if (px = cx) and (py = cy) then
                     begin
                          textcolor(red);
                          writeln('Error... Movimiento no valido. Debe moverse en alguna direccion.');      //Caso borde , se introduce la casilla presente
                          textcolor(white);
                          error:= True;
                     end
                     else if ((cy = 0) and (cx <> 0)) or ((cx = 0) and (cy <> 0)) then
                     begin
                          textcolor(red);
                          writeln('Error... No se puede salir del mapa.');
                          textcolor(white);
                          error:= True;
                     end
                     else if (invalida[cx,cy] = True) then
                     begin                                                                             //Si la pista no es la letra 'A', no la puede recojer
                          textcolor(red);
                          writeln('Error... Solo puede recolectar las pistas en orden alfabetico.');
                          textcolor(white);
                          error:= True;
                     end
                     else if (yavisitada[cx,cy] = True) then                                    //Si la pista ya fue recolectada, la casilla queda marcada, no puede ocupar la casilla
                     begin
                          textcolor(red);
                          writeln('Error... No puede ir a pistas ya recogidas');
                          textcolor(white);
                          error:= True;
                     end
                     else if (px <> cx) and (py <> cy) and (cy + cx <> 0) then                                                        // Caso borde, movimiento Diagonal
                     begin
                          textcolor(red);
                          writeln('Error... Movimiento no valido. El movimiento en diagonal no esta permitido.');
                          textcolor(white);
                          error:= True;
                     end
                     else if (cx = 0) and (cy = 0) then                   //Si el usuario ingresa la coordenada [0,0], se va al menu de acciones especiales
                     begin
                          alterar(error);         //Se llama a alterar con parametro error, dependiendo de error, se pedira otro movimiento o se saldra del juego
                     end
                     else if (casilla[cx,cy] = '<3') then                                 // El jugador cae en la casilla del tesoro
                     begin
                          if (color = 'Amarillo') then                                   // Se verifica que se recojieron todas las pistas del color elejido
                          begin
                               if (restantesA = 0) then
                               begin
                                    creacionA:= False;                                        //Se elimina el mapa para que se cree otro si el usuario asi lo desea
                                    creacionF:= false;
                                    creacionM:= false;
                                    str(cx,xs);
                                    str(cy,ys);
                                    if (length(caminos) <= 240) then
                                    begin
                                         caminos:= caminos + '[' + xs + ',' + ys + ']' + ',';                          // Se guardan los movimientos realizados por el jugador
                                    end
                                    else if (length(caminos) >= 240) then                                    //Si el string donde se guardan los caminos excede de 240, se guardara el camino restante en caminos2
                                    begin
                                         caminos2:= caminos2 + '[' + xs + ',' + ys + ']' + ',';
                                    end
                                    else if (length(caminos2) >= 240) then                                                                    //Lo mismo para el camino2, se guardara en 3
                                    begin
                                         caminos3:= caminos3 + '[' + xs + ',' + ys + ']' + ',';
                                    end;
                                    casilla[cx,cy]:= '1-2';                                   //'1-2' significa que aqui se recogio el tesoro
                                    movimientos:= movimientos + 1;                            //El procedimiento es el mismo para cualquier color de pistas
                                    felicitar(movimientos);
                                    juego:= False;
                               end
                               else if (restantesA > 0) then
                               begin
                                    casilla[i,j]:= ' ';                                                                  //Si todavia quedan pistas, el movimiento sera invalido
                                    writeln('No puedes abrir el tesoro!');
                                    Writeln('Todavia faltan pistas amarillas por recojer!');
                                    error:= True;
                                    readkey;                                                             // Se hace lo mismo para todos los colores
                               end;
                          end
                          else if (color = 'Azul') then                                                  // En caso de que sea azul...
                          begin
                               if (restantesF = 0) then
                               begin
                                    creacionA:= False;                                            //Se anula el mapa creado
                                    creacionF:= false;
                                    creacionM:= false;
                                    str(cx,xs);
                                    str(cy,ys);                                                                //'1-2' significa que aqui se recogio el tesoro
                                    casilla[cx,cy]:= '1-2';
                                    if (length(caminos) <= 240) then
                                    begin
                                         caminos:= caminos + '[' + xs + ',' + ys + ']' + ',';                          // Se guardan los movimientos realizados por el jugador
                                    end
                                    else if (length(caminos) >= 240) then                                    //Si el string donde se guardan los caminos excede de 240, se guardara el camino restante en caminos2
                                    begin
                                         caminos2:= caminos2 + '[' + xs + ',' + ys + ']' + ',';
                                    end
                                    else if (length(caminos2) >= 240) then                                                                    //Lo mismo para el camino2, se guardara en 3
                                    begin
                                         caminos3:= caminos3 + '[' + xs + ',' + ys + ']' + ',';
                                    end;
                                    movimientos:= movimientos + 1;                            //Se cuenta el movimiento
                                    felicitar(movimientos);                                   //Se llama al procedimiento felicitar
                                    juego:= False;                                            //Se termina el juego
                               end
                               else if (restantesA > 0) then
                               begin
                                    casilla[i,j]:= ' ';
                                    writeln('No puedes abrir el tesoro!');
                                    Writeln('Todavia faltan pistas azules por recojer!');
                                    error:= True;
                                    readkey;
                               end;
                          end
                          else if (color = 'Verde') then                                                  // En caso de que sea azul
                          begin
                               if (restantesV = 0) then
                               begin
                                    creacionA:= False;
                                    creacionF:= false;                                  //Se anula cualquier mapa creado
                                    creacionM:= false;
                                    str(cx,xs);
                                    str(cy,ys);
                                    casilla[cx,cy]:= '1-2';                                    //'1-2' significa que aqui se recogio el tesoro
                                    if (length(caminos) <= 240) then
                                    begin
                                         caminos:= caminos + '[' + xs + ',' + ys + ']' + ',';                          // Se guardan los movimientos realizados por el jugador
                                    end
                                    else if (length(caminos) >= 240) then                                    //Si el string donde se guardan los caminos excede de 240, se guardara el camino restante en caminos2
                                    begin
                                         caminos2:= caminos2 + '[' + xs + ',' + ys + ']' + ',';
                                    end
                                    else if (length(caminos2) >= 240) then                                                                    //Lo mismo para el camino2, se guardara en 3
                                    begin
                                         caminos3:= caminos3 + '[' + xs + ',' + ys + ']' + ',';
                                    end;
                                    movimientos:= movimientos + 1;                            //Se cuenta el movimiento
                                    felicitar(movimientos);
                                    juego:= False;
                               end
                               else if (restantesV > 0) then
                               begin
                                    casilla[i,j]:= ' ';
                                    writeln('No puedes abrir el tesoro!');
                                    writeln('Todavia faltan pistas verdes por recojer!');
                                    error:= True;
                                    readkey;
                               end;
                          end;
                     end;
               end;
               until (error = False);                                                     // Se vuelve a pedir una coordenada al usuario siempre y cuando error sea False

               movimientos:= movimientos + 1;                                  //Se aumenta la cantidad de movimientos
               str(cx,xs);
               str(cy,ys);
               if (length(caminos) <= 240) then
                  caminos:= caminos + '[' + xs + ',' + ys + ']' + ','                          // Se guardan los movimientos realizados por el jugador
               else if (length(caminos) >= 240) then                                    //Si el string donde se guardan los caminos excede de 240, se guardara el camino restante en caminos2
                    caminos2:= caminos2 + '[' + xs + ',' + ys + ']' + ','
               else if (length(caminos2) >= 240) then                                                                     //Lo mismo para el camino2, se guardara en 3
               begin
                    caminos3:= caminos3 + '[' + xs + ',' + ys + ']' + ',';
               end;

               if (casilla[cx,cy] = '*') or (minado[cx,cy] = True) then                                     // El jugador cae en una mina
               begin
                    textcolor(red);
                    writeln('Has Caido en una mina!');                                                   // Siempre se le avisara al jugador que cayo en una mina
                    nvidas:= nvidas - 1;                                                                 // Si el jugador es mortal, se le resta una vida
                    if (nvidas = 0) and (mortalidad = True) then
                    begin
                         textcolor(red);
                         writeln('HAS MUERTO!');
                         textcolor(white);
                         casilla[i,j]:= ' ';                                                   // Si el jugador ya no tiene vidas, el juego termina
                         readkey;
                         clrscr;
                         textcolor(white);
                         creacionA:= False;
                         creacionF:= false;                                                     //Se elimina el mapa para que se cree otro si el usuario asi lo desea
                         creacionM:= false;
                         juego:= False;
                    end
                    else if (nvidas > 0) or (mortalidad = false) then                           //Si el jugador todavia tiene vidas, se limpiara la casilla y el jugador tomara el lugar de la mina
                    begin
                         casilla[cx,cy]:= ':^)';
                         minado[cx,cy]:= False;
                    end;
                    readkey;
                    textcolor(white);
               end
               else if (casilla[cx,cy] = 'PA') then      //El jugador cae en una pista del color escojido
               begin
                    if (color = 'Amarillo') then
                    begin
                         writeln('Pista Amarilla Recolectada');
                         restantesA:= restantesA - 1;                                    //Se resta una pista a recolectar
                         if (restantesA = 0) then
                         begin
                              textcolor(yellow);
                              writeln('Ya puedes Recoger El Tesoro!');
                              textcolor(white);
                         end;
                         yavisitada[cx,cy]:= True;                                       //Se marca la casilla como ya visitada
                         orden:= orden + 1;                                             //Se aumenta en orden para que la proxima pista
                         if (fijo = False) and (inicio = False) then                // Si esta en modo fijo, se llama a mover la mina
                         begin
                              mover(casilla,i,j);
                         end;
                         readkey;
                    end
                    else
                    begin
                         yavisitada[cx,cy]:= False;                                       //la casilla puede volver a visitarse
                    end;
                    amarillas:= amarillas + 1;                                      //Se aumenta una pisa recolectada al marcador
               end
               else if (casilla[cx,cy] = 'PV') then                               // El jugador cae en pista Verde
               begin
                    if (color = 'Verde') then
                    begin
                         writeln('Pista Verde Recolectada!');
                         restantesV:= restantesV - 1;                           //Se resta la cantidad de pistas necesarias para abrir el tesoro
                         if (restantesV = 0) then
                         begin
                              textcolor(10);
                              writeln('Ya puedes Recoger El Tesoro!');
                              textcolor(white);
                         end;
                         yavisitada[cx,cy]:= True;                             //Se marca la pista como una casilla ya visitada
                         orden:= orden + 1;
                         if (fijo = False) and (inicio = False) then                // Se esta en modo fijo, se llama a mover la mina
                         begin
                              casilla[i,j]:= ' ';
                              mover(casilla,i,j);
                         end;
                         readkey;
                    end
                    else
                    begin
                         yavisitada[cx,cy]:= False;
                    end;
                    verdes:= verdes + 1;                                               //La casilla podra ser visitada nuevamente

               end
               else if (casilla[cx,cy] = 'PF') then                                //El jugador cae en pista azul
               begin
                    if (color = 'Azul') then
                    begin
                         writeln('Pista Azul Recolectada!');
                         restantesF:= restantesF - 1;
                         if (restantesF = 0) then
                         begin
                              textcolor(cyan);
                              writeln('Ya puedes Recoger El Tesoro!');
                              textcolor(white);
                         end;
                         yavisitada[cx,cy]:= True;                                //Se marca la pista como una casilla ya visitada
                         orden:= orden + 1;
                         if (fijo = False) and (inicio = False) then                // Se esta en modo fijo, se llama a mover la mina
                         begin
                              casilla[i,j]:= ' ';
                              mover(casilla,i,j);
                         end;
                         readkey;
                    end
                    else
                    begin
                         yavisitada[cx,cy]:= False;                                  //La casilla podra ser visitada nuevamente
                    end;
                    azules:= azules + 1;                                            //Se aumenta el marcador
               end
          end;
     end;
     fin:= True;
     creacionA:= false;
     creacionF:= False;                //Se elimina el mapa creado
     creacionM:= False;
     submenu:= False;
     menup:= True;
end;

PROCEDURE visualizar(var casilla:mapa; f,c:integer);                             //Proceso donde se visualiza el mapa el mapa ya creado, simplemente se muestra en pantalla
begin
     writeln;
     writeln('Este es el mapa a jugar!');
     writeln;
     for i:= 1 to f do
     begin                                                  //Se lee cada casilla de la matriz
          write('| ');
          for j:= 1 to c do
          begin
               if (casilla[i,j] = 'PA') then
               begin
                    textcolor(yellow);                               //Se cambia el color
                    casilla[i,j]:= copy(abc,indice[i,j],1);           //Se asigna la letra del abecedario dependiendo del indice de la pista
                    write(casilla[i,j]:3);                             //Se escribe la letra
                    textcolor(white);                                   //Se cambia el color
                    casilla[i,j]:= 'PA';                                 //Se vuelve a asignar como 'PA'
                    write('| ');                                          //Se cierra la casilla
               end
               else if (casilla[i,j] = 'PF') then
               begin
                    textcolor(cyan);
                    casilla[i,j]:= copy(abc,indice[i,j],1);
                    write(casilla[i,j]:3);                                     //Mismo procedimiento para el color azul
                    casilla[i,j]:= 'PF';
                    textcolor(white);
                    write('| ');
               end
               else if (casilla[i,j] = 'PV') then
               begin
                    textcolor(10);                                          //Mismo procedimient para el color Verde
                    casilla[i,j]:= copy(abc,indice[i,j],1);
                    write(casilla[i,j]:3);
                    casilla[i,j]:= 'PV';
                    textcolor(white);
                    write('| ');
               end
               else if (casilla[i,j] = '*') then                           //Si la casilla es una mina
               begin
                    textcolor(red);                                       //Se cambia el color y se escribe la mina
                    write(casilla[i,j]:3);
                    textcolor(white);
                    write('| ');                                         //Se cierra la casilla
               end
               else if (casilla[i,j] = '<3') then
               begin
                    textcolor(magenta);
                    write(casilla[i,j]:3);                              //Mismo proceso para el tesoro y punto de partida
                    textcolor(white);
                    write('| ');
               end
               else if (casilla[i,j] = ':^)') then
               begin
                    write(casilla[i,j]:3);
                    write('| ');
               end
               else
               begin                             //Espacio vacio
                    write(casilla[i,j]:3);
                    write('| ');
               end;
          end;
          writeln;
     end;
     readkey;
end;


PROCEDURE llenar (var casilla:mapa; f,c:integer);                                       //Procedimiento que llena la matriz con los elementos
var
   x,y,p,z,u,o,minas,pistas:integer;
   tesoro, inicio, valido,PV:boolean;
   SA,SV,SF:string;
begin
     npistas:= (f * c) - f;                          // Numero maximo de pistas en el mapa
     error:= true;
     while (error = True) do
     begin
          minas:= 0;                                                                       // Se incializan ciertas variables
          pistas:= 0;
          x:= 1;
          y:= 1;
          p:= 1;
          tesoro:= False;
          inicio:= False;
          error:= true;
          restantesA:= 0;
          restantesF:= 0;
          restantesV:= 0;
          PV:= False;
          valido:= false;
          for i:= 1 to f do
          begin
               for j:= 1 to c do
               begin
                    z:= random(6);                                                      // Se generan 2 numeros aleatorios, dependiendo de sus valores, se generara un elemento diferente en el mapa
                    u:= random(3);
                    o:= random(2);

                    if ((z = 0) and (u = 1)) and (minas < nminas) then                 // La casilla seria una mina
                    begin
                         minas:= minas + 1;
                         casilla[i,j]:= '*';
                         minado[i,j]:= True;
                         if (minasM = True) and (minas = nminas) then                     //Si las minas se declararon de manera manual y ya todas las minas fueron llenadas, sera valido el mapa
                         begin
                              valido:= True;
                         end
                         else if (minasM = True) and (minas < nminas) then               //Si las minas se declararon de manera manual pero faltan minas por llenar, sera invalido el mapa
                         begin
                              valido:= False;
                         end
                         else if (minasM = False) then                                   //Si las minas no fueron declaradas, solo importa con que haya almenos una en el mapa
                         begin
                              valido:= True;
                         end;
                    end
                    else if ((z = 4) and (o = 0) and (inicio = False)) then             // La casilla el punto de inicio
                    begin
                         casilla[i,j]:= ':^)';
                         inicio:= True;
                    end
                    else if ((z = 5) and (o = 1) and (tesoro = False)) then           // La casilla seria el tesoro
                    begin
                         casilla[i,j]:= '<3';
                         tesoro:= True;
                    end
                    else if ((z = 1) and (o = 1)) and (pistas < npistas) then                       // La casilla seria una pista Amarilla
                    begin
                         casilla[i,j]:= 'PA';                                         //Se asigna la casilla como 'PA'
                         SA:= copy(abc,x,1);                                          //SA es la letra a la cual se le asignara a la pista que tiene posicion en x
                         indice[i,j]:= pos(SA,abc);                                   //El indice sera la posicion de SA en el abecedario
                         x:= x + 1;                                                   //Se aumenta x para la proxima pista
                         restantesA:= restantesA + 1;                                       //Se cuenta las restantes
                         pistas:= pistas + 1;                                         //Se aumenta la cantidad de pistas totales
                    end
                    else if ((z = 2) and (o = 1)) and (pistas < npistas) then                       // La casilla seria una pista Verde
                    begin
                         casilla[i,j]:= 'PV';
                         SV:= copy(abc,y,1);
                         indice[i,j]:= pos(SV,abc);                                    //Mismo procesos para diferentes colores de pistas
                         restantesV:= restantesV + 1;                                       //Se cuenta las restantes
                         y:= y + 1;
                         pistas:= pistas + 1;
                    end
                    else if ((z = 3)and (o = 1)) and (pistas < npistas) then                       // La casilla seria una pista Azul
                    begin
                         casilla[i,j]:= 'PF';
                         SF:= copy(abc,p,1);
                         indice[i,j]:= pos(SF,abc);                                      //Mismo procesos para diferentes colores de pistas
                         p:= p + 1;
                         pistas:= pistas + 1;
                         restantesF:= restantesF + 1;                                       //Se cuenta las restantes
                    end
                    else
                    begin
                         casilla[i,j]:= ' ';                                          // La casilla seria un espacio
                    end;
                end;
           end;

           if ((restantesA > 0) and (restantesF > 0) and (restantesV > 0)) then    //Si todos los colores de pistas fueron ingresados, Sera valido VP (pistas Validas)
           begin
                PV:= True;
           end
           else
           begin
                PV:= False;
           end;

           if ((valido = false) or (tesoro = false) or (inicio = false) or (PV = false)) then              //Si el mapa se genera sin minas, o sin punto de inicio o sin tesoro, se dara error
           begin
                error:= True;
           end
           else
           begin
                error:= False;
           end;
     end;                          //Fin del ciclo while

     creacionA:= true;


     if (consulta = False) and (error = False) then              //Si no esta en modo consulta o el mapa se genero sin error, se imprime el mapa para jugar
     begin
          imprimir(casilla,f,c);
     end
     else if (consulta = True) then
     begin                                    //De lo contrario, solo se visualiza
          visualizar(casilla,f,c);
     end;
end;

PROCEDURE llenarminas (var minado: mapa2; f,c:integer);         // Proceso para crear dos matrizes de boolean
begin
     for i:= 1 to f do
     begin
          for j:= 1 to c do
          begin
               minado[i,j]:= False;                           // Se llenan todas las casillas en False (Sin minas)
          end;
     end;
end;

PROCEDURE mapear (var yavisitada: mapa2; f,c:integer);    // Proceso para crear una matriz de boolean donde donde cada casilla que sea True, representara una casilla ya visitada
begin
     for i:= 1 to f do
     begin
          for j:= 1 to c do
          begin
               yavisitada[i,j]:= False;                         // Se llenan todas las casillas en False (Ninguna casilla ha sido visitada)
          end;
     end;
end;

PROCEDURE jugar;
begin
     fin:= False;
     if (creacionM = False) and (creacionF = False) and (creacionA = False) then                       //Si el mapa no ha sido creado, se crea uno
     begin
          mapear(yavisitada,f,c);                  // Se genera otro mapa de boolean que representan las posiciones ya visitadas
          llenarminas(minado,f,c);                 // Se genera un mapa de boolean que representan las minas
          llenar(casilla,f,c);
     end;

     while (fin = False) and (consulta = False) do                       //Si no se esta en una consulta, y el juego no ha terminado, se imprime el mapa y se juega
     begin
          imprimir(casilla,f,c);
     end;
end;

PROCEDURE empezar;                                        // Proceso que muestra todas las configuraciones para el juego que se iniciara
begin
     if (creacionM = False) and (creacionF = False) and (creacionA = False) then   //Si ningun mapa ha sido creado
     begin
          valorar;
     end;
     clrscr;
     textcolor(cyan);
     writeln('Modo de Juego: ', modo);
     textcolor(white);                                             //Dimensiones del mapa
     writeln('Cantidad de filas: ',f);
     writeln('Cantidad de columnas: ',c);
     if (creacionM = True) or (creacionF = True) then
     begin
          textcolor(red);
          writeln('Cantidad de minas: ',nminas);                        //Cantidad de minas
     end;

     if (color = 'Azul') then
        textcolor(cyan)
     else if (color = 'Amarillo') then                                 //Color a seguir por el usuario
         textcolor(yellow)
     else if (color = 'Verde') then
     begin
         textcolor(10);
     end;

     writeln('Color de pistas elejido: ',color);                    // El color elegido por el usuario

     if (Fijo = True) then
     begin
          textcolor(red);
          writeln('Minas fijas');
     end
     else                                                               //Comportamiento de minas
     begin
          textcolor(red);
          writeln('Minas Cambiantes');
     end;

     textcolor(white);
     if (mortalidad = True) then
     begin
          writeln('Mortal con ',nvidas,' vida(s)');                         //Mortalidad o Cantidad de vidas
     end
     else
     begin
          writeln('Inmortal');
     end;

     if (auto = True) then
     begin
          writeln('Modo de Ejecucion: Automatica.');
     end                                                                    // Modo de ejecucion
     else
     begin
         writeln('Modo de Ejecucion: Manual.');
     end;

     writeln('Presione cualquier tecla para jugar!');
     readkey;
     jugar;
end;

PROCEDURE explicar;                                                                //Historia sobre el Tesoro
begin
     clrscr;
     textcolor(10);
     writeln('Introduccion');
     textcolor(white);
     writeln;
     writeln('Durante el siglo XVII, los piratas gobernaban las aguas de Europa y America. Dominando por');
     writeln('completo las monarquias de la epoca. Robando y asesinando brutalmente, se consolidaron como');
     writeln('la autoridad maxima de los mares.');
     writeln;
     writeln('Pero esto no siempre fue asi, a lo largo del tiempo, los piratas eran mas conocidos por robar');
     writeln('a pescadores solitarios o navegantes de recreacion. Por su falta de organizacion y egoismo hacia');
     writeln('los otros piratas, nunca fueron un problema grave para la justicia. Fue asi, hasta que a principios');
     writeln('del siglo XVI, llego Dionisio de Machiavelli.');
     writeln;
     readkey;
     writeln('Nacido en la isla de Tortuga, de una familia de italianos imigrantes, Dionisio estuvo desde muy');
     writeln('joven con piratas. Su padre, Mario Machiavelli, le enseno a Dionisio sobre la importancia de la');
     writeln('disciplina y el trabajo en equipo, contandole historias sobre el imperio romano y Julio Cesar.');
     writeln;
     writeln('Una noche, Dionisio y su padre caminaban de regreso a casa, cuando vieron a un policia abusando de una chica.');
     writeln('Cuando el padre lo vio, le grito y lo acuso con ir a la policia, el hombre, asustado, saco su pistola y le');
     writeln('metio un tiro en la barriga y salio corriendo, dejando al padre de Dionisio desangrandose en el piso.');
     writeln('Dionisio, paralizado por el miedo, lloraba mientras veia a su padre morir frente sus ojos, llenandole');
     writeln('las manos de sangre.');
     writeln;
     writeln('Desde ese momento, Dionisio juro venganza y empezo a involucrarse con piratas. Paso el tiempo, Dionisio');
     writeln('empezo a ganarse el respeto de los oceanos y de los otros piratas. Dionisio, en vez de robar o asesinar');
     writeln('a la "competencia", empezo a formar alianzas, y se convirtio en el pirata mas poderoso del Oceano Atlantico.');
     writeln;
     writeln('Despues de muchas aventuras, Dionisio fue diagnositicado con Sarampion, sabiendo que no le quedaba mucho');
     writeln('tiempo, reunio sus riquezas y escondio su tesoro en la isla de Capri, en Italia. Desde ese momento,');
     writeln('incontables piratas, y cazarecompensas se han embarcado a la busqueda del tesoro, pero todos fallan o');
     writeln('mueren en el intento.');
     writeln;
     textcolor(cyan);
     writeln('Seras capaz de conseguirlo?');
     readkey;
     writeln;
     textcolor(10);
     writeln('Objetivo');
     writeln;                                                                                                 //Objetivo y Reglas del juego
     textcolor(white);
     writeln('Se debe navegar el mapa en busca de las pistas del color elegido.');
     writeln('Una vez que se recolectaron todas las pistas, se debe navegar hasta el tesoro.');
     writeln('Pero no va a ser tan facil, el mapa tiene minas escondidas que al pisarlas, perderas una vida.');
     writeln('Si te quedas sin vidas, has perdido y el tesoro quedara para otro buscador.');
     writeln;
     textcolor(red);
     writeln('Reglas');
     textcolor(white);
     writeln;
     writeln('1- Solo se puede mover la distancia de una casilla, hacia arriba, abajo, isquierda o derecha.');
     writeln('2- Es Obligatorio recoger todas las pistas para poder abrir el tesoro.');
     writeln('3- Recoger una pista la eliminara del mapa.');
     writeln('4- Puedes recoger pistas de los colores que no elejiste para ganar puntos bonus.');
     writeln('5- Mientras menos pistas queden en el mapa, mas puntos bonus obtendras.');
     writeln;
     writeln('NOTA: Puedes ingresar la coordenada [0,0] para acceder al menu de acciones especiales.');
     writeln;
     writeln('Estas Listo??');
     writeln;
     writeln('Presione cualquier tecla para continuar.');
     readkey;
end;

PROCEDURE SALUDAR;
begin
     clrscr;
     textcolor(yellow);                                                           // Mensaje de Bienvenida
     write('BUSQUEDA ');
     textcolor(cyan);
     write('DEL ');
     textcolor(10);
     write('TESORO!');
     writeln;
     textcolor(white);
     writeln('Presione cualquier tecla para continuar');
     readkey;
end;


PROCEDURE CONFIGURAR;                                                             //Menu de configuracion del Juego
var
   menu,submenu,subsubmenu,n,color:boolean;
BEGIN
     Menu:= True;
     while (menu = True) do
     begin
          clrscr;
          textcolor(10);
          writeln('CONFIGURACION DEL JUEGO');
          writeln;
          textcolor(white);
          writeln('Modo de Ejecucion (1)');
          writeln('Comportamiento de minas (2)');
          writeln('Mortalidad (3)');
          writeln('ATRAS (4)');
          writeln('SALIR (5)');
          writeln;
          writeln('Seleccione una opcion ingresando el numero correspondiente:');
          validar(opcion,1,5);                                                    // Se guarda y valida la opcion ingresada

          if (opcion = 1) then
          begin
               submenu:= True;
               while (Submenu = True) do                                             // SubMenu para el modo de Ejecucion
               begin
                    clrscr;
                    textcolor(cyan);
                    writeln('MODO DE EJECUCION');
                    writeln;
                    textcolor(darkgray);
                    writeln('Hay dos modos de ejecuccion en el juego: Automatico y Manual.');
                    writeln('En el modo Automatico, se mostraran automaticamente los recorridos necesarios para ganar el juego.');          // Informacion de relevancia sobre los modos de ejecuccion para el usuario
                    writeln('En modo manual, el jugador debera encontrar su propio camino.');
                    writeln;
                    textcolor(white);
                    writeln('Manual (1) [Deffault]');
                    writeln('Automatico (2)');
                    writeln('ATRAS(3)');
                    writeln('SALIR (4)');
                    writeln;
                    writeln('Seleccione una opcion ingresando el numero correspondiente:');
                    validar(opcion,1,4);
                                                                                   // Se almacena y valida la opcion elejida
                    if (opcion = 1) then
                    begin
                         Auto:= False;
                         writeln('Modo Manual Seleccionado');                      // Modo Manual
                         readkey;
                    end
                    else if (opcion = 2) then
                    begin
                         submenu:= True;
                         while (submenu = True) do
                         begin
                              clrscr;
                              textcolor(10);
                              writeln('EJECUCION AUTOMATICA');                   // Submenu para Ejecucion Automatico
                              textcolor(darkgray);
                              writeln('Nota: Es necesario definir la cantidad de caminos y colores a seguir para que la ejecucion automatica sea valida.');
                              writeln;
                              textcolor(white);
                              writeln('Cantidad de Caminos(1)');
                              writeln('Colores (2)');
                              writeln('ATRAS (3)');
                              writeln('SALIR (4)');
                              writeln;
                              writeln('Seleccione una opcion ingresando el numero correspondiente:');

                              validar(opcion,1,4);
                              if (opcion = 1) then
                              begin
                                   writeln('CANTIDAD DE CAMINOS');                                // Se piden cantidad de caminos a generar en la ejecucion automatica
                                   writeln;
                                   writeln('Introduzca la cantidad de caminos que desea generar (max 6):');
                                   validar(ncaminos,1,6);
                                   writeln('Advertencia: es posible que no hallan suficientes caminos posibles en el mapa que se genere.');
                                   n:= True;
                                   readkey;
                              end
                              else if (opcion = 2) then
                              begin
                                   subsubmenu:= True;
                                   while (subsubmenu = True) do                        //SubSubmenu para elejir los colores de los cuales se generaran caminos en ejecucion automatica
                                   begin
                                        textcolor(cyan);
                                        clrscr;
                                        writeln('COLORES');
                                        writeln;
                                        textcolor(white);
                                        writeln('Amarillo (1)');
                                        writeln('Azul (2)');
                                        writeln('Verde (3)');
                                        writeln('Todos (4)');
                                        writeln('ATRAS (5)');
                                        writeln('SALIR (6)');
                                        writeln;
                                        writeln('Seleccione el o los colores que desea seguir para generar caminos: ');
                                        validar(opcion,1,6);

                                        if (opcion = 1) then
                                        begin
                                             writeln('Color Amarillo seleccionado');
                                             seguirA:= True;                                                 //Se buscaran caminos para el color amarillo
                                             color:= True;
                                             readkey;
                                        end
                                        else if (opcion = 2) then
                                        begin
                                             writeln('Color Azul seleccionado');
                                             color:= true;
                                             seguirF:= True;
                                             readkey;
                                        end
                                        else if (opcion = 3) then
                                        begin
                                             color:= True;                                                   //se buscaran caminos para el color verde
                                             seguirV:= True;
                                             writeln('Color Verde seleccionado');
                                             readkey;
                                        end
                                        else if (opcion = 4) then
                                        begin
                                             writeln('Todos los colores han sido seleccionados');
                                             color:= True;
                                             seguirA:= True;
                                             seguirF:= True;                                                //Se buscaran caminos para todos los colores
                                             seguirV:= True;
                                             readkey;
                                        end
                                        else if (opcion = 5) then                    // Atras, al submenu de ejecucion automatica
                                        begin
                                             subsubmenu:= False;
                                        end
                                        else if (opcion = 6) then                    // Salir del programa
                                        begin
                                             subsubmenu:= false;
                                             submenu:= false;
                                             menup:= false;
                                             despedir;
                                        end
                                   end;
                              end
                              else if (opcion = 3) then                           //Atras, al menu de configuracion de juego
                              begin
                                   if (color = False) or (n = False) then                    //Si uno de los requisitos no es verdadero, se anula la ejecucion automatica
                                   begin
                                        writeln('Ejecucion Automatica Anulada... Faltaron datos por llenar.');
                                        auto:= False;
                                   end
                                   else if (color = True) and (n = True) then                          //Si ambos son verdaderos, se activa la ejecucion automatica
                                   begin
                                        writeln('Ejecucion Automatica Activada.');
                                        auto:= True;
                                   end;
                                   readkey;
                                   submenu:= False;
                              end
                              else if (opcion = 4) then
                              begin                                              // Salir del programa
                                   submenu:= false;
                                   menu:= false;
                                   menup:= false;
                                   despedir;
                              end;
                         end;
                    end
                    else if (opcion = 3) then          // Atras
                    begin
                         submenu:= False;
                    end
                    else if (opcion = 4) then          // Salir
                    begin
                         menu:= False;
                         menuP:= false;
                         submenu:= False;
                         despedir;
                    end;
               end;
          end
          else if (opcion = 2) then
          begin
               submenu:= True;
               while (submenu = true) do                                           // Submenu para el comportamiento de Minas
               begin
                    clrscr;
                    textcolor(cyan);
                    writeln('COMPORTAMIENTO DE MINAS');
                    textcolor(darkgray);
                    writeln('Las minas pueden ser fijas o cambiar de posicion cuando se encuentra una pista.');            //Breve introduccion sobre la configuracion del comportamiento de minas
                    textcolor(white);
                    writeln;
                    writeln('Fijas (1)[Deffault]');
                    writeln('Cambiantes (2)');
                    writeln('ATRAS (3)');
                    writeln('SALIR (4)');
                    writeln;
                    writeln('Seleccione una opcion ingresando el numero correspondiente:');
                    validar(opcion,1,4);                                         // Se almacena y valida la opcion

                    if (opcion = 1) then
                    begin
                         Fijo:= True;
                         comportamiento:= False;
                         writeln('Las minas seran Fijas.');                              // Las minas seran Fijas
                         readkey;
                    end
                    else if (opcion = 2) then
                    begin
                         Fijo:= False;                                                  //Las minas seran Cambiantes
                         writeln('Las minas seran Cambiantes.');
                         comportamiento:= True;
                         readkey;
                    end
                    else if (opcion = 3) then              // Atras, al menu anterior (Configuracion del juego)
                    begin
                         submenu:= False;
                    end
                    else if (opcion = 4) then      // Salir del Programa
                    begin
                         menu:= False;
                         menuP:= false;
                         submenu:= False;
                         despedir;
                    end;
               end;
           end
           else if (opcion = 3) then
           begin
                subsubmenu:= True;
                while (subsubmenu = True) do                                                                      //Submenu para la Mortalidad
                begin
                     clrscr;                                                                                      // Se limpia la pantalla
                     textcolor(cyan);
                     writeln('MORTALIDAD');
                     textcolor(darkgray);
                     writeln('Se puede elejir entre tener una sola vida(Simple Mortal), Definir Cantidad de');     // Breve Introduccion sobre la configuracion de mortalidad
                     writeln('vidas, o ser Inmortal');
                     textcolor(white);
                     writeln;
                     writeln('Simple Mortal (1)[Deffault]');                                                      //Opciones
                     writeln('Definir Cantidad de Vidas (2)');
                     writeln('Ser Inmortal (3)');
                     writeln('ATRAS (4)');
                     writeln('SALIR (5)');
                     writeln;
                     writeln('Seleccione una opcion ingresando el numero correspondiente:');
                     validar(opcion,1,5);                                           // Se almacena y guarda la opcion

                     if (opcion = 1) then                                           // Simple Mortal
                     begin
                          writeln('Jugaras como un simple Mortal!');
                          mortalidad:= True;
                          mort:= True;
                          readkey;
                     end
                     else if (opcion = 2) then                                      //Definir cantidad de vidas
                     begin
                          repeat
                          write('Introduzca cantidad de vidas deseadas: ');          // Se pide la cantidad de vidas y se valida la cantidad
                          readln(nvidas);
                          if (nvidas = 0) then                                       // Caso borde, el jugador no puede tener 0 vidas
                          begin
                               textcolor(10);
                               writeln('Te crees Gracioso eh?');
                               textcolor(white);
                          end;
                          until (nvidas > 0);
                          writeln('Tendras ',nvidas,' vidas!');
                          mortalidad:= True;                                          // Se establece la mortalidad del jugador y la cantidad de vidas
                          mort:= True;
                          vidas:= true;
                          readkey;
                     end
                     else if (opcion = 3) then                                       // Dios Inmortal
                     begin
                          writeln('Jugaras como un Dios Inmortal!');
                          mortalidad:= False;
                          mort:= True;
                          readkey;
                     end
                     else if (opcion = 4) then                                      // Atras, al menu anterior (Configuracion de Juego)
                     begin
                          subsubmenu:= False;
                     end
                     else if (opcion = 5) then
                     begin                                                            // Sale del Programa
                          menu:= False;
                          menuP:= false;
                          submenu:= False;
                          despedir;
                     end;
                end;
           end
           else if (opcion = 4) then    // Atras
           begin
                menu:= False;
           end
           else if (opcion = 5) then     // Salir
           begin
                menu:= False;
                menuP:= false;
                submenu:= False;
                despedir;
           end;
     end;
END;

PROCEDURE colorear;                               //Procedimiento en el que el jugador decide que color de pistas va a seguir
var
   menu:boolean;
begin
     clrscr;
     menu:= True;
     while (menu = true) do
     begin
          textcolor(white);
          writeln('PISTAS A SEGUIR');                                                     // Se imprime el menu
          writeln('Escoja el color de pistas que usara para encontrar el tesoro.');
          writeln;
          textcolor(yellow);
          writeln('Amarillo (1)');
          textcolor(cyan);
          writeln('Azul (2)');
          textcolor(10);
          writeln('Verde (3)');
          textcolor(white);
          writeln('ATRAS (4)');
          writeln('SALIR (5)');
          writeln;
          writeln('Seleccione un color ingresando el numero correspondiente:');
          validar(opcion,1,5);                                                            //Se guarda la opcion

          if (opcion = 1) then
          begin
               color:= 'Amarillo';
               menu:= False;
               empezar
          end
          else if (opcion = 2) then                                                    //Dependiendo del color, se asigna un valor a la variable 'color' de tipo string
          begin
               color:= 'Azul';
               menu:= False;
               empezar;
          end
          else if (opcion = 3) then
          begin
               color:= 'Verde';
               menu:= False;
               empezar;
          end
          else if (opcion = 4) then
          begin
               menu:= False;                                                     //Atras
          end
          else if (opcion = 5) then
          begin                                                                  //Salir del programa
               menu:= False;
               submenu:= False;
               MenuP:= false;
               Despedir;
          end;
     end;
end;

PROCEDURE LlenarM (var casilla:mapa; f,c:integer);                 //Procedimiento para la creacion Manual del Mapa
var
   i,j,minas,npistas,pistas,x,y,p:integer;
   elemento,SA,SF,SV:string;
   partida,tesoro,pistaA,pistaF,pistaV,error:boolean;
begin
     pistas:= 0;
     npistas:= (f * c) - f;                          // Numero maximo de pistas en el mapa
     clrscr;
     writeln('Cantidad de filas: ',f);
     writeln('Cantidad de columnas: ',c);
     writeln;
     writeln('Elementos Validos:');                                         //Se presenta un indice sobre los diferentes elementos validos que se pueden ingresar en el mapa
     writeln;
     writeln('Punto de Partida.................... "1"');
     writeln('Tesoro.............................. "<3"');
     writeln('Pista Amarilla...................... "PA"');
     writeln('Pista Verde......................... "PV"');
     writeln('Pista Azul.......................... "PF"');
     writeln('Espacio Libre....................... " "');
     writeln('Mina................................ "*"');
     writeln;
     tesoro:= False;
     minas:= 0;
     partida:= False;
     x:= 1;
     y:= 1;                                       //Siempre se va a introducir la pista A
     p:= 1;

     for i:= 1 to f do
     begin
          for j:= 1 to c do
          begin                                                                       //Se inicia el ciclo que va por cada casilla pidiendole un valor al usuario
               repeat
               error:= False;
               write('Ingrese un elemento para la casilla[',i,',',j,']: ');
               readln(elemento);                                                        //Se pide un elemento al usuario en forma de string
               if (elemento = '1') then
               begin
                    if (partida = False) then
                    begin                                                              //Se ingresa el punto de partida en el mapa
                       casilla[i,j]:= ':^)';
                       partida:= True;
                    end
                    else
                    begin
                         writeln('ERROR... El punto de partida ya fue ingresado.');         //Si el punto de partida ya fue ingresado, da error
                    end;
               end
               else if (elemento = '*') then                                             //Se ingresa una mina
               begin
                    if (minas < nminas) then
                    begin
                         casilla[i,j]:= '*';
                         minado[i,j]:= True;
                         minas:= minas + 1;
                    end
                    else
                    begin
                         writeln('ERROR... Numero maximo de minas ya fue alcanzado.');        //Si ya se ingreso la cantidad mxima de minas, da error
                    end;
               end
               else if (elemento = '<3') and (tesoro = False) then
               begin                                                                 //Se ingresa el tesoro
                    casilla[i,j]:= '<3';
                    tesoro:= True;
               end
               else if (elemento = 'PA') and (pistas < npistas) then                                        //Se ingresa una pista amarilla
               begin
                    casilla[i,j]:= 'PA';
                    SA:= copy(abc,x,1);                            //SA sera una letra del abecedario para las pistas amarillas
                    indice[i,j]:= pos(SA,abc);                     //Dependiendo de la posicion de SA en el abecedario, el indice de la pista sera diferente
                    x:= x + 1;                                     //Se aumenta 1 en la posicion para SA
                    pistaA:= True;                                 //Se verfica que ya se introdujo una pista amarilla al mapa
                    pistas:= pistas + 1;                           //Se cuenta el numero total de pistas para que no se exceda del maximo
                    restantesA:= restantesA + 1;                                       //Se cuenta las restantes
               end
               else if (elemento = 'PF') and (pistas < npistas) then                                       //Se ingresa una pista azul
               begin
                    casilla[i,j]:= 'PF';
                    SF:= copy(abc,p,1);
                    indice[i,j]:= pos(SF,abc);                      //Mismos procedimientos para diferente color
                    p:= p + 1;
                    pistaF:= True;
                    restantesF:= restantesF + 1;                                       //Se cuenta las restantes
                    pistas:= pistas + 1;
               end
               else if (elemento = 'PV') and (pistas < npistas) then
               begin                                                                  //Se ingresa un a pista Verde
                    casilla[i,j]:= 'PV';
                    SV:= copy(abc,y,1);
                    indice[i,j]:= pos(SV,abc);
                    y:= y + 1;                                            //Mismos procedimientos para diferente color
                    pistaV:= True;
                    restantesV:= restantesV + 1;                                       //Se cuenta las restantes
                    pistas:= pistas + 1;
               end
               else if (elemento = ' ') then                                       //La casilla quedara vacia
               begin
                    casilla[i,j]:= ' ';
               end
               else
               begin
                    textcolor(red);
                    writeln('ERROR... Debe introducir un elemento valido.');         //Si el valor ingresado por el usuario no es valido, mensaje de error
                    textcolor(white);
                    error:= True;
               end;
               until (error = False);                               //Si el valor no es valido, se volvera a pedir el elemento
          end;
     end;

     if (pistaV = true) and (pistaA = True) and (pistaF = True) and (minas > 0) and (tesoro = True) and (partida = True) then
     begin
          textcolor(10);
          writeln('Creacion Manual Completada!!');                                             //Si todos los valores minimos fueron ingresados, se creara el mapa
          textcolor(white);
          writeln('Presione cualquier tecla para continuar...');
          readkey;
          creacionM:= True;               //Se activa la creacion Manual
          creacionF:= False;              //Se desactiva la creacion por Archivo
     end
     else
     begin
          textcolor(10);                                                                        //Si faltaron valores en el mapa, la creacion manual no se activara
          writeln('MAPA INVALIDO. Uno o varios elementos no fueron Ingresados.');
          textcolor(10);
          creacionM:= False;
          readkey;
     end;
end;

PROCEDURE leer (var A:text);                                          //Proceso para leer archivo
var
   x:char;
   y:string;
   nminas,pistas,npistas,ordenA,ordenV,ordenF,Ai,Fi,Vi:integer;
   error,partida,tesoro,mina,pista,PA,PV,PF,orden:boolean;
begin
     error:= False;
     PA:= False;
     PV:= False;
     PF:= False;                                                     //Se inicializan variables
     pista:= False;
     partida:= False;
     tesoro:= False;
     mina:= False;
     orden:= False;
     restantesA:= 0;
     restantesF:= 0;
     restantesV:= 0;
     ordenA:= 0;
     ordenF:= 0;
     ordenV:= 0;
     nminas:= 0;
     pistas:= 0;
     i:= 1;
     j:= 1;
     reset(A);                        //Se abre el archivo A
     while (not(EOF(A))) do
     begin
          read(A,f);    //Se lee cantidad de filas
          readln(A,c);  //Se lee cantidadd de columnas

          if (f > max) or (f < 6) or (c > max) or (c < 6) then    //Si las dimensiones no son validas, el archivo sera invalido
          begin
               error:= True;
               textcolor(red);
               writeln('Error en el mapa! Las dimensiones no son Validas.');
               textcolor(white);
          end;
          npistas:= (f * c) - f;    //Numero maximo de pistas en el mapa

          while (not(EOLN(A))) do
          begin
               read(A,x);                  //Se lee cada caracter del archivo
               if (x = '*') then
               begin
                    y:= '*';                             //Si es *, se marcara como mina
                    mina:= True;
                    minado[i,j]:= true;
                    nminas:= nminas + 1;
               end
               else if (x = '5') then                     //Si es 5 y no se ha excedido el numero maximo de pistas, sera una pista amarilla
               begin
                    read(A,x);
                    if (pos(UPCASE(x),abc) = 0) then
                    begin                                    //Luego se lee el caracter consecutivo al numero y si esta es una letra, se escribe la pista
                         error:= True;
                    end
                    else                                 //De no estarlo, se marcara el mapa como no valido
                    begin
                         y:= 'PA';
                         indice[i,j]:= pos(upcase(x),abc);        //Se le asigna un numero a cada pista dependiendo de su posicion en el abecedario
                         restantesA:= restantesA + 1;
                         ordenA:= ordenA + pos(upcase(x),abc);       //Orden es la suma de las posiciones en el alfabeto de las pistas
                         pistas:= pistas + 1;
                         PA:= True;
                    end;
               end
               else if (x = '6') then
               begin                                         //Si es 6, la pista sera azul
                    read(A,x);
                    if (pos(x,abc) = 0) then
                    begin
                         error:= True;
                    end
                    else
                    begin
                         y:= 'PF';
                         indice[i,j]:= pos(upcase(x),abc);
                         restantesF:= restantesF + 1;
                         ordenF:= ordenF + pos(upcase(x),abc);         //Orden es la suma de las posiciones en el alfabeto de las pistas
                         pistas:= pistas + 1;
                         PF:= True;
                    end;
               end
               else if (x = '7') then                         //Si es 7 la pista sera verde
               begin
                    read(A,x);
                    if (pos(x,abc) = 0) then
                    begin
                         error:= True;
                    end                                                             //Si el numero maximo de pistas ha sido alcanzado y se encuentra otra pista, se invalidara el archivo ...
                    else                                                            //...Al igual que con las minas
                    begin
                         y:= 'PV';
                         indice[i,j]:= pos(upcase(x),abc);
                         restantesV:= restantesV + 1;
                         ordenV:= ordenV + pos(upcase(x),abc);                  //Orden es la suma de las posiciones en el alfabeto de las pistas
                         pistas:= pistas + 1;
                         PV:= True;
                    end;
               end
               else if (x = '1') then                          //Si es 1, se escribe el punto de partida/jugador
               begin
                    y:= ':^)';
                    partida:= True;
               end
               else if (x = '2') then                        //Si es 2, se escribe el tesoro
               begin
                    y:= '<3';
                    tesoro:= True;
               end
               else if (x = '-') then                    //Si es un '-', se contara como un espacio
               begin
                    y:= ' ';
               end
               else if (x = ' ') then                  //Si se encuentra un espacio, no se contara como parte del mapa
               begin
                    j:= j - 1;
               end
               else
               begin
                    error:= True;                     //Si en el archivo hay cualquier otro caracter que no sea valido, se marcara el archivo como no valido
               end;
               casilla[i,j]:= y;                      //Cada elemento encontrado se guardara en el mapa
               j:= j + 1;                             //Se aumenta el indice en columnas

               if (EOLN(A)) then
               begin                               //Si se llega al final de una linea, se aumenta el indice de filas y se inicializa las columnas en 1
                    readln(A);
                    i:= i + 1;
                    j:= 1;
               end;
           end;
     end;
     close(A);             //Cerramos A

     if (PA = True) and (PV = True) and (PF = True) then               //Si todos los colores de pistas fueron escritos en el mapa, pista sera true
     begin
          pista:= True;
     end;

     Ai:= 0;                                 //Para cada cantidad posible de pistas, el valor de orden debe ser un valor especifico
     for i:= 1 to restantesA do
     begin
          Ai:= Ai + i;
     end;

     Fi:= 0;
     for i:= 1 to restantesF do            //Se chequea ese valor para cada color de pista
     begin
          Fi:= Fi + i;
     end;

     Vi:= 0;
     for i:= 1 to restantesV do
     begin
          Vi:=  Vi + i;
     end;

     if (Ai <> ordenA) or (Fi <> ordenF) or (Vi <> ordenV) then     //Si el valor de orden no concuerda con el valor obtenido por la suma de sus indices, quedara invalido el mapa
     begin
          textcolor(red);
          writeln('Error en el mapa! Las pistas no cumplen la secuencia del alfabeto.');       //Significaria que hay pistas invalidas
          orden:= False;
          textcolor(white);
     end
     else if (Ai = ordenA) and (Fi = ordenF) and (Vi = ordenV) then
     begin
          orden:= True;
     end;

     if (pista = False) then                                                           //mensaje de error  por si faltan pistas
     begin
          textcolor(red);
          writeln('Error en el mapa! Faltan pistas de otros colores.');
          textcolor(white);
     end;

     if (pistas > npistas) then
     begin
          textcolor(red);
          writeln('Error en el mapa! Hay demasiadas pistas en el mapa.');          //mensaje de error por si hay demasiadas pistas
          textcolor(white);
     end;

     if (nminas > f) then
     begin
          textcolor(red);
          writeln('Error en el mapa! Hay demasiadas minas en el mapa.');          //mensaje de error por si hay demasiadas minas
          textcolor(white);
     end;

     if (tesoro = False) then
     begin                                                                       //mensaje de error por si falta el tesoro
          textcolor(red);
          writeln('Error en el mapa! no esta el tesoro.');
          textcolor(white);
     end;

     if (partida = False) then
     begin
          textcolor(red);                                                        //Mensaje de error por si falta el punto de partida
          writeln('Error en el mapa! no esta el punto de partida.');
          textcolor(white);
     end;

     if (mina = False) then
     begin
          textcolor(red);                                                        //Mensaje de error por si no hay minas en el mapa
          writeln('Error en el mapa! no hay minas en el mapa.');
          textcolor(white);
     end;

     if (error = True) then
     begin
          textcolor(red);                                                        //Mensaje de error por si hay elementos invalidos
          writeln('Error en el mapa! hay elementos invalidos.');
          textcolor(white);
     end;

     if (error = False) and (tesoro = True) and (partida = True) and (mina = True) and (pista = True) and (orden = True) then    //Si todos los elementos necesarios estan incluidos en el mapa, se validara el mapa
     begin
          textcolor(10);
          writeln('Mapa del Tesoro valido!');
          textcolor(white);
          creacionF:= True;
          creacionM:= False;
     end
     else
     begin
          textcolor(red);
          writeln('Mapa invalido.');        //De lo contrario, se imprime mensaje de error y el mapa se anula
          textcolor(white);
          creacionF:= False;
     end;
end;

PROCEDURE abrir (var A:text);                 //Proceso para abrir el archivo introducido por el usuario
begin
     {$I-}
     reset(A);
     {$I+}
     if (IOResult <> 0) then                   //El archivo da error
     begin
          textcolor(red);
          writeln('Error en el archivo!');
          textcolor(white);
     end
     else
     begin
          close(A);
          leer(A);                            //Se llama al procedimiento leer
     end;
end;

PROCEDURE Crear;
var
   menu,mina,submenu:boolean;
BEGIN
     menu:= True;                                                                  // Menu para la Creacion del Mapa
     while (menu = True) do
     begin
          clrscr;                                                                   // Se limpia la pantalla
          textcolor(10);
          writeln('CREAR EL MAPA');
          textcolor(darkgray);
          writeln('Crear el mapa Aleatoria, por Archivo o Manualmente.');                // Se imprime el menu de Crear Mapa
          writeln;
          textcolor(white);
          writeln('Aleatoriamente (1)');
          writeln('Por Archivo (2)');                                                     // Opciones Posibles
          writeln('Manualmente (3)');
          writeln('ATRAS (4) ');
          writeln('SALIR (5) ');
          writeln;
          writeln('Seleccione una opcion ingresando el numero correspondiente:');
          writeln;

          validar(opcion,1,5);                                                       //Se almacena y valida la opcion elejida

          if (opcion = 1) then      // creacion Aleatoria
          begin
               mina:= False;
               subMenu:= True;
               while (submenu = True) do
               begin
                    clrscr;                                                          // Se limpia la pantalla
                    textcolor(cyan);
                    writeln('CREACION ALEATORIA');
                    textcolor(darkgray);
                    writeln('Todo dato que no se defina sera llenado aleatoriamente.');            // Se imprime el menu sobre la pantalla
                    textcolor(white);
                    writeln;
                    writeln('Definir Cantidad de Filas(1)');
                    writeln('Definir Cantidad de Columnas(2)');
                    writeln('Definir Cantidad de Minas(3)');
                    writeln('ATRAS(4)');
                    writeln('SALIR(5)');
                    writeln;
                    writeln('Seleccione una opcion ingresando el numero correspondiente:');
                    writeln;

                    validar(opcion,1,5);                                                   // Pide y valida la opcion elejida


                    if (opcion = 1) then                                               // Se define la cantidad de filas
                    begin
                         writeln('Introduzca cantidad de Filas (6-15 filas)');
                         validar(f,6,15);
                         writeln('Cantidad de Filas configurada!');
                         filas:= True;
                         mina:= True;
                         creacionA:= False;                //Se marcara creacionA como falsa para que se vuelva a genenerar un mapa
                         readkey;
                    end
                    else if (opcion = 2) then                                         // Se define la cantidad de columnas
                    begin
                         writeln('Introduzca cantidad de Columnas (6-15 columnas)');
                         validar(c,6,15);
                         writeln('Cantidad de Columnas configurada!');
                         creacionA:= False;                //Se marcara creacionA como falsa para que se vuelva a genenerar un mapa
                         columnas:= true;
                         readkey;
                    end
                    else if (opcion = 3) and (mina = True) then                     // Se define la cantidad de filas
                    begin
                         write('Introduzca la cantidad de minas (',1,' - ',f,' minas): ');
                         validar(nminas,1,f);
                         writeln('Cantidad de Minas configurada!');
                         minasM:= True;
                         readkey;
                    end
                    else if (opcion = 4) then                                       //Atras, al menu de Crear Mapa (anterior)
                    begin
                         submenu:= false;
                    end
                    else if (opcion = 3) and (mina = False) then                          // Caso Borde
                    begin
                         textcolor(red);
                         writeln('Antes de configurar las minas es necesario configurar las dimensiones del mapa.');        //No se pueden introducir la cantidad de minas en el mapa, sin definir la cantidad de filas
                         textcolor(white);
                         readkey;
                    end
                    else if (opcion = 5) then                                      // Salir del juego
                    begin
                         submenu:= False;
                         menu:= False;
                         menuP:= False;
                         despedir;
                    end;
               end;
          end
          else if (opcion = 2) then  //Creacion por Archivo
          begin
               textcolor(10);
               writeln('CREACION POR ARCHIVO');
               textcolor(darkgray);
               writeln('Se abrira un archivo de texto ya existente y se creara el mapa apartir de los datos encontrados.');
               textcolor(white);
               writeln;

               asignar(A);                    //Se llama a asignar
               abrir(A);                       //Se llama a abrir el archivo

               readkey;
          end
          else if (opcion = 3) then   //Creacion Manual
          begin
               textcolor(10);
               writeln('CREACION MANUAL');
               textcolor(darkgray);
               writeln('En la creacion manual, todo dato debe ser llenado, de lo contrario, el mapa quedara invalido y');
               writeln('todas las configuraciones hechas quedaran anuladas.');
               writeln;
               textcolor(white);
               writeln('Presione cualquier tecla para continuar');
               readkey;
               submenu:= true;
               while (submenu = True) do
               begin
                    clrscr;
                    textcolor(10);
                    writeln('CREACION MANUAL');
                    textcolor(white);
                    writeln('Para volver al menu anterior, introduzca 5');
                    writeln;
                    write('Introduzca la cantidad de filas(min 6, max 15): ');                       //Primero se piden las dimensiones del mapa, lo cual define los limites del mapa
                    validar(f,5,15);
                    write('Introduzca la cantidad de columnas(min 6, max 15): ');
                    validar(c,5,15);                                                                 //Se piden y guardan las coordenadas x,y de todos los elementos por separado
                    if (f = 5) or (c = 5) then
                    begin
                         submenu:= False;
                    end
                    else
                    begin
                         clrscr;
                         LlenarM(casilla,f,c);
                    end;
                    submenu:= False;
               end;
          end
          else if (opcion = 4) then
          begin
               menu:= False;                                            //Atras, al menu de Crear Mapa (anterior)
          end
          else if (opcion = 5) then
          begin
               menu:= False;                                           //Salir del Programa
               menuP:= False;
               despedir;
          end;
     end;
END;


BEGIN                                                                             // Programa Principal
     consulta:= False;
     Saludar;
     menuP:= True;
     valorar;
     while (menuP = True) do                                                     //Menu Principal
     begin
          clrscr;
          textcolor(white);
          writeln('----------------');
          write('|');
          textcolor(10);
          write('MENU PRINCIPAL');
          textcolor(white);
          writeln('|');
          writeln('----------------');
          writeln;
          textcolor(white);
          writeln('Crear Mapa (1)');
          writeln('Configuracion del Juego (2)');
          writeln('Jugar (3)');
          writeln('Consultar Mapa (4)');
          writeln('Explicar Juego (5)');
          writeln('Volver (6)');
          writeln('Salir (7)');
          writeln;
          writeln('Seleccione una opcion ingresando el numero correspondiente:');
          validar(opcion,1,7);

          if (opcion = 1) then          // Se crea el mapa
          begin
               clrscr;
               crear;
          end
          else if (opcion = 2) then                  //Se va al menu de configuraciones
          begin
               clrscr;
               configurar;
          end
          else if (opcion = 3) then              //Jugar
          begin
               clrscr;
               submenu:= True;
               while (submenu = True) do
               begin
                    clrscr;
                    textcolor(cyan);
                    writeln('MODO DE JUEGO');
                    textcolor(darkgray);
                    writeln('Se puede jugar como supervisor o jugador. En modo supervisor puedes ver todas las minas y pistas.');        //Informacion de relevancia sobre los modos de juego para el usuario
                    writeln('En modo jugador no');
                    textcolor(white);
                    writeln;
                    writeln('Supervisor (1)');
                    writeln('Jugador (2)');
                    writeln('ATRAS (3)');
                    writeln('SALIR (4)');
                    writeln;
                    writeln('Seleccione una opcion ingresando el numero correspondiente:');

                    validar(opcion,1,4);                                             // Se guarda y valida la opcion


                    if (opcion = 1) then
                    begin
                         modo:= 'Supervisor';                                       //Se elije el modo SUPERVISOR
                         writeln('Modo Supervisor Seleccionado.');
                         if (auto = False) then
                         begin
                              colorear;
                         end
                         else if (auto = True) then                               //Si la ejecucion es manual, se explica el juego
                         begin
                              empezar;
                         end;
                         submenu:= False;
                         readkey;
                    end
                    else if (opcion = 2) then
                    begin
                         modo:= 'Jugador';                                           // Se elije el modo JUGADOR
                         writeln('Modo Jugador Seleccionado.');
                         if (auto = False) then
                         begin
                              colorear;
                         end
                         else if (auto = True) then                               //Si la ejecucion es manual, se explica el juego
                         begin
                              empezar;
                         end;
                         submenu:= False;
                         readkey;
                    end
                    else if (opcion = 3) then                                        // Atras
                    begin
                         submenu:= False;
                    end
                    else if (opcion = 4) then                                           // Salir
                    begin
                         submenu:= False;
                         menup:= False;
                         despedir;
                    end;
               end;
          end
          else if (opcion = 4) then
          begin
               if (creacionF = False) and (creacionM = False) and (creacionA = False) then              //Si el mapa no ha sido creado, se crea uno aleatoriamente
               begin
                    consulta:= True;
                    llenar(casilla,f,c);
                    consulta:= false;
               end
               else
               begin
                    visualizar(casilla,f,c);          //Si el mapa ya fue creado, se visualiza
               end;
          end
          else if (opcion = 5) then
          begin
               explicar;
          end
          else if (opcion = 6) then                                   //Se vuelve a la pantalla de bienvenda
          begin
               Saludar;
          end
          else if (opcion = 7) then                            //Se sale del juego
          begin
               menuP:= False;
               despedir;
          end;
      end;
END.
