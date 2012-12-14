From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] Fix cap_capable to only allow owners in the parent
	user namespace to have caps.
Date: Fri, 14 Dec 2012 10:12:53 -0800
Message-ID: <87r4ms5wpm.fsf@xmission.com>
References: <87ip88uw4n.fsf@xmission.com> <50CA2B55.5070402@amacapital.net>
	<87mwxhtxve.fsf@xmission.com> <87zk1hshk7.fsf_-_@xmission.com>
	<20121214032820.GA5115@mail.hallyn.com> <87bodxi9zw.fsf@xmission.com>
	<20121214152607.GA9266@mail.hallyn.com> <87bodwd4aw.fsf@xmission.com>
	<20121214161514.GA9962@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121214161514.GA9962-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Fri, 14 Dec 2012 16:15:14 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
>> 
>> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> >> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
>> >> 
>> >> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> >> >> 
>> >> >> Andy Lutomirski pointed out that the current behavior of allowing the
>> >> >> owner of a user namespace to have all caps when that owner is not in a
>> >> >> parent user namespace is wrong.
>> >> >
>> >> > To make sure I understand right, the issue is when a uid is mapped
>> >> > into multiple namespaces.
>> >> 
>> >> Yes.
>> >> 
>> >> i.e. uid 1000 in ns1 may own ns2, but uid 1000 in ns3 does not?
>> >> 
>> >> I am not certain of your example.
>> >> 
>> >> The simple case is:
>> >> 
>> >> init_user_ns:
>> >>      child_user_ns1 (owned by uid == 0 [in all user namespaces])
>> >>            child_user_ns2 (owned by uid == 0 [ in all user namespaces])
>> >> 
>> >> 
>> >> root (uid == 0) in child_user_ns2 has all rights over anything in
>> >> child_user_ns1.
>> >
>> > Well that is only if there was no mapping.  (since we're comparing
>> > kuids, not uid_ts).  right?  If you didn't map uid 0 in child_user_ns2
>> > to another id in the parent ns, you weren't all *that* serious about
>> > isolating the ns.
>> >
>> > The case I was thinking is
>> >
>> >   init_user_ns:  [0-uidmax]
>> >       child_user_ns1  [100000-199999]
>> >       child_user_ns2  [100000-199999]
>> >         child_user_ns3  [200000-299999]
>
> Wait is my example above possible?  Or does child_user_ns3's range need
> to be a subset of child_user_ns2's?
>
> In which case it would be
>
>        child_user_ns1  [100000-199999]
>        child_user_ns2  [100000-199999]
>          child_user_ns3  [120000-129999]
>

Yes.  You have to nest uids.

>> > with unfortunate mappings  - ns1 and ns2 should have had nonoverlapping
>> > ranges, but in any case now uid 1000 in ns1 can exert privilege over
>> > ns3.  Again, uids comparisons will succeed for file access anyway, so
>> > ns1 can 0wn ns2 and ns3 other ways.
>> 
>> Yes yours is the more realistic scenario.  Mine was simplified to be clear.
>> 
>> > Heck I'm starting to think the bug is a feature - surely given the
>> > mappings above I meant for ns1 and ns2 to bleed privilege to each
>> > other?
>> 
>> The serious problem is that privileges can bleed up. A user in 
>> ns3 can wind up owning ns2 or ns1.  Which totally defeats the permission
>> model.  You have CAP_DAC_OVERRIDE so you don't even need access to files
>> you own, etc, etc.
>
> Would that not require intervention from the init_user_ns?  In my
> example above (let's add that ns2 is owned by kuid.uid=1000 in
> init_user_ns), root in child_user_ns2 cannot map kuid.val=0 or
> kuid.val=1000 into ns3 because 0 and 1000 are not in the range
> 100000-199999.  So there is no uid in child_user_ns3 which is able
> to spoof uid=0 in child_user_ns1.

Right.  It does require having the uid of the owner of ns1 or ns2 in
ns3.  So you have to explicitly allow it.

What I don't see is any point in allowing something like that.


After taking a second look I just realized that this is completely
unexploitable with the code that is currently merged.  As creating
a grand child user namespace is competelely impossible.  Creating
a user namespace is requires capable(CAP_SYS_ADMIN) which is never
present in anything but the initial user namespace.


That said I think the current semantics of cap_capable are completely
fatal to reasoning about user namespaces.

A child user namespace having capabilities against processes in it's
parent seems totally bizarre and pretty dangerous from a capabilities
standpoint.

That said Serge I think I have lost track of the point of your question.

Eric
