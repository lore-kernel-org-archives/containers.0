From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] Fix cap_capable to only allow owners in the
	parent user namespace to have caps.
Date: Fri, 14 Dec 2012 20:29:21 +0000
Message-ID: <20121214202921.GA11450__25132.0116258741$1355516678$gmane$org@mail.hallyn.com>
References: <87ip88uw4n.fsf@xmission.com> <50CA2B55.5070402@amacapital.net>
	<87mwxhtxve.fsf@xmission.com> <87zk1hshk7.fsf_-_@xmission.com>
	<20121214032820.GA5115@mail.hallyn.com>
	<87bodxi9zw.fsf@xmission.com>
	<20121214152607.GA9266@mail.hallyn.com>
	<87bodwd4aw.fsf@xmission.com>
	<20121214161514.GA9962@mail.hallyn.com>
	<87r4ms5wpm.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87r4ms5wpm.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

Note: I acked your patch before and still don't object to it.

> > In which case it would be
> >
> >        child_user_ns1  [100000-199999]
> >        child_user_ns2  [100000-199999]
> >          child_user_ns3  [120000-129999]
> >
> 
> Yes.  You have to nest uids.
> 
> >> > with unfortunate mappings  - ns1 and ns2 should have had nonoverlapping
> >> > ranges, but in any case now uid 1000 in ns1 can exert privilege over
> >> > ns3.  Again, uids comparisons will succeed for file access anyway, so
> >> > ns1 can 0wn ns2 and ns3 other ways.
> >> 
> >> Yes yours is the more realistic scenario.  Mine was simplified to be clear.
> >> 
> >> > Heck I'm starting to think the bug is a feature - surely given the
> >> > mappings above I meant for ns1 and ns2 to bleed privilege to each
> >> > other?
> >> 
> >> The serious problem is that privileges can bleed up. A user in 
> >> ns3 can wind up owning ns2 or ns1.  Which totally defeats the permission
> >> model.  You have CAP_DAC_OVERRIDE so you don't even need access to files
> >> you own, etc, etc.
> >
> > Would that not require intervention from the init_user_ns?  In my
> > example above (let's add that ns2 is owned by kuid.uid=1000 in
> > init_user_ns), root in child_user_ns2 cannot map kuid.val=0 or
> > kuid.val=1000 into ns3 because 0 and 1000 are not in the range
> > 100000-199999.  So there is no uid in child_user_ns3 which is able
> > to spoof uid=0 in child_user_ns1.
> 
> Right.  It does require having the uid of the owner of ns1 or ns2 in
> ns3.  So you have to explicitly allow it.
> 
> What I don't see is any point in allowing something like that.

The point isn't specifically to allow that, but rather to not muddle the
kuids with the user namespace *.

If I clone two tasks in separate user namespace but give them the same
uid mappings, how should the uids between those namespaces be related?
The way you're doing it now they will equate for DAC checks but not
for privilege checks.  It feels ad-hoc and flaky.

> A child user namespace having capabilities against processes in it's
> parent seems totally bizarre and pretty dangerous from a capabilities
> standpoint.

How would it have them against its parent?

> That said Serge I think I have lost track of the point of your question.

Look at it this way.  You've introduced kuids which allow "uids" to be
disassociated from the user namespace * in kernel.  You have the uid
mapping rules which enforce some sanity (requiring nesting).

If the parent ns has re-used an active uid of its own to give to a child
namespace, then any DAC-governed objects (files in particular) will be
owned by that uid in the child user ns.  I'm not sure - does this also
apply to /proc/$$/fd/* access?

-serge
