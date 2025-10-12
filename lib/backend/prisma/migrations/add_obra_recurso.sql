-- CreateTable
CREATE TABLE "obra_recurso" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "obra_id" UUID NOT NULL,
    "recurso_tipo" VARCHAR NOT NULL,
    "vehiculo_id" UUID,
    "herramienta_id" UUID,
    "epp_id" INTEGER,
    "fecha_asignacion" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fecha_retiro" TIMESTAMP(6),
    "cantidad" INTEGER NOT NULL DEFAULT 1,
    "observaciones" TEXT,
    "estado" VARCHAR NOT NULL DEFAULT 'activo',

    CONSTRAINT "obra_recurso_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "obra_recurso" ADD CONSTRAINT "obra_recurso_obra_id_fkey" FOREIGN KEY ("obra_id") REFERENCES "obras"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "obra_recurso" ADD CONSTRAINT "obra_recurso_vehiculo_id_fkey" FOREIGN KEY ("vehiculo_id") REFERENCES "vehiculos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "obra_recurso" ADD CONSTRAINT "obra_recurso_herramienta_id_fkey" FOREIGN KEY ("herramienta_id") REFERENCES "herramientas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "obra_recurso" ADD CONSTRAINT "obra_recurso_epp_id_fkey" FOREIGN KEY ("epp_id") REFERENCES "epp"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- CreateIndex
CREATE INDEX "idx_obra_recurso_obra" ON "obra_recurso"("obra_id");

-- CreateIndex
CREATE INDEX "idx_obra_recurso_vehiculo" ON "obra_recurso"("vehiculo_id");

-- CreateIndex
CREATE INDEX "idx_obra_recurso_herramienta" ON "obra_recurso"("herramienta_id");

-- CreateIndex
CREATE INDEX "idx_obra_recurso_epp" ON "obra_recurso"("epp_id");

-- CreateIndex
CREATE UNIQUE INDEX "uk_obra_vehiculo" ON "obra_recurso"("obra_id", "vehiculo_id") WHERE (recurso_tipo = 'vehiculo' AND vehiculo_id IS NOT NULL);

-- CreateIndex
CREATE UNIQUE INDEX "uk_obra_herramienta" ON "obra_recurso"("obra_id", "herramienta_id") WHERE (recurso_tipo = 'herramienta' AND herramienta_id IS NOT NULL);

-- CreateIndex
CREATE UNIQUE INDEX "uk_obra_epp" ON "obra_recurso"("obra_id", "epp_id") WHERE (recurso_tipo = 'epp' AND epp_id IS NOT NULL);

-- Add constraint to validate that only one ID is not null based on recurso_tipo
ALTER TABLE "obra_recurso" ADD CONSTRAINT "check_valid_recurso" CHECK (
    (recurso_tipo = 'vehiculo' AND vehiculo_id IS NOT NULL AND herramienta_id IS NULL AND epp_id IS NULL) OR
    (recurso_tipo = 'herramienta' AND vehiculo_id IS NULL AND herramienta_id IS NOT NULL AND epp_id IS NULL) OR
    (recurso_tipo = 'epp' AND vehiculo_id IS NULL AND herramienta_id IS NULL AND epp_id IS NOT NULL)
);