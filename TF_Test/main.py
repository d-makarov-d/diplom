import os
import matplotlib.pyplot as plt
import numpy as np

import tensorflow as tf
import tensorflow.contrib.eager as tfe

from m_model import MModel


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


def loss(model, x, y):
    y_ = model.model(x)
    return tf.reduce_sum(tf.pow(tf.norm(y_) - tf.to_float(y), 2))


BATCH = 32

with open('train/train.csv') as f:
    l1 = f.readline()
    DATA_LINE_LENGTH = int(l1.split(' ')[0])

print("TensorFlow version: {}".format(tf.VERSION))
print("Eager execution: {}".format(tf.executing_eagerly()))

train_dataset = tf.data.TextLineDataset('train/train.csv')
train_dataset = train_dataset.skip(1)  # skip the first header row
train_dataset = train_dataset.map(parse_csv)  # parse each row
train_dataset = train_dataset.shuffle(buffer_size=1000)  # randomize
train_dataset = train_dataset.batch(BATCH)

model = MModel(DATA_LINE_LENGTH, BATCH)

optimizer = tf.train.GradientDescentOptimizer(learning_rate=0.01)

sess = tf.Session()
sess.run(tf.global_variables_initializer())

train_loss_results = []
train_accuracy_results = []
for i in range(100):
    sess.run(tf.global_variables_initializer())
    epoch_loss_avg = tfe.metrics.Mean()
    epoch_accuracy = tfe.metrics.Accuracy()
    a = train_dataset.make_one_shot_iterator().get_next()
    x = a[0]
    y = a[1]

    sess.run(optimizer.minimize(loss(model, x, y)))

    epoch_loss_avg(loss(model.model, x, y))  # add current batch loss
    epoch_accuracy(tf.argmax(model.model(x), axis=1, output_type=tf.int32), y)
    train_loss_results.append(epoch_loss_avg.result())
    train_accuracy_results.append(epoch_accuracy.result())
    if i % 10 == 0:
        print("Epoch {:03d}: Loss: {:.3f}, Accuracy: {:.3%}".format(i,
                                                                    epoch_loss_avg.result(),
                                                                    epoch_accuracy.result()))

[fig, axes] = plt.subplots(2, sharex=True, figsize=(12, 8))
fig.suptitle('Training Metrics')

axes[0].set_ylabel("Loss", fontsize=14)
axes[0].plot(train_loss_results)

axes[1].set_ylabel("Accuracy", fontsize=14)
axes[1].set_xlabel("Epoch", fontsize=14)
axes[1].plot(train_accuracy_results)

fig1 = plt.figure(figsize=(3, 3))
ax = fig1.add_subplot(111)
ax.plot(model.get_ans())

plt.show()
