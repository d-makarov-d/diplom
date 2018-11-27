import tensorflow as tf
import matplotlib.pyplot as plt
import random as rnd
import numpy as np


def parse_csv(line):
    global DATA_LINE_LENGTH
    # sets field types
    example_defaults = (DATA_LINE_LENGTH + 1)*[[0.]]
    example_defaults[DATA_LINE_LENGTH] = [0]
    parsed_line = tf.decode_csv(line, example_defaults)
    # First 4 fields are features, combine into single tensor
    features = tf.reshape(parsed_line[:-1], shape=(DATA_LINE_LENGTH,))
    # Last field is the label
    label = tf.reshape(parsed_line[-1], shape=())
    return [features, label]


with open('train/train.csv') as f:
    l1 = f.readline()
    DATA_LINE_LENGTH = int(l1.split(' ')[0])
train_dataset = tf.data.TextLineDataset('train/train.csv')
train_dataset = train_dataset.skip(1)  # skip the first header row
train_dataset = train_dataset.map(parse_csv)  # parse each row
train_dataset = train_dataset.shuffle(buffer_size=1000)  # randomize
train_dataset = train_dataset.batch(32)

variable = tf.Variable(DATA_LINE_LENGTH*[0.5], dtype=tf.float32, name="variable")
x = tf.placeholder(tf.float32, [None, DATA_LINE_LENGTH], "data")
y_ = tf.placeholder(tf.int32, None, "label")
#y = tf.norm(tf.abs(tf.ifft( tf.complex(tf.abs(tf.multiply(tf.fft(tf.complex(x / tf.norm(x), 0.)), tf.complex(variable, 0.))), 0.)) ))
y = tf.norm(tf.abs(tf.ifft(tf.multiply(tf.fft(tf.complex(x / tf.norm(x), 0.)), tf.complex(variable, 0.)))))
loss = tf.reduce_mean(tf.pow(tf.pow(y, 2) - tf.to_float(y_), 2))
#loss = tf.reduce_sum(tf.pow(tf.reduce_mean(y) - tf.to_float(y_), 2))
x1 = tf.placeholder(tf.float32, shape=(1251,))
y1 = tf.norm(tf.abs(tf.ifft(tf.multiply(tf.fft(tf.complex(x1 / tf.norm(x1), 0.)), tf.complex(variable, 0.)))))
#y1 = tf.norm(tf.abs(tf.ifft( tf.complex(tf.abs(tf.multiply(tf.fft(tf.complex(x1 / tf.norm(x1), 0.)), tf.complex(variable, 0.))), 0.)) ))

epoch = 300
losses = epoch*[0]

sess = tf.Session()
sess.run(tf.global_variables_initializer())
[X, Y_] = sess.run(train_dataset.make_one_shot_iterator().get_next())
test_batch = 32*[None]
for i in range(32):
    test_batch[i] = [X[i], Y_[i], rnd.random()]

fig00 = plt.figure(figsize=(3, 3))
ax = fig00.add_subplot(111)
for k in range(32):
    if test_batch[k][1] == 0:
        ax.plot(sess.run(y1, feed_dict={x1: test_batch[k][0], y_: test_batch[k][1]}), test_batch[k][2], 'go')
    else:
        ax.plot(sess.run(y1, feed_dict={x1: test_batch[k][0], y_: test_batch[k][1]}), test_batch[k][2], 'r+')


for i in range(epoch):
    [X, Y_] = sess.run(train_dataset.make_one_shot_iterator().get_next())
    sess.run(tf.train.GradientDescentOptimizer(1).minimize(loss), feed_dict={x: X, y_: Y_})
    losses[i] = sess.run(loss, feed_dict={x: X, y_: Y_})
    print("Loss: {}, Epoch: {}".format(losses[i], i))

f = open('var.dta', 'w')
var = sess.run(variable)
for i in range(len(var)):
    f.write('{}|'.format(var[i]))
f.close()

fig0 = plt.figure(figsize=(3, 3))
ax = fig0.add_subplot(111)

for k in range(32):
    if test_batch[k][1] == 0:
        ax.plot(sess.run(y1, feed_dict={x1: test_batch[k][0], y_: test_batch[k][1]}), test_batch[k][2], 'go')
    else:
        ax.plot(sess.run(y1, feed_dict={x1: test_batch[k][0], y_: test_batch[k][1]}), test_batch[k][2], 'r+')

fig1 = plt.figure(figsize=(3, 3))
ax = fig1.add_subplot(111)
ax.plot(losses)

fig2 = plt.figure(figsize=(3, 3))
ax = fig2.add_subplot(111)
ax.plot(sess.run(variable))

plt.show()