From: Jiro SEKIBA <jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org>
Subject: Re: Linux Checkpoint-Restart - v19
Date: Tue, 16 Mar 2010 17:36:55 +0900
Message-ID: <0B4E8136-FFC6-490D-B04A-23A6E1A924FF@dependable-os.net>
References: <4B83106C.7040203@cs.columbia.edu>
	<a1c54a921003150155q4a0c7fc1vb02ba0464b07f452@mail.gmail.com>
	<4B9EBAF2.1060304@cs.columbia.edu>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B9EBAF2.1060304-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

Thank you for prompt reply!
Sorry that I didn't post to containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cuFJUID1Z7QI@public.gmane.org

On 2010/03/16, at 7:55, Oren Laadan wrote:

> Hi,
> 
> Thanks for taking the time to evaluate c/r. You may want to also
> try the latest, which is (as of now) ckpt-v20-rc2.

Yeah, I'll eventually try to keep up with the latest,
but I just want to try the one  you think it's stable first anyway.

> In the future, please CC the containers mailing list for issues
> related to c/r, at "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org".
> 
> Jiro SEKIBA wrote:
>> Hi,
>> I'm trying to evaluate external checkpoint/restart with cr-v19 kernel.
>> However, when I restart, I got "Killed" message in stdout.
>> Do you have any tips or clue that are not in
>> Documentation/checkpoint/usage.txt ?
>> I'm using kernel pulled from
>> git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git .
>> checkout tag named "ckpt-v19". Base distro is ubuntu 9.10.
>> I ran self checkpioint/restart sample program in Documentation/checkpint.
>> It works as written in usage.txt.
>> However, I can not make external checkpint/restart work properly.
>> I made a simple test program bellow and create checkpoint externally using
>> the program in Documentation/checkpoint/, it looks checkpoint file is
>> created properly.
>> However, when I ran self_restart < ckpt.image, I got "Killed" message.
> 
> If you take an external checkpoint, then you need to match it
> with an external restart, as opposed to self_restart.
> 
> Otherwise, restarting with self_restart from a checkpoint that is
> not a self-checkpoint can yield unexpected results.
> 
> Since you don't mention in your post, I don't know if you are using
> the tools from user-cr. If not, then you should use 'checkpoint' and
> 'restart' tools from there. It is available from:
> 	git://git.ncl.cs.columbia.edu/pub/git/user-cr.git
> (use the same branch as the one you used to linux-cr).
> 
> Once you have the tools compiled, and you checkpoint with the
> 'checkpoint' utility from there, you can restart with:
> 	restart -v < ckpt.image
> 

Thank you for the information.
Actually I was trying to create checkpoint in Document/checkpints.

Now, I tried with user-cr, compiled binary in the same tag (ckpt-v19).
Creating checkpoint  looks OK and restart -v shows it Success.  nice!
However, the contents in /tmp/test.out never get further,
it remains same as when created checkpoint.

I tried  "./restart -F /cgroup/0 -v --no-pidns < ckpt.image", got Success.
cat /cgroup/0/tasks tells that there is a process.
ps shows ./test.  So, it looks restarting.

# ps axuww |grep $(cat /cgroup/0/tasks )
root      7231  0.1  0.0   1588    64 pts/0    D    16:57   0:00 ./test
root      7238  0.0  0.1   2716   660 pts/1    R+   16:57   0:00 grep 7231

under the /proc, one file descriptor opened, and it is /tmp/test.out

#  ls -l /proc/$(cat /cgroup/0/tasks)/fd
total 0
lrwx------ 1 root root 64 Mar 16 16:58 0 -> /tmp/test.out

Nhh, it's close..

I found that when I mount cgroup with -o freezer, self_checkpoint won't work.
It worked even I didn't mount the cgroup.
Is it what you expect?

Thank you again for the help!
I'm feeling better to use the latest ..


> Oren.
> 
>> Is there any extra configurations other than cgroup freezer and
>> checkpint/restart ?
>> Or any limitation other than closing stdout,err,in ?
>> what I did is following:
>> # mount -t cgroup -o freezer cgroup /cgroup
>> # mkdir /cgroup/0
>> ..
>> # ./test &
>> # PID=$(ps | grep test | cut -f 2 -d' ')
>> # echo $PID > /cgroup/0/tasks
>> # sleep 3
>> # echo FROZEN > /cgroup/0/freezer.state
>> # ./checkpoint $PID > ckpt.image
>> # mv /tmp/test.out /tmp/test.out.orig
>> # cp /tmp/test.out.orig /tmp/test.out
>> # echo THAWED > /cgroup/0/freezer.state
>> # ./self_restart < ckpt.image
>> Killed
>> ----- test.c -----
>> int main(void)
>> {
>>  FILE *fp;
>>  int i;
>>  close(0);
>> //  close(1);  // I got SEGV when I uncomment this line, when restarting
>>  close(2);
>>  fp = fopen("/tmp/test.out","w+");
>>  for(i=0;i<10;i++) {
>>    fprintf(fp,"%d\n",i);
>>    fflush(fp);
>>    sleep(1);
>>  }
>>  fclose(fp);
>>  return 0;
>> }
>> ----- test.c -----
>> Thank you very much in advance
>> 2010/2/23 Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>:
>>> Hi Andrew,
>>> 
>>> We've put a stake in the ground for our next set of checkpoint/restart
>>> patches, v19. It has some great new stuff, and we put extra effort to
>>> address your concerns. We would like to have the code included in -mm
>>> for wider feedback and testing.
>>> 
>>> This one is able to checkpoint/restart screen and vnc sessions, and
>>> live-migrate network servers between hosts. It also adds support for
>>> x86-64 (in addition to x86-32, s390x and powerpc). It is rebased to
>>> kernel 2.6.33-rc8.
>>> 
>>> Since one of your main concerns was about what is not yet implemented
>>> and how complicated or ugly it will be to support that, we've put up
>>> a wiki page to address that. In it there is a simple table that lists
>>> what is not implemented and the anticipated solution impact, and for
>>> some entries a link to more details.
>>> 
>>> The page is here:   http://ckpt.wiki.kernel.org/index.php/Checklist
>>> 
>>> We want to stress that the patchset is already very useful as-is. We
>>> will keep working to implement more features cleanly. Some features we
>>> are working on include network namespaces and device configurations,
>>> mounts and mounts namespaces, and file locks. Should a complicated
>>> feature prove hard to implement, users have alternatives systems like
>>> kvm, until we manage to come up with a clean solution.
>>> 
>>> We believe that maintenance is best addressed through testing. We now
>>> have a comprehensive test-suite to automatically find regressions.
>>> In addition, we ran LTP and the results are the same with CHECKPOINT=n
>>> and =y.
>>> 
>>> If desired we'll send the whole patchset to lkml, but the git trees
>>> can be seen at:
>>> 
>>> kernel:       http://www.linux-cr.org/git/?p=linux-cr.git;a=summary
>>> user tools:   http://www.linux-cr.org/git/?p=user-cr.git;a=summary
>>> tests suite:  http://www.linux-cr.org/git/?p=tests-cr.git;a=summary
>>> 
>>> Thanks,
>>> 
>>> Application checkpoint/restart team
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
>>> 
