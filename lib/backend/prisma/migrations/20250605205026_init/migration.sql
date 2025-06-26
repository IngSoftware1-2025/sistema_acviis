-- CreateTable
CREATE TABLE "trabajadores" (
    "id" TEXT NOT NULL,
    "nombre_completo" TEXT NOT NULL,
    "estado_civil" TEXT NOT NULL,
    "rut" TEXT NOT NULL,
    "fecha_de_nacimiento" TIMESTAMP(3) NOT NULL,
    "direccion" TEXT NOT NULL,
    "correo_electronico" TEXT NOT NULL,
    "sistema_de_salud" TEXT NOT NULL,
    "prevision_afp" TEXT NOT NULL,
    "obra_en_la_que_trabaja" TEXT NOT NULL,
    "rol_que_asume_en_la_obra" TEXT NOT NULL,

    CONSTRAINT "trabajadores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contratos" (
    "id" INTEGER NOT NULL,
    "id_trabajadores" TEXT NOT NULL,
    "plazo_de_contrato" TEXT NOT NULL,
    "estado_de_despido" BOOLEAN NOT NULL,
    "documento_de_vacaciones_del_trabajador" VARCHAR(255) NOT NULL,
    "comentario_adicional_acerca_del_trabajador" VARCHAR(255) NOT NULL,
    "fecha_de_contratacion" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "contratos_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "contratos_id_trabajadores_key" ON "contratos"("id_trabajadores");

-- CreateIndex
CREATE INDEX "contratos_id_trabajadores_idx" ON "contratos"("id_trabajadores");

-- AddForeignKey
ALTER TABLE "contratos" ADD CONSTRAINT "contratos_id_trabajadores_fkey" FOREIGN KEY ("id_trabajadores") REFERENCES "trabajadores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
