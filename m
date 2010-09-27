From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/3][V2] remove the ns_cgroup
Date: Mon, 27 Sep 2010 13:45:26 -0700
Message-ID: <m1zkv2ncex.fsf@fess.ebiederm.org>
References: <1285582453-6127-1-git-send-email-daniel.lezcano@free.fr>
	<20100927125741.0df22f09.akpm@linux-foundation.org>
	<20100927203658.GA5320@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100927203658.GA5320-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Mon, 27 Sep 2010 15:36:58 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:

> Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
>> On Mon, 27 Sep 2010 12:14:10 +0200
>> Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
>> 
>> > The ns_cgroup is a control group interacting with the namespaces.
>> > When a new namespace is created, a corresponding cgroup is 
>> > automatically created too. The cgroup name is the pid of the process
>> > who did 'unshare' or the child of 'clone'.
>> > 
>> > This cgroup is tied with the namespace because it prevents a
>> > process to escape the control group and use the post_clone callback,
>> > so the child cgroup inherits the values of the parent cgroup.
>> > 
>> > Unfortunately, the more we use this cgroup and the more we are facing
>> > problems with it:
>> > 
>> >  (1) when a process unshares, the cgroup name may conflict with a previous
>> >  cgroup with the same pid, so unshare or clone return -EEXIST
>> > 
>> >  (2) the cgroup creation is out of control because there may have an
>> >  application creating several namespaces where the system will automatically
>> >  create several cgroups in his back and let them on the cgroupfs (eg. a vrf
>> >  based on the network namespace).
>> > 
>> >  (3) the mix of (1) and (2) force an administrator to regularly check and
>> >  clean these cgroups.
>> > 
>> > This patchset removes the ns_cgroup by adding a new flag to the cgroup
>> > and the cgroupfs mount option. It enables the copy of the parent cgroup
>> > when a child cgroup is created. We can then safely remove the ns_cgroup as
>> > this flag brings a compatibility. We have now to manually create and add the
>> > task to a cgroup, which is consistent with the cgroup framework.
>> 
>> So this is a non-backward-compatible userspace-visible change?
>
> Yes, it is.
>

We have always been able to compile out the ns cgroup right?

In which case this is not a backwards incompatible change so much
as the permanent removal of a borked kernel feature.

Eric
