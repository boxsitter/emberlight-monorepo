#!/bin/bash
# Dev Docker management script for Bessie

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to start the development environment
start_dev() {
    print_status "Starting Bessie development environment..."
    check_docker
    
    print_status "Building and starting containers..."
    docker-compose -f docker-compose.debug.yml up --build -d
    
    print_status "Development environment started successfully!"
    echo
    print_status "Access your application at:"
    echo "  - Bessie Web App: http://localhost:8080"
    echo "  - Firebase Emulator UI: http://localhost:4000"
    echo
    print_status "To view logs: ./dev-docker.sh logs"
    print_status "To stop: ./dev-docker.sh stop"
}

# Function to stop the development environment
stop_dev() {
    print_status "Stopping development environment..."
    docker-compose -f docker-compose.debug.yml down
    print_status "Development environment stopped."
}

# Function to show logs
show_logs() {
    docker-compose -f docker-compose.debug.yml logs -f
}

# Function to rebuild and restart
restart_dev() {
    print_status "Restarting development environment..."
    stop_dev
    start_dev
}

# Function to show status
show_status() {
    print_status "Container status:"
    docker-compose -f docker-compose.debug.yml ps
}

# Function to clean up Docker resources
cleanup() {
    print_warning "This will remove all stopped containers, unused networks, and build cache."
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleaning up Docker resources..."
        docker system prune -f
        print_status "Cleanup completed."
    else
        print_status "Cleanup cancelled."
    fi
}

# Function to show help
show_help() {
    echo "Emberlight Monorepo Docker Development Script"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  start     Start the development environment"
    echo "  stop      Stop the development environment"
    echo "  restart   Restart the development environment"
    echo "  logs      Show container logs"
    echo "  status    Show container status"
    echo "  cleanup   Clean up Docker resources"
    echo "  help      Show this help message"
    echo
    echo "If no command is provided, 'start' will be executed."
}

# Main script logic
case "${1:-start}" in
    start)
        start_dev
        ;;
    stop)
        stop_dev
        ;;
    restart)
        restart_dev
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    cleanup)
        cleanup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo
        show_help
        exit 1
        ;;
esac
