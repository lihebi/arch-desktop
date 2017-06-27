FROM base/archlinux

ENV PACMAN_OPTIONS="--noconfirm --needed"
RUN pacman $PACMAN_OPTIONS -Syu

##############################
# basic tools
##############################
RUN pacman $PACMAN_OPTIONS -S base-devel
RUN pacman $PACMAN_OPTIONS -S git unzip ntfs-3g
RUN pacman $PACMAN_OPTIONS -S man
# for mkfs.vfat
RUN pacman $PACMAN_OPTIONS -S dosfstools

# shell utilities
RUN pacman $PACMAN_OPTIONS -S mlocate tmux bash-completion ctags doxygen the_silver_searcher curl ispell cloc svn openssh
RUN pacman $PACMAN_OPTIONS -S spice

# scripts
RUN pacman $PACMAN_OPTIONS -S python python2
RUN pacman $PACMAN_OPTIONS -S python-pip ipython r ruby

##############################
# libraries
##############################
RUN pacman $PACMAN_OPTIONS -S clang llvm clang-tools-extra
RUN pacman $PACMAN_OPTIONS -S pugixml gtest rapidjson boost

RUN pacman $PACMAN_OPTIONS -S libxslt

##############################
# apps
##############################
RUN pacman $PACMAN_OPTIONS -S docker
RUN pacman $PACMAN_OPTIONS -S emacs
# the command is remove-viewer
RUN pacman $PACMAN_OPTIONS -S tigervnc
RUN pacman $PACMAN_OPTIONS -S virt-viewer
RUN pacman $PACMAN_OPTIONS -S feh tidy mplayer youtube-dl markdown

# compile utilities
RUN pacman $PACMAN_OPTIONS -S cmake ninja antlr2 gperftools valgrind
RUN pacman $PACMAN_OPTIONS -S gradle
RUN pacman $PACMAN_OPTIONS -S clojure
# need to install at least a font so that the png file can be outputed
RUN pacman $PACMAN_OPTIONS -S graphviz ttf-dejavu

##############################
# xorg
##############################
RUN pacman $PACMAN_OPTIONS -S xterm xorg-server xorg-xinit rxvt-unicode xorg-xinput xorg-xdm xorg-xconsole
RUN pacman $PACMAN_OPTIONS -S lxde openbox x11vnc xfce4 xorg-xclock
# display managers
RUN pacman $PACMAN_OPTIONS -S lxdm xorg-xdm lightdm gdm xorg-twm


##############################
# AUR
##############################
# aur packages must be built using non-root
# create admin account
RUN useradd -m admin
RUN echo "admin ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/admin && chmod 0440 /etc/sudoers.d/admin
USER admin
WORKDIR /home/admin
RUN git clone https://aur.archlinux.org/cl-ppcre && cd cl-ppcre && makepkg -si --noconfirm
RUN git clone https://aur.archlinux.org/clx-git && cd clx-git && makepkg -si --noconfirm
RUN git clone https://aur.archlinux.org/stumpwm && cd stumpwm && echo "md5sums=('SKIP' 'SKIP')" >> PKGBUILD && makepkg -si --noconfirm
RUN git clone https://aur.archlinux.org/quicklisp && cd quicklisp && makepkg -si --noconfirm
# RUN git clone https://aur.archlinux.org/rtags-git && cd rtags-git && makepkg -si --noconfirm
# RUN git clone https://aur.archlinux.org/plantuml && cd plantuml && makepkg -si --noconfirm

RUN rm -r cl-ppcre clx-git stumpwm quicklisp

USER root

RUN useradd -m user && echo "user:user" | chpasswd
RUN echo "user ALL=(ALL) ALL" > /etc/sudoers.d/user && chmod 0440 /etc/sudoers.d/user


USER user
WORKDIR /home/user/
# config files
RUN git clone https://github.com/lihebi/stumpwm.d .stumpwm.d

# copy files
COPY xinitrc.d .xinitrc.d
COPY ./startup.sh /usr/bin/startup.sh
# RUN echo -e "#/bin/sh\nexec stumpwm" > .xinitrc && chmod +x .xinitrc

# RUN vncserver
RUN mkdir -p ~/.vnc && echo "vncpasswd" | vncpasswd -f > ~/.vnc/passwd && chmod 0600 ~/.vnc/passwd

# use -P to publish all exposed port
# docker run -d -p 5901:5901 -p 5902:5902 lihebi/hebi-arch
# use C-] C-[ to detach, do not exit the container
# use docker attach <name> to attach
# docker exec <name> bash cannot run sudo command
EXPOSE 5901
EXPOSE 5902

# RUN vncserver -xstartup ~/.xinitrc
ENTRYPOINT ["/usr/bin/startup.sh"]
# CMD ["vncserver", "-xstartup", "~/.xinitrc", "&&", "/bin/bash"]
# CMD echo "hello"



##############################
# optional
##############################
# RUN pacman -S texlive-core texlive-most 

# vncpasswd
# vncserver

# add user
# RUN useradd -ms /bin/bash admin
# USER admin
# WORKDIR /home/admin

# CMD vncserver :1

# WORKDIR /root
# need manually perform this because it needs password
# RUN git clone https://github.com/lihebi/helium
