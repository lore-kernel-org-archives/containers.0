From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [LKP] More information please. Re: [fs] 54cc07a761: BUG: kernel
	test crashed
Date: Tue, 26 Jul 2016 14:50:58 -0500
Message-ID: <87wpk8p49p.fsf@x220.int.ebiederm.org>
References: <5793dfa5.mvXPj4LJOS0dlz3i%xiaolong.ye@intel.com>
	<877fc9a6mb.fsf@x220.int.ebiederm.org>
	<20160726143545.GA23656@wfg-t540p.sh.intel.com>
	<87vazsv4cn.fsf@x220.int.ebiederm.org>
	<20160726151344.GB8811@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160726151344.GB8811-q6ZYBFIlbFFi0tQiZxhdj1DQ4js95KgL@public.gmane.org> (Fengguang Wu's
	message of "Tue, 26 Jul 2016 23:13:44 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:

> On Tue, Jul 26, 2016 at 09:52:40AM -0500, Eric W. Biederman wrote:
>>Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
>>> On Mon, Jul 25, 2016 at 01:57:00PM -0500, Eric W. Biederman wrote:
>>>>kernel test robot <xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
>>[snip]
>>>>>
>>>>> [   19.206454] VFS: Warning: trinity-c0 using old stat() call. Recompile your binary.
>>>>>
>>>>> Elapsed time: 70
>>>>> BUG: kernel test crashed
>>>>
>>>>What application generated the line "BUG: kernel test crashed."
>>>>What flavor of crash was this?
>>>
>>> It's a simple boot test with a quick trinity run. So there will be
>>> some randomness in this test.
>>>
>>> The "BUG: kernel test crashed" means the VM reboots by itself while
>>> the trinity test is running. If the error message is "BUG: kernel boot
>>> crashed" it'd mean VM abnormally reboots before any test is launched.
>>
>>Is it possible to include a url pointing to a page of documentation
>>holding this information in your emails or alternatively a url pointing
>>to some source code.  Just so other people don't have to ask you this
>>question.
>
> Yes that's the right directions to follow. We'll make the reports more
> understandable and the test/bisects more reliable.

Thanks.  Does trinity have a random seed it can export/import to rerun
the same tests?  I ask because there was a failure these tests caught
that if the right kernel options was enabled was 100% reliable and it
blamed a commit 10 patches down from the indicated commit.  The problem
being 100% reproducible it wasn't an issue that the indicated commit
was wrong.  But a 100% reliable failure being misattributed suggest
a way attribution could become more reliable.

> In particular, I suspect this false report might be related to QEMU
> watchdog. The wild guess is, if trinity touches the watchdog device by
> accident, it may result in the VM reset w/o any symptom.

Interesting.  I hope it is the watchdog.  I know some qemu versions +
some kernel versions have race conditions that are observable during
boot.  I don't know if those happen in your test harness but it may be
worth a look.  I tend to get grumpy when I see those and work on
stabalizing a magic kernel config that likes qemu, but I keep finding
issues when I try other peoples configurations for reproducing problems
like this one.

Eric
