From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH] vfs: Lock in place mounts from more privileged
	users
Date: Wed, 24 Jul 2013 09:05:36 -0700
Message-ID: <87ehaolz8v.fsf@xmission.com>
References: <877gghruwq.fsf@xmission.com>
	<CALCETrXXGhVbkG6AnRck+W1kMns5TJuNYAqe_tV44JvWgDoUzA@mail.gmail.com>
	<87li4wpi2b.fsf@xmission.com> <20130724124933.GA16517@mail.hallyn.com>
	<20130724153018.GA17960@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130724153018.GA17960-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Wed, 24 Jul 2013 15:30:18 +0000")
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Serge E. Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
>> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> > 
>> > Serge does this patch break lxc?  I think all should be well but I want
>> > to make certain there is not some hidden case where this fundamentaly
>> > breaks some functionality.
>> 
>> I haven't yet tried.  I'll build and test a kernel today.  I'm pretty
>> sure all the child's mounts are done after clone, so I *think* the worst
>> case will be that the unmounting of put_old after pivot_root() will
>> be noisy.  Will let you know.
>> 
>> -serge
>
> Just tested it - works fine.  Warns about all of the failed umounts.

Just to confirm.  Can you do a lazy umount of put_old and get rid of
them?

> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>
> ( Mind you I'm not approving of the idea of hiding mounts as a security
> mechanisms, but I know that neither are you :)

As a security mechanism, not really.  This is more about closing a
theoretical hole in case someone was sloppy, and doing it before user
namespaces are too widely deployed so we avoid massive user space
breakage.  It let's me sleep more soundly at night if I know you can't
more access more with user namespaces that you can without user
namespaces.

Eric
