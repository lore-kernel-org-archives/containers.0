From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Tue, 23 Feb 2010 19:39:38 -0600
Message-ID: <20100224013938.GA1142__217.424243646924$1266975711$gmane$org@hallyn.com>
References: <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org>
	<20100223234942.GO3604@count0.beaverton.ibm.com>
	<m18waj2zc8.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m18waj2zc8.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > On Tue, Feb 23, 2010 at 12:00:55PM -0800, Eric W. Biederman wrote:
> >> jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> writes:
> >> 
> >> > Added Daniel to the discussion..
> >> >
> >> > On Tue, 2010-02-23 at 06:07 -0800, Eric W. Biederman wrote:
> >> >> jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> writes:
> >> >
> >> >> > Does the point after sys_setns(fd) allow me to do io inside
> >> >> > ns <name>? Can i do open() and get a fd from ns <name>?
> >> >> 
> >> >> Yes.  My intention is that current->nsproxy->net_ns be changed.
> >> >> We can already change it in unshare so this is feasible.
> >> >
> >> > I like it if it makes it as easy as it sounds;-> With lxc,
> >> > i essentially have to create a proxy process inside the
> >> > namespace that i use unix domain to open fds inside the ns.
> >> > Do i still need that?
> >> 
> >> That point of the mount to hold a persistent reference to the
> >> namespace without using a process.
> >
> > I think technicaly it's still held using processes, only now it's
> > much more indirect:
> >
> > netns <- mount <- mount namespace(s) <- process(es)
> 
> True. The practical difference is that it doesn't require a dedicated
> process which is a big improvement operationally.
> 
> > Using a mount requires keeping names for the namespaces themselves
> > in the kernel which is a problem we've largely avoided so far.
> > The nscgroup is an example of the messes that creates, I think. And it
> > further complicates c/r -- we'd need to checkpoint and recreate the
> > names of the namespaces too. So we'll need a namespace for the names of
> > the namespaces to make restart reliable won't we? Makes my head spin...
> 
> This is strictly different.  It may require a bit of extra support from
> checkpoint/restart because it introduces some more user visible objects
> but the names themselves are nothing special.  The name that userspace
> sees and deals with is the name of the mount point.  No new namespaces
> are required.

Shouldn't be a big deal - assuming the mount is of a special type
for a network ns, we just record the objref for the checkpointed
network ns.  We don't need a namespace for the namespaces - we just
need unique names for the checkpoint image (the objref, which is
unique per netns).

Guess it really is about time that i work on some clean patches
for checkpoint/restart of mounts namespaces and mounts.

-serge
