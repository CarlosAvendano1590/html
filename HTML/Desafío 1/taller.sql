-- Taller
-- Javiera Pacheco Bascur
-- 1-nov-2022


-- 1 --

with fechas as(
select date::date 
from generate_series(
  '2021-01-01'::date,
  '2022-12-31'::date,
  '1 day'::interval) 
date
)
  
, feriados as (
select distinct nombre
, fecha 
from api_feriados af
where nombre <> 'Todos los Días Domingos'
)



, indicadores as (
select date
, dd.valor_dolar::float 
, ed.valor_euro::float
, ud.valor_uf
, u.valor_utm 
, i.valor_ipc 
, f.nombre  
FROM fechas
full join dolar_diario dd  on date = dd.fecha::date
full join euro_diario ed on date = ed.fecha ::date
full join uf_diario ud on date  = ud.fecha::date
full join utm u on to_char(date, 'YYYY-MM') = to_char(u.fecha::date, 'YYYY-MM') 
full join ipc i on to_char(date, 'YYYY-MM') = to_char(i.fecha::date, 'YYYY-MM') 
full join feriados f on date  = f.fecha::date 
where date between '2021-01-01' and '2022-12-31'
order by date
)



-- 2 --
-- a --
-- ¿Qué pasa con los valores de dólar y euro para cada día? ¿Qué --
-- problemática se le presenta al presentar la información diaria? --

select date
,valor_dolar
,valor_euro
from indicadores


-- Respuesta: Hay días en los que hay valores nulos (no tiene valores) --

-- b --
-- ¿Qué sucede desde el 01-01-2021 al 03-01-2021? --

where date between '2021-01-01' and '2021-01-03' 

-- Respuesta: No hay valores para dolar ni para euro.

-- c -- 
-- Respuesta : Una alternativa sería rellenar los valores nulos con una media del mes para el valor solicitado
-- Para eso creo una tabla donde se almacenan todos los promedios mensuales de cada columna 
--(valor_dolar y valor_euro) Para eso creo una tabla temporal donde se almacenan todos los promedios.--
, tabla_promedios as (
select to_char(date, 'YYYY-MM') as fech, avg(valor_dolar) as promedio_dolar, avg(valor_euro) as promedio_euro
from indicadores as ind
group by to_char(date, 'YYYY-MM')
order by to_char(date, 'YYYY-MM') asc
)

-- Y luego bajo la condicion de que un campo este nulo, se llena con el promedio del mes que le
-- corresponde utilizando un case , en el caso de que el valor sea nulo, agregaría el 
-- promedio del mes que le corresponde.
) 

insert into indicadores (valor_dolar)
select promedio_dolar
from tabla_promedios
where valor_dolar = null
and fech = to_char(ind.date, 'YYYY-MM') 

