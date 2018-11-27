import tensorflow as tf
import matplotlib.pyplot as plt


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

variable = tf.Variable(DATA_LINE_LENGTH*[1.], dtype=tf.float32, name="variable")

#loss = tf.reduce_sum(tf.pow(tf.pow(tf.norm(y), 2) - y_, 2))


epoch = 100
losses = epoch*[0]

sess = tf.Session()
sess.run(tf.global_variables_initializer())
for i in range(epoch):
    [X, Y_] = train_dataset.make_one_shot_iterator().get_next()
    loss = tf.placeholder_with_default(0., shape=None)
    for k in range(32):
        x = X[k]
        y_ = Y_[k]
        y = tf.abs(tf.ifft(tf.multiply(tf.fft(tf.complex(x / tf.norm(x), 0.)), tf.complex(variable, 0.))))
        #loss = loss + tf.pow(tf.reduce_mean(y) - tf.to_float(y_), 2)
        loss = loss + tf.reduce_sum(tf.pow(tf.pow(tf.norm(y), 2) - tf.to_float(y_), 2))
    print("Loss: {}, Epoch: {}".format(sess.run(loss)/32, i))
    sess.run(tf.train.GradientDescentOptimizer(0.1).minimize(loss))
    losses[i] = sess.run(loss)

fig1 = plt.figure(figsize=(3, 3))
ax = fig1.add_subplot(111)
ax.plot(losses)

fig2 = plt.figure(figsize=(3, 3))
ax = fig2.add_subplot(111)
ax.plot(sess.run(variable))

plt.show()
