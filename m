From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Tue, 09 Mar 2010 11:26:09 +0100
Message-ID: <4B962241.6060300__8300.82748220793$1268138724$gmane$org@free.fr>
References: <4B88E431.6040609@parallels.com>	<m1y6iaqsmm.fsf@fess.ebiederm.org>
	<20100303000743.GA13744@us.ibm.com>	<m1ocj6qljj.fsf@fess.ebiederm.org>
	<4B8E9370.3050300@parallels.com>	<m17hptjh3m.fsf@fess.ebiederm.org>
	<4B9158F5.5040205@parallels.com>	<m1vdda1pmx.fsf@fess.ebiederm.org>
	<4B926B1B.5070207@free.fr>	<m1aaulyy5c.fsf@fess.ebiederm.org>
	<4B92C886.9020507@free.fr>	<m1fx4bxlfy.fsf@fess.ebiederm.org>
	<4B952BBE.6070507@free.fr>	<m11vfuvi1t.fsf@fess.ebiederm.org>
	<4B9556A9.60206@free.fr>	<m11vfusgsa.fsf@fess.ebiederm.org>
	<4B95611C.5060403@free.fr>	<m1sk8ar15b.fsf@fess.ebiederm.org>
	<4B956852.7050804@free.fr>	<m1lje2qzf4.fsf@fess.ebiederm.org>
	<4B961D09.4010802@free.fr> <m1ocixn6q3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ocixn6q3.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
>> [ ... ]
>>     
>>> I guess my meaning is I was expecting.
>>> child = fork();
>>> if (child == 0) {
>>> 	execve(...);
>>> }
>>> waitpid(child);
>>>
>>> This puts /bin/sh in the container as well.
>>>   
>>>       
>> #include <unistd.h>
>> #include <stdlib.h>
>> #include <stdio.h>
>> #include <syscall.h>
>> #include <sys/types.h>
>> #include <sys/stat.h>
>> #include <fcntl.h>
>> #include <sys/param.h>
>>
>> #define __NR_setns 300
>>
>> int setns(int nstype, int fd)
>> {
>>    return syscall (__NR_setns, nstype, fd);
>> }
>>
>> int main(int argc, char *argv[])
>> {
>>    char path[MAXPATHLEN];
>>    char *ns[] = { "pid", "mnt", "net", "pid", "uts" };
>>    const int size = sizeof(ns) / sizeof(char *);
>>    int fd[size];
>>    int i;
>>    pid_t pid;
>>    if (argc != 3) {
>>        fprintf(stderr, "mynsenter <pid> <command>\n");
>>        exit(1);
>>    }
>>
>>    for (i = 0; i < size; i++) {
>>            sprintf(path, "/proc/%s/ns/%s", argv[1], ns[i]);
>>
>>        fd[i] = open(path, O_RDONLY| FD_CLOEXEC);
>>        if (fd[i] < 0) {
>>            perror("open");
>>            return -1;
>>        }
>>
>>    }
>>    for (i = 0; i < size; i++)
>>        if (setns(0, fd[i])) {
>>            perror("setns");
>>            return -1;
>>        }
>>
>>    pid = fork();
>>    if (!pid) {
>>
>>        fprintf(stderr, "mypid is %d\n", syscall(__NR_getpid));
>>
>>        execve(argv[2], &argv[2], NULL);
>>        perror("execve");
>>
>>    }
>>
>>    if (pid < 0) {
>>        perror("fork");
>>        return -1;
>>    }
>>
>>    if (waitpid(&pid, NULL, 0) < 0) {
>>        perror("waitpid");
>>    }
>>
>>    return 0;
>> }
>>     
>
> &pid ???  Isn't that a type error?
>   
argh ! right :)

Sorry for the noise. Works well now.
