
FROM gitlab/gitlab-ce:10.8.1-ce.0


VOLUME ["/app/gitlab/data"]


RUN set -ex \
    && echo 'tzdata tzdata/Areas select Asia\n\
tzdata tzdata/Zones/Asia select Shanghai\n\n\
locales locales/locales_to_be_generated    multiselect en_US.UTF-8 UTF-8\n\
locales locales/default_environment_locale select      en_US.UTF-8\n' > /etc/debconf.txt \
    && sed -i "s/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/${IMAGE_ARG_APT_MIRROR:-archive.ubuntu.com}\/ubuntu\//g" /etc/apt/sources.list \
    && apt-get -y update \
    && apt-get -yq install --reinstall locales tzdata debconf \
    && debconf-set-selections /etc/debconf.txt \
    && echo "Asia/Shanghai" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && dpkg-reconfigure -f noninteractive locales \
#    && apt-get -y upgrade \
    && apt-get -y install apt-transport-https aria2 build-essential ca-certificates curl httpie jq nano net-tools python python-pip unzip vim wget \
    && apt-get -q -y autoremove \
    && apt-get -q -y clean && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8


COPY --from=cirepo/waitforit:2.2.0-archive /data/root /


COPY docker /
RUN chmod 755 /app/gitlab/*.sh


ENTRYPOINT ["/app/gitlab/entrypoint.sh"]
CMD ["/assets/wrapper"]
