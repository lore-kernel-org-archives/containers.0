From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH] devpts: Add ptmx_uid and ptmx_gid options
Date: Tue, 31 Mar 2015 06:12:29 -0700
Message-ID: <CALCETrWKA4ZdHfdLuW0_W5xxJOSCJdt_fiRWs6vDk+8ZQ9n9iA__9776.64605384252$1427807581$gmane$org@mail.gmail.com>
References: <b321c0c2729d1c2a72aea319b077dce7afd79698.1424480579.git.luto@amacapital.net>
	<CALCETrVtGE8LdBCFTe1_cqpLf=SxPNX5iCe5wa-hZ0pe8ps_jA@mail.gmail.com>
	<1427447013.2250.9.camel@HansenPartnership.com>
	<1427788642.4411.12.camel@redhat.com>
	<1427807248.2117.117.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1427807248.2117.117.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
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

On Tue, Mar 31, 2015 at 6:07 AM, James Bottomley
<James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> wrote:
> On Tue, 2015-03-31 at 09:57 +0200, Alexander Larsson wrote:
>> On fre, 2015-03-27 at 10:03 +0100, James Bottomley
>> >
>> > > On Fri, Feb 20, 2015 at 5:04 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> > > > It's currently impossible to mount devpts in a user namespace that
>> > > > has no root user, since ptmx can't be created.
>> >
>> > This is where I stopped reading because it's not true ... because it is
>> > possible, you just do it from the host as real root.
>>
>> The point is being able to set up a container as a user, not requiring
>> the setup to be run as root at all. In my case container is a desktop
>> application which will be started by the user, and will run as the user.
>> There is no root involved in the call chain at all.
>
> I don't really like that use case:  Most container setups are under the
> control of an orchestration system (like LXC, OpenVZ or even Docker).
> You typically get the orchestration system to do the dangerous
> operations (mount being one of the bigger dangers) because it has the
> capacity to vet them.  I can see the value in allowing a user to set up
> a container without an oversight system, but at the same time you're
> increasing the security vulnerability of the system.  Security is often
> a result of policy, so now this embeds policy into the kernel.  I
> strongly feel we should define the list of things we expect an
> unsupervised (as in with no orchestration system) container to do and
> then revisit this once we've given it some thought.

Try thinking "sandbox", not "container".  The ability to create
sandboxes without some root-installed orchestration is incredibly
valuable.

In any event, this ship sailed quite awhile ago.  devpts is one of the
smallish number of important missing features.

--Andy
