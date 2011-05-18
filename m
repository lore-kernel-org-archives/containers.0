From: Raghu D K <dk.raghu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Testing Linux-CR -- Some Documentation
Date: Wed, 18 May 2011 12:39:54 +0530
Message-ID: <BANLkTinQhntbVEvNUmdtFQvr04imEvxm9w@mail.gmail.com>
References: <BANLkTimjvdKGr_ZKpoozV5JzdbJeSE7PEA@mail.gmail.com>
	<20110513114245.GA4121@mail.hallyn.com> <4DCD3B3E.1040704@hp.com>
	<20110513145140.GA23848@mail.hallyn.com>
	<BANLkTimSFKU8ibjSpQqQ4vHSFoptJorPFQ@mail.gmail.com>
	<20110516132734.GA26650@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110516132734.GA26650-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

>  1. add '-l logfile' arguments to checkpoint and restart commands,
>     to put more debug messages into 'logfile'  (which must not yet
>     exist)
>  2. add '-v' argument to checkpoint and restart for debugging
>  3. look at /var/log/syslog for lots of error messages, assuming
>     you have CONFIG_CHECKPOINT_DEBUG (or whatever that is called)
>     set in your kernel
>  4. after doing checkpoint, use 'ckptinfo', which came with the
>     user-cr programs, to analyze the checkpoint image

I have done all of these and tried even the "ckptinfo", which every
reports the error of "unexpected end of file".


> I suspect what happened to you, though, is that you left file
> descriptors open.  If you look at counterloop/crcounter.c in
> the tests, it does 'for i in (1..100) close(i)'.  The problem
> with not doing this is that the program you are checkpointing has
> inherited file descriptors from its parent task, and, at restart,
> it has no way to recreate those.

I am not testing the sample scripts, I just wrote a sample one as I am
not able to understand
how the Linux CR is supposed to work.
1. Is it mandatory to have the "mount -tcgroup -o freezer cgroup
/cgroup" mounted ?
2. Do we have to launch programs using "nsexec" to be able to
checkpoint and restart them ?

I have tried all the "--help" options, however failed to get the
described results. Even the "self_checkpoint" & "self_restart" code,
provided in the "linux/Documentation/checkpoint" folder is not
executing as described in "usage.txt"

The only application that is showing positive result is
"/test-cr/simple/ckpt.c"

Warm Regards,
Raghu

On Mon, May 16, 2011 at 6:57 PM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> Quoting Raghu D K (dk.raghu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
>> Hello All,
>>
>> I moved =A0the "#!/bin/sh" to point to "bash" however I still see issues
>> in used the "git://www.linux-cr.org/pub/git/tests-cr" scripts.
>> Probably I am missing something with my wrong understanding, I am a
>> little confused with the usage of user space application "checkpoint"
>> and "restart" and the applications in the "test-cr" folder.
>>
>> I wrote a sample shell script "my-test.sh" and tried the following
>> without much success.
>>
>> #!/bin/sh
>> #
>> #
>> #***********************************************************************=
************
>>
>> echo "Incrementing variable ..."
>> COUNT=3D$1
>> X=3D0
>> while [ $X -le $COUNT ];
>> do
>> =A0 =A0 =A0 =A0 X=3D$(( $X + 1 ))
>> =A0 =A0 =A0 =A0 echo "Value of X =3D" $X
>> =A0 =A0 =A0 =A0 sleep 1
>> done
>>
>>
>> $ cd ~/user-cr
>> $ mount -tcgroup -o freezer cgroup /cgroup
>> $ mkdir -p /cgroup/1
>> $ nsexec -z5000 my-test.sh 100 &
>> $ echo 5000 > /cgroup/1/tasks
>> $ echo FROZEN > /cgroup/1/freezer.state
>>
>> $ checkpoint 5000 > ckpt.image
>>
>> This generated a "ckpt.image" file of size 2594550 bytes
>>
>> $ ckptinfo -epv ckpt.image
>> info: [@8] object =A0 1 HDR_HEADER len 72
>> info: [@80] object =A0 4 HDR_BUFFER len 73
>> info: [@153] object =A0 4 HDR_BUFFER len 73
>> info: [@226] object =A0 4 HDR_BUFFER len 73
>> ...
>> unexpected end of file (read 0 of 8)
>>
>> $ kill -9 5000
>> $ echo THAWED > /cgroup/1/freezer.state
>> $ ./restart < ckpt.image
>>
>> This one shows error "Bad file discriptor", what I am missing ?
>
> First, you can find more information about what went wrong in a
> few ways:
>
> =A01. add '-l logfile' arguments to checkpoint and restart commands,
> =A0 =A0 to put more debug messages into 'logfile' =A0(which must not yet
> =A0 =A0 exist)
> =A02. add '-v' argument to checkpoint and restart for debugging
> =A03. look at /var/log/syslog for lots of error messages, assuming
> =A0 =A0 you have CONFIG_CHECKPOINT_DEBUG (or whatever that is called)
> =A0 =A0 set in your kernel
> =A04. after doing checkpoint, use 'ckptinfo', which came with the
> =A0 =A0 user-cr programs, to analyze the checkpoint image
>
> I suspect what happened to you, though, is that you left file
> descriptors open. =A0If you look at counterloop/crcounter.c in
> the tests, it does 'for i in (1..100) close(i)'. =A0The problem
> with not doing this is that the program you are checkpointing has
> inherited file descriptors from its parent task, and, at restart,
> it has no way to recreate those.
>
> -serge
>
