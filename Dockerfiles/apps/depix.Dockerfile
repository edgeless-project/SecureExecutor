FROM secureexecutor-app-base:python3

RUN pip install pillow==10.2.0

RUN git clone https://github.com/spipm/Depix
WORKDIR Depix
# Tested on this commit
RUN git checkout ccda29bfba7715bc03368964463dfb7ba9d8bce6

CMD python3 depix.py \
        -p images/testimages/testimage3_pixels.png \
        -s images/searchimages/debruinseq_notepad_Windows10_closeAndSpaced.png