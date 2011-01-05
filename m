From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Containers and /proc/sys/vm/drop_caches
Date: Wed, 5 Jan 2011 19:46:17 +0530
Message-ID: <AANLkTi=x=6gUZTxJC8LXxYNu029+firyzKqjMa6m+R-x@mail.gmail.com>
References: <20110105094022.GA5366@glandium.org> <4D243EC3.1050101@free.fr>
	<20110105140159.GC2718@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110105140159.GC2718-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Mike Hommey <mh-YmoObPS1fuhg9hUCZPvPmw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jan 5, 2011 at 7:31 PM, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> w=
rote:
> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>> On 01/05/2011 10:40 AM, Mike Hommey wrote:
>> >[Copy/pasted from a previous message to lkml, where it was suggested to
>> > =A0try containers@]
>> >
>> >Hi,
>> >
>> >I noticed that from within a lxc container, writing "3" to
>> >/proc/sys/vm/drop_caches would flush the host page cache. That sounds a
>> >little dangerous for VPS offerings that would be based on lxc, as in one
>> >VPS instance root user could impact the overall performance of the host.
>> >I don't know about other containers but I've been told openvz isn't
>> >subject to this problem.
>> >I only tested the current Debian Squeeze kernel, which is based on
>> >2.6.32.27.
>>
>> There is definitively a big work to do with /proc.
>>
>> Some files should be not accessible (/proc/sys/vm/drop_caches,
>> /proc/sys/kernel/sysrq, ...) and some other should be virtualized
>> (/proc/meminfo, /proc/cpuinfo, ...).
>>
>> Serge suggested to create something similar to the cgroup device
>> whitelist but for /proc, maybe it is a good approach for denying
>> access a specific proc's file.
>
> Long-term, user namespaces should fix this - /proc will be owned
> by the user namespace which mounted it, but we can tell proc to
> always have some files (like drop_caches) be owned by init_user_ns.
>
> I'm hoping to push my final targeted capabilities prototype in the
> next few weeks, and after that I start seriously attacking VFS
> interaction.
>
> In the meantime, though, you can use SELinux/Smack, or a custom
> cgroup file does sound useful. =A0Can cgroups be modules nowadays?
> (I can't keep up) =A0If so, an out of tree proc-cgroup module seems
> like a good interim solution.
>

Ideally a drop_cache should drop page cache in that container, but
given container have a lot of shared page cache, what is suggested
might be a good way to work around the problem

Balbir
