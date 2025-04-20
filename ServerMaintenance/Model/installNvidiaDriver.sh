dnf config-manager --set-enabled crb
dnf install epel-release -y
dnf upgrade

dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
rpm --import https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/D42D0685.pub
dnf module install nvidia-driver:open-dkim -y
# dnf install freeglut-devel libX11-devel libXi-devel libXmu-devel make mesa-libGLU-devel freeimage-devel
