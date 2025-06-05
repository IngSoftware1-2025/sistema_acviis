-- CreateTable
CREATE TABLE "Trabajador" (
    "id" TEXT NOT NULL,
    "nombre" VARCHAR(100) NOT NULL,
    "apellido" TEXT,
    "email" TEXT NOT NULL,
    "edad" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Trabajador_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Trabajador_email_key" ON "Trabajador"("email");
