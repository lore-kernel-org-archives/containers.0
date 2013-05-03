From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET] blk-throttle: implement proper hierarchy support
Date: Fri, 3 May 2013 11:58:15 -0700
Message-ID: <20130503185815.GB22860__4084.26711005649$1367607511$gmane$org@mtj.dyndns.org>
References: <20130502181747.GH30020@redhat.com>
	<20130502182933.GN19814@mtj.dyndns.org>
	<20130502184514.GI30020@redhat.com>
	<20130502184953.GP19814@mtj.dyndns.org>
	<20130502190732.GK30020@redhat.com>
	<CAOS58YOk7G=dBG1v5Ed2z3biMMyKkkutp30vH5XC72z0_Z85cw@mail.gmail.com>
	<20130502193139.GL30020@redhat.com>
	<20130502231307.GT19814@mtj.dyndns.org>
	<20130503175652.GB6062@redhat.com>
	<20130503185751.GA22860@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="xHFwDpU9dbj6ez1V"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130503185751.GA22860-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, May 03, 2013 at 11:57:51AM -0700, Tejun Heo wrote:
> On Fri, May 03, 2013 at 01:56:52PM -0400, Vivek Goyal wrote:
> > > Yeah, I think that's what *should* be happening but not what I'm
> > > seeing.  I'm seeing ~15% penalty.
> > 
> > What test are you running. I am running a simple dd with directIO and
> > I am not seeing any penalty.
> 
> Combination of dd and a test program that I've been using for some
> while which can generate concurrent direct random IOs.  Attaching the
> source code for the latter.

And actually attaching...

-- 
tejun

--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="test_rawio.c"

#define _GNU_SOURCE
#define _FILE_OFFSET_BITS 64

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <ctype.h>
#include <unistd.h>
#include <inttypes.h>
#include <sys/ioctl.h>
#include <signal.h>
#include <pthread.h>
#include <time.h>
#include <string.h>
#include <sys/time.h>

#include <sys/user.h>
#include <linux/fs.h>

static int dev_fd, blocks_per_rq, concurrency, do_write;
static int block_size;
static uint64_t device_size, nr_blocks;

static int exiting, nr_exited;

static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
static uint64_t *dispenser_ar;
static unsigned nr_succeeded, nr_failed;

static void sigexit_handler(int dummy)
{
	exiting = 1;
}

static uint64_t dispense_block(int idx)
{
	while (1) {
		uint64_t block;
		int i;
		block = ((uint64_t)random() << 31 | random())
			% (nr_blocks - blocks_per_rq + 1);
		for (i = 0; i < concurrency; i++) {
			if (block + blocks_per_rq > dispenser_ar[i] &&
			    block < dispenser_ar[i] + blocks_per_rq)
				break;
		}
		if (i == concurrency) {
			dispenser_ar[idx] = block;
			return block;
		}
	}
}

static void * do_rawio(void *arg)
{
	int idx = (int)(unsigned long)arg, my_exiting = 0, i;
	size_t bufsz = blocks_per_rq * block_size;
	char *rbuf, *wbuf = NULL;
	uint64_t block;
	ssize_t ret;

	if ((rbuf = malloc(bufsz + PAGE_SIZE)) == NULL ||
	    (do_write && (wbuf = malloc(bufsz + PAGE_SIZE)) == NULL)) {
		perror("malloc");
		exit(1);
	}

	rbuf = (void *)((unsigned long)(rbuf + PAGE_SIZE-1) & ~(PAGE_SIZE-1));
	wbuf = (void *)((unsigned long)(wbuf + PAGE_SIZE-1) & ~(PAGE_SIZE-1));

	if (do_write)
		for (i = 0; i < bufsz / sizeof(int); i++)
			wbuf[i] = idx + i;

	pthread_mutex_lock(&mutex);
 again:
	if (exiting || my_exiting) {
		nr_exited++;
		pthread_mutex_unlock(&mutex);
		return NULL;
	}
	block = dispense_block(idx);
	pthread_mutex_unlock(&mutex);

	if (do_write) {
		ret = pwrite(dev_fd, wbuf, bufsz, block * block_size);
		if (ret != bufsz) {
			fprintf(stderr, "\rThread %02d: write failed on "
				"block %"PRIu64" ret=%zd errno=%d wbuf=%p\n",
				idx, block, ret, errno, wbuf);
			goto failed;
		}
	}

	ret = pread(dev_fd, rbuf, bufsz, block * block_size);
	if (ret != bufsz) {
		fprintf(stderr, "\rThread %02d: read failed on block "
			"%"PRIu64" ret=%zd errno=%d rbuf=%p\n",
			idx, block, ret, errno, rbuf);
		goto failed;
	}

	if (do_write && memcmp(wbuf, rbuf, bufsz) != 0) {
		fprintf(stderr, "\rThread %02d: data mismatch on block "
			"%"PRIu64" ret=%zd errno=%d\n", idx, block, ret, errno);
		goto failed;
	}

	nr_succeeded++;
	pthread_mutex_lock(&mutex);
	goto again;

 failed:
	nr_failed++;
	my_exiting = 1;
	pthread_mutex_lock(&mutex);
	goto again;
}

