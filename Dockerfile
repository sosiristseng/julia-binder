FROM jupyter/base-notebook:2023-05-08

# Julia
USER root
ENV JULIA_CI true
ENV JULIA_NUM_THREADS "auto"
ENV JULIA_CONDAPKG_BACKEND "Null"
ENV JULIA_DEPOT_PATH /srv/juliapkg/
RUN mkdir -p ${JULIA_DEPOT_PATH} && chown ${NB_UID}:${NB_UID} ${JULIA_DEPOT_PATH}
ENV JULIA_PATH /usr/local/julia/
ENV PATH ${JULIA_PATH}/bin:${PATH}
COPY --from=julia:1.9.0 ${JULIA_PATH} ${JULIA_PATH}

USER ${NB_UID}
COPY --chown=${NB_UID}:${NB_UID} Project.toml Manifest.toml ./
COPY --chown=${NB_UID}:${NB_UID} src/ src
RUN julia --color=yes --project="" -e 'import Pkg; Pkg.add("IJulia"); using IJulia; installkernel("Julia", "--project=@.")' &&\
    julia --color=yes --project=@. -e 'import Pkg; Pkg.instantiate(); Pkg.resolve(); Pkg.precompile()'
