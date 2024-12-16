FROM secureexecutor-app-base:python3

RUN pip install --no-cache-dir pillow==10.2.0

WORKDIR /app
RUN git clone https://github.com/spipm/Depix
WORKDIR /app/Depix
# Tested on this commit
RUN git checkout ccda29bfba7715bc03368964463dfb7ba9d8bce6

CMD ["python3", "depix.py", "-p", "images/testimages/testimage3_pixels.png", "-s", "images/searchimages/debruinseq_notepad_Windows10_closeAndSpaced.png"]