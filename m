From: Cedric Le Goater <legoater@free.fr>
Subject: Re: pidns memory leak
Date: Tue, 03 Nov 2009 10:24:39 +0100
Message-ID: <4AEFF6D7.9080509@free.fr>
References: <20091006040526.GA22923@us.ibm.com> <4ACAFD6A.3060008@fr.ibm.com>	<20091008030828.GA18973@us.ibm.com> <4ACD9ECC.90508@fr.ibm.com>	<20091009032928.GA2031@us.ibm.com> <4ACF381F.9050808@fr.ibm.com>	<20091010013235.GA11904@us.ibm.com> <4AD2EBC7.2020109@fr.ibm.com>	<20091014061533.GA23569@us.ibm.com>	<20091102133326.e3dc51fb.akpm@linux-foundation.org>	<20091102223818.GA15628@us.ibm.com>	<20091102144752.71fd4a31.akpm@linux-foundation.org>	<4AEFDAAE.500@free.fr> <m1ljiogfun.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755569AbZKCJYj@vger.kernel.org>
In-Reply-To: <m1ljiogfun.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Serge E. Hallyn" <serue@us.ibm.com>, andrea@cpushare.com, Linux Containers <containers@lists.osdl.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Emelianov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@mail.ru>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 11/03/2009 09:41 AM, Eric W. Biederman wrote:
> Cedric Le Goater <legoater@free.fr> writes:
> 
>> On 11/02/2009 11:47 PM, Andrew Morton wrote:
>>> On Mon, 2 Nov 2009 16:38:18 -0600
>>> "Serge E. Hallyn" <serue@us.ibm.com> wrote:
>>>
>>>>> This bug hasn't been fixed yet, has it?
>>>>
>>>> Well Suka did trace the bug to commit 7766755a2f249e7, and posted a patch
>>>> to revert that, acked by Eric on Oct 20.  Suka, were you going to repost
>>>> that patch?
>>>
>>> Ah.  OK.  Thanks.  Found it in the backlog pile.
>>
>> We've added the patch to our patchset and we confirm that the pid_* leaks have 
>> been reduced to 'nearly' nothing but we still have a lot of inodes and dentries
>> leaks. I hope to find some time to investigate and reproduce with a small 
>> scenario, we are running a LTP like testsuite in a container environment.
> 
> Does forcing a cache flush help with the other leaks?

yes, it frees a few more dentries, but not enough.

I did:

	$ echo 2 > /proc/sys/vm/drop_caches

before :

	size-64           193243 198088     88   44    1 
	dentry            110584 111202    280   14    1 
	inode_cache       107543 107543   4096    1    1 
	size-128           56341  63450    152   25    1 
	size-4096          21107  21107   4096    1    1 
	vm_area_struct     11838  11960    192   20    1 
	size-256           11406  11424    280   14    1 
	size-32             9408   9916     56   67    1 
	size-512            7710   7710   4096    1    1 
	sysfs_dir_cache     5288   5328    104   37    1 
	pid_2                302    336    136   28    1 
	pid_namespace          1      1   4096    1    1 
	nsproxy                1     53     72   53    1 

after: 

	size-64           193150 198044     88   44    1 
	dentry            110509 111202    280   14    1 
	inode_cache       107543 107543   4096    1    1 
	size-128           56326  63450    152   25    1 
	size-4096          21107  21107   4096    1    1 
	vm_area_struct     11857  11960    192   20    1 
	size-256           11405  11424    280   14    1 
	size-32             9408   9916     56   67    1 
	size-512            7710   7710   4096    1    1 
	sysfs_dir_cache     5288   5328    104   37    1 
	pid_2                302    336    136   28    1 
	pid_namespace          1      1   4096    1    1 
	nsproxy                1     53     72   53    1 


I'll come back to you (daniel or me) when we've nailed this one with a simpler
program. it shows up when stressing the system with lxc containers.

Cheers,

C.
