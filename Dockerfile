# Use rocker/shiny with R 4.5
FROM rocker/shiny:4.5

# Install system dependencies for R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Use Posit Package Manager for pre-compiled binaries (much faster!)
ENV CRAN_REPO=https://packagemanager.posit.co/cran/__linux__/noble/latest

# Accept GitHub PAT as build argument to avoid rate limits
ARG GITHUB_PAT
ENV GITHUB_PAT=$GITHUB_PAT

# Install pak for faster and more reliable package installation
RUN R -e "install.packages('pak', repos=Sys.getenv('CRAN_REPO'))"

# Install CRAN dependencies first (using pre-compiled binaries - much faster!)
RUN R -e "install.packages(c('shiny', 'fredr', 'glue', 'htmltools', 'shinyjs', 'duckplyr'), repos=Sys.getenv('CRAN_REPO'))"

# Install GitHub packages (blockr ecosystem) using pak - faster and more reliable
# Note: blockr.dplyr@public excludes expression blocks for security
# Only install needed packages (not umbrella 'blockr' which pulls in blockr.ai)
RUN R -e "pak::pak(c( \
    'BristolMyersSquibb/blockr.core', \
    'BristolMyersSquibb/blockr.dplyr@public', \
    'BristolMyersSquibb/blockr.ggplot', \
    'BristolMyersSquibb/blockr.dock', \
    'BristolMyersSquibb/blockr.dag' \
  ))"

# Install blockr.fredr package from local source
COPY . /tmp/blockr.fredr
RUN R -e "pak::pak('local::/tmp/blockr.fredr')"

# Copy the Shiny app to the default Shiny Server location
RUN rm -rf /srv/shiny-server/*
COPY deploy /srv/shiny-server/

# Set working directory
WORKDIR /srv/shiny-server

# Make sure the app is readable
RUN chmod -R 755 /srv/shiny-server

# Expose port 3838 for Shiny Server
EXPOSE 3838

# Create startup script that sets environment variables for R
RUN echo '#!/bin/bash\n\
# Pass environment variables to R\n\
if [ ! -z "$FRED_API_KEY" ]; then\n\
  echo "FRED_API_KEY=$FRED_API_KEY" >> /usr/local/lib/R/etc/Renviron.site\n\
fi\n\
exec /usr/bin/shiny-server\n\
' > /start.sh && chmod +x /start.sh

# Run startup script
CMD ["/start.sh"]
