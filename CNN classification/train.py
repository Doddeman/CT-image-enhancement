from __future__ import print_function
import tensorflow as tf
import os
from sklearn.model_selection import train_test_split

#just ignore  warning that AVX2 is not used
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

#print ("hello der")
print (os.getcwd())
DATASET_PATH = 'samples_train' # the dataset file or root folder path.

# Image Parameters
N_CLASSES = 2 # total number of classes
IMG_HEIGHT = 256 # the image height to be resized to
IMG_WIDTH = 256 # the image width to be resized to
CHANNELS = 1 # color channels

# Reading the dataset
def read_images(dataset_path, batch_size):
	imagepaths = list()
	labels = list()
	# An ID will be affected to each sub-folders by alphabetical order
	label = 0
	# List the directory
	try:  # Python 2
		classes = sorted(os.walk(dataset_path).next()[1])
	except Exception:  # Python 3
		classes = sorted(os.walk(dataset_path).__next__()[1])
	# List each sub-directory (the classes)
	for c in classes:
		c_dir = os.path.join(dataset_path, c)
		try:  # Python 
			walk = next(os.walk(c_dir)) #.next()
		except Exception:  # Python 3
			walk = os.walk(c_dir).__next__()
		# Add each image to the training set
		for sample in walk[2]:
		# Only keeps png images
			if sample.endswith('.png'):
				#print(sample)
				imagepaths.append(os.path.join(c_dir, sample))
				labels.append(label)
		label += 1

	#X_train, X_test, y_train, y_test = train_test_split(
	#									imagepaths,labels,
	#									test_size=0.2,random_state=101
	#									)

	# Convert to Tensor
	X_train = tf.convert_to_tensor(imagepaths, dtype=tf.string)
	y_train = tf.convert_to_tensor(labels, dtype=tf.int32)

	# Build a TF Queue, shuffle data
	image, label = tf.train.slice_input_producer([X_train, y_train],
	                                             shuffle=True)

	#print ("shape",image.shape)
	# Read images from disk
	image = tf.read_file(image)
	#print (image.shape)
	image = tf.image.decode_png(image, channels=CHANNELS)
	#print (image.shape)

	# Resize images to a common size
	image = tf.image.resize_images(image, [IMG_HEIGHT, IMG_WIDTH])
	#print (image.shape)

	# Normalize
	image = image * 1.0/127.5 - 1.0
	#print (image)

	# Create batches
	X, Y = tf.train.batch([image, label], batch_size=batch_size, capacity=batch_size * 8, num_threads=4)
	return X, Y

# Parameters
learning_rate = 0.01
num_steps = 100
batch_size = 4
display_step = 1
dropout = 0.65 # probability to keep units

# Build the data input
X, Y = read_images(DATASET_PATH, batch_size)
#print("x:", X)
#print("y:", Y)

#print(X.shape)

# Create model
def conv_net(x, n_classes, dropout, reuse, is_training):
    # Define a scope for reusing the variables
    with tf.variable_scope('ConvNet', reuse=reuse):

        # Convolution Layer with 32 filters and a kernel size of 5
        conv1 = tf.layers.conv2d(x, 32, 5, activation=tf.nn.relu)
        # Max Pooling (down-sampling) with strides of 2 and kernel size of 2
        conv1 = tf.layers.max_pooling2d(conv1, 2, 2)

        # Convolution Layer with 32 filters and a kernel size of 5
        conv2 = tf.layers.conv2d(conv1, 64, 3, activation=tf.nn.relu)
        # Max Pooling (down-sampling) with strides of 2 and kernel size of 2
        conv2 = tf.layers.max_pooling2d(conv2, 2, 2)

        # Flatten the data to a 1-D vector for the fully connected layer
        fc1 = tf.contrib.layers.flatten(conv2)

        # Fully connected layer (in contrib folder for now)
        fc1 = tf.layers.dense(fc1, 1024)
        # Apply Dropout (if is_training is False, dropout is not applied)
        fc1 = tf.layers.dropout(fc1, rate=dropout, training=is_training)

        # Output layer, class prediction
        out = tf.layers.dense(fc1, n_classes)
        #print("out1:",out.name)
        # Because 'softmax_cross_entropy_with_logits' already apply softmax,
        # we only apply softmax to testing network
        out = tf.nn.softmax(out) if not is_training else out

    return out

# Create a graph for training	
logits_train = conv_net(X, N_CLASSES, dropout, reuse=False, is_training=True)
# Create another graph for testing that reuse the same weights
logits_test = conv_net(X, N_CLASSES, dropout, reuse=True, is_training=False)

# Define loss and optimizer (with train logits, for dropout to take effect)
loss_op = tf.reduce_mean(tf.nn.sparse_softmax_cross_entropy_with_logits(
    logits=logits_train, labels=Y))

tf.summary.scalar("Cost", loss_op) #for tensorboard visualisation

optimizer = tf.train.AdamOptimizer(learning_rate=learning_rate)
train_op = optimizer.minimize(loss_op)

# Evaluate model (with test logits, for dropout to be disabled)
correct_pred = tf.equal(tf.argmax(logits_test, 1), tf.cast(Y, tf.int64))
accuracy = tf.reduce_mean(tf.cast(correct_pred, tf.float32))

tf.summary.scalar("Accuracy", accuracy) #for tensorboard visualisation

# Initialize the variables (i.e. assign their default value)
init = tf.global_variables_initializer()

#Tensorboard
merged = tf.summary.merge_all()
writer = tf.summary.FileWriter('tensorboard', graph=tf.get_default_graph())
# Saver object
saver = tf.train.Saver()

# Start training
#with tf.Session(config=tf.ConfigProto(log_device_placement=True)) as sess:
with tf.Session() as sess:

	# Run the initializer
	sess.run(init)

	# Start the data queue
	tf.train.start_queue_runners()

	# Training cycle
	for step in range(1, num_steps+1):
		if step % display_step == 0:
			# Run optimization and calculate batch loss and accuracy
			summary, _, loss, acc = sess.run([merged, train_op, loss_op, accuracy])
			writer.add_summary(summary, step)
			print("Step " + str(step) + ", Minibatch Loss= " + \
				"{:.4f}".format(loss) + ", Training Accuracy= " + \
				"{:.3f}".format(acc))
		else:
			# Only run the optimization op (backprop)
			summary,_ = sess.run([merged, train_op])
			writer.add_summary(summary, step)

	print("Optimization Finished!")
	save_path = saver.save(sess, "tmp/model.ckpt")
	print("Model saved in path: %s" % save_path)