# Use a plumber-enabled R image
FROM rstudio/plumber

# Install system dependencies (optional: update based on actual needs)
RUN apt-get update -qq && apt-get install -y \
    libssl-dev \
    libcurl4-gnutls-dev \
    libpng-dev \
    pandoc

# Install required R packages
RUN R -e "install.packages(c('caret', 'plumber', 'rpart', 'rpart.plot', 'tibble'))"

# Copy all project files into container
COPY . /app

# Set working directory
WORKDIR /app

# Expose plumber port
EXPOSE 8000

# Start plumber API
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb('API.R'); pr$run(host='0.0.0.0', port=8000)"]
