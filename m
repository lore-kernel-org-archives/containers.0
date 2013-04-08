From: Lennart Poettering <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Tue, 09 Apr 2013 01:32:01 +0200
Message-ID: <51635371.7070104__12853.1111324721$1365463945$gmane$org@redhat.com>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<5162CA21.4060108@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5162CA21.4060108-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Heya,

On 08.04.2013 15:46, Glauber Costa wrote:
> On 04/06/2013 05:21 AM, Tejun Heo wrote:
>> Hello, guys.
>>
> Hello Tejun, how are you?
>
>>   Status-quo
>>   ==========
>>
> tl;did read;
>
> This is mostly sensible. There is still one problem that we hadn't yet
> had the bandwidth to tackle that should be added to your official TODO list.
>
> The cpu cgroup needs a real-time timeslice to accept real time tasks. It
> defaults to 0, meaning that a newly created cpu cgroup cannot accept
> tasks (rt tasks) without the user having to manually configure it.
> As far as I know, this problem hasn't yet been fixed.
>
> The fix of course, is as trivial as setting a new value instead of 0 as
> a default. The complication lies in determining which value should that be.
>
> There are many things that we should ask from a controller to implement
> in order to be able to handle fully joint hierarchies. One of them,
> IMHO, is that if you drop a task into a newly created cgroup it should
> run without the user having to do anything for it.

The other big thing we want from the systemd side is saner notifications 
when cgroups run empty. i.e. currently we don't get these at all in 
containers (since the agent can be only installed once, for the host). 
And the way we get this is awful, via kernel-spawned processes. I am 
looking for a way how I can establish a watch on a certain subtree (not 
just one directory) and get simple notifications in a race-free whenever 
a cgroup runs empty.

Lennart
