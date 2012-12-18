From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC PATCH 0/9] Add container support for cgroup
Date: Tue, 18 Dec 2012 13:37:17 +0800
Message-ID: <50D0010D.3020201__15388.7257831686$1355809071$gmane$org@cn.fujitsu.com>
References: <1355726615-15224-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20121217234816.GA10220@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121217234816.GA10220-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello Tejun

On 2012/12/18 07:48, Tejun Heo wrote:
> Hello,
> 
> On Mon, Dec 17, 2012 at 02:43:26PM +0800, Gao feng wrote:
>> Right now,if we mount cgroup in the container,we will get
>> host's cgroup informations and even we can change host's
>> cgroup in container.
>>
>> So the resource controller of the container will lose
>> effectiveness.
>>
>> This patchset try to add contianer support for cgroup.
>> the main idea is allocateing cgroup super-block for each
>> cgroup mounted in different pid namespace.
>>
>> The top cgroup of container will share css with host.
>> When the cgroup being mounted in contianer,the tasks in
>> this container will be attached to this new mounted
>> hierarchy's top cgroup, And when unmounting cgroup in
>> container,these tasks will be attached back to host's cgroup.
>>
>> Since the container can change the shared css through it's
>> cgroup subsystem files. patch 7/8 disable the write permission
>> of container's top cgroup files. In my TODO list, container
>> will have it's own css, this problem will disappear.
>>
>> This patchset is sent as RFC,any comments are welcome.
>> Maybe this isn't the best solution, if you have better
>> solution,Please let me know.
> 
> So, I'm *highly* unlikely to accept any patches which try to add
> namespace support directly to cgroup in any form unless someone can
> definitively show me this can't be done using FUSE or other userland
> solutions.
> 
> cgroupfs is going to be an interface to expose the resource control
> facilities of the kernel and that's the extent the interface will be
> capable of.  It in itself won't support delegation of resource
> policies to names spaces or unprivieged users.
> 
> Although I don't have anything concrete yet, the tentative plan is to
> have something in userland which can integrate with the base system so
> that userland has an unified and controlled way to interact with
> cgroup which can be easily integrated with the rest of the base system
> and kernel has at least some level of interface isolation.  Basically,
> something like libudev or libsysfs.


As your advice,the container's interface will be changed in container.
Container will not be able to enable cgroup by the command:
"mount -t cgroup -o xxx xxx /path".

Though something like libudev or libsysfs can afford the interface for
container to get and set cgroups.But the interface provided by cgroupfs
will lose effectiveness in container.


> 
> So, if people want to allow NSes control its subtree of cgroups, I
> really want something in the userland which sits between the NSes and
> actual cgroup, and I bet things would actually be much better that
> way.  cgroupfs seems to allow it but you can't really delegate
> management of subtree easily.  Controllers would collapse with
> increasing level of nesting, root cgroups have different knobs or
> different interpretations of the same knobs, and siblings interact
> with each other, and I don't think making cgroupfs interface generic
> enough so that it can be used for all that is desirable or a
> worthwhile effort.
> 

I recognize it's not easy,BUT I just want the usage of the OS which
running in container as same as the host.

Thanks.
