import argparse
import os
import tensorflow as tf
tf.set_random_seed(19)
from model import cyclegan

parser = argparse.ArgumentParser(description='')
parser.add_argument('--dataset_dir', dest='dataset_dir', default='artifacts', help='path of the dataset')
parser.add_argument('--epoch', dest='epoch', type=int, default=80, help='# of epochs')
#Hyperparameter
parser.add_argument('--epoch_step', dest='epoch_step', type=int, default=100, help='# of epoch to decay lr')
#Hyperparameter
parser.add_argument('--batch_size', dest='batch_size', type=int, default=8, help='# images in batch')
#parser.add_argument('--train_size', dest='train_size', type=int, default=40, help='# images used to train')
parser.add_argument('--train_size', dest='train_size', type=int, default=1e8, help='# images used to train')
#Change to save RAM?
parser.add_argument('--load_size', dest='load_size', type=int, default=286, help='scale images to this size')
parser.add_argument('--fine_size', dest='fine_size', type=int, default=256, help='then crop to this size')
#Hyperparameter. can be decreased to save RAM
parser.add_argument('--ngf', dest='ngf', type=int, default=64, help='# of gen filters in first conv layer')
#Hyperparameter. can be decreased to save RAM
parser.add_argument('--ndf', dest='ndf', type=int, default=64, help='# of discri filters in first conv layer')
parser.add_argument('--input_nc', dest='input_nc', type=int, default=1, help='# of input image channels')
parser.add_argument('--output_nc', dest='output_nc', type=int, default=1, help='# of output image channels')
#Hyperparameter. Recommended initial learning rate (alpha) for adam is 0.001
parser.add_argument('--lr', dest='lr', type=float, default=0.0002, help='initial learning rate for adam')
#Hyperparameter. Recommended beta1 for adam is 0.9
parser.add_argument('--beta1', dest='beta1', type=float, default=0.5, help='momentum term of adam')
parser.add_argument('--which_direction', dest='which_direction', default='AtoB', help='AtoB or BtoA')
parser.add_argument('--phase', dest='phase', default='train', help='train, test')
#save_freq should be training data set size divided by batch size
#parser.add_argument('--save_freq', dest='save_freq', type=int, default=4098, help='save a model every save_freq iterations')
parser.add_argument('--print_freq', dest='print_freq', type=int, default=10, help='print the debug information every print_freq iterations')
parser.add_argument('--continue_train', dest='continue_train', type=bool, default=False, help='if continue training, load the latest model: 1: true, 0: false')
parser.add_argument('--checkpoint_dir', dest='checkpoint_dir', default='./checkpoint', help='models are saved here')
#get that checkpoint
parser.add_argument('--checkpoint', dest='checkpoint', type=int, default=-1, help='which checkpoint to test')
parser.add_argument('--sample_dir', dest='sample_dir', default='./sample', help='sample are saved here')
parser.add_argument('--test_dir', dest='test_dir', default='./test_artifacts', help='test sample are saved here')
#parser.add_argument('--test_dir', dest='test_dir', default='./test_128(256)', help='test sample are saved here')
#Hyperparameter
parser.add_argument('--L1_lambda', dest='L1_lambda', type=float, default=10.0, help='weight on L1 term in objective')
parser.add_argument('--use_resnet', dest='use_resnet', type=bool, default=True, help='generation network using reidule block')
parser.add_argument('--use_lsgan', dest='use_lsgan', type=bool, default=True, help='gan loss defined in lsgan')
parser.add_argument('--max_size', dest='max_size', type=int, default=50, help='max size of image pool, 0 means do not use image pool')

args = parser.parse_args()


def main(_):
    if not os.path.exists(args.checkpoint_dir):
        os.makedirs(args.checkpoint_dir)
    if not os.path.exists(args.sample_dir):
        os.makedirs(args.sample_dir)
    if not os.path.exists(args.test_dir):
        os.makedirs(args.test_dir)

    tfconfig = tf.ConfigProto(allow_soft_placement=True)
    tfconfig.gpu_options.allow_growth = True
    with tf.Session(config=tfconfig) as sess:
        model = cyclegan(sess, args)
        model.train(args) if args.phase == 'train' \
            else model.test(args)

if __name__ == '__main__':
    tf.app.run()
