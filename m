From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [fs]  54cc07a761: BUG: kernel test crashed
Date: Sat, 23 Jul 2016 16:52:48 -0500
Message-ID: <87y44snhsf.fsf@x220.int.ebiederm.org>
References: <5793dfa5.mvXPj4LJOS0dlz3i%xiaolong.ye@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5793dfa5.mvXPj4LJOS0dlz3i%xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> (kernel test
	robot's message of "Sun, 24 Jul 2016 05:20:37 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kernel test robot <xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

kernel test robot <xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:

> FYI, we noticed the following commit:
>
> https://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing
> commit 54cc07a761deb38318aca64ddf07fc45157c85e0 ("fs: Call d_automount with the filesystems creds")
>
> in testcase: boot
>
> on test machine: 1 threads qemu-system-x86_64 -enable-kvm -cpu Westmere with 320M memory
>
> caused below changes:
>
>
> +-------------------------+------------+------------+
> |                         | 8175435777 | 54cc07a761 |
> +-------------------------+------------+------------+
> | boot_successes          | 102        | 16         |
> | boot_failures           | 0          | 3          |
> | BUG:kernel_test_crashed | 0          | 3          |
> | timestamp.last          | 0          | 54.951425  |
> +-------------------------+------------+------------+

The problem here seems to be the line: "BUG: kernel test crashed"
Can someone give me some clarity on what that refers to?

My experience in the last week indicates I can't trust the commit the
test bot tells me is the problem commit on these tests.  So if there is
an issue I need something more to track it down with than a line of
output I don't have the source to.

Eric
