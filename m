From: Raghu D K <dk.raghu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Testing Linux-CR -- Some Documentation
Date: Mon, 16 May 2011 16:04:54 +0530
Message-ID: <BANLkTimSFKU8ibjSpQqQ4vHSFoptJorPFQ@mail.gmail.com>
References: <BANLkTimjvdKGr_ZKpoozV5JzdbJeSE7PEA@mail.gmail.com>
	<20110513114245.GA4121@mail.hallyn.com> <4DCD3B3E.1040704@hp.com>
	<20110513145140.GA23848@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110513145140.GA23848-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello All,

I moved  the "#!/bin/sh" to point to "bash" however I still see issues
in used the "git://www.linux-cr.org/pub/git/tests-cr" scripts.
Probably I am missing something with my wrong understanding, I am a
little confused with the usage of user space application "checkpoint"
and "restart" and the applications in the "test-cr" folder.

I wrote a sample shell script "my-test.sh" and tried the following
without much success.

#!/bin/sh
#
#
#***********************************************************************************

echo "Incrementing variable ..."
COUNT=$1
X=0
while [ $X -le $COUNT ];
do
        X=$(( $X + 1 ))
        echo "Value of X =" $X
        sleep 1
done


$ cd ~/user-cr
$ mount -tcgroup -o freezer cgroup /cgroup
$ mkdir -p /cgroup/1
$ nsexec -z5000 my-test.sh 100 &
$ echo 5000 > /cgroup/1/tasks
$ echo FROZEN > /cgroup/1/freezer.state

$ checkpoint 5000 > ckpt.image

This generated a "ckpt.image" file of size 2594550 bytes

$ ckptinfo -epv ckpt.image
info: [@8] object   1 HDR_HEADER len 72
info: [@80] object   4 HDR_BUFFER len 73
info: [@153] object   4 HDR_BUFFER len 73
info: [@226] object   4 HDR_BUFFER len 73
...
unexpected end of file (read 0 of 8)

$ kill -9 5000
$ echo THAWED > /cgroup/1/freezer.state
$ ./restart < ckpt.image

This one shows error "Bad file discriptor", what I am missing ?

Warm Regards,
Raghu


>>
>> Or you can run:
>>
>> # sudo dpkg-reconfigure dash
>>
>> and choose "No", which will make /bin/sh point to bash.
>
> Good point :)
