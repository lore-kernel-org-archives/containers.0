From: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: No limitation in physical memory in cgroups
Date: Thu, 21 May 2009 14:47:17 +0800
Message-ID: <d95d44a20905202347y177e9744k1a9817236a102b53@mail.gmail.com>
References: <d95d44a20905192252t6cce5169y730a37184075beb9@mail.gmail.com>
	<4A13ABC8.2000907@cn.fujitsu.com>
	<d95d44a20905200335v6aabfc28qa3958e8404965775@mail.gmail.com>
	<20090521085857.d4b82cba.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090521085857.d4b82cba.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

> I wonder....
>
> max_usage_in_bytes is not _reseted_ when you specified limit.
> Then, please set limit before attaching task.
>
> Sane sequence is.
> 1. mount
> 2. mkdir
> 3. set limit
> 4. attach.
>
>

I have tried again the experiment based on the above rules,
but I get the same result.

Again, my operations are as follows: (I have prepared three shell, #1,
#2 and #3)

a) In shell #1, prepare a bash :

# bash
# echo $$
11026

b) In shell #2, prepare the memory control via cgroupfs:

# mount -t cgroup cgroup /mnt/mycgrp2
# cd /mn/mycgrp2
# mkdir mycontainer2
# cd mycontainer2
# echo 0 > cpuset.mems
# echo 0-1 > cpuset.cpus
# echo 350000 > memory.limit_in_bytes

# cat memory.usage_in_bytes
0
# cat memory.max_usage_in_bytes
0
# cat memory.limit_in_bytes
352256

# echo 11026 > tasks
# cat tasks
11026


c) In Shell #1, run a memory consumer (in which, malloc() is called
to allocate memory and not free until program is existed) to allocate
500M memory:


# ./memconsume  500
Begin allocate block ... OK
allocate No.2 block ... OK
...

d) In Shell #3, run the top and see the memory consumption of memconsume:

# ps -ef | grep memconsume
root     11667 11647  0 00:40 pts/0    00:00:00 ./memconsume 500
root     11671 10536  0 00:56 pts/2    00:00:00 grep memconsume
# top -p 11667

e) In Sehll #2, I cat the usage_in_bytes to see the ascending
change of memory:

# cat memory.usage_in_bytes
143360
# cat memory.usage_in_bytes
159744
# cat memory.usage_in_bytes
233472
...
# cat memory.usage_in_bytes   //<--  hit the max limited value
352256
# cat memory.usage_in_bytes
258048
# cat memory.usage_in_bytes
282624
...
# cat memory.usage_in_bytes   // <--  hit the max limited value
348160
# cat memory.usage_in_bytes
122880
...

On the other hand, the top shown in Shell #3 that the virtual
memory is growing up to 450M, but RES is fluctuating between
615 and 497 and the %MEM always shows 0.2  and 0.3 in the whole
experiment.

Does the phenomena conform with the behaviors of memroy cgroups?
Currently, the memory cgroups can not kill the processes or limit
their further allocation of memory when the processes call for more
memory, right?

Maybe, something wrong in my test codes. The following is the
code of memconsume.c

------------------------  memconsume.c ----------------------------

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	int i, t_total;
	char *p = NULL;

	if (argc != 2) {
		printf("Usage: %s  number (block = 1M) \n", argv[0]);
		return -1;
	}

	i = t_total = 0;

	t_total = atoi(argv[1]);
	if (t_total == 0) {
		printf("Usage: %s number (kb) \n", argv[0]);
		printf("\t- number is integer (kb)\n");
		return -1;
	}

	printf("Begin allocate memory ...");

	while (1) {
		p = NULL;
		p = (char *) malloc(1024 * 1024);
		if (p) {
			printf("OK\n");
			i++;
			if (i >= t_total)
				break;
		} else
			printf("fail\n");
		sleep(1);
		printf("allocate No.%d block ...", i + 1);
	}


	printf("End the consumption, total memory = %d * 1024 * 1024 bytes\n",  i);
	return 0;
}


------------------------------------------------------------------------------

Thanks again,

Anqin
