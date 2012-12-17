From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC PATCH 0/9] Add container support for cgroup
Date: Mon, 17 Dec 2012 16:54:32 +0800
Message-ID: <50CEDDC8.7030802__29494.1855049276$1355734502$gmane$org@cn.fujitsu.com>
References: <1355726615-15224-1-git-send-email-gaofeng@cn.fujitsu.com>
	<50CED2FD.1040509@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50CED2FD.1040509-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Glauber

On 2012/12/17 16:08, Glauber Costa wrote:
> On 12/17/2012 10:43 AM, Gao feng wrote:
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
>>
>> This patchset is sent as RFC,any comments are welcome.
>> Maybe this isn't the best solution, if you have better
>> solution,Please let me know.
> 
> 
> Question 1:
> 
> Any particular reason to have picked the pid namespace?
> 
> Maybe it is the right thing, since we are basically dealing with
> grouping of tasks. OTOH, what you are doing sounds very much like
> a private mount, indicating that the mount namespace should be used.
> This needs to be well justified.


Consider this situation, a container only has mnt ns unshared with host.
then we mount cgroup in this container. we don't know what we can do with
this new cgroup.we don't know which tasks should be attached to this cgroup,
unless we find out all tasks in this mnt ns.

I want to make things clear,all tasks in the pid ns use the cgroup which
mounted in this pid ns.

> 
> Also, "container support" can really mean a lot of things. I am still
> trying, while reading your patches, to figure out what exactly do you
> want to achieve. What it seems so far is that you want an unprivileged
> process living inside a namespace to manipulate the cgroup hierarchy and
> have its own copy of the cgroup tree, laid as it pleases. You also want
> to be able to write PIDs as seen by the containing namespace, and to
> have it somehow translated. Am I right?
> 

Yes, you are right :)

"container support" is confused,I will change it to "pidns support".

> For future submissions, could you make this clearer?
> 

Will do , thanks for you comment!
