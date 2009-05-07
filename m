From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Thu, 07 May 2009 13:47:47 +0800
Message-ID: <4A027603.6040509__48352.4191113704$1241675452$gmane$org@cn.fujitsu.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A014619.1040000@cn.fujitsu.com>
	<20090506161012.GC8180@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060002070506020304030307"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090506161012.GC8180-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------060002070506020304030307
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Vivek Goyal wrote:
> Hi Gui,
> 
> Thanks for the report. I use cgroup_path() for debugging. I guess that
> cgroup_path() was passed null cgrp pointer that's why it crashed.
> 
> If yes, then it is strange though. I call cgroup_path() only after
> grabbing a refenrece to css object. (I am assuming that if I have a valid
> reference to css object then css->cgrp can't be null).

  I think so too...

> 
> Anyway, can you please try out following patch and see if it fixes your
> crash.
> 
> ---
>  block/elevator-fq.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> Index: linux11/block/elevator-fq.c
> ===================================================================
> --- linux11.orig/block/elevator-fq.c	2009-05-05 15:38:06.000000000 -0400
> +++ linux11/block/elevator-fq.c	2009-05-06 11:55:47.000000000 -0400
> @@ -125,6 +125,9 @@ static void io_group_path(struct io_grou
>  	unsigned short id = iog->iocg_id;
>  	struct cgroup_subsys_state *css;
>  
> +	/* For error case */
> +	buf[0] = '\0';
> +
>  	rcu_read_lock();
>  
>  	if (!id)
> @@ -137,15 +140,12 @@ static void io_group_path(struct io_grou
>  	if (!css_tryget(css))
>  		goto out;
>  
> -	cgroup_path(css->cgroup, buf, buflen);
> +	if (css->cgroup)

  According to CR2, when kernel crashing, css->cgroup equals 0x00000100.
  So i guess this patch won't fix this issue.

> +		cgroup_path(css->cgroup, buf, buflen);
>  
>  	css_put(css);
> -
> -	rcu_read_unlock();
> -	return;
>  out:
>  	rcu_read_unlock();
> -	buf[0] = '\0';
>  	return;
>  }
>  #endif
> 
> BTW, I tried following equivalent script and I can't see the crash on 
> my system. Are you able to hit it regularly?

  yes, it's 50% chance that i can reproduce it.
  i'v attached the rwio source code.

> 
> Instead of killing the tasks I also tried moving the tasks into root cgroup
> and then deleting test1 and test2 groups, that also did not produce any crash.
> (Hit a different bug though after 5-6 attempts :-)
> 
> As I mentioned in the patchset, currently we do have issues with group
> refcounting and cgroup/group going away. Hopefully in next version they
> all should be fixed up. But still, it is nice to hear back...
> 
> 

-- 
Regards
Gui Jianfeng

--------------060002070506020304030307
Content-Type: image/x-xbitmap;
 name="rwio.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rwio.c"

#define _GNU_SOURCE
#define __USE_GNU

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <asm/page.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#ifndef PAGE_SIZE
#define PAGE_SIZE getpagesize()
#endif

#define WRITE_LEN 2147483648UL

void *buf = NULL;
int opt_r = 0;
int opt_w = 0;
int opt_d = 0;
char *filename = NULL;
unsigned long f_size = WRITE_LEN;

void parse_args(int argc, char **argv)
{
	int opt;

	while ((opt = getopt(argc, argv, "rwds:f:")) != EOF) {
		switch (opt) {
		case 'r':
			opt_r++;
			break;
		case 'w':
			opt_w++;
			break;
		case 'd':
			opt_d++;
			break;
		case 'f':
			filename = optarg;
			break;
		case 's':
			f_size = atoi(optarg);
			printf("%lu,", f_size);
		}
	}

	if ((opt_r && opt_w) || !filename) {
		fprintf(stderr, "bad parameter\n");
		exit(1);
	}
}

int main(int argc, char *argv[])
{
	int fd, num, ret;
	int count = 0;
	int flags = O_RDWR | O_LARGEFILE;

	parse_args(argc, argv);

	if (opt_d)
		flags |= O_DIRECT;
	if (opt_w)
		flags |= O_CREAT;
	
	if ((fd = open(filename, flags, 0600)) < 0) {
		perror("open fail");
		return 1;
	}

	ret = posix_memalign(&buf, PAGE_SIZE, 4096);
        if (ret < 0) {
		perror("posix_memalign");
                return 1;
        }
	memset(buf, 0xaa, 4096);

	if (opt_r) {
		while ((num = read(fd, buf, 4096))) {
			if (num <= 0) {
				printf("num:%d\n", num);
				perror("read");
				return 1;
			}
			count += num;
		}
	}	

	if (opt_w) {
		while ((count += write(fd, buf, 4096)) < f_size) {
			;
		}
	}

	close(fd);
	printf("%d\n", count);
	return 0;
}

--------------060002070506020304030307
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------060002070506020304030307--
