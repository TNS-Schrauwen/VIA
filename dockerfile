FROM mambaorg/micromamba:1.5.10-noble
COPY --chown=$MAMBA_USER:$MAMBA_USER conda.yml /tmp/conda.yml
RUN micromamba install -y -n base -f /tmp/conda.yml \
    && micromamba install -y -n base conda-forge::procps-ng \
    && micromamba env export --name base --explicit > environment.lock \
    && echo ">> CONDA_LOCK_START" \
    && cat environment.lock \
    && echo "<< CONDA_LOCK_END" \
    && micromamba clean -a -y
USER root
ENV PATH="$MAMBA_ROOT_PREFIX/bin:$PATH"

ENV HOME=/tmp
# ABOVE IS THE BASE AND NORMALLY YOU WOULD NOT CHANGE THIS

#ADD IF YOU ARE USING PYTHON OR R PACKAGES

# Create cache directories
RUN mkdir -p /tmp/cache/pip && \
    chmod -R 777 /tmp/cache

# Python caches
ENV PIP_CACHE_DIR=/tmp/cache/pip
ENV PYTHONUSERBASE=/tmp/cache/python
ENV PYTHONDONTWRITEBYTECODE=1

# ADD IF YOU ARE INCLUDING A SCRIPT
RUN mkdir -p /home/mambauser

COPY VIA /home/mambauser/VIA

# Custum wrapper
RUN echo '#!/bin/bash' > /usr/local/bin/VIA \
    && echo 'python /home/mambauser/VIA/main.py "$@"' >> /usr/local/bin/VIA \
    && chmod +x /usr/local/bin/VIA

CMD ["/bin/bash"]