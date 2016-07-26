From: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [LKP] More information please. Re: [fs] 54cc07a761: BUG: kernel
	test crashed
Date: Tue, 26 Jul 2016 23:13:44 +0800
Message-ID: <20160726151344.GB8811@wfg-t540p.sh.intel.com>
References: <5793dfa5.mvXPj4LJOS0dlz3i%xiaolong.ye@intel.com>
	<877fc9a6mb.fsf@x220.int.ebiederm.org>
	<20160726143545.GA23656@wfg-t540p.sh.intel.com>
	<87vazsv4cn.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87vazsv4cn.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jul 26, 2016 at 09:52:40AM -0500, Eric W. Biederman wrote:
>Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
>> On Mon, Jul 25, 2016 at 01:57:00PM -0500, Eric W. Biederman wrote:
>>>kernel test robot <xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
>[snip]
>>>>
>>>> [   19.206454] VFS: Warning: trinity-c0 using old stat() call. Recompile your binary.
>>>>
>>>> Elapsed time: 70
>>>> BUG: kernel test crashed
>>>
>>>What application generated the line "BUG: kernel test crashed."
>>>What flavor of crash was this?
>>
>> It's a simple boot test with a quick trinity run. So there will be
>> some randomness in this test.
>>
>> The "BUG: kernel test crashed" means the VM reboots by itself while
>> the trinity test is running. If the error message is "BUG: kernel boot
>> crashed" it'd mean VM abnormally reboots before any test is launched.
>
>Is it possible to include a url pointing to a page of documentation
>holding this information in your emails or alternatively a url pointing
>to some source code.  Just so other people don't have to ask you this
>question.

Yes that's the right directions to follow. We'll make the reports more
understandable and the test/bisects more reliable.

In particular, I suspect this false report might be related to QEMU
watchdog. The wild guess is, if trinity touches the watchdog device by
accident, it may result in the VM reset w/o any symptom.

>>>Given the last boot test failure that was reported to me was about 10
>>>commits after the problem commit I unfortunately can't take it at face
>>>value that the appropriate commit has been pinpointed.
>>>
>>>If you could give me enough information to dig into this that would
>>>be great.  Otherwise I am going to have to proceed forward on the basis
>>>that this is a testing robot failure, and that the people who maintain
>>>the testing robot don't care enough to look after it.
>>
>> I queued more tests in various KVM instances and find the kernel test
>> crashes can also happen in the parent commit. So it looks like a false
>> report. Sorry for the noise!
>>
>> 81754357770ebd90  aeaa4a79ff6a5ed912b7362f20
>> ----------------  --------------------------
>>       fail:runs  %reproduction    fail:runs
>>           |             |             |
>>          5:100          0%           5:100   dmesg.BUG:kernel_test_crashed
>>           :100          1%           1:100   dmesg.Mem-Info
>>           :100          1%           1:100   dmesg.invoked_oom-killer:gfp_mask=0x
>
>Thank you for verifying this.

You are welcome!

Thanks,
Fengguang
