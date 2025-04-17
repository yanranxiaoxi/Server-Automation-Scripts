dnf config-manager --set-enabled crb
dnf makecache
dnf -y install epel-release
dnf upgrade
dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
dnf makecache
dnf module install nvidia-driver:latest
dnf install freeglut-devel libX11-devel libXi-devel libXmu-devel make mesa-libGLU-devel freeimage-devel