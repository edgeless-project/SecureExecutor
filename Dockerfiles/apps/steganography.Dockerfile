FROM secureexecutor-app-base:ubuntu

# Download app and preparation
RUN git clone https://github.com/7thSamurai/steganography.git
WORKDIR steganography/
RUN mkdir build

# Build
WORKDIR build
RUN cmake -DCMAKE_BUILD_TYPE=Release ..
RUN make -j 4

# Run
CMD ./steganography encode -i ../data/orig.png -e ../data/jekyll_and_hyde.zip -o output.png