From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] Fix cap_capable to only allow owners in the
	parent user namespace to have caps.
Date: Sat, 15 Dec 2012 00:14:47 +0000
Message-ID: <20121215001447.GD13659__7034.47858472845$1355530201$gmane$org@mail.hallyn.com>
References: <87mwxhtxve.fsf@xmission.com> <87zk1hshk7.fsf_-_@xmission.com>
	<20121214032820.GA5115@mail.hallyn.com>
	<87bodxi9zw.fsf@xmission.com>
	<20121214152607.GA9266@mail.hallyn.com>
	<87bodwd4aw.fsf@xmission.com>
	<20121214161514.GA9962@mail.hallyn.com>
	<87r4ms5wpm.fsf@xmission.com>
	<20121214202921.GA11450@mail.hallyn.com>
	<87bodww9hv.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87bodww9hv.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> 
> >> A child user namespace having capabilities against processes in it's
> >> parent seems totally bizarre and pretty dangerous from a capabilities
> >> standpoint.
> >
> > How would it have them against its parent?
> 
> init_user_ns
>    userns a --- created by kuid 1

Now a mapping needs to be set up (by a task with CAP_SYS_ADMIN in
init_user_ns) which allows kuids 1 and 2 to be used by userns a.
Otherwise (if no mapping is set up) userns a only has the overlowuid.

Realistically only kuids over 100000 (let's say) would used.  i.e.
kuids 100,000-199,999 would map to container uids 0-99,999.

>      userns b -- created by kuid 2

Now a mapping needs to be set up (by a task with CAP_SYS_ADMIN in
userns a) which allows kuids 1 and 2 to be used by userns b.

If userns had been mapped with kuids 100,000-199,999 mapping to
uids 0-99999, then only kuids in that range could be mapped into
userns b.

>         process c in userns b with kuid 1
>
> Serge read the first permisison check in common_cap. 
> Think what happens in the above example.
> 
> For the rest I understand your concern.

Ok.  Then we can discuss my concern later (after the new year).

> Serge please read and look at the patches I have posted to fix
> the issues Andy found with the user namespace tree.  Especially
> the fix to commit_creds.

The setns fixes were IMO the most important - and interesting - ones :)

Thanks, Andy!

> After you have looked at the patches to fix the issues I will
> be happy to discuss things further with you.

Thanks,
-serge
