From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC] cgroup TODOs
Date: Sun, 16 Sep 2012 07:41:48 -0700
Message-ID: <87boh6owr7.fsf__15655.5360452787$1347806535$gmane$org@xmission.com>
References: <20120913205827.GO7677@google.com>
	<20120914183641.GA2191@cathedrallabs.org>
	<1347783557.2463.1.camel@dabdike.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1347783557.2463.1.camel-sFMDBYUN5F8GjUHQrlYNx2Wm91YjaHnnhRte9Li2A+AAvxtiuMwx3w@public.gmane.org>
	(James Bottomley's message of "Sun, 16 Sep 2012 09:19:17 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: Aristeu Rozanski <aris-moeOTchvdi7YtjvyW6yDsg@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Paul Turner <pjt-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> writes:

> On Fri, 2012-09-14 at 14:36 -0400, Aristeu Rozanski wrote:
>> also, heard about the desire of having a device namespace instead with
>> support for translation ("sda" -> "sdf"). If anyone see immediate use for
>> this please let me know.
>
> That sounds like a really bad idea to me.  We've spent ages training
> users that the actual sd<x> name of their device doesn't matter and they
> should use UUIDs or WWNs instead ... why should they now care inside
> containers?

The goal is not to introduce new the cases where people care but to
handle cases where people do care.

The biggest practical case of interest that I know of is if

stat /home/myinteresintfile Device: 806h	Inode: 7460974
migration
stat /home/myinteresintfile Device: 732h	Inode: 7460974

And an unchanging file looks like it has just become a totally different
file on a totally different filesystem.

I think even things like git status will care.  Although how much git
cares about the device number I don't know.  I do know rsyncing a git
tree to another directory is enough to give git conniption fits.


So this is really about device management and handling the horrible
things that real user space does.  There is also the case that
there are some very strong ties between the names of device nodes
the names of sysfs files.  Strong enough ties that I think you can
strongly confuse userspace if you just happen to rename a device node.


And ultimately this conversation is about the fact that none of this
has been interesting enough in practice to figure out what really needs
to be done to manage devices in containers.


You can read the other thread if you want details.  But right now it
looks to me like the right answer is going to be building some userspace
software and totally deprecating the device control group.

Eric
