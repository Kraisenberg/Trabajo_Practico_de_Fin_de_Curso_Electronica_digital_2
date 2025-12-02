# Trabajo fin de curso ED2: Theremin:

En este repositorio se adjunta todo el contenido respecto del trabajo final de fin de curso para la materia electrónica digital 2 del Grupo 3 cuyos integrantes son Acuña María Pia, Di Paolo Valentino, Sacchi Matías Leonel

# Theremin:
El theremín es uno de los primeros instrumentos musicales electrónicos, inventado por el ruso Léon Theremin a principios del siglo XX. Su característica más distintiva es que se toca sin contacto físico, manipulando el sonido a través de dos antenas que controlan la frecuencia (tono) y la amplitud (volumen) con las manos. 

# Funcionamiento del proyecto:
Nuestro proyecto implementa un theremin digital utilizando un sensor de ultrasonido HC-SR04 para detectar la posición de la mano del usuario y transformar esa distancia en una frecuencia audible generada por el microcontrolador.

El funcionamiento se basa en los siguientes principios:

🔹 1. Medición de distancia con ultrasonido

El sensor HC-SR04 emite un pulso ultrasónico de 40 kHz y mide el tiempo que tarda en regresar tras rebotar en la mano del usuario.
El microcontrolador calcula la distancia usando:

distancia = (tiempo_eco * velsonido)/2

Esta distancia cambia de forma continua conforme el usuario mueve la mano.

El valor de distancia lo enviamos por computadora a traves de una coneccion serial asincrona

🔹 2. Conversión de distancia a frecuencia

La distancia medida se convierte en un valor de frecuencia.
Cuando la mano está cerca, la frecuencia generada es alta; cuando la mano está lejos, la frecuencia es baja, simulando el comportamiento del theremin tradicional.

El microcontrolador ajusta un temporizador para generar una onda cuadrada en función de esta frecuencia calculada.

🔹 3. Generación del sonido

La salida PWM u oscilación por temporizador se envía a un parlante, buzzer o amplificador, produciendo el tono audible.
Al mover la mano, el usuario “toca el theremin” sin tocar físicamente ningún componente.

🎶 Resumen del proceso

El sensor ultrasonido mide la distancia a la mano.

El microcontrolador convierte esa distancia en una frecuencia.

Se genera un tono correspondiente a esa frecuencia.

El usuario controla el sonido moviendo la mano en el aire.

# Diagrama de circuito:
![Proteus](https://github.com/Kraisenberg/Trabajo_Practico_de_Fin_de_Curso_Electronica_digital_2/blob/main/simulador/esquema.png)
