From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [RFC][PATCH] locks: Allow disabling mandatory locking at compile
	time
Date: Wed, 11 Nov 2015 15:26:07 -0500
Message-ID: <20151111202607.GD29410__9505.29369661144$1447274159$gmane$org@fieldses.org>
References: <876118v333.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <876118v333.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 11, 2015 at 11:49:20AM -0600, Eric W. Biederman wrote:
> 
> Mandatory locking appears to be almost unused and buggy and there
> appears no real interest in doing anything with it.  Since effectively
> no one uses the code and since the code is buggy let's allow it to be
> disabled at compile time.  I would just suggest removing the code but
> undoubtedly that will break some piece of userspace code somewhere.
> 
> For the distributions that don't care about this piece of code
> this gives a nice starting point to make mandatory locking go away.
> 
> Cc: Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
> Cc: J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
> 
> A piece of userspace software having problematic interactions with
> mandatory locking recently came up as an issue

Is there any more interesting story there?

> and I am wondering if there are enough people actually using and
> interested in mandatory locking that it makes sense to push people to
> support it, or if mandatory locking should be confined to it's own
> little corner of existence where it can wither and die.

I hate mandatory locking and would be delighted, but my opinion probably
shouldn't get too much weight.

> From what little I can glean we want to discourage people from using
> mandatory locking and to let it wither and die.  A Kconfig option that
> allows mandatory locking to be disabled at compile time seems like the
> first step in making that happen.  Perhaps in a decade or so when all
> linux distributions are setting the option we can remove the code.
> 
> Does anyone know of any real world use cases of mandatory locking?

Isn't byte-range locking on Windows mandatory?  So Samba people might be
the ones to talk to.  (Or Wine?  Or anyone else doing Windows
interoperability.)

My suspicion would be that the semantics they need are different enough
from what we support that we'd be better off ignoring it and starting
over from scratch anyway.  But I could be wrong.

--b.
