🧱 Concrete Crack Detection MIEM
📌 Описание
Многофункциональное веб-приложение для анализа бетонных изображений с помощью сверточных нейронных сетей. Позволяет:

Выявлять наличие трещин

Оценивать прочность бетона образца керна

Определять класс бетона по фото

🚀 Технологии
Backend: Python, FastAPI, PyTorch, torchvision, pandas

Frontend: React + Tailwind (в папке frontend)

ML-модели: MobileNet, кастомные CNN

Формат входных данных: .jpg, .jpeg, .dng (с паттерном IMG_XXXX.ext)

📁 Структура проекта
bash
Copy
Edit
neuroBetonWeb/
├── backend/
│   ├── main.py                    # FastAPI приложение
│   ├── model_service.py          # Логика загрузки и вызова моделей
│   ├── models/                   # Каталог моделей (.pt, .pkl)
│   ├── data/                     # Таблица с типами бетона (CSV)
│   ├── requirements.txt
├── frontend/                     # Next.js/React интерфейс
├── .gitignore
└── LICENSE

🛠 Установка и запуск
1. 📦 Установка зависимостей (backend)
bash
Copy
Edit
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

2. ⚙️ Запуск backend
bash
Copy
Edit
uvicorn main:app --reload
# Доступно по http://127.0.0.1:8000

3. 🌐 Запуск frontend
bash
Copy
Edit
cd frontend
npm install
npm run dev
# Открыть http://localhost:3000
