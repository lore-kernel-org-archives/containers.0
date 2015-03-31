From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH] devpts: Add ptmx_uid and ptmx_gid options
Date: Tue, 31 Mar 2015 06:59:38 -0700
Message-ID: <CALCETrU1vKf3fXPt8nS-ABDgfp8NxrFjHwTc68rA0rtvg2Lufg__18783.7880374447$1427810426$gmane$org@mail.gmail.com>
References: <b321c0c2729d1c2a72aea319b077dce7afd79698.1424480579.git.luto@amacapital.net>
	<CALCETrVtGE8LdBCFTe1_cqpLf=SxPNX5iCe5wa-hZ0pe8ps_jA@mail.gmail.com>
	<1427447013.2250.9.camel@HansenPartnership.com>
	<1427788642.4411.12.camel@redhat.com>
	<1427807248.2117.117.camel@HansenPartnership.com>
	<CALCETrWKA4ZdHfdLuW0_W5xxJOSCJdt_fiRWs6vDk+8ZQ9n9iA@mail.gmail.com>
	<1427808184.2117.122.camel@HansenPartnership.com>
	<CALCETrW8v1NFa7fcJbyJKXk9Msudht5BJ7Zy1Rg7ZC_TS-2Y-Q@mail.gmail.com>
	<1427810118.2117.126.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1427810118.2117.126.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: gnome-os-list-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, mclasen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 31, 2015 at 6:55 AM, James Bottomley
<James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> wrote:
> On Tue, 2015-03-31 at 06:44 -0700, Andy Lutomirski wrote:
>> On Tue, Mar 31, 2015 at 6:23 AM, James Bottomley
>> <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> wrote:
>> > On Tue, 2015-03-31 at 06:12 -0700, Andy Lutomirski wrote:
>> >> On Tue, Mar 31, 2015 at 6:07 AM, James Bottomley
>> >> <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> wrote:
>> >> > On Tue, 2015-03-31 at 09:57 +0200, Alexander Larsson wrote:
>> >> >> On fre, 2015-03-27 at 10:03 +0100, James Bottomley
>> >> >> >
>> >> >> > > On Fri, Feb 20, 2015 at 5:04 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> >> >> > > > It's currently impossible to mount devpts in a user namespace that
>> >> >> > > > has no root user, since ptmx can't be created.
>> >> >> >
>> >> >> > This is where I stopped reading because it's not true ... because it is
>> >> >> > possible, you just do it from the host as real root.
>> >> >>
>> >> >> The point is being able to set up a container as a user, not requiring
>> >> >> the setup to be run as root at all. In my case container is a desktop
>> >> >> application which will be started by the user, and will run as the user.
>> >> >> There is no root involved in the call chain at all.
>> >> >
>> >> > I don't really like that use case:  Most container setups are under the
>> >> > control of an orchestration system (like LXC, OpenVZ or even Docker).
>> >> > You typically get the orchestration system to do the dangerous
>> >> > operations (mount being one of the bigger dangers) because it has the
>> >> > capacity to vet them.  I can see the value in allowing a user to set up
>> >> > a container without an oversight system, but at the same time you're
>> >> > increasing the security vulnerability of the system.  Security is often
>> >> > a result of policy, so now this embeds policy into the kernel.  I
>> >> > strongly feel we should define the list of things we expect an
>> >> > unsupervised (as in with no orchestration system) container to do and
>> >> > then revisit this once we've given it some thought.
>> >>
>> >> Try thinking "sandbox", not "container".  The ability to create
>> >> sandboxes without some root-installed orchestration is incredibly
>> >> valuable.
>> >
>> > A container is anything that uses the various container APIs (mostly
>> > cgroups and namespaces), so the set of possible containers overlaps the
>> > set of possible sandboxes.
>> >
>> >> In any event, this ship sailed quite awhile ago.  devpts is one of the
>> >> smallish number of important missing features.
>> >
>> > I'm not saying "don't do it" I'm saying think carefully about the
>> > allowable features we permit an unprivileged user to take advantage of.
>> > This one feels strange to me in that you're asking to give an
>> > unprivileged user in a container more abilities than an unprivileged
>> > user outside a container (a non-root user can't mount /dev/ptmx today).
>> > This would mean that every unprivileged container user can now interfere
>> > with the tty subsystem.
>>
>> That is true, but this is already the case.  The current code is:
>>
>>         root_uid = make_kuid(current_user_ns(), 0);
>>         root_gid = make_kgid(current_user_ns(), 0);
>>
>> Unprivileged tasks can make a userns and map themselves as "0" inside,
>> at which point the code I quoted will work fine.  The failure only
>> happens if they opt not to map anything at all as "0", as many
>> sandboxes will do.
>
> Yes, I know.  However remember we use containers to host VPSs which
> themselves can have non-root users.  I don't want a non root user inside
> the VPS to be able to muck with the tty subsystem.  Your patch allows
> that.

I don't think that this is correct.  That user can already create a
nested userns and map themselves as 0 inside it.  Then they can mount
devpts.

--Andy

>  It will effectively relax security of a VPS container which is
> highly undesirable.  We need the security of an operating system
> container to be the same as it would be for an unvirtualized operating
> system otherwise people get nasty surprises.
>
> The fact that container root can mount /dev/ptmx is fine to me, because
> container root is a privileged user inside the container.  There's still
> no way, short of a privilege escalation, than a non-root container user
> can become container root.
>
> James
>
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
