From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: container userspace tools
Date: Fri, 12 Dec 2008 10:21:43 +0100
Message-ID: <49422D27.5080500@free.fr>
References: <48EF35F1.2060308@fr.ibm.com> <48F5BE23.1060602@fr.ibm.com>
	<8f34198c0810150351n7549a1dcx63547746344fce25@mail.gmail.com>
	<48F5DB43.70003@fr.ibm.com>
	<8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
	<49031A54.70806@fr.ibm.com>
	<8f34198c0812112333k6c1474f3hb67e963b39a0d0d6@mail.gmail.com>
	<20081212081238.GA4365@balbir.in.ibm.com>
	<8f34198c0812120106k390a1097ub31905cd2bc44676@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8f34198c0812120106k390a1097ub31905cd2bc44676-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian jonhson <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Ian jonhson wrote:
>> With what version of the kernel due you see this problem. The memory
>> controller is undergoing a churn and I think we found something that
>> potentially breaks the memory controller in the current -mm. To verify
>>
> I am not sure whether the -mm is opened. I just opened the options as
> said in REAEME of lxc-0.3.0. And, the kernel version in my VM is:
> 2.6.27-rc8.

2.6.27.8 is out, perhaps you should try this version which contains the 
latest bug fixes.

>> 1. Can you see the memory.usage_in_bytes corresponding to the control
>> group where you run the container
> 
> How can I know the number correspond to the control group?

Assuming you created a container named "foo", you should be able 
retrieve these values with the following commands:

lxc-cgroup -n foo tasks
lxc-cgroup -n foo memory.usage_in_bytes

The lxc-0.5.1 has been released and it fixes some bugs related with the 
cgroup management.

>> 2. Check tasks file to see that the container tasks are indeed in the
>> container.
>>
> 
> My program forks a child and its child (grandson of previous process) call the
> the /bin/bash to open a shell. I just can find the parent process is
> in container
> tasks file, but its child and grandson process are not.
> 
> 
> Any help?
> 
