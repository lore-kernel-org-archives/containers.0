From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] Fix cap_capable to only allow owners in the parent
	user namespace to have caps.
Date: Fri, 14 Dec 2012 07:47:03 -0800
Message-ID: <87bodwd4aw.fsf__39159.1718690053$1355500055$gmane$org@xmission.com>
References: <87ip88uw4n.fsf@xmission.com> <50CA2B55.5070402@amacapital.net>
	<87mwxhtxve.fsf@xmission.com> <87zk1hshk7.fsf_-_@xmission.com>
	<20121214032820.GA5115@mail.hallyn.com> <87bodxi9zw.fsf@xmission.com>
	<20121214152607.GA9266@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121214152607.GA9266-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Fri, 14 Dec 2012 15:26:07 +0000")
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
>> >> 
>> >> Andy Lutomirski pointed out that the current behavior of allowing the
>> >> owner of a user namespace to have all caps when that owner is not in a
>> >> parent user namespace is wrong.
>> >
>> > To make sure I understand right, the issue is when a uid is mapped
>> > into multiple namespaces.
>> 
>> Yes.
>> 
>> i.e. uid 1000 in ns1 may own ns2, but uid 1000 in ns3 does not?
>> 
>> I am not certain of your example.
>> 
>> The simple case is:
>> 
>> init_user_ns:
>>      child_user_ns1 (owned by uid == 0 [in all user namespaces])
>>            child_user_ns2 (owned by uid == 0 [ in all user namespaces])
>> 
>> 
>> root (uid == 0) in child_user_ns2 has all rights over anything in
>> child_user_ns1.
>
> Well that is only if there was no mapping.  (since we're comparing
> kuids, not uid_ts).  right?  If you didn't map uid 0 in child_user_ns2
> to another id in the parent ns, you weren't all *that* serious about
> isolating the ns.
>
> The case I was thinking is
>
>   init_user_ns:  [0-uidmax]
>       child_user_ns1  [100000-199999]
>       child_user_ns2  [100000-199999]
>         child_user_ns3  [200000-299999]
>
> with unfortunate mappings  - ns1 and ns2 should have had nonoverlapping
> ranges, but in any case now uid 1000 in ns1 can exert privilege over
> ns3.  Again, uids comparisons will succeed for file access anyway, so
> ns1 can 0wn ns2 and ns3 other ways.

Yes yours is the more realistic scenario.  Mine was simplified to be clear.

> Heck I'm starting to think the bug is a feature - surely given the
> mappings above I meant for ns1 and ns2 to bleed privilege to each
> other?

The serious problem is that privileges can bleed up. A user in 
ns3 can wind up owning ns2 or ns1.  Which totally defeats the permission
model.  You have CAP_DAC_OVERRIDE so you don't even need access to files
you own, etc, etc.

Or the more fun version as root:
	/* Drop all privs */
	pid = clone(CLONE_NEWUSER);
	if (pid == 0) {
		/* Have all privs! Bahaha */
	}

Which makes dropping capabilies a joke.

And since up to through 3.7 the only user that can create a user namespace
is root that is a very realistic scenario.  It doesn't work against the
initial user namespace thankfully, but in v3.7 it works against every
other user namespace.

To keep user namespaces safe we need to maintain the invariant that a
child user namespace can not get capapabilities in it's parent user
namespace.

Eric
