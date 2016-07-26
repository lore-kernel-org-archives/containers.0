From: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [LKP] More information please. Re: [fs] 54cc07a761: BUG: kernel
	test crashed
Date: Tue, 26 Jul 2016 22:35:45 +0800
Message-ID: <20160726143545.GA23656@wfg-t540p.sh.intel.com>
References: <5793dfa5.mvXPj4LJOS0dlz3i%xiaolong.ye@intel.com>
	<877fc9a6mb.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <877fc9a6mb.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org, kernel test robot <xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Eric,

Sorry for the delay!

On Mon, Jul 25, 2016 at 01:57:00PM -0500, Eric W. Biederman wrote:
>kernel test robot <xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
>
>> FYI, we noticed the following commit:
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing
>> commit 54cc07a761deb38318aca64ddf07fc45157c85e0 ("fs: Call d_automount with the filesystems creds")
>>
>> in testcase: boot
>>
>> on test machine: 1 threads qemu-system-x86_64 -enable-kvm -cpu Westmere with 320M memory
>>
>> caused below changes:
>>
>>
>> +-------------------------+------------+------------+
>> |                         | 8175435777 | 54cc07a761 |
>> +-------------------------+------------+------------+
>> | boot_successes          | 102        | 16         |
>> | boot_failures           | 0          | 3          |
>> | BUG:kernel_test_crashed | 0          | 3          |
>> | timestamp.last          | 0          | 54.951425  |
>> +-------------------------+------------+------------+
>>
>>
>>
>> [   19.206454] VFS: Warning: trinity-c0 using old stat() call. Recompile your binary.
>>
>> Elapsed time: 70
>> BUG: kernel test crashed
>
>What application generated the line "BUG: kernel test crashed."
>What flavor of crash was this?

It's a simple boot test with a quick trinity run. So there will be
some randomness in this test.

The "BUG: kernel test crashed" means the VM reboots by itself while
the trinity test is running. If the error message is "BUG: kernel boot
crashed" it'd mean VM abnormally reboots before any test is launched.

>Given the last boot test failure that was reported to me was about 10
>commits after the problem commit I unfortunately can't take it at face
>value that the appropriate commit has been pinpointed.
>
>If you could give me enough information to dig into this that would
>be great.  Otherwise I am going to have to proceed forward on the basis
>that this is a testing robot failure, and that the people who maintain
>the testing robot don't care enough to look after it.

I queued more tests in various KVM instances and find the kernel test
crashes can also happen in the parent commit. So it looks like a false
report. Sorry for the noise!

81754357770ebd90  aeaa4a79ff6a5ed912b7362f20
----------------  --------------------------
       fail:runs  %reproduction    fail:runs
           |             |             |
          5:100          0%           5:100   dmesg.BUG:kernel_test_crashed
           :100          1%           1:100   dmesg.Mem-Info
           :100          1%           1:100   dmesg.invoked_oom-killer:gfp_mask=0x
 
Regards,
Fengguang
