FROM python:3.12-slim

RUN useradd --create-home --uid 10001 --shell /usr/sbin/nologin appuser

WORKDIR /app
COPY app/app.py .

ENV PORT=8080
EXPOSE 8080
USER appuser

CMD ["python", "app.py"]
