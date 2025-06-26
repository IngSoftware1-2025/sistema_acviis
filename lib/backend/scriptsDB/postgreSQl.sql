CREATE TABLE public.trabajadores (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nombre_completo character varying NOT NULL UNIQUE,
  estado_civil character varying NOT NULL,
  rut character varying NOT NULL UNIQUE,
  fecha_de_nacimiento date NOT NULL,
  direccion character varying NOT NULL,
  correo_electronico character varying NOT NULL UNIQUE,
  sistema_de_salud character varying NOT NULL,
  prevision_afp character varying NOT NULL,
  obra_en_la_que_trabaja character varying NOT NULL,
  rol_que_asume_en_la_obra character varying NOT NULL,
  estado character varying NOT NULL,
  CONSTRAINT trabajadores_pkey PRIMARY KEY (id)
);
CREATE TABLE public.contratos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_trabajadores uuid NOT NULL,
  plazo_de_contrato character varying NOT NULL,
  estado character varying NOT NULL,
  fecha_de_contratacion date NOT NULL,
  CONSTRAINT contratos_pkey PRIMARY KEY (id),
  CONSTRAINT fk_contrato_trabajador FOREIGN KEY (id_trabajadores) REFERENCES public.trabajadores(id)
);
CREATE TABLE public.anexos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_contrato uuid NOT NULL,
  fecha_de_creacion date NOT NULL,
  duracion character varying NOT NULL,
  tipo character varying NOT NULL,
  parametros character varying NOT NULL DEFAULT ''::character varying,
  CONSTRAINT anexos_pkey PRIMARY KEY (id),
  CONSTRAINT fk_anexo_contrato FOREIGN KEY (id_contrato) REFERENCES public.contratos(id)
);
CREATE TABLE public.comentarios (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_trabajadores uuid NOT NULL,
  id_contrato uuid,
  fecha timestamp without time zone NOT NULL,
  comentario character varying NOT NULL,
  id_anexo uuid,
  CONSTRAINT comentarios_pkey PRIMARY KEY (id),
  CONSTRAINT fk_comentario_anexo FOREIGN KEY (id_anexo) REFERENCES public.anexos(id),
  CONSTRAINT fk_comentario_contrato FOREIGN KEY (id_contrato) REFERENCES public.contratos(id),
  CONSTRAINT fk_comentario_trabajador FOREIGN KEY (id_trabajadores) REFERENCES public.trabajadores(id)
);