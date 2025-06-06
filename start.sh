#!/bin/bash

# Цвета для красивого вывода в терминале
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Функция для красивого лого
print_logo() {
    echo -e "${CYAN}"
    echo "███╗   ██╗███████╗██╗   ██╗██████╗  ██████╗ ██████╗ ███████╗████████╗ ██████╗ ███╗   ██╗"
    echo "████╗  ██║██╔════╝██║   ██║██╔══██╗██╔═══██╗██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗████╗  ██║"
    echo "██╔██╗ ██║█████╗  ██║   ██║██████╔╝██║   ██║██████╔╝█████╗     ██║   ██║   ██║██╔██╗ ██║"
    echo "██║╚██╗██║██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══██╗██╔══╝     ██║   ██║   ██║██║╚██╗██║"
    echo "██║ ╚████║███████╗╚██████╔╝██║  ██║╚██████╔╝██████╔╝███████╗   ██║   ╚██████╔╝██║ ╚████║"
    echo "╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝"
    echo -e "${NC}"
    echo -e "${PURPLE}🚀 Запуск системы анализа прочности бетона${NC}\n"
}

# Функция для проверки зависимостей
check_dependencies() {
    echo -e "${BLUE}🔍 Проверяем зависимости...${NC}"
    
    # Проверяем Python
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}❌ Python3 не найден! Установите Python3${NC}"
        exit 1
    fi
    
    # Проверяем Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js не найден! Установите Node.js${NC}"
        exit 1
    fi
    
    # Проверяем npm
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}❌ npm не найден! Установите npm${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Все зависимости найдены${NC}\n"
}

# Функция для создания виртуального окружения если его нет
setup_venv() {
    if [ ! -d ".venv" ]; then
        echo -e "${YELLOW}📦 Создаем виртуальное окружение...${NC}"
        python3 -m venv .venv
        echo -e "${GREEN}✅ Виртуальное окружение создано${NC}"
    fi
}

# Функция для установки Python зависимостей
install_backend_deps() {
    echo -e "${BLUE}📦 Устанавливаем зависимости бэкенда...${NC}"
    
    # Активируем виртуальное окружение и устанавливаем зависимости
    source .venv/bin/activate
    
    if [ -f "backend/requirements.txt" ]; then
        pip install -r backend/requirements.txt
        echo -e "${GREEN}✅ Зависимости бэкенда установлены${NC}"
    else
        echo -e "${RED}❌ Файл requirements.txt не найден в папке backend${NC}"
        exit 1
    fi
}

# Функция для установки Node.js зависимостей
install_frontend_deps() {
    echo -e "${BLUE}📦 Устанавливаем зависимости фронтенда...${NC}"
    
    cd frontend
    if [ -f "package.json" ]; then
        npm install
        echo -e "${GREEN}✅ Зависимости фронтенда установлены${NC}"
    else
        echo -e "${RED}❌ Файл package.json не найден в папке frontend${NC}"
        exit 1
    fi
    cd ..
}

# Функция для остановки всех процессов при выходе
cleanup() {
    echo -e "\n${YELLOW}🛑 Останавливаем серверы...${NC}"
    # Убиваем все дочерние процессы
    jobs -p | xargs -r kill
    wait
    echo -e "${GREEN}✅ Все серверы остановлены${NC}"
    exit 0
}

# Функция запуска бэкенда
start_backend() {
    echo -e "${BLUE}🚀 Запускаем бэкенд сервер...${NC}"
    cd backend
    # Активируем виртуальное окружение
    source ../.venv/bin/activate
    # Запускаем uvicorn в фоне
    uvicorn main:app --reload --host 0.0.0.0 --port 8000 &
    BACKEND_PID=$!
    echo -e "${GREEN}✅ Бэкенд запущен на http://localhost:8000 (PID: $BACKEND_PID)${NC}"
    cd ..
}

# Функция запуска фронтенда
start_frontend() {
    echo -e "${BLUE}🚀 Запускаем фронтенд сервер...${NC}"
    cd frontend
    # Запускаем Next.js в фоне
    npm run dev &
    FRONTEND_PID=$!
    echo -e "${GREEN}✅ Фронтенд запущен на http://localhost:3000 (PID: $FRONTEND_PID)${NC}"
    cd ..
}

# Функция ожидания готовности серверов
wait_for_servers() {
    echo -e "${YELLOW}⏳ Ждем запуска серверов...${NC}"
    sleep 3
    
    # Проверяем бэкенд
    echo -e "${BLUE}🔍 Проверяем бэкенд...${NC}"
    for i in {1..10}; do
        if curl -s http://localhost:8000 > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Бэкенд готов!${NC}"
            break
        fi
        sleep 1
        echo -e "${YELLOW}⏳ Ждем бэкенд... ($i/10)${NC}"
    done
    
    # Проверяем фронтенд
    echo -e "${BLUE}🔍 Проверяем фронтенд...${NC}"
    for i in {1..15}; do
        if curl -s http://localhost:3000 > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Фронтенд готов!${NC}"
            break
        fi
        sleep 1
        echo -e "${YELLOW}⏳ Ждем фронтенд... ($i/15)${NC}"
    done
}

# Основная функция
main() {
    # Очищаем экран и показываем лого
    clear
    print_logo
    
    # Устанавливаем обработчик сигналов для корректного завершения
    trap cleanup SIGINT SIGTERM
    
    # Проверяем аргументы командной строки
    case "${1:-}" in
        --install-deps)
            check_dependencies
            setup_venv
            install_backend_deps
            install_frontend_deps
            echo -e "${GREEN}🎉 Все зависимости установлены! Теперь запустите: ./start.sh${NC}"
            exit 0
            ;;
        --help|-h)
            echo -e "${CYAN}Использование:${NC}"
            echo -e "  ./start.sh              - Запустить приложение"
            echo -e "  ./start.sh --install-deps - Установить зависимости"
            echo -e "  ./start.sh --help       - Показать эту справку"
            exit 0
            ;;
    esac
    
    # Проверяем зависимости
    check_dependencies
    
    # Проверяем наличие виртуального окружения
    if [ ! -d ".venv" ]; then
        echo -e "${YELLOW}⚠️  Виртуальное окружение не найдено${NC}"
        echo -e "${BLUE}💡 Запустите: ./start.sh --install-deps для установки зависимостей${NC}"
        exit 1
    fi
    
    # Запускаем серверы
    start_backend
    start_frontend
    
    # Ждем готовности
    wait_for_servers
    
    # Выводим информацию
    echo -e "\n${GREEN}🎉 NeuroBeton успешно запущен!${NC}"
    echo -e "${CYAN}📍 Адреса серверов:${NC}"
    echo -e "   🌐 Фронтенд: ${YELLOW}http://localhost:3000${NC}"
    echo -e "   🔧 Бэкенд:   ${YELLOW}http://localhost:8000${NC}"
    echo -e "   📚 API Docs: ${YELLOW}http://localhost:8000/docs${NC}"
    echo -e "\n${PURPLE}💡 Для остановки нажмите Ctrl+C${NC}\n"
    
    # Ждем сигнала завершения
    wait
}

# Запускаем основную функцию с переданными аргументами
main "$@"