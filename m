From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: userns idea: preventing SCM_CREDENTIALS from leaking out
Date: Tue, 26 Nov 2013 19:17:35 -0800
Message-ID: <87eh62v8hc.fsf@xmission.com>
References: <CALCETrWWSVnwg6Sb=bZz0xuAj_ASjZmsLYy=ELoR_uSqKJJaWg@mail.gmail.com>
	<20131127014920.GA31364@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131127014920.GA31364-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Wed, 27 Nov 2013 01:49:20 +0000")
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Andy Lutomirski (luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org):
>> IIUC there are multiple ways to end up with a socket pair for which
>> one end is in a user namespace and the other is outside of it.  That
>> means that SCM_CREDENTIALS can be used by a process in a userns to
>> authenticate to a process outside.
>> 
>> This is all well and good (and, as far as I know, correct), but I'm
>
> And the cgroup manager I'm starting on depends on this.
>
>> not sure this is always the desired behavior.  In the context of a
>> tool like Docker, it might be useful to have several user namespaces
>> that have the *same* uids mapped.  Nonetheless, if one of those
>> namespaces is compromised, it probably shouldn't be permitted to
>> attack things outside the user namespace (or in the host, if any
>> interesting uids are mapped).
>> 
>> Would it make sense to have an option to allow a user namespace to opt
>> into different behavior so that its users show up as the invalid uid
>> as seen from outside (as least for SCM_CREDENTIALS and SO_PEERCRED)?
>> 
>> Implementing this might be awkward (ok, it might actively suck due to
>> a possible need for reference counting), but I'm wondering if it's a
>> good idea even in principle.
>
> Well, I'll grant you, if I have a single directory with a socket in
> it, and I make that the aufs or overlayfs underlay for two separate
> mounts, which each are in different containers, then you might have
> a problem here.
>
> Now maybe the answer to that is that the sockets should be created
> in tmpfss (/run, /tmp, etc) anyway.  But the more I think about it
> the more I, unfortunately, agree that this could be a problem.

I really hate the concept of mapping a uid in some contexts and not
others.  That seems very prone to go wrong. Given all of the possible
kinds of perumutations I can't imagine how we would get it correct.

MS_NOSUID and MS_RDONLY will help with some of the worst offenders.
But it will still be possible for the user namespace root to call
setuid(NNN); and create a process with that uid.  And if a unix domain
socket isn't the only means of interacting there will still be problems.

I will suggest that writing a uid mapping filesystem like overlayfs or
perhaps as a mount option of overlayfs is likely to be a more robuse
solution in general.  Certainly that is what I originally had on the
drawing board to solve this class of problem.

Eric
