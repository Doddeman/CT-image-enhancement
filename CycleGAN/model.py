from __future__ import division
import os
import time
from glob import glob
import tensorflow as tf
import numpy as np
from collections import namedtuple
from module import *
from utils import *
from shutil import copyfile
from skimage.transform import resize

class cyclegan(object):
    def __init__(self, sess, args):
        self.sess = sess
        self.batch_size = args.batch_size
        self.image_size = args.fine_size
        self.input_c_dim = args.input_nc
        self.output_c_dim = args.output_nc
        self.L1_lambda = args.L1_lambda
        self.dataset_dir = args.dataset_dir

        self.discriminator = discriminator
        if args.use_resnet:
            self.generator = generator_resnet
        else:
            self.generator = generator_unet
        if args.use_lsgan:
            self.criterionGAN = mae_criterion
        else:
            self.criterionGAN = sce_criterion

        OPTIONS = namedtuple('OPTIONS', 'batch_size image_size \
                              gf_dim df_dim output_c_dim is_training')
        self.options = OPTIONS._make((args.batch_size, args.fine_size,
                                      args.ngf, args.ndf, args.output_nc,
                                      args.phase == 'train'))

        self._build_model()
        self.saver = tf.train.Saver(max_to_keep=None) #keeps all
        self.pool = ImagePool(args.max_size)

    def _build_model(self):
        print("Building model")
        self.real_data = tf.placeholder(tf.float32,
                                        [None, self.image_size, self.image_size,
                                         self.input_c_dim + self.output_c_dim],
                                        name='real_A_and_B_images')

        self.real_A = self.real_data[:, :, :, :self.input_c_dim]
        self.real_B = self.real_data[:, :, :, self.input_c_dim:self.input_c_dim + self.output_c_dim]

        #real_A -> generatorA2B -> fake_B
        self.fake_B = self.generator(self.real_A, self.options, False, name="generatorA2B")
        #fake_B -> generatorB2A -> fake_A_
        self.fake_A_ = self.generator(self.fake_B, self.options, False, name="generatorB2A")
        #real_B -> generatorB2A -> fake_A
        self.fake_A = self.generator(self.real_B, self.options, True, name="generatorB2A")
        #fake_A -> generatorA2B -> fake_B_
        self.fake_B_ = self.generator(self.fake_A, self.options, True, name="generatorA2B")

        #discriminatorB
        self.DB_fake = self.discriminator(self.fake_B, self.options, reuse=False, name="discriminatorB")
        #discriminatorA
        self.DA_fake = self.discriminator(self.fake_A, self.options, reuse=False, name="discriminatorA")

        #generatorA2B loss = mse(DB_fake) + abs(real_A-fake_A_) + abs(real_B-fake_B_)
        self.g_loss_a2b = self.criterionGAN(self.DB_fake, tf.ones_like(self.DB_fake)) \
            + self.L1_lambda * abs_criterion(self.real_A, self.fake_A_) \
            + self.L1_lambda * abs_criterion(self.real_B, self.fake_B_)
        #generatorB2A loss = mse(DA_fake) + abs(real_A-fake_A_) + abs(real_B-fake_B_)
        self.g_loss_b2a = self.criterionGAN(self.DA_fake, tf.ones_like(self.DA_fake)) \
            + self.L1_lambda * abs_criterion(self.real_A, self.fake_A_) \
            + self.L1_lambda * abs_criterion(self.real_B, self.fake_B_)
        #generator loss = mse(DA_fake) + mse(DB_fake) + abs(real_A-fake_A_) + abs(real_B-fake_B_)
        self.g_loss = self.criterionGAN(self.DA_fake, tf.ones_like(self.DA_fake)) \
            + self.criterionGAN(self.DB_fake, tf.ones_like(self.DB_fake)) \
            + self.L1_lambda * abs_criterion(self.real_A, self.fake_A_) \
            + self.L1_lambda * abs_criterion(self.real_B, self.fake_B_)

        #fake_A_sample
        self.fake_A_sample = tf.placeholder(tf.float32,
                                            [None, self.image_size, self.image_size,
                                             self.input_c_dim], name='fake_A_sample')
        #fake_B_sample
        self.fake_B_sample = tf.placeholder(tf.float32,
                                            [None, self.image_size, self.image_size,
                                             self.output_c_dim], name='fake_B_sample')

        self.snr = tf.placeholder(tf.float32, [None])
        self.cnr = tf.placeholder(tf.float32, [None])

        #real_B -> DB -> DB_real
        self.DB_real = self.discriminator(self.real_B, self.options, reuse=True, name="discriminatorB")
        #real_A -> DA -> DA_real
        self.DA_real = self.discriminator(self.real_A, self.options, reuse=True, name="discriminatorA")
        #fake_B_sample -> DB -> DB_fake_sample
        self.DB_fake_sample = self.discriminator(self.fake_B_sample, self.options, reuse=True, name="discriminatorB")
        #fake_A_sample -> DA -> DA_fake_sample
        self.DA_fake_sample = self.discriminator(self.fake_A_sample, self.options, reuse=True, name="discriminatorA")

        #DB_loss_real = mse(DB_real)
        self.db_loss_real = self.criterionGAN(self.DB_real, tf.ones_like(self.DB_real))
        #DB_loss_fake = mse(DB_fake_sample). This loss should probably include SNR & CNR
        self.db_loss_fake = self.criterionGAN(self.DB_fake_sample, tf.zeros_like(self.DB_fake_sample), \
            DB_fake=True, snr=self.snr, cnr=self.cnr)
        #Average DB loss = (real+fake)/2
        self.db_loss = (self.db_loss_real + self.db_loss_fake) / 2
        #DA_loss_real = mse(DA_real)
        self.da_loss_real = self.criterionGAN(self.DA_real, tf.ones_like(self.DA_real))
        #DA_loss_fake = mse(DA_fake_sample)
        self.da_loss_fake = self.criterionGAN(self.DA_fake_sample, tf.zeros_like(self.DA_fake_sample))
        #Average DB loss = (real+fake)/2
        self.da_loss = (self.da_loss_real + self.da_loss_fake) / 2
        #Total D loss = DA loss + DB loss
        self.d_loss = self.da_loss + self.db_loss

        #only for tensorboard
        self.g_loss_a2b_sum = tf.summary.scalar("g_loss_a2b", self.g_loss_a2b)
        self.g_loss_b2a_sum = tf.summary.scalar("g_loss_b2a", self.g_loss_b2a)
        self.g_loss_sum = tf.summary.scalar("g_loss", self.g_loss)
        self.g_sum = tf.summary.merge([self.g_loss_sum])

        self.db_loss_sum = tf.summary.scalar("db_loss", self.db_loss)
        self.da_loss_sum = tf.summary.scalar("da_loss", self.da_loss)
        self.d_loss_sum = tf.summary.scalar("d_loss", self.d_loss)
        self.db_loss_real_sum = tf.summary.scalar("db_loss_real", self.db_loss_real)
        self.db_loss_fake_sum = tf.summary.scalar("db_loss_fake", self.db_loss_fake)
        self.da_loss_real_sum = tf.summary.scalar("da_loss_real", self.da_loss_real)
        self.da_loss_fake_sum = tf.summary.scalar("da_loss_fake", self.da_loss_fake)

        self.snr_gain = tf.summary.scalar("snr", self.snr)
        self.cnr_gain = tf.summary.scalar("cnr", self.cnr)

        self.d_sum = tf.summary.merge(
            [self.d_loss_sum,self.db_loss_fake_sum,self.snr_gain,self.cnr_gain,
            self.d_loss_sum, self.db_loss_fake_sum, self.db_loss_real_sum]
        )

        self.test_A = tf.placeholder(tf.float32,
                                     [None, self.image_size, self.image_size,
                                      self.input_c_dim], name='test_A')
        self.test_B = tf.placeholder(tf.float32,
                                     [None, self.image_size, self.image_size,
                                      self.output_c_dim], name='test_B')
        self.testB = self.generator(self.test_A, self.options, True, name="generatorA2B")
        self.testA = self.generator(self.test_B, self.options, True, name="generatorB2A")

        t_vars = tf.trainable_variables()
        self.d_vars = [var for var in t_vars if 'discriminator' in var.name]
        self.g_vars = [var for var in t_vars if 'generator' in var.name]

    def train(self, args):
        """Train cyclegan"""
        self.lr = tf.placeholder(tf.float32, None, name='learning_rate')
        self.d_optim = tf.train.AdamOptimizer(self.lr, beta1=args.beta1) \
            .minimize(self.d_loss, var_list=self.d_vars)
        self.g_optim = tf.train.AdamOptimizer(self.lr, beta1=args.beta1) \
            .minimize(self.g_loss, var_list=self.g_vars)

        init_op = tf.global_variables_initializer()
        self.sess.run(init_op)
        #Change this folder for tensorboard events
        self.writer = tf.summary.FileWriter("./events/snr_test", self.sess.graph)

        ###### Only for locating continued counters #######
        dataA = glob('./datasets/{}/*.png*'.format(self.dataset_dir + '/trainA'))
        dataB = glob('./datasets/{}/*.png*'.format(self.dataset_dir + '/trainB'))
        tr_size = min(min(len(dataA), len(dataB)), args.train_size) // self.batch_size

        if args.continue_train:
            load = self.load(args.checkpoint_dir, test=False)
            if load[0] == True:
                print(" [*] Load SUCCESS")
                init_epoch = int(load[1]) + 1 #iniate training at checkpoint epoch
                counter = init_epoch*tr_size
                batch_counter = init_epoch*tr_size*args.batch_size
            else:
                print(" [!] Load failed...")
                return
        else:
            init_epoch = 0
            counter = 1
            batch_counter = 0

        start_time = time.time()

        for epoch in range(init_epoch, args.epoch):
            dataA = glob('./datasets/{}/*.png*'.format(self.dataset_dir + '/trainA'))
            dataB = glob('./datasets/{}/*.png*'.format(self.dataset_dir + '/trainB'))
            np.random.shuffle(dataA)
            np.random.shuffle(dataB)
            batch_idxs = min(min(len(dataA), len(dataB)), args.train_size) // self.batch_size
            lr = args.lr if epoch < args.epoch_step else args.lr*(args.epoch-epoch)/(args.epoch-args.epoch_step)

            for idx in range(0, batch_idxs):
                batch_files = list(zip(dataA[idx * self.batch_size:(idx + 1) * self.batch_size],
                                       dataB[idx * self.batch_size:(idx + 1) * self.batch_size]))

                batch_images = []
                flipped = []
                for batch_file in batch_files:
                    AB_image, flip = load_train_data(batch_file, args.load_size, args.fine_size, args.input_nc, args.output_nc)
                    batch_images.append(AB_image)
                    flipped.append(flip)

                #batch_images = [load_train_data(batch_file, args.load_size, args.fine_size, args.input_nc, args.output_nc) \
                #for batch_file in batch_files]
                batch_images = np.array(batch_images).astype(np.float32)


                print ("bt", len(batch_images))
                print ("flipt", flipped)

                # Update G network and record fake outputs
                fake_A, fake_B, _, summary_str, g_loss = self.sess.run(
                    [self.fake_A, self.fake_B, self.g_optim, self.g_sum, self.g_loss],
                    feed_dict={self.real_data: batch_images, self.lr: lr})
                self.writer.add_summary(summary_str, counter)
                #########################
                # Save images for cnr and snr calculations in matlab
                #if epoch % 4 == 0:
                #print ("Total step counter:", counter)
                print("saving batch", idx)
                path = "../MATLAB/to_matlab/"
                snrv = []
                cnrv = []
                for i in range(len(batch_files)):
                    #print(i, batch_files[i][0])
                    file_name = batch_files[i][0].rsplit("\\", 1)
                    file_name = file_name[1]
                    #print("fn:", file_name)
                    original_path = path + "origs_test/" + str(epoch) + "_" + str(batch_counter) + "-" + file_name
                    fake_path = path + "fakes_test/" + str(epoch) + "_" + str(batch_counter) + "-" + file_name
                    #print("original_path", original_path)
                    #print("fake_path:", fake_path)
                    copyfile(batch_files[i][0], original_path)
                    print("fake_B[i]:",fake_B[i].shape)
                    #remove color channel info to make image saveable
                    resh = np.reshape(fake_B[i], (args.fine_size, args.fine_size))
                    if flipped[i]:
                        resh = np.fliplr(resh)

                    # RESIZE TO 256x256 ?
                    # I think so if you want to perform calcs on it
                    # To get SNR etc.
                    #resh = resize(resh, (256,256), anti_aliasing=True)
                    scipy.misc.imsave(fake_path, resh)

                    snr, cnr = get_snr_cnr(fake_path)
                    print("snr",snr,"cnr",cnr)
                    snrv.append(snr)
                    cnrv.append(cnr)

                    batch_counter += 1

                ###########################
                [fake_A, fake_B] = self.pool([fake_A, fake_B])

                # Update D network
                _, summary_str, d_loss = self.sess.run(
                    [self.d_optim, self.d_sum, self.d_loss],
                    feed_dict={self.real_data: batch_images,
                               self.fake_A_sample: fake_A,
                               self.fake_B_sample: fake_B,
                               self.snr: snrv,
                               self.cnr: cnrv,
                               self.lr: lr})
                self.writer.add_summary(summary_str, counter)

                print("G_LOSS:", g_loss, "D_LOSS:", d_loss)

                counter += 1
                #Prints info and saves a sample image with print_freq
                if np.mod(counter, args.print_freq) == 0:
                    #self.sample_model(args.sample_dir, epoch, idx, args.load_size, args.fine_size)
                    print(("Epoch: [%2d/%2d] [%4d/%4d] time: %4.4f" % (
                        epoch, args.epoch-1, idx, batch_idxs, time.time() - start_time)))
                    #print("SNR:",snr)
                    #print("G_LOSS:", g_loss, "D_LOSS:", d_loss)

                #Create a model checkpoint at save_freq
                #if np.mod(counter, args.save_freq) == 2:
                #Switched it to save every epoch
                if np.mod(counter, batch_idxs) == 0:
                    print("Epoch checkpoint at counter =", counter)
                    self.save(args.checkpoint_dir, epoch, counter)

        print("Training finished!")

    def save(self, checkpoint_dir, epoch, step):
        model_name = "cyclegan.model"
        #remove image size from directory name? no it's useful
        model_dir = "%s_%s" % (self.dataset_dir, self.image_size)
        checkpoint_dir = os.path.join(checkpoint_dir, model_dir)

        if not os.path.exists(checkpoint_dir):
            os.makedirs(checkpoint_dir)

        self.saver.save(self.sess,
                        os.path.join(checkpoint_dir, model_name),
                        global_step=epoch) #epoch in the name instead of step

    def load(self, checkpoint_dir, checkpoint=-1, test=True):
        print(" [*] Reading checkpoint...")

        #remove image size from directory name? no it's useful
        model_dir = "%s_%s" % (self.dataset_dir, self.image_size)
        #model_dir = "ct_lq2hq_new_128"
        checkpoint_dir = os.path.join(checkpoint_dir, model_dir)
        print("CHECKPOINT_DIR:", checkpoint_dir)
        ckpt = tf.train.get_checkpoint_state(checkpoint_dir)
        #doesnt work
        #ckpt = tf.train.get_checkpoint_state(checkpoint_dir, latest_filename="cyclegan.model-214002")
        if ckpt and ckpt.model_checkpoint_path:
            if checkpoint == -1:
                ckpt_name = os.path.basename(ckpt.model_checkpoint_path)
            else:  #Test each epoch
                ckpt_name = "cyclegan.model-" + str(checkpoint)
            print("CHECKPOINT:", ckpt)
            print("CHECKPOINT NAME:", ckpt_name)
            init_epoch = ckpt_name.split('-')[-1]
            self.saver.restore(self.sess, os.path.join(checkpoint_dir, ckpt_name))

            if test:
                return True
            else:
                return True, init_epoch
        else:
            return False

    def sample_model(self, sample_dir, epoch, idx, load_size, fine_size):
        dataA = glob('./datasets/{}/*.png*'.format(self.dataset_dir + '/testA'))
        dataB = glob('./datasets/{}/*.png*'.format(self.dataset_dir + '/testB'))
        np.random.shuffle(dataA)
        np.random.shuffle(dataB)
        batch_files = list(zip(dataA[:self.batch_size], dataB[:self.batch_size]))
        sample_images = [load_train_data(batch_file, load_size=load_size, \
            fine_size=fine_size, is_testing=True) for batch_file in batch_files]
        sample_images = np.array(sample_images).astype(np.float32)

        fake_A, fake_B = self.sess.run(
            [self.fake_A, self.fake_B],
            feed_dict={self.real_data: sample_images}
        )
        save_images(fake_A, [self.batch_size, 1],
                    './{}/A_{:02d}_{:04d}.png'.format(sample_dir, epoch, idx))
        save_images(fake_B, [self.batch_size, 1],
                    './{}/B_{:02d}_{:04d}.png'.format(sample_dir, epoch, idx))

    def test(self, args, output_size=256):
        """Test cyclegan"""
        init_op = tf.global_variables_initializer()
        self.sess.run(init_op)
        if args.which_direction == 'AtoB':
            sample_files = glob('./datasets/{}/*.png*'.format(self.dataset_dir + '/testA'))
        elif args.which_direction == 'BtoA':
            sample_files = glob('./datasets/{}/*.png*'.format(self.dataset_dir + '/testB'))
        else:
            raise Exception('--which_direction must be AtoB or BtoA')

        print("number of test files:", len(sample_files))

        if self.load(args.checkpoint_dir, checkpoint=args.checkpoint):
            print(" [*] Load SUCCESS")
        else:
            print(" [!] Load failed...")
            return

        # write html for visual comparison
        '''index_path = os.path.join(args.test_dir, '{0}_index.html'.format(args.which_direction))
        index = open(index_path, "w")
        index.write("<html><body><table><tr>")
        index.write("<th>name</th><th>input</th><th>output</th></tr>")'''

        out_var, in_var = (self.testB, self.test_A) if args.which_direction == 'AtoB' else (
            self.testA, self.test_B)

        #print("OU", out_var,"INN" in_var)

        file_counter = 0
        for sample_file in sample_files:
            print('Processing image: ', file_counter+1, "out of", len(sample_files))
            sample_image = [load_test_data(sample_file, args.fine_size)]
            #Get image size
            #But will probably only receive 256x256
            sample_image = np.array(sample_image).astype(np.float32)
            image_path = os.path.join(args.test_dir,
                                      '{0}_{1}'.format(args.checkpoint, 
                                      os.path.basename(sample_file))) #added checkpoint to file name
            fake_img = self.sess.run(out_var, feed_dict={in_var: sample_image})

            #Resize image to 256x256
            '''n_of_images = fake_img.shape[0]
            for i in range(n_of_images):
                fake_resized = resize(fake_img[0], (output_size,output_size), anti_aliasing=True)
                fake_resized = np.reshape(fake_resized, (output_size, output_size)) #get rid of color channel
                #print("FAKE_REIZED2:", fake_resized.shape)
                scipy.misc.imsave(image_path, fake_resized)'''
            #print("IMAGE PATH:", image_path)
            save_images(fake_img, [1, 1], image_path)
            '''index.write("<td>%s</td>" % os.path.basename(image_path))
            index.write("<td><img src='%s'></td>" % (sample_file if os.path.isabs(sample_file) else (
                '..' + os.path.sep + sample_file)))
            index.write("<td><img src='%s'></td>" % (image_path if os.path.isabs(image_path) else (
                '..' + os.path.sep + image_path)))
            index.write("</tr>")'''
            file_counter += 1
        #index.close()