static uint64_t now_in_usec(void)
{
	struct timeval tv;

	gettimeofday(&tv, NULL);
	return (uint64_t)tv.tv_sec * 1000000 + tv.tv_usec;
}

int main(int argc, char **argv)
{
	struct stat sbuf;
	int i, summary_only;
	pthread_t *thrs;
	uint64_t started_at, last_tstmp;
	unsigned last_succeeded = 0;
	double iops = 0;

	if (argc < 5) {
		fprintf(stderr,
		"Usage: test_rawio BLOCKDEV BLOCKS_PER_RQ CONCURRENCY (r|w) [s(ummary)|w(ait)]\n");
		return 1;
	}

	blocks_per_rq = atoi(argv[2]);
	concurrency = atoi(argv[3]);

	if (blocks_per_rq <= 0 || concurrency <= 0) {
		fprintf(stderr, "invalid parameters\n");
		return 1;
	}

	if (!(dispenser_ar = malloc(sizeof(dispenser_ar[0]) * concurrency)) ||
	    !(thrs = malloc(sizeof(thrs[0]) * concurrency))) {
		perror("malloc");
		return 1;
	}
	memset(dispenser_ar, 0, sizeof(dispenser_ar[0]) * concurrency);

	do_write = tolower(argv[4][0]) == 'w';

	summary_only = 0;
	if (argc >= 6 && strchr(argv[5], 's'))
		summary_only = 1;

	if (argc >= 6 && strchr(argv[5], 'w')) {
		char buf[64];
		printf("press enter to continue\n");
		fgets(buf, sizeof(buf), stdin);
	}

	dev_fd = open(argv[1], (do_write ? O_RDWR : O_RDONLY) | O_DIRECT);
	if (dev_fd < 0) {
		perror("open");
		return 1;
	}

	if (fstat(dev_fd, &sbuf) < 0) {
		perror("fstat");
		return 1;
	}

	if (!S_ISBLK(sbuf.st_mode)) {
		fprintf(stderr, "not a block device\n");
		return 1;
	}

	if (ioctl(dev_fd, BLKSSZGET, &block_size) < 0 ||
	    ioctl(dev_fd, BLKGETSIZE64, &device_size) < 0) {
		perror("ioctl");
		return 1;
	}
	nr_blocks = device_size / block_size;

	if (!summary_only)
		printf("%s block_size=%d nr_blocks=%"PRIu64" (%.2lfGiB)\n",
		       argv[1], block_size, nr_blocks,
		       (double)device_size / (1 << 30));

	if (signal(SIGINT, sigexit_handler) == SIG_ERR) {
		perror("signal");
		return 1;
	}

	srandom(getpid());

	for (i = 0; i < concurrency; i++)
		if ((errno = pthread_create(&thrs[i], NULL, do_rawio,
					    (void *)(unsigned long)i))) {
			perror("pthread_create");
			return 1;
		}

	started_at = last_tstmp = now_in_usec();

	while (nr_exited < concurrency) {
		struct timespec ts_200ms = { 0, 200 * 1000 * 1000 };
		const char pgstr[] = "|/-\\";

		if (!summary_only) {
			uint64_t now = now_in_usec();
			double time_delta = ((double)now - last_tstmp) / 1000000;
			double io_delta = nr_succeeded - last_succeeded;

			if (last_tstmp - started_at < 1000000)
				iops = io_delta / time_delta;
			else
				iops = iops * 0.9 + io_delta / time_delta * 0.1;

			printf("\rnr_succeeded=%-8u nr_failed=%-8u iops=%7.03lf kbps=%9.03lf %s%c",
			       nr_succeeded, nr_failed, iops,
			       iops * block_size * blocks_per_rq / 1024,
			       exiting ? "exiting..." : "",
			       pgstr[i++%(sizeof(pgstr)-1)]);

			last_tstmp = now;
			last_succeeded += io_delta;
		}

		fflush(stdout);
		nanosleep(&ts_200ms, NULL);
	}

	if (!summary_only)
		printf("\n");
	else
		printf("nr_succeeded=%u nr_failed=%8u iops=%03.03lf\n",
		       nr_succeeded, nr_failed,
		       (double)nr_succeeded /
		       (((double)now_in_usec() - started_at) / 1000000));

	return 0;
}

--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--xHFwDpU9dbj6ez1V--
