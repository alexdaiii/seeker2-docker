FROM mambaorg/micromamba:debian12-slim AS builder

# switch back to root to install git
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential

USER mambauser

COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yml /tmp/environment.yml

RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

RUN git clone https://github.com/seekrcentral/seekr2.git \
    && cd seekr2 \
    && micromamba run -n base python -m pip install .

FROM rokdev/bddocker:latest AS runner

COPY --from=builder --chown=browndye:browndye /opt/conda /opt/conda

COPY --from=builder --chown=browndye:browndye /tmp/seekr2 /home/browndye/seekr2

RUN chown -R browndye:browndye /home/browndye

USER browndye

ENV PATH="/opt/conda/bin:${PATH}"

WORKDIR /home/browndye/seekr2/seekr2
