From: Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Subject: Re: [RFC][PATCH] locks: Allow disabling mandatory locking at
	compile time
Date: Mon, 16 Nov 2015 09:58:41 -0500
Message-ID: <20151116095841.0f620a5c@tlielax.poochiereds.net>
References: <876118v333.fsf@x220.int.ebiederm.org>
	<20151111202607.GD29410@fieldses.org>
	<20151111174401.5778153c@tlielax.poochiereds.net>
	<876118ruiu.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <876118ruiu.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 11 Nov 2015 17:22:33 -0600
ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) wrote:

> Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org> writes:
> 
> > On Wed, 11 Nov 2015 15:26:07 -0500
> > "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> wrote:
> >
> >> On Wed, Nov 11, 2015 at 11:49:20AM -0600, Eric W. Biederman wrote:
> >> > 
> >> > Mandatory locking appears to be almost unused and buggy and there
> >> > appears no real interest in doing anything with it.  Since effectively
> >> > no one uses the code and since the code is buggy let's allow it to be
> >> > disabled at compile time.  I would just suggest removing the code but
> >> > undoubtedly that will break some piece of userspace code somewhere.
> >> > 
> >> > For the distributions that don't care about this piece of code
> >> > this gives a nice starting point to make mandatory locking go away.
> >> > 
> >> > Cc: Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >> > Cc: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> >> > Cc: Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
> >> > Cc: J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> >> > Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> >> > ---
> >> > 
> >> > A piece of userspace software having problematic interactions with
> >> > mandatory locking recently came up as an issue
> >> 
> >> Is there any more interesting story there?
> 
> Only that I overlooked them when implementing user namespace support for
> mounting filesystems so it is currently possible to without privilege to
> mount tmpfs with mandatory locking enabled and pass a file descriptor to
> a daemon that was not expecting them.  Causing nice denial of service
> attacks.
> 
> So I need to decide what to do with mandatory locking in user
> namespaces.
> 
> As the consensus of this thread is that users of mandatory locking are
> as rare as hen's teeth I can just not allow mandatory locking if you
> something is being mounted just user namespace permissions.  If users
> would be more wide spread I would need to figure out how to avoid breaking
> users.
> 
> >> > and I am wondering if there are enough people actually using and
> >> > interested in mandatory locking that it makes sense to push people to
> >> > support it, or if mandatory locking should be confined to it's own
> >> > little corner of existence where it can wither and die.
> >> 
> >> I hate mandatory locking and would be delighted, but my opinion probably
> >> shouldn't get too much weight.
> >> 
> >
> > Ditto...It's really hard to believe that anyone uses them, given the
> > well documented races in the Linux implementation.
> 
> >> > From what little I can glean we want to discourage people from using
> >> > mandatory locking and to let it wither and die.  A Kconfig option that
> >> > allows mandatory locking to be disabled at compile time seems like the
> >> > first step in making that happen.  Perhaps in a decade or so when all
> >> > linux distributions are setting the option we can remove the code.
> >> > 
> >> > Does anyone know of any real world use cases of mandatory locking?
> >> 
> >> Isn't byte-range locking on Windows mandatory?  So Samba people might be
> >> the ones to talk to.  (Or Wine?  Or anyone else doing Windows
> >> interoperability.)
> >> 
> >> My suspicion would be that the semantics they need are different enough
> >> from what we support that we'd be better off ignoring it and starting
> >> over from scratch anyway.  But I could be wrong.
> >> 
> >
> > Windows BRLs are mandatory but they have totally different semantics.
> >
> > I think there is little reason to keep POSIX mandatory locks for
> > windows emulation purposes. I'm pretty sure Samba doesn't rely on them,
> > for instance, given that you have to use a funky mode bit combo to
> > enable them.
> >
> > This patch seems like a logical step to me. I'll review it soon and
> > will plan to queue it up for v4.5 unless there are objections between
> > now and the next merge window.
> 
> Thanks.
> 
> Given the general concensus of this thread it looks like we will also
> want this incremental patch to deal with the user namespace case.
> 
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Date: Wed, 11 Nov 2015 17:18:07 -0600
> Subject: [PATCH] locks: Don't allow mounts in user namespaces to enable mandatory locking
> 
> Since no one uses mandatory locking and files with mandatory locks can
> cause problems don't allow them in user namespaces.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/namespace.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index dee44b4791f0..95a349d5003d 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1589,7 +1589,7 @@ static inline bool may_mandlock(void)
>  #ifndef	CONFIG_MANDATORY_FILE_LOCKING
>  	return false;
>  #endif
> -	return true;
> +	return capable(CAP_SYS_ADMIN);
>  }
>  
>  /*

Fair enough. I'll merge that as well and we'll see what breaks.

-- 
Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
