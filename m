From: Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Subject: Re: [PATCH 4/4 v5 RESEND] selftests: add devpts selftests
Date: Tue, 10 Apr 2018 19:34:36 +1000
Message-ID: <87bmerbe1f.fsf__29632.7779688456$1523352774$gmane$org@concordia.ellerman.id.au>
References: <20180313165527.24038-1-christian.brauner@ubuntu.com>
	<20180313165527.24038-5-christian.brauner@ubuntu.com>
	<87efjnbn0j.fsf@concordia.ellerman.id.au>
	<20180410084208.GA14520@mailbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180410084208.GA14520-cl+VPiYnx/1AfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
List-Id: containers.vger.kernel.org

Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
> On Tue, Apr 10, 2018 at 04:20:44PM +1000, Michael Ellerman wrote:
>> Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
>> > diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
>> > index 7442dfb73b7f..dbda89c9d9b9 100644
>> > --- a/tools/testing/selftests/Makefile
>> > +++ b/tools/testing/selftests/Makefile
>> > @@ -7,6 +7,7 @@ TARGETS += cpufreq
>> >  TARGETS += cpu-hotplug
>> >  TARGETS += efivarfs
>> >  TARGETS += exec
>> > +TARGETS += filesystems
>>    ^ This, and ...
>> 
>> > diff --git a/tools/testing/selftests/filesystems/Makefile b/tools/testing/selftests/filesystems/Makefile
>> > index 13a73bf725b5..4e6d09fb166f 100644
>> > --- a/tools/testing/selftests/filesystems/Makefile
>> > +++ b/tools/testing/selftests/filesystems/Makefile
>> > @@ -1,5 +1,5 @@
>> >  # SPDX-License-Identifier: GPL-2.0
>> > -TEST_PROGS := dnotify_test
>> > +TEST_PROGS := dnotify_test devpts_pts
>>                  ^
>>                  this ...
>> 
>> Have the unfortunate effect of running dnotify_test as part of the
>> default selftest run.
>> 
>> dnotify_test boils down to:
>> 
>> 	while (1) {
>> 		pause();
>> 		printf("Got event on fd=%d\n", event_fd);
>> 	}
>> 
>> 
>> ie. an infinite loop :)
>
> Hi Michael,
>
> Ugh, didn't notice this before. Weird test.

No worries. It looks like it was copied from Documentation where it was
really just sample code, rather than a test.
 
>> I'll send a patch to fix it.
>
> Excellent, you can likely route it through Greg's tty tree.

I've sent it to the kselftest list as well as Greg, so whoever wants to
merge it is fine by me.

cheers
