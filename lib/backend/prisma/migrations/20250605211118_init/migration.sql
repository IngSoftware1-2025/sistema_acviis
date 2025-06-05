/*
  Warnings:

  - You are about to drop the column `estado_de_despido` on the `contratos` table. All the data in the column will be lost.
  - Added the required column `estado` to the `contratos` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX "contratos_id_trabajadores_key";

-- AlterTable
ALTER TABLE "contratos" DROP COLUMN "estado_de_despido",
ADD COLUMN     "estado" TEXT NOT NULL;
