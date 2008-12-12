From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: container userspace tools
Date: Fri, 12 Dec 2008 13:42:38 +0530
Message-ID: <20081212081238.GA4365@balbir.in.ibm.com>
References: <48EF35F1.2060308@fr.ibm.com>
	<8f34198c0810150033p42b74badrf194e66433e32cd5@mail.gmail.com>
	<48F5BE23.1060602@fr.ibm.com>
	<8f34198c0810150351n7549a1dcx63547746344fce25@mail.gmail.com>
	<48F5DB43.70003@fr.ibm.com>
	<8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
	<49031A54.70806@fr.ibm.com>
	<8f34198c0812112333k6c1474f3hb67e963b39a0d0d6@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8f34198c0812112333k6c1474f3hb67e963b39a0d0d6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

* Ian jonhson <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2008-12-12 15:33:15]:

> Hi again,
> 
> > The container will be more or less isolated depending of what you specify in
> > the configuration file.
> >
> > Without any configuration file, you will have pid, ipc and mount points
> > isolated. If you specify the utsname, it will be isolated and if you specify
> > the network you will have a new network stack allowing to run for example a
> 
> I have played with lxc-0.3.0 for several days, trying to transplant
> existing applications
> on the base of container.
> 
> The default configuration can present a view of isolated pid, ipc (e.g. run the
> ps or top), however the memory seems not to be isolated. The process in
> a container still can see the whole physical memory. Also, my test routine
> can still apply more memory than the quota defined in "memory.limit_in_bytes".
> 
> Are there anything missing?
>

Hi, Ian,

With what version of the kernel due you see this problem. The memory
controller is undergoing a churn and I think we found something that
potentially breaks the memory controller in the current -mm. To verify

1. Can you see the memory.usage_in_bytes corresponding to the control
group where you run the container
2. Check tasks file to see that the container tasks are indeed in the
container.


-- 
	Balbir
