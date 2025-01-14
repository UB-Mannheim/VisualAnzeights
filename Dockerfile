# Build step #1: build the React front end
FROM node:18-alpine as build-step
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY WebAppAnsights/package.json ./
COPY WebAppAnsights/src ./src
COPY WebAppAnsights/public ./public
RUN npm install
RUN npm install react-dropdown-date
RUN npm run build

# Build step #2: build the API with the client as static files
FROM python:3.9
RUN apt-get update
RUN apt-get install ffmpeg libsm6 libxext6 tesseract-ocr -y
WORKDIR /app/WebAppAnsights
COPY --from=build-step /app/build ./build

WORKDIR /app
COPY ./README.md .
COPY ./data ./data
COPY ./requirements.txt .
COPY ./setup.py .
COPY ./src ./src
RUN pip install -r ./requirements.txt
RUN pip install .
RUN python -m spacy download de_core_news_md
RUN pip install gunicorn
ENV FLASK_ENV production

EXPOSE 3000
WORKDIR /app/src/flask_backend
CMD ["gunicorn", "-b", ":3000","--timeout","240", "flask_orchestrator:app"]