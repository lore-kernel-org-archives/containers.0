From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 08 Mar 2010 21:42:04 +0100
Message-ID: <4B95611C.5060403__39939.7779991434$1268080972$gmane$org@free.fr>
References: <4B88E431.6040609@parallels.com>	<m1iq9io5sc.fsf@fess.ebiederm.org>
	<4B89727C.9040602@parallels.com>	<m1ljeempk6.fsf@fess.ebiederm.org>
	<4B8AE8C1.1030305@free.fr>	<4B8D28CF.8060304@parallels.com>
	<20100302211942.GA17816@us.ibm.com>	<m1y6iaqsmm.fsf@fess.ebiederm.org>
	<20100303000743.GA13744@us.ibm.com>	<m1ocj6qljj.fsf@fess.ebiederm.org>
	<4B8E9370.3050300@parallels.com>	<m17hptjh3m.fsf@fess.ebiederm.org>
	<4B9158F5.5040205@parallels.com>	<m1vdda1pmx.fsf@fess.ebiederm.org>
	<4B926B1B.5070207@free.fr>	<m1aaulyy5c.fsf@fess.ebiederm.org>
	<4B92C886.9020507@free.fr>	<m1fx4bxlfy.fsf@fess.ebiederm.org>
	<4B952BBE.6070507@free.fr>	<m11vfuvi1t.fsf@fess.ebiederm.org>
	<4B9556A9.60206@free.fr> <m11vfusgsa.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11vfusgsa.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> writes:
>
>   
>> Eric W. Biederman wrote:
>>     
>>> Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> writes:
>>>
>>>   
>>>       
>>>> Eric W. Biederman wrote:
>>>>     
>>>>         
>>>>> I have take an snapshot of my development tree and placed it at.
>>>>>
>>>>>
>>>>> git://git.kernel.org/pub/scm/linux/people/ebiederm/linux-2.6.33-nsfd-v5.git
>>>>>         
>>>>>           
>>>> Hi Eric,
>>>>
>>>> thanks for the pointer.
>>>>
>>>> I tried to boot the kernel under qemu and I got this oops:
>>>>     
>>>>         
>>> I am clearly running an old userspace on my test machine.  No udev.
>>> It looks like udev has a long standing netlink misfeature, where
>>> it does not initializing NETLINK_CB....
>>>
>>>
>>> >From 8d85e3ab88718eda3d94cf8e1be14b69dae2b8f1 Mon Sep 17 00:00:00 2001
>>> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>> Date: Mon, 8 Mar 2010 09:25:20 -0800
>>> Subject: [PATCH] kobject_uevent:  Use the netlink allocator helper...
>>>
>>> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>>>   
>>>       
>> Thanks.
>>
>> I was able to boot but I have the following warning:
>>     
>
> Thanks for the bug report.
>   
Thanks to you for the patchset :)

> For the moment you might want to drop:
> af_netlink:  Allow credentials to work across namespaces.
> af_netlink: Debugging in case I have missed something.
>
> Although I am curious if you hit my debugging messages in
> netlink recv.
>   
No, it does not appear (looked for "missing NETLINK_CB proto").

> I guess if the goal is to test my nsfd bits you can drop everything
> starting with my 'scm: Reorder scm_cookie.' commit.  The rest is what
> it takes to get get uids, gid and pids translated when the cross
> namespaces on an af_unix of an af_netlink socket.
>
> At least in the af_netlink case it appears clear I am have missed
> something.
>
> This is a warning that netlink throws when the packet accounting messed
> up.  So it sounds like you are exercising another path that I failed
> to exercise and fix.
>   
I will look forward if I find more clues for this warning.

In the meantime  was able to enter the container with the ugly following 
program:

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <syscall.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/param.h>

#define __NR_setns 300

int setns(int nstype, int fd)
{
    return syscall (__NR_setns, nstype, fd);
}

int main(int argc, char *argv[])
{
    char path[MAXPATHLEN];
    char *ns[] = { "pid", "mnt", "net", "pid", "uts" };
    const int size = sizeof(ns) / sizeof(char *);
    int fd[size];
    int i;

    if (argc != 3) {
        fprintf(stderr, "mynsenter <pid> <command>\n");
        exit(1);
    }

    for (i = 0; i < size; i++) {
       
        sprintf(path, "/proc/%s/ns/%s", argv[1], ns[i]);

        fd[i] = open(path, O_RDONLY);
        if (fd[i] < 0) {
            perror("open");
            return -1;
        }

    }

    for (i = 0; i < size; i++) {

        if (setns(0, fd[i])) {
            perror("setns");
            return -1;
        }
    }

    execve(argv[2], &argv[2], NULL);
    perror("execve");

    return 0;
}

At the fist glance, no problem :)
