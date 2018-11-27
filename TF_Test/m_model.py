import tensorflow as tf
import numpy as np


class MModel:

    def __init__(self, n, b):
        self.variable = tf.Variable(n*[1.], dtype=tf.complex64)
        self.x = tf.placeholder(tf.complex64, shape=(None, n))

    def model(self, inp):
        self.x = tf.complex(inp, 0.)
        self.x = self.x/tf.norm(self.x)
        self.x = tf.fft(self.x)
        tf.multiply(self.x, self.variable)
        self.x = tf.ifft(self.x)
        return tf.abs(self.x)

    def get_ans(self):
        y = np.ndarray((len(self.variable),), float)
        for i in range(0, len(self.variable)):
            y[i] = tf.to_float(self.variable[i])
        return y
