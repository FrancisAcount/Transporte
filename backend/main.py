
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from database import engine, verificar_conexion

app = FastAPI(
    title="API Transporte Escolar Maranata",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://localhost:8000",
        "http://localhost:5000",
        "http://localhost:8080",
        "http://localhost:5173",
        "http://localhost:3000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def inicio():
    return {
        "mensaje": "API de Transporte Escolar Maranata",
        "estado": "activa",
    }


@app.get("/db-check")
def comprobar_base_datos():
    try:
        if not verificar_conexion():
            raise HTTPException(
                status_code=503,
                detail="MySQL no respondió correctamente",
            )

        with engine.connect() as conexion:
            tablas = conexion.execute(
                text("SHOW TABLES")
            ).scalars().all()

        return {
            "conexion": "correcta",
            "base_datos": "maranata_escolar",
            "cantidad_tablas": len(tablas),
            "tablas": tablas,
        }

    except SQLAlchemyError:
        raise HTTPException(
            status_code=503,
            detail="No se pudo conectar con MySQL. "
                   "Revisa el servidor y las credenciales.",
        )

@app.get("/estudiantes")
def listar_estudiantes():
    try:
        with engine.connect() as conexion:
            resultado = conexion.execute(
                text("""
                    SELECT
                        id,
                        nombres,
                        apellidos,
                        curso,
                        nombre_tutor,
                        telefono_tutor,
                        direccion,
                        estado
                    FROM estudiantes
                    ORDER BY apellidos, nombres
                """)
            )

            estudiantes = [
                dict(fila)
                for fila in resultado.mappings().all()
            ]

        return {
            "total": len(estudiantes),
            "estudiantes": estudiantes,
        }

    except SQLAlchemyError:
        raise HTTPException(
            status_code=503,
            detail="No se pudieron consultar los estudiantes.",
        )
