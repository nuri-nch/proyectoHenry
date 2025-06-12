


## Estructura del Proyecto

- data_avance/  Carpeta que contiene los archivos de datos (CSV) usados en el análisis.  

- avance1.ipynb Notebook principal donde se realiza la carga, limpieza, análisis y feature engineering de los datos.  

## Objetivos
- Cargar y explorar una base de datos grande de ventas y empleados.  
- Detectar y marcar outliers en la columna "TotalPriceCalculated" usando el método del rango intercuartílico (IQR).  
- Extraer y analizar la información temporal para identificar patrones de venta por hora y día.  
- Calcular nuevas variables derivadas, como edad del empleado al contratarse y años de experiencia al momento de la venta.  
- Preparar un dataset final para modelado, aplicando transformaciones adecuadas a variables numéricas y categóricas, dejando la variable objetivo sin modificar.  

## Conclusiones
- Se detectaron un gran número de outliers en las ventas totales.  
- La mayoría de las ventas se concentran durante el día y especialmente entre semana.  
- La edad al contratar y experiencia del empleado son variables importantes que pueden influir en el desempeño de ventas.  
- El dataset final quedó preparado para entrenar modelos de machine learning con variables numéricas escaladas y variables categóricas codificadas.

## Stack Técnico
- Python 3.x  
- Pandas para manipulación y análisis de datos  
- Jupyter Notebook para desarrollo interactivo  
- SQLite 
